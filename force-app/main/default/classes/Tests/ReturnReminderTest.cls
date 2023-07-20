/**
 * Created by kamil on 16.07.2023.
 */
@IsTest
public with sharing class ReturnReminderTest {
    private static final String EMAIL_PREFIX = 'testemail';
    private static final Integer NUMBER_OF_DATA = 5;
    private static final Date END_OF_RENTAL = ReturnReminder.addBusinessDays(Date.today(), ReturnReminder.DAYS_TO_RETURN);

    @TestSetup
    private static void insertBasicData() {
        List<Item__c> unavailableBooks = TestDataFactory.createItemsList(NUMBER_OF_DATA, true, 'Test', Consts.ITEMS.TYPE.PAPER_BOOK, Consts.ITEMS.GENRE.SCIENCE_FICTIN);
        List<Item__c> borrowedBooks = TestDataFactory.createItemsList(NUMBER_OF_DATA, true, 'Test', Consts.ITEMS.TYPE.PAPER_BOOK, Consts.ITEMS.GENRE.SCIENCE_FICTIN);
        List<Item__c> returnedBooks = TestDataFactory.createItemsList(NUMBER_OF_DATA, true, 'Test', Consts.ITEMS.TYPE.PAPER_BOOK, Consts.ITEMS.GENRE.SCIENCE_FICTIN);

        List<Person__c> borrowers = TestDataFactory.createPeopleList(NUMBER_OF_DATA, true, 'Test', EMAIL_PREFIX, 3);
        List<Person__c> returnedBorrowers = TestDataFactory.createPeopleList(NUMBER_OF_DATA, true, 'Returned', 'Returned', 3);
        List<Person__c> notRemindBorrowers = TestDataFactory.createPeopleList(NUMBER_OF_DATA, true, 'NotRemind', 'NotRemind', 3);

        TestDataFactory.createLoansList(NUMBER_OF_DATA, true, unavailableBooks, borrowers, Date.today(), END_OF_RENTAL, Consts.LOANS.STATUS.BORROWED);
        TestDataFactory.createLoansList(NUMBER_OF_DATA, true, borrowedBooks, notRemindBorrowers, Date.today(), END_OF_RENTAL.addDays(4), Consts.LOANS.STATUS.BORROWED);
        TestDataFactory.createLoansList(NUMBER_OF_DATA, true, returnedBooks, returnedBorrowers, Date.today(), END_OF_RENTAL, Consts.LOANS.STATUS.RETURNED);
    }
    @IsTest
    static void testScheduleMe() {
        Test.startTest();
        Id jobId = ReturnReminder.scheduleMe();
        Test.stopTest();

        CronTrigger cronTrigger = [SELECT Id, CronExpression, CronJobDetail.Name FROM CronTrigger WHERE Id = :jobId];
        Assert.areEqual(ReturnReminder.JOB_NAME, cronTrigger.CronJobDetail.Name, 'Invalid job name');
        Assert.areEqual(Consts.CRONS.CRON.RETURN_REMINDER, cronTrigger.CronExpression, 'Inavlid cron expression');
    }


    @IsTest
    static void testSendedEmails() {
        String emailSubject = ReturnReminder.EMAIL_SUBJECT;
        Date expectedDate = ReturnReminder.addBusinessDays(Date.today(), ReturnReminder.DAYS_TO_RETURN);
        List<Item__c> books = [SELECT Name FROM Item__c];
        Map<String, Loan__c> emailToLoan = new Map<String, Loan__c>();
        for (Loan__c loan : [SELECT Status__c, End_Of_Rental__c, Borrower__r.Email__c, Item__r.Name FROM Loan__c]) {
            emailToLoan.put(loan.Borrower__r.Email__c, loan);
        }

        Test.startTest();
        ReturnReminder returnReminder = new ReturnReminder();
        returnReminder.execute(null);
        Test.stopTest();

        List<EmailMessage> emails = [SELECT TextBody, Subject, ToAddress, Id FROM EmailMessage WHERE MessageDate > :Datetime.now().addMinutes(-1)];

        Assert.areEqual(NUMBER_OF_DATA, emails.size(), 'Invalid number of emails sent');

        for (Integer i = 0; i < NUMBER_OF_DATA; i++) {
            String toAddress = emails.get(i).ToAddress;
            Assert.areEqual(Consts.LOANS.STATUS.BORROWED, emailToLoan.get(toAddress).Status__c, 'Incorrect loan status for address ' + toAddress);
            Assert.areEqual(expectedDate, emailToLoan.get(toAddress).End_Of_Rental__c, 'Incorrect email sending date for address ' + toAddress);
            Assert.areEqual(emails.get(i).Subject, emailSubject, 'Incorrect email subject');
            Assert.areEqual(emails.get(i).TextBody, String.format(Label.ReturnReminder, new List<String>{
                    books.get(i).Name, END_OF_RENTAL.format()
            }), 'Incorrect email content');
            Assert.areEqual(toAddress, EMAIL_PREFIX + i + TestDataFactory.EMAIL_SUFFIX, 'Incorrect email address for ' + EMAIL_PREFIX + i + TestDataFactory.EMAIL_SUFFIX);
        }
    }

    @IsTest
    static void addDaysInWeek() {
        Date inputDate1 = Date.newInstance(2023, 7, 17); // Monday
        Date expectedDate1 = Date.newInstance(2023, 7, 18); // Tuesday
        Integer additionalDays1 = 1;
        Date actualDate1 = ReturnReminder.addBusinessDays(inputDate1, additionalDays1);
        Assert.areEqual(expectedDate1, actualDate1, 'Test case 1 failed');

        Date inputDate2 = Date.newInstance(2023, 7, 17); // Monday
        Date expectedDate2 = Date.newInstance(2023, 7, 20); // Thursday
        Integer additionalDays2 = 3;
        Date actualDate2 = ReturnReminder.addBusinessDays(inputDate2, additionalDays2);
        Assert.areEqual(expectedDate2, actualDate2, 'Test case 2 failed');

        Date inputDate3 = Date.newInstance(2023, 7, 18); // Tuesday
        Date expectedDate3 = Date.newInstance(2023, 7, 25); // Tuesday
        Integer additionalDays3 = 5;
        Date actualDate3 = ReturnReminder.addBusinessDays(inputDate3, additionalDays3);
        Assert.areEqual(expectedDate3, actualDate3, 'Test case 3 failed');

        Date inputDate4 = Date.newInstance(2023, 7, 18); // Tuesday
        Date expectedDate4 = Date.newInstance(2023, 7, 18); // Tuesday
        Integer additionalDays4 = -3;
        Date actualDate4 = ReturnReminder.addBusinessDays(inputDate4, additionalDays4);
        Assert.areEqual(expectedDate4, actualDate4, 'Test case 4 failed');

        Date inputDate5 = Date.newInstance(2023, 7, 18); // Tuesday
        Date expectedDate5 = Date.newInstance(2023, 8, 1); // Monday
        Integer additionalDays5 = 10;
        Date actualDate5 = ReturnReminder.addBusinessDays(inputDate5, additionalDays5);
        Assert.areEqual(expectedDate5, actualDate5, 'Test case 5 failed');

    }

    @IsTest
    static void addDaysInWeekend() {
        Date inputDate1 = Date.newInstance(2023, 7, 22); // Saturday
        Date expectedDate1 = Date.newInstance(2023, 7, 24); // Monday
        Integer additionalDays1 = 1;
        Date actualDate1 = ReturnReminder.addBusinessDays(inputDate1, additionalDays1);
        Assert.areEqual(expectedDate1, actualDate1, 'Test case 1 failed');

        Date inputDate2 = Date.newInstance(2023, 7, 22); // Sunday
        Date expectedDate2 = Date.newInstance(2023, 7, 25); // Tuesday
        Integer additionalDays2 = 2;
        Date actualDate2 = ReturnReminder.addBusinessDays(inputDate2, additionalDays2);
        Assert.areEqual(expectedDate2, actualDate2, 'Test case 2 failed');

        Date inputDate3 = Date.newInstance(2023, 7, 22); // Saturday
        Date expectedDate3 = Date.newInstance(2023, 7, 28); // Friday
        Integer additionalDays3 = 5;
        Date actualDate3 = ReturnReminder.addBusinessDays(inputDate3, additionalDays3);
        Assert.areEqual(expectedDate3, actualDate3, 'Test case 3 failed');

        Date inputDate4 = Date.newInstance(2023, 7, 23); // Sunday
        Date expectedDate4 = Date.newInstance(2023, 7, 26); // Wednesday
        Integer additionalDays4 = 3;
        Date actualDate4 = ReturnReminder.addBusinessDays(inputDate4, additionalDays4);
        Assert.areEqual(expectedDate4, actualDate4, 'Test case 4 failed');
    }
}