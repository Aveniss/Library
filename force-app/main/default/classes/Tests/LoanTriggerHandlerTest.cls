@isTest
private class LoanTriggerHandlerTest {
  private static final Date RENTAL_DATE = Date.newInstance(2023, 7, 15);
  private static final Date END_OF_RENTAL = Date.newInstance(2023, 7, 20);

  @isTest
  static void testWhenItemIsAvailable() {
    Item__c book = new Item__c(
      Name = 'Test Book',
      Type__c = 'Paper Book',
      Genre__c = 'Fantastic'
    );
    insert book;

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
      Status__c = Consts.LOANS.STATUS.RETURNED,
      Rental_Date__c = RENTAL_DATE,
      End_Of_Rental__c = END_OF_RENTAL
    );
    insert existingLoan;

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

    System.assert(!newLoan.hasErrors(), 'Expected no error to be returned');
  }
  @isTest
  static void testWhenItemIsNotAvailable() {
    Item__c book = new Item__c(
      Name = 'Test Book',
      Type__c = 'Paper Book',
      Genre__c = 'Fantastic'
    );
    insert book;

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

    System.assert(newLoan.hasErrors(), 'Expected error to be returned');
    System.assertEquals(
      'This Paper Book is currently borrowed',
      newLoan.getErrors()[0].getMessage()
    );
  }

  @isTest
  static void testWhenBorrowingLimitIsNotAchieve() {
    Item__c book = new Item__c(
      Name = 'Test Book',
      Type__c = 'Paper Book',
      Genre__c = 'Fantastic'
    );
    insert book;

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
      Status__c = Consts.LOANS.STATUS.RETURNED,
      Rental_Date__c = RENTAL_DATE,
      End_Of_Rental__c = END_OF_RENTAL
    );
    insert existingLoan;

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

    System.assert(!newLoan.hasErrors(), 'Expected no error to be returned');
  }

  @isTest
  static void testWhenBorrowingLimitIsAchieve() {
    Item__c book = new Item__c(
      Name = 'Test Book',
      Type__c = 'Paper Book',
      Genre__c = 'Fantastic'
    );
    insert book;

    Person__c borrower = new Person__c(
      Name = 'Test',
      Last_Name__c = 'Borrower',
      Email__c = 'testEmail@gmail.com',
      Maximum_Number_Of_Rentals__c = 1
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

    System.assert(newLoan.hasErrors(), 'Expected error to be returned');
    System.assertEquals(
      System.Label.MaxNumberOfBorrowing,
      newLoan.getErrors()[0].getMessage()
    );
  }
}
