public without sharing class DelayedItems implements Database.Batchable<SObject>, Schedulable, Database.Stateful {
  public static final String JOB_NAME = 'Delayed Items Job';
  private final Map<String, List<String>> errorToIDs = new Map<String, List<String>>();
  @TestVisible
  private static Boolean shouldForceException = false;
  public static Id scheduleMe() {
    DelayedItems schedule = new DelayedItems();
    return System.schedule(JOB_NAME, Consts.CRONS.CRON.DELAYED_ITEMS, schedule);
  }

  public void execute(SchedulableContext sc) {
    Database.executeBatch(new DelayedItems());
  }

  public Database.QueryLocator start(Database.BatchableContext param1) {
    return Database.getQueryLocator(
      [
        SELECT Id, Status__c
        FROM Loan__c
        WHERE
          Status__c = :Consts.LOANS.STATUS.BORROWED
          AND End_Of_Rental__c < :Date.today()
      ]
    );
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
        String statusCode = srList[i].getErrors().get(0).getStatusCode().name();
        if (!errorToIDs.containsKey(statusCode)) {
          errorToIDs.put(statusCode, new List<String>());
        }
        errorToIDs.get(statusCode).add(loans[i].Id);
      }
    }
  }

  public void finish(Database.BatchableContext param1) {
    if (errorToIDs.size() > 0) {
      String body = String.format(
        Label.DML_Failed,
        new List<String>{
          'PenaltyCharge',
          'Loan__c',
          EmailManager.createEmailContent(errorToIDs)
        }
      );
      EmailManager.sendErrorMessage(Consts.BATCHES.SUBJECT.DELAYED_ITEMS, body);
    }
  }
}
