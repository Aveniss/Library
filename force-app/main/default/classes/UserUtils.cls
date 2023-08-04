/**
 * Created by kamil on 04.08.2023.
 */

public with sharing class UserUtils {
  @TestVisible
  private static final String NEW_PIN_SUBJECT = 'New PIN';

  public static void generatePIN(List<Person__c> newPeople) {
    for (Person__c person : newPeople) {
      person.Encrypted_PIN__c = String.valueOf(generateRandomLong());
    }
  }

  public static void sendNewPinData(List<Person__c> newPeople) {
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

    for (Person__c person : newPeople) {
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

    Messaging.sendEmail(mails);
  }

  public static Long generateRandomLong() {
    Integer randomInt = (Integer) (Math.random() * (99999 - 10000 + 1) + 10000);

    String timestampString =
      String.valueOf(randomInt) +
      String.valueOf(System.currentTimeMillis()).right(5);

    return Long.valueOf(timestampString);
  }
}
