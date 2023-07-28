public without sharing class DelayedItems implements Database.Batchable<SObject>, Schedulable {
  public static final String JOB_NAME = 'Delayed Items Job';
  private static final Date TODAY = Date.today();
  private static final String CHARGE_STATUS = Consts.LOANS.STATUS.BORROWED;
  private static final String QUERY = 'SELECT Id, Status__c FROM Loan__c WHERE Status__c =:CHARGE_STATUS AND End_Of_Rental__c < :TODAY';
  private static final List<Id> failedLoanIDs = new List<Id>();
  @TestVisible
  private static Boolean shouldForceException = false;
  public static Id scheduleMe() {
    DelayedItems schedule = new DelayedItems();
    return System.schedule(JOB_NAME, Consts.CRONS.CRON.DELAYED_ITEMS, schedule);
  }

  public void execute(SchedulableContext sc) {
    Database.executeBatch(new DelayedItems(), 10000);
  }

  public Database.QueryLocator start(Database.BatchableContext param1) {
    return Database.getQueryLocator(QUERY);
  }

  public void execute(Database.BatchableContext param1, List<Loan__c> loans) {
    for (Loan__c loan : loans) {
      loan.Status__c = Consts.LOANS.STATUS.DELAY;
    }

    if (Test.isRunningTest() && shouldForceException) {
      loans.get(0).Status__c = 'SomeFakeStatusToForceException';
    }
    Database.SaveResult[] srList = Database.update(loans, false);
    for (Integer i = 0; i < srList.size(); i++) {
      if (!srList[i].isSuccess()) {
        failedLoanIDs.add(loans[i].Id);
      }
    }
  }

  public void finish(Database.BatchableContext param1) {
    if (failedLoanIDs.size() > 0) {
      List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
      mails.add(
        EmailManager.createSingleEmail(
          Emails__c.getValues('Admin').AdminEmail__c,
          String.format(
            Label.DML_Failed,
            new List<String>{
              'PenaltyCharge',
              'Loan__c',
              String.join(failedLoanIDs, ',')
            }
          ),
          Consts.BATCHES.SUBJECT.DELAYED_ITEMS
        )
      );
      Messaging.sendEmail(mails);
    }
  }
}
