@IsTest
private class LoanTriggerHandlerTest {
  private static final Date RENTAL_DATE = Date.newInstance(2023, 7, 15);
  private static final Date END_OF_RENTAL = Date.newInstance(2023, 7, 20);
  private static final String unavailableBookNamePrefix = 'Unavailable Book';
  private static final String availableBookNamePrefix = 'Available Book';
  private static final String borrowerNamePrefix = 'Test';

  @TestSetup
  private static void insertBasicData() {
    List<Item__c> allItems = new List<Item__c>();
    List<Item__c> unavailableBooks = TestDataFactory.createItemsList(
      1,
      false,
      unavailableBookNamePrefix,
      Consts.ITEMS.TYPE.PAPER_BOOK,
      Consts.ITEMS.GENRE.SCIENCE_FICTIN
    );

    List<Item__c> availableBooks = TestDataFactory.createItemsList(
      1,
      false,
      availableBookNamePrefix,
      Consts.ITEMS.TYPE.PAPER_BOOK,
      Consts.ITEMS.GENRE.NOVEL
    );

    List<Item__c> magazines = TestDataFactory.createItemsList(
      3,
      false,
      'test',
      Consts.ITEMS.TYPE.MAGAZINE,
      Consts.ITEMS.GENRE.NOVEL
    );

    allItems.addAll(magazines);
    allItems.addAll(unavailableBooks);
    allItems.addAll(availableBooks);
    insert allItems;

    List<Person__c> people = new List<Person__c>();
    List<Person__c> borrowers = TestDataFactory.createPeopleList(
      1,
      false,
      borrowerNamePrefix,
      'testEmail',
      2
    );
    people.addAll(
      TestDataFactory.createPeopleList(1, false, 'example', 'testEmail', 1)
    );
    people.addAll(borrowers);
    insert people;

    TestDataFactory.createLoansList(
      1,
      true,
      unavailableBooks,
      borrowers,
      RENTAL_DATE,
      END_OF_RENTAL,
      Consts.LOANS.STATUS.BORROWED
    );
  }

  @IsTest
  static void testWhenItemIsAvailable() {
    List<Item__c> books = [
      SELECT Id, Type__c
      FROM Item__c
      WHERE Name = :availableBookNamePrefix + ' 0'
    ];
    List<Person__c> borrowers = [
      SELECT Id, Maximum_Number_Of_Rentals__c
      FROM Person__c
      WHERE Name = :borrowerNamePrefix + ' 0'
    ];

    List<Loan__c> newLoans = TestDataFactory.createLoansList(
      1,
      false,
      books,
      borrowers,
      RENTAL_DATE,
      END_OF_RENTAL,
      Consts.LOANS.STATUS.BORROWED
    );

    Test.startTest();
    LoanTriggerHandler.checkBookAvailability(newLoans);
    Test.stopTest();

    Assert.isFalse(
      newLoans.get(0).hasErrors(),
      'Expected no error to be returned'
    );
  }
  @IsTest
  static void testWhenItemIsNotAvailable() {
    List<Item__c> books = [
      SELECT Id, Type__c
      FROM Item__c
      WHERE Name = :unavailableBookNamePrefix + ' 0'
    ];

    List<Person__c> borrowers = [
      SELECT Id, Maximum_Number_Of_Rentals__c
      FROM Person__c
      WHERE Name = :borrowerNamePrefix + ' 0'
    ];

    List<Loan__c> newLoans = TestDataFactory.createLoansList(
      1,
      false,
      books,
      borrowers,
      RENTAL_DATE,
      END_OF_RENTAL,
      Consts.LOANS.STATUS.BORROWED
    );

    Test.startTest();
    LoanTriggerHandler.checkBookAvailability(newLoans);
    Test.stopTest();

    Assert.isTrue(newLoans.get(0).hasErrors(), 'Expected error to be returned');
    Assert.areEqual(
      String.format(
        Label.CurrentlyBorrowedItem,
        new List<String>{ Consts.ITEMS.TYPE.PAPER_BOOK }
      ),
      newLoans.get(0).getErrors()[0].getMessage()
    );
  }

