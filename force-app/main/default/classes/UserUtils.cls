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
