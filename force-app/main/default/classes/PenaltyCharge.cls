/**
 * Created by kamil on 19.07.2023.
 */

public with sharing class PenaltyCharge implements Database.Batchable<SObject>, Schedulable {
  public static final String JOB_NAME = 'Penalty Charge Job';
  private static final Date TODAY = Date.today();
  private static final String CHARGE_STATUS = Consts.LOANS.STATUS.DELAY;
  private static final String QUERY = 'SELECT Item__r.Type__c, Penalty__c, End_Of_Rental__c FROM Loan__c WHERE Status__c =: CHARGE_STATUS AND End_Of_Rental__c <: TODAY';
  public static Id scheduleMe() {
    ReturnReminder schedule = new ReturnReminder();
    return System.schedule(
      JOB_NAME,
      Consts.CRONS.CRON.PENALTY_CHARGE,
      schedule
    );
  }

  public void execute(SchedulableContext context) {
    Database.executeBatch(new PenaltyCharge(), 10000);
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    System.debug(QUERY);
    return Database.getQueryLocator(QUERY);
  }

  public void execute(Database.BatchableContext bc, List<Loan__c> loans) {
    for (Loan__c loan : loans) {
      loan.Penalty__c =
        chargeFromItemType(loan.Item__r.Type__c) *
        calculateWorkingDays(loan.End_Of_Rental__c, Date.today());
    }

    update loans;
  }

  public void finish(Database.BatchableContext bc) {
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
