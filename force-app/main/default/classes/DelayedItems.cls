public with sharing class DelayedItems implements Schedulable {
    private static String CRON_EXPRESSION = '0 15 21 * * ?';


    public static void scheduleMe() {
        DelayedItems schedule = new DelayedItems();
        System.schedule('Delayed Items Job', CRON_EXPRESSION, schedule);
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

        List<Loan__c> updatedItems = new List<Loan__c>();
        for (Loan__c loan : overdueItems) {
            loan.Status__c = Consts.LOANS.STATUS.DELAY;
            updatedItems.add(loan);
        }

        if (!updatedItems.isEmpty()) {
            update updatedItems;
        }
    }
}