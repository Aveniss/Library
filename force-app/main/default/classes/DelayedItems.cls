public with sharing class DelayedItems implements Schedulable {
    private static String CRON_EXPRESSION = '0 0 0 * * ?';


    public static Id scheduleMe() {
        DelayedItems schedule = new DelayedItems();
        return System.schedule('Delayed Items Job', CRON_EXPRESSION, schedule);
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