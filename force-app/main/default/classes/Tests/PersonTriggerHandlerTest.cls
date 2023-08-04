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
  public static void sendLoginDataForNewUserTest() {
    String emailPrefix = 'newUser';
    Map<String, EmailMessage> emails = new Map<String, EmailMessage>();

    TestDataFactory.createPeopleList(
      NUMBER_OF_DATA,
      true,
      'user',
      emailPrefix,
      3
    );

    List<Person__c> people = [
      SELECT Email__c, Encrypted_PIN__c, Person_ID__c
      FROM Person__c
      WHERE Email__c LIKE :emailPrefix + '%'
    ];

    for (EmailMessage message : [
      SELECT TextBody, Subject, ToAddress, Id
      FROM EmailMessage
      WHERE
        Subject = :PersonTriggerHandler.NEW_USER_SUBJECT
        AND ToAddress LIKE :emailPrefix + '%'
    ]) {
      emails.put(message.ToAddress, message);
    }

    Assert.areEqual(NUMBER_OF_DATA, emails.size());

    for (Person__c person : people) {
      Assert.isTrue(emails.containsKey(person.Email__c.toLowerCase()));
      Assert.areEqual(
        String.format(
          Label.NewPersonMessage,
          new List<String>{ person.Person_ID__c, person.Encrypted_PIN__c }
        ),
        emails.get(person.Email__c.toLowerCase()).TextBody
      );
      Assert.areEqual(
        PersonTriggerHandler.NEW_USER_SUBJECT,
        emails.get(person.Email__c.toLowerCase()).Subject
      );
    }
  }
}
