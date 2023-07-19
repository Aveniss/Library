/**
 * Created by kamil on 19.07.2023.
 */

@IsTest
public with sharing class PenaltyChargeTest {
    private static final Integer NUMBER_OF_DATA = 5;
    private static final Date END_OF_RENTAL = ReturnReminder.addBusinessDays(Date.today(), ReturnReminder.DAYS_TO_RETURN);
    private static final String EMAIL_PREFIX = 'testemail';
    @TestSetup
    private static void insertBasicData() {
        List<Item__c> delayedBooks = TestDataFactory.createItemsList(NUMBER_OF_DATA, true, 'Test', Consts.ITEMS.TYPE.PAPER_BOOK, Consts.ITEMS.GENRE.SCIENCE_FICTIN);
        List<Item__c> delayedMagazines = TestDataFactory.createItemsList(NUMBER_OF_DATA, true, 'Test', Consts.ITEMS.TYPE.MAGAZINE, Consts.ITEMS.GENRE.SCIENCE_FICTIN);
        List<Item__c> returnedBooks = TestDataFactory.createItemsList(NUMBER_OF_DATA, true, 'Test', Consts.ITEMS.TYPE.PAPER_BOOK, Consts.ITEMS.GENRE.SCIENCE_FICTIN);

        List<Person__c> borrowers = TestDataFactory.createPeopleList(NUMBER_OF_DATA, true, 'Test', EMAIL_PREFIX, 3);

        TestDataFactory.createLoansList(NUMBER_OF_DATA, true, delayedBooks, borrowers, Date.today(), END_OF_RENTAL, Consts.LOANS.STATUS.DELAY);
        TestDataFactory.createLoansList(NUMBER_OF_DATA, true, delayedMagazines, borrowers, Date.today(), END_OF_RENTAL.addDays(4), Consts.LOANS.STATUS.DELAY);
        TestDataFactory.createLoansList(NUMBER_OF_DATA, true, returnedBooks, borrowers, Date.today(), END_OF_RENTAL, Consts.LOANS.STATUS.RETURNED);
    }

    @IsTest
    static void testScheduleMe() {
        Test.startTest();
        Id jobId = PenaltyCharge.scheduleMe();
        Test.stopTest();

        CronTrigger cronTrigger = [SELECT Id, CronExpression, CronJobDetail.Name FROM CronTrigger WHERE Id = :jobId];
        Assert.areEqual(PenaltyCharge.JOB_NAME, cronTrigger.CronJobDetail.Name, 'Invalid job name');
        Assert.areEqual(Consts.CRONS.CRON.PENALTY_CHARGE, cronTrigger.CronExpression, 'Inavlid cron expression');
    }

    @IsTest
    static void testchargeFromItemType() {
        Assert.areEqual(Consts.LOANS.CHARGE.BOOK_CHARGE, PenaltyCharge.chargeFromItemType(Consts.ITEMS.TYPE.PAPER_BOOK), 'Incorrect charge for paper book');
        Assert.areEqual(Consts.LOANS.CHARGE.MAGAZINE_CHARGE, PenaltyCharge.chargeFromItemType(Consts.ITEMS.TYPE.MAGAZINE), 'Incorrect charge for magazine');
        Assert.areEqual(Consts.LOANS.CHARGE.AUDIOBOOK_CHARGE, PenaltyCharge.chargeFromItemType(Consts.ITEMS.TYPE.AUDIOBOOK), 'Incorrect charge for audiobook');
        Assert.areEqual(0, PenaltyCharge.chargeFromItemType('random word'), 'Incorrect charge for incorrect type');
    }

    @IsTest
    static void testExecute() {
        List<Loan__c> loans;

        Test.startTest();
        PenaltyCharge penaltyChargee = new PenaltyCharge();
        penaltyChargee.execute(null);
        Test.stopTest();


        loans = [SELECT Status__c, Penalty__c, Item__r.Type__c FROM Loan__c];

        for (Loan__c loan : loans) {
            if (loan.Status__c == Consts.LOANS.STATUS.DELAY) {
                Assert.areEqual(loan.Penalty__c, PenaltyCharge.chargeFromItemType(loan.Item__r.Type__c), 'Incorrect penalty for ' + loan.Item__r.Type__c);
            } else {
                Assert.areEqual(loan.Penalty__c, 0, 'Not delayed item should not be penalized');
            }
        }

    }
}