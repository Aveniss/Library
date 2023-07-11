@IsTest
private class DelayedItemsTest {

  private static final Date CURRENT_DATA = Date.today();
  private static final String BOOK_NAME = 'Test Book';
  private static final String BORROWER_NAME = 'Test';
  @TestSetup
  private static void insertBasicData() {
    Item__c book = new Item__c(
            Name = BOOK_NAME,
            Type__c = Consts.ITEMS.TYPE.PAPER_BOOK,
            Genre__c = Consts.ITEMS.GENRE.NOVEL
    );
    insert book;

    Person__c borrower = new Person__c(
            Name = BORROWER_NAME,
            Last_Name__c = 'Borrower',
            Email__c = 'testEmail@gmail.com',
            Maximum_Number_Of_Rentals__c = 2
    );
    insert borrower;
  }
  @IsTest
  static void chechDelayedItems() {
    List<Loan__c> newLoans = new List<Loan__c>();

    Item__c book = [
            SELECT Id, Type__c
            FROM Item__c
            WHERE Name = :BOOK_NAME
    ];
    Person__c borrower = [
            SELECT Id, Maximum_Number_Of_Rentals__c
            FROM Person__c
            WHERE Name = :BORROWER_NAME
    ];

    for (Integer i = 1; i <= 5; i++) {
      Loan__c loan = new Loan__c(
        Name = 'Test Loan',
        Item__c = book.Id,
        Borrower__c = borrower.Id,
        Status__c = Consts.LOANS.STATUS.BORROWED,
        Rental_Date__c = CURRENT_DATA.addDays(-(5 + 1)),
        End_Of_Rental__c = CURRENT_DATA.addDays(-i)
      );

      newLoans.add(loan);
    }

    insert newLoans;

    Test.startTest();
    DelayedItems scheduler = new DelayedItems();
    scheduler.execute(null);
    Test.stopTest();

    List<Loan__c> updatedLoans = [
      SELECT Id, Status__c
      FROM Loan__c
      WHERE Id IN :newLoans
    ];

    for (Loan__c updatedLoan : updatedLoans) {
      System.assertEquals(Consts.LOANS.STATUS.DELAY, updatedLoan.Status__c);
    }
  }

  @IsTest
  static void chechNoDelayedItems() {
    List<Loan__c> newLoans = new List<Loan__c>();

    Item__c book = [
            SELECT Id, Type__c
            FROM Item__c
            WHERE Name = :BOOK_NAME
    ];
    Person__c borrower = [
            SELECT Id, Maximum_Number_Of_Rentals__c
            FROM Person__c
            WHERE Name = :BORROWER_NAME
    ];


    for (Integer i = 1; i <= 5; i++) {
      Loan__c loan = new Loan__c(
        Name = 'Test Loan',
        Item__c = book.Id,
        Borrower__c = borrower.Id,
        Status__c = Consts.LOANS.STATUS.BORROWED,
        Rental_Date__c = CURRENT_DATA.addDays(-(5 + 1)),
        End_Of_Rental__c = CURRENT_DATA.addDays(+i)
      );

      newLoans.add(loan);
    }

    insert newLoans;

    Test.startTest();
    DelayedItems scheduler = new DelayedItems();
    scheduler.execute(null);
    Test.stopTest();

    List<Loan__c> updatedLoans = [
      SELECT Id, Status__c
      FROM Loan__c
      WHERE Id IN :newLoans
    ];

    for (Loan__c updatedLoan : updatedLoans) {
      System.assertEquals(Consts.LOANS.STATUS.BORROWED, updatedLoan.Status__c);
    }
  }
}