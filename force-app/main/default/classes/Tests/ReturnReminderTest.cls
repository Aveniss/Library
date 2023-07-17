/**
 * Created by kamil on 16.07.2023.
 */
@IsTest
public with sharing class ReturnReminderTest {
    @isTest
    static void testScheduleMe() {
        Test.startTest();
        Id jobId = ReturnReminder.scheduleMe();
        Test.stopTest();

        CronTrigger cronTrigger = [SELECT Id, CronExpression, CronJobDetail.Name FROM CronTrigger WHERE Id = :jobId];
        Assert.areEqual(ReturnReminder.JOB_NAME, cronTrigger.CronJobDetail.Name,'Invalid job name');
        Assert.areEqual(ReturnReminder.CRON_EXPRESSION, cronTrigger.CronExpression,'Inavlid cron expression');
    }

}