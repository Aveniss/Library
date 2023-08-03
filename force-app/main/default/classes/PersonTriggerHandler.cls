/**
 * Created by kamil on 03.08.2023.
 */

public with sharing class PersonTriggerHandler {
  @TestVisible
  private static final String NEW_USER_SUBJECT = 'Login Data';
  @TestVisible
  private static final String NEW_PIN_SUBJECT = 'New PIN';

  @AuraEnabled
  public static void generateNewPin(String personId) {
    List<Person__c> person = [
      SELECT Email__c, Person_ID__c, Encrypted_PIN__c
      FROM Person__c
      WHERE Id = :personId
    ];
    generatePIN(person);
    update person;
    sendLoginData(false, person);
  }

  public static void generatePIN(List<Person__c> newPeople) {
    for (Person__c person : newPeople) {
      person.Encrypted_PIN__c = String.valueOf(generateRandomInteger());
    }
  }

  public static void sendLoginData(
    Boolean areNewUsers,
    List<Person__c> newPeople
  ) {
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

    for (Person__c person : newPeople) {
      if (areNewUsers) {
        mails.add(
          EmailManager.createSingleEmail(
            person.Email__c,
            String.format(
              Label.NewPersonMessage,
              new List<String>{ person.Person_ID__c, person.Encrypted_PIN__c }
            ),
            NEW_USER_SUBJECT
          )
        );
      } else {
        mails.add(
          EmailManager.createSingleEmail(
            person.Email__c,
            String.format(
              Label.NewPinMessage,
              new List<String>{ person.Encrypted_PIN__c }
            ),
            NEW_PIN_SUBJECT
          )
        );
      }
    }

    Messaging.sendEmail(mails);
  }

  private static Long generateRandomInteger() {
    Long minRange = 1000000000L;
    Long maxRange = 9999999999L;

    Long randomLong = (Long) (Math.random() * (maxRange - minRange + 1) +
    minRange);

    return randomLong;
  }
}
