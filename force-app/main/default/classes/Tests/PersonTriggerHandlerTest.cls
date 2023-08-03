/**
 * Created by kamil on 03.08.2023.
 */

@IsTest
public with sharing class PersonTriggerHandlerTest {
  private static final Integer NUMBER_OF_DATA = 5;

  @TestSetup
  public static void generateBasicDat() {
    TestDataFactory.createPeopleList(
      NUMBER_OF_DATA,
      true,
      'Test',
      'testemail',
      3
    );
  }

  @IsTest
  public static void generatePINTest() {
    List<Person__c> people = [SELECT Encrypted_PIN__c FROM Person__c];

    for (Person__c person : people) {
      Assert.areEqual(10, person.Encrypted_PIN__c.length());

      Long.valueOf(person.Encrypted_PIN__c);
    }
  }

  @IsTest
  public static void generateNewPinTest() {
    Person__c person = [SELECT Id, Encrypted_PIN__c FROM Person__c LIMIT 1];
    String oldPin = person.Encrypted_PIN__c;

    Test.startTest();
    PersonTriggerHandler.generateNewPin(person.Id);
    Test.stopTest();

    person = [SELECT Id, Encrypted_PIN__c FROM Person__c WHERE Id = :person.Id];

    Assert.areNotEqual(oldPin, person.Encrypted_PIN__c);
  }

  @IsTest
  public static void sendLoginDataForNewUserTest() {
    List<Person__c> people = [
      SELECT Person_ID__c, Email__c, Encrypted_PIN__c
      FROM Person__c
    ];
    List<EmailMessage> emails = [
      SELECT TextBody, Subject, ToAddress, Id
      FROM EmailMessage
      WHERE Subject = :PersonTriggerHandler.NEW_USER_SUBJECT
    ];

    Assert.areEqual(NUMBER_OF_DATA, emails.size());

    for (Integer i = 0; i < NUMBER_OF_DATA; i++) {
      Assert.areEqual(people.get(i).Email__c, emails.get(i).ToAddress);
      Assert.areEqual(
        String.format(
          Label.NewPersonMessage,
          new List<String>{
            people.get(i).Person_ID__c,
            people.get(i).Encrypted_PIN__c
          }
        ),
        emails.get(i).TextBody
      );
      Assert.areEqual(
        PersonTriggerHandler.NEW_USER_SUBJECT,
        emails.get(i).Subject
      );
    }
  }

  @IsTest
  public static void sendLoginDataForChangePINTest() {
    List<Person__c> people = [
      SELECT Person_ID__c, Email__c, Encrypted_PIN__c
      FROM Person__c
    ];

    Test.startTest();
    PersonTriggerHandler.sendLoginData(false, people);
    Test.stopTest();

    List<EmailMessage> emails = [
      SELECT TextBody, Subject, ToAddress, Id
      FROM EmailMessage
      WHERE Subject = :PersonTriggerHandler.NEW_PIN_SUBJECT
    ];

    Assert.areEqual(NUMBER_OF_DATA, emails.size());

    for (Integer i = 0; i < NUMBER_OF_DATA; i++) {
      Assert.areEqual(people.get(i).Email__c, emails.get(i).ToAddress);
      Assert.areEqual(
        String.format(
          Label.NewPinMessage,
          new List<String>{ people.get(i).Encrypted_PIN__c }
        ),
        emails.get(i).TextBody
      );
      Assert.areEqual(
        PersonTriggerHandler.NEW_PIN_SUBJECT,
        emails.get(i).Subject
      );
    }
  }
}
