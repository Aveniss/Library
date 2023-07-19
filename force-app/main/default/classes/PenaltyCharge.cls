/**
 * Created by kamil on 19.07.2023.
 */

public with sharing class PenaltyCharge {
    public static final String JOB_NAME = 'Penalty Charge Job';
    public static Id scheduleMe() {
        ReturnReminder schedule = new ReturnReminder();
        return System.schedule(JOB_NAME, Consts.CRONS.CRON.PENALTY_CHARGE, schedule);
    }

    public void execute(SchedulableContext context) {
        List<Loan__c> delayedLoans = [SELECT Item__r.Type__c, Penalty__c FROM Loan__c WHERE Status__c = :Consts.LOANS.STATUS.DELAY];

        for (Loan__c loan : delayedLoans) {
            loan.Penalty__c += chargeFromItemType(loan.Item__r.Type__c);
        }

        update delayedLoans;
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

}