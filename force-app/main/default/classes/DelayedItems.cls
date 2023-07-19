public with sharing class DelayedItems implements Schedulable {
    public static final String JOB_NAME = 'Delayed Items Job';
    public static Id scheduleMe() {
        DelayedItems schedule = new DelayedItems();
        return System.schedule(JOB_NAME, Consts.CRONS.CRON.DELAYED_ITEMS, schedule);
    }

    public void execute(SchedulableContext sc) {
        Date currentDate = Date.today();

        List<Loan__c> overdueItems = [
                SELECT Id, Status__c
                FROM Loan__c
                WHERE
                        Status__c = :Consts.LOANS.STATUS.BORROWED
                        AND End_Of_Rental__c < :currentDate
        ];

        for (Loan__c loan : overdueItems) {
            loan.Status__c = Consts.LOANS.STATUS.DELAY;
        }

        update overdueItems;

    }
}