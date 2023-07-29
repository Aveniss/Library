/**
 * Created by kamil on 19.07.2023.
 */

public with sharing class PenaltyCharge implements Database.Batchable<SObject>, Schedulable,Database.Stateful {
  public static final String JOB_NAME = 'Penalty Charge Job';
  private final Map<String,List<String>> errorToIDs = new Map<String, List<String>>();
  @TestVisible
  private static Boolean shouldForceException = false;
  public static Id scheduleMe() {
    ReturnReminder schedule = new ReturnReminder();
    return System.schedule(
      JOB_NAME,
      Consts.CRONS.CRON.PENALTY_CHARGE,
      schedule
    );
  }

  public void execute(SchedulableContext context) {
    Database.executeBatch(new PenaltyCharge(), 150);
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [
        SELECT Id, Item__r.Type__c, Penalty__c, End_Of_Rental__c
        FROM Loan__c
        WHERE
          Status__c = :Consts.LOANS.STATUS.DELAY
          AND End_Of_Rental__c < :Date.today()
      ]
    );
  }

  public void execute(Database.BatchableContext bc, List<Loan__c> loans) {
    for (Loan__c loan : loans) {
      loan.Penalty__c =
        chargeFromItemType(loan.Item__r.Type__c) *
        calculateWorkingDays(loan.End_Of_Rental__c, Date.today());
    }
    if (Test.isRunningTest() && shouldForceException) {
      loans.get(0).Penalty__c = -100;
    }

    Database.SaveResult[] srList = Database.update(loans, false);
    for (Integer i = 0; i < srList.size(); i++) {
      if (!srList[i].isSuccess()) {
        String statusCode = srList[i].getErrors().get(0).getStatusCode().name();
        if(!errorToIDs.containsKey(statusCode)) {
          errorToIDs.put(statusCode,new List<String>());
        }
        errorToIDs.get(statusCode).add(loans[i].Id);
      }
    }
  }

  public void finish(Database.BatchableContext bc) {
    if (errorToIDs.size() > 0) {
      List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
      mails.add(
        EmailManager.createSingleEmail(
          Emails__c.getValues(Consts.BATCHES.EMAILS.ADMIN).AdminEmail__c,
          String.format(
            Label.DML_Failed,
            new List<String>{
              'PenaltyCharge',
              'Loan__c', EmailManager.createEmailContent(errorToIDs)
            }
          ),
          Consts.BATCHES.SUBJECT.PENALTY_CHARGE
        )
      );
      Messaging.sendEmail(mails);
    }
  }

  @TestVisible
  private static Double chargeFromItemType(String itemType) {
    if (itemType.equals(Consts.ITEMS.TYPE.PAPER_BOOK)) {
      return Consts.LOANS.CHARGE.BOOK_CHARGE;
    } else if (itemType.equals(Consts.ITEMS.TYPE.MAGAZINE)) {
      return Consts.LOANS.CHARGE.MAGAZINE_CHARGE;
    } else if (itemType.equals(Consts.ITEMS.TYPE.AUDIOBOOK)) {
      return Consts.LOANS.CHARGE.AUDIOBOOK_CHARGE;
    } else {
      return 0;
    }
  }
  @TestVisible
  private static Integer calculateWorkingDays(Date startDate, Date endDate) {
    if (startDate > endDate) {
      throw new IncorrectDateOrderException(
        'startDate cannot be greater than endData'
      );
    }

    Integer workingDays = 0;
    Datetime currentDate = startDate;
    while (currentDate < endDate) {
      currentDate = currentDate.addDays(1);
      if (
        !(currentDate.format('E').equals('Sat') ||
        currentDate.format('E').equals('Sun'))
      ) {
        workingDays++;
      }
    }
    return workingDays;
  }
}