  @IsTest
  static void testWhenBorrowingLimitIsNotAchieve() {
    List<Item__c> books = [
      SELECT Id, Type__c
      FROM Item__c
      WHERE Name = :availableBookNamePrefix + ' 0'
    ];

    List<Person__c> borrowers = [
      SELECT Id, Maximum_Number_Of_Rentals__c
      FROM Person__c
      WHERE Name = :borrowerNamePrefix + ' 0'
    ];

    try {
      TestDataFactory.createLoansList(
        1,
        true,
        books,
        borrowers,
        RENTAL_DATE,
        END_OF_RENTAL,
        Consts.LOANS.STATUS.BORROWED
      );
    } catch (DmlException e) {
      Assert.isTrue(false, 'Expected no error to be returned');
    }
  }

  @IsTest
  static void testWhenBorrowingLimitIsAchieve() {
    List<Item__c> books = [
      SELECT Id, Type__c
      FROM Item__c
      WHERE Name = :availableBookNamePrefix + ' 0'
    ];

    List<Person__c> borrowers = [
      SELECT Id, Maximum_Number_Of_Rentals__c
      FROM Person__c
      WHERE Name = :borrowerNamePrefix + ' 0'
    ];

    borrowers.get(0).Maximum_Number_Of_Rentals__c = 0;
    update borrowers;

    try {
      TestDataFactory.createLoansList(
        1,
        true,
        books,
        borrowers,
        RENTAL_DATE,
        END_OF_RENTAL,
        Consts.LOANS.STATUS.BORROWED
      );
      Assert.isTrue(false, 'An error should be thrown');
    } catch (DmlException e) {
      Assert.areEqual(System.Label.MaxNumberOfBorrowing, e.getDmlMessage(0));
    }
  }

  @isTest
  static void testChangeAvailabilityStatusAfterBorrowed() {
    List<Loan__c> loans = [
      SELECT Status__c, Item__r.Name, Item__r.Is_Available__c
      FROM Loan__c
      WHERE Status__c = :Consts.LOANS.STATUS.BORROWED
    ];

    for (Loan__c loan : loans) {
      Assert.isFalse(
        loan.Item__r.Is_Available__c,
        loan.Item__r.Name + ' should not be available'
      );
    }
  }

  @isTest
  static void testChangeAvailabilityStatusAfterDelete() {
    List<Id> ids = new List<Id>();
    List<Loan__c> loans = [
      SELECT Status__c, Item__c, Item__r.Name, Item__r.Is_Available__c
      FROM Loan__c
    ];
    for (Loan__c loan : loans) {
      ids.add(loan.Item__c);
    }

    Test.startTest();
    delete loans;
    Test.stopTest();

    List<Item__c> items = [
      SELECT Name, Is_Available__c
      FROM Item__c
      WHERE Id IN :ids
    ];

    for (Item__c item : items) {
      Assert.isTrue(item.Is_Available__c, item.Name + ' should be available');
    }
  }
  @isTest
  static void testChangeAvailabilityStatusAfterReturned() {
    List<Loan__c> loans = [
      SELECT Status__c, Item__r.Name, Item__r.Is_Available__c
      FROM Loan__c
    ];

    for (Loan__c loan : loans) {
      loan.Status__c = Consts.LOANS.STATUS.RETURNED;
    }
    update loans;

    loans = [
      SELECT Status__c, Item__r.Name, Item__r.Is_Available__c
      FROM Loan__c
    ];

    for (Loan__c loan : loans) {
      Assert.isTrue(
        loan.Item__r.Is_Available__c,
        loan.Item__r.Name + ' should be available'
      );
    }
  }

  @IsTest
  public static void testAchieveMaxLoansNumberWithNewPerson() {
    Person__c borrower = [
      SELECT Maximum_Number_Of_Rentals__c
      FROM Person__c
      WHERE Maximum_Number_Of_Rentals__c = 1
    ];
    List<Item__c> items = [
      SELECT Id, Is_Available__c
      FROM Item__c
      WHERE Type__c = :Consts.ITEMS.TYPE.MAGAZINE
    ];
    List<Loan__c> loans = new List<Loan__c>();

    for (Item__c item : items) {
      loans.add(
        new Loan__c(
          Borrower__c = borrower.Id,
          Item__c = item.Id,
          Status__c = Consts.LOANS.STATUS.BORROWED,
          Rental_Date__c = Date.today(),
          End_Of_Rental__c = Date.today().addDays(7)
        )
      );
    }

    try {
      insert loans;
      Assert.isTrue(false, 'An error should be thrown');
    } catch (DmlException e) {
      Assert.areEqual(System.Label.MaxNumberOfBorrowing, e.getDmlMessage(0));
    }
  }
}
