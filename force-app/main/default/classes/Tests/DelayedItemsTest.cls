@IsTest
private class DelayedItemsTest {

  private static final Date CURRENT_DATE = Date.today();
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
  static void scheduleMeTest(){

    Test.startTest();
    Id scheduleID = DelayedItems.scheduleMe();
    Test.stopTest();

    List<CronTrigger> cronTriggers = [SELECT Id FROM CronTrigger WHERE Id=:scheduleID];

    Assert.isTrue(cronTriggers.size()==1,'New Schedule Job was not added correctly');
  }
  @IsTest
  static void checkDelayedItems() {
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
        Rental_Date__c = CURRENT_DATE.addDays(-(5 + i)),
        End_Of_Rental__c = CURRENT_DATE.addDays(-i)
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
      Assert.areEqual(Consts.LOANS.STATUS.DELAY, updatedLoan.Status__c);
    }
  }

  @IsTest
  static void checkNoDelayedItems() {
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
        Rental_Date__c = CURRENT_DATE.addDays(-(5 + i)),
        End_Of_Rental__c = CURRENT_DATE.addDays(+i)
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
      Assert.areEqual(Consts.LOANS.STATUS.BORROWED, updatedLoan.Status__c);
    }
  }
}