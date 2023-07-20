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
        List<Loan__c> delayedLoans = [SELECT Item__r.Type__c, Penalty__c, End_Of_Rental__c FROM Loan__c WHERE Status__c = :Consts.LOANS.STATUS.DELAY AND End_Of_Rental__c < :Date.today()];

        for (Loan__c loan : delayedLoans) {
            loan.Penalty__c = chargeFromItemType(loan.Item__r.Type__c) * calculateWorkingDays(loan.End_Of_Rental__c, Date.today());
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
    @TestVisible
    private static Integer calculateWorkingDays(Date startDate, Date endDate) {
        if (startDate > endDate) {
            throw new IncorrectDateOrderException('startDate cannot be greater than endData');
        }

        Integer workingDays = 0;
        Datetime currentDate = startDate;
        while (currentDate < endDate) {
            currentDate = currentDate.addDays(1);
            if (!(currentDate.format('E').equals('Sat') || currentDate.format('E').equals('Sun'))) {
                workingDays++;
            }
        }
        return workingDays;
    }

}