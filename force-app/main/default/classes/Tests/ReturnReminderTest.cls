/**
 * Created by kamil on 16.07.2023.
 */
@IsTest
public with sharing class ReturnReminderTest {
    private static final String EMAIL_PREFIX = 'testemail';
    private static final Integer NUMBER_OF_DATA = 5;

    @TestSetup
    private static void insertBasicData() {
        List<Item__c> unavailableBooks = TestDataFactory.createItemsList(NUMBER_OF_DATA, true, 'Test', Consts.ITEMS.TYPE.PAPER_BOOK, Consts.ITEMS.GENRE.SCIENCE_FICTIN);

        List<Person__c> borrowers = TestDataFactory.createPeopleList(NUMBER_OF_DATA, true, 'Test', EMAIL_PREFIX, 2);

        TestDataFactory.createLoansList(NUMBER_OF_DATA, true, unavailableBooks, borrowers, Date.today(), Date.today().addDays(ReturnReminder.DAYS_TO_RETURN), Consts.LOANS.STATUS.BORROWED);
    }
    @IsTest
    static void testScheduleMe() {
        Test.startTest();
        Id jobId = ReturnReminder.scheduleMe();
        Test.stopTest();

        CronTrigger cronTrigger = [SELECT Id, CronExpression, CronJobDetail.Name FROM CronTrigger WHERE Id = :jobId];
        Assert.areEqual(ReturnReminder.JOB_NAME, cronTrigger.CronJobDetail.Name, 'Invalid job name');
        Assert.areEqual(ReturnReminder.CRON_EXPRESSION, cronTrigger.CronExpression, 'Inavlid cron expression');
    }


    @IsTest
    static void testSendedEmails() {

        Test.startTest();
        ReturnReminder returnReminder = new ReturnReminder();
        returnReminder.execute(null);
        Test.stopTest();


        List<EmailMessage> emails = [SELECT ToAddress, Id, HtmlBody FROM EmailMessage WHERE MessageDate > :Datetime.now().addMinutes(-1)];
        Assert.areEqual(NUMBER_OF_DATA, emails.size(), 'Invalid number of emails sent');

        for (Integer i = 0; i < NUMBER_OF_DATA; i++) {
            Assert.areEqual(emails.get(i).ToAddress, EMAIL_PREFIX + i + TestDataFactory.EMAIL_SUFFIX, 'Incorrect email address for ' + EMAIL_PREFIX + i + TestDataFactory.EMAIL_SUFFIX);
        }
    }

}