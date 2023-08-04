/**
 * Created by kamil on 03.08.2023.
 */

public with sharing class PersonTriggerHandler {
  @TestVisible
  private static final String NEW_USER_SUBJECT = 'Login Data';

  public static void generatePIN(List<Person__c> newPeople) {
    UserUtils.generatePIN(newPeople);
  }

  public static void sendLoginData(List<Person__c> newPeople) {
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

    for (Person__c person : newPeople) {
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
    }

    Messaging.sendEmail(mails);
  }
}
