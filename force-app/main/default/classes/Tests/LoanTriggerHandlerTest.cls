@isTest
private class LoanTriggerHandlerTest {
  private static final Date RENTAL_DATE = Date.newInstance(2023, 7, 15);
  private static final Date END_OF_RENTAL = Date.newInstance(2023, 7, 20);

  @TestSetup
  private static void insertBasicData() {
    Item__c book = new Item__c(
      Name = 'Unavailable Book',
      Type__c = Consts.ITEMS.TYPE.PAPER_BOOK,
      Genre__c = Consts.ITEMS.GENRE.SCIENCE_FICTIN
    );
    insert book;

    Item__c availableBook = new Item__c(
      Name = 'Available Book',
      Type__c = Consts.ITEMS.TYPE.PAPER_BOOK,
      Genre__c = Consts.ITEMS.GENRE.NOVEL
    );
    insert availableBook;

    Person__c borrower = new Person__c(
      Name = 'Test',
      Last_Name__c = 'Borrower',
      Email__c = 'testEmail@gmail.com',
      Maximum_Number_Of_Rentals__c = 2
    );
    insert borrower;

    Loan__c existingLoan = new Loan__c(
      Name = 'Test Loan',
      Item__c = book.Id,
      Borrower__c = borrower.Id,
      Status__c = Consts.LOANS.STATUS.BORROWED,
      Rental_Date__c = RENTAL_DATE,
      End_Of_Rental__c = END_OF_RENTAL
    );
    insert existingLoan;
  }

  @isTest
  static void testWhenItemIsAvailable() {
    Item__c book = [
      SELECT Id, Type__c
      FROM Item__c
      WHERE Name = :'Available Book'
    ];
    Person__c borrower = [
      SELECT Id, Maximum_Number_Of_Rentals__c
      FROM Person__c
      WHERE Name = :'Test'
    ];

    Loan__c newLoan = new Loan__c(
      Name = 'Second Test Loan',
      Item__c = book.Id,
      Borrower__c = borrower.Id,
      Status__c = Consts.LOANS.STATUS.BORROWED,
      Rental_Date__c = RENTAL_DATE,
      End_Of_Rental__c = END_OF_RENTAL
    );
    List<Loan__c> newLoans = new List<Loan__c>{ newLoan };

    Test.startTest();
    LoanTriggerHandler.checkBookAvailability(newLoans);
    Test.stopTest();

    Assert.isFalse(newLoan.hasErrors(), 'Expected no error to be returned');
  }
  @isTest
  static void testWhenItemIsNotAvailable() {
    Item__c book = [
      SELECT Id, Type__c
      FROM Item__c
      WHERE Name = :'Unavailable Book'
    ];
    Person__c borrower = [
      SELECT Id, Maximum_Number_Of_Rentals__c
      FROM Person__c
      WHERE Name = :'Test'
    ];

    Loan__c newLoan = new Loan__c(
      Name = 'Second Test Loan',
      Item__c = book.Id,
      Borrower__c = borrower.Id,
      Status__c = Consts.LOANS.STATUS.BORROWED,
      Rental_Date__c = RENTAL_DATE,
      End_Of_Rental__c = END_OF_RENTAL
    );
    List<Loan__c> newLoans = new List<Loan__c>{ newLoan };

    Test.startTest();
    LoanTriggerHandler.checkBookAvailability(newLoans);
    Test.stopTest();

    Assert.isTrue(newLoan.hasErrors(), 'Expected error to be returned');
    Assert.areEqual(
      String.format(
        Label.CurrentlyBorrowedItem,
        new List<String>{ Consts.ITEMS.TYPE.PAPER_BOOK }
      ),
      newLoan.getErrors()[0].getMessage()
    );
  }

  @isTest
  static void testWhenBorrowingLimitIsNotAchieve() {
    Item__c book = [
      SELECT Id, Type__c
      FROM Item__c
      WHERE Name = :'Unavailable Book'
    ];
    Person__c borrower = [
      SELECT Id, Maximum_Number_Of_Rentals__c
      FROM Person__c
      WHERE Name = :'Test'
    ];

    Loan__c newLoan = new Loan__c(
      Name = 'Second Test Loan',
      Item__c = book.Id,
      Borrower__c = borrower.Id,
      Status__c = Consts.LOANS.STATUS.BORROWED,
      Rental_Date__c = RENTAL_DATE,
      End_Of_Rental__c = END_OF_RENTAL
    );
    List<Loan__c> newLoans = new List<Loan__c>{ newLoan };

    Test.startTest();
    LoanTriggerHandler.checkBookLimit(newLoans);
    Test.stopTest();

    Assert.isFalse(newLoan.hasErrors(), 'Expected no error to be returned');
  }

  @isTest
  static void testWhenBorrowingLimitIsAchieve() {
    Item__c book = [
      SELECT Id, Type__c
      FROM Item__c
      WHERE Name = :'Unavailable Book'
    ];
    Person__c borrower = [
      SELECT Id, Maximum_Number_Of_Rentals__c
      FROM Person__c
      WHERE Name = :'Test'
    ];
    borrower.Maximum_Number_Of_Rentals__c = 1;
    update borrower;

    Loan__c newLoan = new Loan__c(
      Name = 'Second Test Loan',
      Item__c = book.Id,
      Borrower__c = borrower.Id,
      Status__c = Consts.LOANS.STATUS.BORROWED,
      Rental_Date__c = RENTAL_DATE,
      End_Of_Rental__c = END_OF_RENTAL
    );
    List<Loan__c> newLoans = new List<Loan__c>{ newLoan };

    Test.startTest();
    LoanTriggerHandler.checkBookLimit(newLoans);
    Test.stopTest();

    Assert.isTrue(newLoan.hasErrors(), 'Expected error to be returned');
    Assert.areEqual(
      System.Label.MaxNumberOfBorrowing,
      newLoan.getErrors()[0].getMessage()
    );
  }
}
