public with sharing class DelayedItems implements Database.Batchable<SObject>, Schedulable {
  public static final String JOB_NAME = 'Delayed Items Job';
  private static final Date TODAY = Date.today();
  private static final String CHARGE_STATUS = Consts.LOANS.STATUS.BORROWED;
  private static final String QUERY = 'SELECT Id, Status__c FROM Loan__c WHERE Status__c =:CHARGE_STATUS AND End_Of_Rental__c < :TODAY';
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

    update loans;
  }

  public void finish(Database.BatchableContext param1) {
    // wrzucić zapytanie do execute (chyba)
  }
}
