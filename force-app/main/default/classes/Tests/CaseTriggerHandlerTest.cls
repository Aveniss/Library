/**
 * Created by kamil on 12.07.2023.
 */

@IsTest
public with sharing class CaseTriggerHandlerTest {

    private static List<String> emails = new List<String>{'test1@example.com','test2@example.com','test3@example.com'};
    @IsTest
    static void testAddEmailSender() {
        List<Case> newCases = new List<Case>();

        Case case1 = new Case(
                Status = CaseConst.INSTANCE.STATUS.NEW_CASE,
                Reason = CaseConst.INSTANCE.CASE_ORIGIN.EMAIL,
                SuppliedEmail = emails.get(0)
        );
        Case case2 = new Case(
                Status = CaseConst.INSTANCE.STATUS.NEW_CASE,
                Reason = CaseConst.INSTANCE.CASE_ORIGIN.EMAIL,
                SuppliedEmail = emails.get(1)
        );
        Case case3 = new Case(
                Status = CaseConst.INSTANCE.STATUS.NEW_CASE,
                Reason = CaseConst.INSTANCE.CASE_ORIGIN.EMAIL,
                SuppliedEmail = emails.get(2)
        );
        newCases.add(case1);
        newCases.add(case2);
        newCases.add(case3);

        Person__c person1 = new Person__c(Name = 'Test',Last_Name__c = 'Test',Email__c = emails.get(0));
        Person__c person2 = new Person__c(Name = 'Test',Last_Name__c = 'Test',Email__c = emails.get(1));
        insert new List<Person__c>{person1, person2};

        Test.startTest();
        CaseTriggerHandler.addEmailSender(newCases);
        Test.stopTest();

        Assert.areEqual(person1.Id,case1.Email_Sender__c, String.format('Unexpected Email_Sender__c for {0}',emails));
        Assert.areEqual(person2.Id,case2.Email_Sender__c, String.format('Unexpected Email_Sender__c for {1}',emails));
        Assert.isNull(case3.Email_Sender__c, String.format('Email_Sender__c for {2} should be null',emails));
    }
}