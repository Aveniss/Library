@IsTest
public with sharing class UserUtilsTest {
  private static final Integer NUMBER_OF_DATA = 5;

  @TestSetup
  public static void generateBasicDat() {
    TestDataFactory.createItemsList(
      NUMBER_OF_DATA,
      true,
      'Test',
      Consts.ITEMS.TYPE.PAPER_BOOK,
      Consts.ITEMS.GENRE.SCIENCE_FICTIN
    );

    TestDataFactory.createPeopleList(
      NUMBER_OF_DATA,
      true,
      'Test',
      'testemail',
      NUMBER_OF_DATA
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

  @IsTest
  public static void testCreateLoans() {
    Person__c borrower = [SELECT Id FROM Person__c LIMIT 1];
    List<Item__c> items = [SELECT Name, Id FROM Item__c];

    Date endOfRental = Date.today().addDays(7);
    String status = Consts.LOANS.STATUS.BORROWED;

    Test.startTest();
    insert UserUtils.createLoans(borrower.Id, items, endOfRental, status);
    Test.stopTest();

    List<Loan__c> loans = [
      SELECT
        Id,
        Borrower__c,
        Item__c,
        Item__r.Name,
        Rental_Date__c,
        End_Of_Rental__c,
        Status__c
      FROM Loan__c
    ];
    Assert.areEqual(
      NUMBER_OF_DATA,
      loans.size(),
      'Incorrect number of inserted items'
    );

    for (Integer i = 0; i < loans.size(); i++) {
      Assert.areEqual(
        items.get(i).Name,
        loans.get(i).Item__r.Name,
        'Incorrect item name'
      );
      Assert.areEqual(
        borrower.Id,
        loans.get(i).Borrower__c,
        'Incorrect borrower id'
      );
      Assert.areEqual(
        Consts.LOANS.STATUS.BORROWED,
        loans.get(i).Status__c,
        'Incorrect status'
      );
      Assert.areEqual(
        endOfRental,
        loans.get(i).End_Of_Rental__c,
        'Incorrect end of rental date'
      );
    }
  }

  @IsTest
  public static void decryptUserPinTest() {
    List<Person__c> people = [SELECT Id, Encrypted_PIN__c FROM Person__c];

    for (Person__c person : people) {
      Person__c deserializedBorrower = (Person__c) JSON.deserialize(
        JSON.serialize(person),
        Person__c.class
      );

      Assert.areEqual(
        deserializedBorrower.Encrypted_PIN__c,
        UserUtils.decryptUserPin(person),
        'Incorrect decrypted pin'
      );
    }
  }
}
