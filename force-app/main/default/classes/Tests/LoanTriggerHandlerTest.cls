@IsTest
private class LoanTriggerHandlerTest {
  private static final Date RENTAL_DATE = Date.newInstance(2023, 7, 15);
  private static final Date END_OF_RENTAL = Date.newInstance(2023, 7, 20);
  private static final String unavailableBookNamePrefix = 'Unavailable Book';
  private static final String availableBookNamePrefix = 'Available Book';
  private static final String borrowerNamePrefix = 'Test';

  @TestSetup
  private static void insertBasicData() {
    List<Item__c> unavailableBooks = DataFactory.createItemsList(1,true,unavailableBookNamePrefix,Consts.ITEMS.TYPE.PAPER_BOOK,Consts.ITEMS.GENRE.SCIENCE_FICTIN);

    List<Item__c> availableBooks = DataFactory.createItemsList(1,true,availableBookNamePrefix,Consts.ITEMS.TYPE.PAPER_BOOK,Consts.ITEMS.GENRE.NOVEL);

    List<Person__c> borrowers = DataFactory.createPeopleList(1,true,borrowerNamePrefix,'testEmail',2);

    DataFactory.createLoansList(1,true,unavailableBooks,borrowers,RENTAL_DATE,END_OF_RENTAL,Consts.LOANS.STATUS.BORROWED);
  }

  @IsTest
  static void testWhenItemIsAvailable() {
    List<Item__c> books = [
      SELECT Id, Type__c
      FROM Item__c
      WHERE Name = :availableBookNamePrefix+' 0'
    ];
    List<Person__c> borrowers = [
      SELECT Id, Maximum_Number_Of_Rentals__c
      FROM Person__c
      WHERE Name = :borrowerNamePrefix+' 0'
    ];

    System.debug(books + '\n'+borrowers);
    List<Loan__c> newLoans = DataFactory.createLoansList(1,false,books,borrowers,RENTAL_DATE,END_OF_RENTAL,Consts.LOANS.STATUS.BORROWED);

    Test.startTest();
    LoanTriggerHandler.checkBookAvailability(newLoans);
    Test.stopTest();

    Assert.isFalse(newLoans.get(0).hasErrors(), 'Expected no error to be returned');
  }
  @IsTest
  static void testWhenItemIsNotAvailable() {
    List<Item__c> books = [
            SELECT Id, Type__c
            FROM Item__c
            WHERE Name = :unavailableBookNamePrefix+' 0'
    ];

    List<Person__c> borrowers = [
            SELECT Id, Maximum_Number_Of_Rentals__c
            FROM Person__c
            WHERE Name = :borrowerNamePrefix+' 0'
    ];

    List<Loan__c> newLoans = DataFactory.createLoansList(1,false,books,borrowers,RENTAL_DATE,END_OF_RENTAL,Consts.LOANS.STATUS.BORROWED);


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
            WHERE Name = :unavailableBookNamePrefix+' 0'
    ];

    List<Person__c> borrowers = [
            SELECT Id, Maximum_Number_Of_Rentals__c
            FROM Person__c
            WHERE Name = :borrowerNamePrefix+' 0'
    ];

    List<Loan__c> newLoans = DataFactory.createLoansList(1,false,books,borrowers,RENTAL_DATE,END_OF_RENTAL,Consts.LOANS.STATUS.BORROWED);

    Test.startTest();
    LoanTriggerHandler.checkBookLimit(newLoans);
    Test.stopTest();

    Assert.isFalse(newLoans.get(0).hasErrors(), 'Expected no error to be returned');
  }

  @IsTest
  static void testWhenBorrowingLimitIsAchieve() {
    List<Item__c> books = [
            SELECT Id, Type__c
            FROM Item__c
            WHERE Name = :unavailableBookNamePrefix+' 0'
    ];

    List<Person__c> borrowers = [
            SELECT Id, Maximum_Number_Of_Rentals__c
            FROM Person__c
            WHERE Name = :borrowerNamePrefix+' 0'
    ];
    borrowers.get(0).Maximum_Number_Of_Rentals__c = 1;
    update borrowers;

    List<Loan__c> newLoans = DataFactory.createLoansList(1,false,books,borrowers,RENTAL_DATE,END_OF_RENTAL,Consts.LOANS.STATUS.BORROWED);


    Test.startTest();
    LoanTriggerHandler.checkBookLimit(newLoans);
    Test.stopTest();

    Assert.isTrue(newLoans.get(0).hasErrors(), 'Expected error to be returned');
    Assert.areEqual(
      System.Label.MaxNumberOfBorrowing,
      newLoans.get(0).getErrors()[0].getMessage()
    );
  }

}
