/**
 * Created by kamil on 03.08.2023.
 */

@IsTest
public with sharing class PersonTriggerHandlerTest {
  private static final Integer NUMBER_OF_DATA = 5;
  private static final String EMAIL_PREFIX = 'testemail';

  @IsTest
  public static void sendLoginDataForNewUserTest() {
    Map<String, EmailMessage> emails = new Map<String, EmailMessage>();
    EmailTemplate emailTemplate = [
      SELECT Subject, Body
      FROM EmailTemplate
      WHERE Name = :PersonTriggerHandler.NEW_USER_EMAIL_TEMPLATE
    ];

    TestDataFactory.createPeopleList(
      NUMBER_OF_DATA,
      true,
      'user',
      EMAIL_PREFIX,
      3
    );

    List<Person__c> people = [
      SELECT Email__c, Name, Encrypted_PIN__c, Person_ID__c, LastModifiedBy.Name
      FROM Person__c
      WHERE Email__c LIKE :EMAIL_PREFIX + '%'
    ];

    for (EmailMessage message : [
      SELECT TextBody, Subject, ToAddress, Id
      FROM EmailMessage
      WHERE
        Subject = :emailTemplate.Subject
        AND ToAddress LIKE :EMAIL_PREFIX + '%'
    ]) {
      emails.put(message.ToAddress, message);
    }

    Assert.areEqual(NUMBER_OF_DATA, emails.size());

    for (Person__c person : people) {
      Assert.isTrue(emails.containsKey(person.Email__c.toLowerCase()));
      Assert.areEqual(
        String.format(
          emailTemplate.Body,
          new List<String>{
            person.Name,
            person.Person_ID__c,
            person.Encrypted_PIN__c,
            person.LastModifiedBy.Name
          }
        ),
        emails.get(person.Email__c.toLowerCase()).TextBody
      );
    }
  }
}
