/**
 * Created by kamil on 04.08.2023.
 */

@IsTest
public with sharing class UserUtilsTest {
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

      Assert.isTrue(person.Encrypted_PIN__c.isNumeric(), 'It is not a number');
    }
  }

  @IsTest
  public static void generateNewPinTest() {
    Person__c person = [SELECT Id, Encrypted_PIN__c FROM Person__c LIMIT 1];
    String oldPin = person.Encrypted_PIN__c;

    Test.startTest();
    UserUtils.generateNewPin(person.Id);
    Test.stopTest();

    person = [SELECT Id, Encrypted_PIN__c FROM Person__c WHERE Id = :person.Id];

    Assert.areNotEqual(oldPin, person.Encrypted_PIN__c);
  }

  @IsTest
  public static void sendLoginDataForChangePINTest() {
    List<Person__c> people = [
      SELECT Person_ID__c, Email__c, Encrypted_PIN__c
      FROM Person__c
    ];
    Map<String, EmailMessage> emails = new Map<String, EmailMessage>();

    Test.startTest();
    UserUtils.sendNewPinData(people);
    Test.stopTest();

    for (EmailMessage message : [
      SELECT TextBody, Subject, ToAddress, Id
      FROM EmailMessage
      WHERE Subject = :UserUtils.NEW_PIN_SUBJECT
    ]) {
      emails.put(message.ToAddress, message);
    }

    Assert.areEqual(NUMBER_OF_DATA, emails.size());

    for (Person__c person : people) {
      Assert.isTrue(emails.containsKey(person.Email__c.toLowerCase()));
      Assert.areEqual(
        String.format(
          Label.NewPinMessage,
          new List<String>{ person.Encrypted_PIN__c }
        ),
        emails.get(person.Email__c.toLowerCase()).TextBody
      );
      Assert.areEqual(
        UserUtils.NEW_PIN_SUBJECT,
        emails.get(person.Email__c.toLowerCase()).Subject
      );
    }
  }
}
