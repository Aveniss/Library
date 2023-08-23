/**
 * Created by kamil on 04.08.2023.
 */

public with sharing class UserUtils {
  @TestVisible
  private static final String NEW_PIN_TEMPLATE = 'New PIN Template';

  public static void generatePIN(List<Person__c> newPeople) {
    for (Person__c person : newPeople) {
      person.Encrypted_PIN__c = String.valueOf(generateRandomLong());
    }
  }

  public static void sendNewPinData(List<Person__c> newPeople) {
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    EmailTemplate emailTemplate = [
      SELECT Subject, HtmlValue
      FROM EmailTemplate
      WHERE Name = :NEW_PIN_TEMPLATE
    ];

    for (Person__c person : newPeople) {
      mails.add(
        EmailManager.createSingleEmailFromTemplate(
          person.Email__c,
          emailTemplate,
          new List<String>{
            person.Name,
            UserUtils.decryptUserPin(person),
            person.LastModifiedBy.Name
          }
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

  public static List<Loan__c> createLoans(
    String borrowerId,
    List<Item__c> items,
    Date endOfRental,
    String status
  ) {
    List<Loan__c> newLoans = new List<Loan__c>();

    for (Item__c item : items) {
      newLoans.add(
        new Loan__c(
          Borrower__c = borrowerId,
          Item__c = item.Id,
          Rental_Date__c = Date.today(),
          End_Of_Rental__c = endOfRental,
          Status__c = status
        )
      );
    }

    return newLoans;
  }

  public static String decryptUserPin(Person__c person) {
    Person__c deserializedBorrower = (Person__c) JSON.deserialize(
      JSON.serialize(person),
      Person__c.class
    );
    return deserializedBorrower.Encrypted_PIN__c;
  }
}
