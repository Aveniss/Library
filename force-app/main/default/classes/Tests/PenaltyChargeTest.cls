/**
 * Created by kamil on 19.07.2023.
 */

@IsTest
public with sharing class PenaltyChargeTest {
    private static final Integer NUMBER_OF_DATA = 5;
    private static final Integer NUMBER_OF_WORKING_DAYS = 5;
    private static final Date RENTAL_DATE = Date.newInstance(2023, 7, 10);
    private static final Date END_OF_RENTAL = Date.newInstance(2023, 7, 15);
    private static final String EMAIL_PREFIX = 'testemail';
    @TestSetup
    private static void insertBasicData() {
        List<Item__c> allItems = new List<Item__c>();
        List<Item__c> delayedBooks = TestDataFactory.createItemsList(NUMBER_OF_DATA, false, 'Test', Consts.ITEMS.TYPE.PAPER_BOOK, Consts.ITEMS.GENRE.SCIENCE_FICTIN);
        List<Item__c> delayedMagazines = TestDataFactory.createItemsList(NUMBER_OF_DATA, false, 'Test', Consts.ITEMS.TYPE.PAPER_BOOK, Consts.ITEMS.GENRE.SCIENCE_FICTIN);
        List<Item__c> returnedBooks = TestDataFactory.createItemsList(NUMBER_OF_DATA, false, 'Test', Consts.ITEMS.TYPE.PAPER_BOOK, Consts.ITEMS.GENRE.SCIENCE_FICTIN);

        allItems.addAll(delayedBooks);
        allItems.addAll(delayedMagazines);
        allItems.addAll(returnedBooks);

        insert allItems;

        List<Person__c> borrowers = TestDataFactory.createPeopleList(NUMBER_OF_DATA, true, 'Test', EMAIL_PREFIX, 3);

        List<Loan__c> allLoans = new List<Loan__c>();
        allLoans.addAll(TestDataFactory.createLoansList(NUMBER_OF_DATA, false, delayedBooks, borrowers, RENTAL_DATE, END_OF_RENTAL, Consts.LOANS.STATUS.DELAY));
        allLoans.addAll(TestDataFactory.createLoansList(NUMBER_OF_DATA, false, delayedMagazines, borrowers, Date.today(), Date.today().addDays(3), Consts.LOANS.STATUS.BORROWED));
        allLoans.addAll(TestDataFactory.createLoansList(NUMBER_OF_DATA, false, returnedBooks, borrowers, RENTAL_DATE, END_OF_RENTAL, Consts.LOANS.STATUS.RETURNED));

        insert allLoans;
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
    static void testChargeFromItemType() {
        Assert.areEqual(Consts.LOANS.CHARGE.BOOK_CHARGE, PenaltyCharge.chargeFromItemType(Consts.ITEMS.TYPE.PAPER_BOOK), 'Incorrect charge for paper book');
        Assert.areEqual(Consts.LOANS.CHARGE.MAGAZINE_CHARGE, PenaltyCharge.chargeFromItemType(Consts.ITEMS.TYPE.MAGAZINE), 'Incorrect charge for magazine');
        Assert.areEqual(Consts.LOANS.CHARGE.AUDIOBOOK_CHARGE, PenaltyCharge.chargeFromItemType(Consts.ITEMS.TYPE.AUDIOBOOK), 'Incorrect charge for audiobook');
        Assert.areEqual(0, PenaltyCharge.chargeFromItemType('random word'), 'Incorrect charge for incorrect type');
    }

    @IsTest
    static void testCalculateWorkingDays(){
        Date inputDate1 = Date.newInstance(2023, 7, 17); // Monday
        Date inputSeceondDate1 = Date.newInstance(2023, 7, 18); // Tuesday
        Integer expectedResult1 = 1;
        Integer result1 = PenaltyCharge.calculateWorkingDays(inputDate1, inputSeceondDate1);
        Assert.areEqual(expectedResult1, result1, 'Test case 1 failed');

        Date inputDate2 = Date.newInstance(2023, 7, 18); // Tuesday
        Date inputSeceondDate2 = Date.newInstance(2023, 7, 25); // Tuesday
        Integer expectedResult2 = 5;
        Integer result2 = PenaltyCharge.calculateWorkingDays(inputDate2, inputSeceondDate2);
        Assert.areEqual(expectedResult2, result2, 'Test case 2 failed');

        Date inputDate3 = Date.newInstance(2023, 7, 18); // Tuesday
        Date inputSeceondDate3 = Date.newInstance(2023, 8, 1); // Monday
        Integer expectedResult3 = 10;
        Integer result3 = PenaltyCharge.calculateWorkingDays(inputDate3, inputSeceondDate3);
        Assert.areEqual(expectedResult3, result3, 'Test case 3 failed');

        Date inputDate4 = Date.newInstance(2023, 7, 22); // Saturday
        Date inputSeceondDate4 = Date.newInstance(2023, 7, 24); // Monday
        Integer expectedResult4 = 1;
        Integer result4 = PenaltyCharge.calculateWorkingDays(inputDate4, inputSeceondDate4);
        Assert.areEqual(expectedResult4, result4, 'Test case 4 failed');

        Date inputDate5 = Date.newInstance(2023, 7, 22); // Sunday
        Date inputSeceondDate5 = Date.newInstance(2023, 7, 25); // Tuesday
        Integer expectedResult5 = 2;
        Integer result5 = PenaltyCharge.calculateWorkingDays(inputDate5, inputSeceondDate5);
        Assert.areEqual(expectedResult5, result5, 'Test case 5 failed');
    }

    @IsTest
    static void testExecute() {
        List<Loan__c> loans;

        Test.startTest();
        PenaltyCharge penaltyChargee = new PenaltyCharge();
        penaltyChargee.execute(null);
        Test.stopTest();


        loans = [SELECT Status__c, Penalty__c, Item__r.Type__c,End_Of_Rental__c FROM Loan__c];

        for (Loan__c loan : loans) {
            if (loan.Status__c == Consts.LOANS.STATUS.DELAY && loan.End_Of_Rental__c < Date.today()) {
                Assert.areEqual(
                        Consts.LOANS.CHARGE.BOOK_CHARGE * PenaltyCharge.calculateWorkingDays(END_OF_RENTAL, Date.today()),
                        loan.Penalty__c,
                        'Incorrect penalty for ' + loan.Item__r.Type__c
                );
            } else {
                Assert.areEqual(0,loan.Penalty__c, 'Not delayed item should not be penalized');
            }
        }

    }
}