@IsTest
private class DelayedItemsTest {
  private static final Date CURRENT_DATE = Date.today();
  private static final Date DELAYED_DATE = CURRENT_DATE.addDays(-1);
  private static final Date NOT_DELAYED_DATE = CURRENT_DATE.addDays(3);
  private static final Integer NUMBER_OF_DATA = 2;
  @TestSetup
  private static void insertBasicData() {
    TestDataFactory.createEmailCustomSetting(true,Consts.BATCHES.EMAILS.ADMIN,'kamilst934@gmail.com');

    List<Item__c> allItems = new List<Item__c>();
    List<Item__c> delayedBooks = TestDataFactory.createItemsList(
      NUMBER_OF_DATA,
      false,
      'Test',
      Consts.ITEMS.TYPE.PAPER_BOOK,
      Consts.ITEMS.GENRE.SCIENCE_FICTIN
    );
    List<Item__c> delayedMagazines = TestDataFactory.createItemsList(
      NUMBER_OF_DATA,
      false,
      'Test',
      Consts.ITEMS.TYPE.PAPER_BOOK,
      Consts.ITEMS.GENRE.SCIENCE_FICTIN
    );
    allItems.addAll(delayedBooks);
    allItems.addAll(delayedMagazines);
    insert allItems;

    List<Person__c> borrowers = TestDataFactory.createPeopleList(
      NUMBER_OF_DATA,
      true,
      'Test',
      'test',
      NUMBER_OF_DATA
    );

    List<Loan__c> allLoans = new List<Loan__c>();
    allLoans.addAll(
      TestDataFactory.createLoansList(
        NUMBER_OF_DATA,
        false,
        delayedBooks,
        borrowers,
        CURRENT_DATE.addDays(-5),
        DELAYED_DATE,
        Consts.LOANS.STATUS.BORROWED
      )
    );
    allLoans.addAll(
      TestDataFactory.createLoansList(
        NUMBER_OF_DATA,
        false,
        delayedMagazines,
        borrowers,
        CURRENT_DATE.addDays(-5),
        NOT_DELAYED_DATE,
        Consts.LOANS.STATUS.BORROWED
      )
    );
    insert allLoans;
  }

  @IsTest
  static void scheduleMeTest() {
    Test.startTest();
    Id scheduleID = DelayedItems.scheduleMe();
    Test.stopTest();

    CronTrigger cronTrigger = [
      SELECT Id, CronExpression, CronJobDetail.Name
      FROM CronTrigger
      WHERE Id = :scheduleID
    ];
    Assert.areEqual(
      DelayedItems.JOB_NAME,
      cronTrigger.CronJobDetail.Name,
      'Invalid job name'
    );
    Assert.areEqual(
      Consts.CRONS.CRON.DELAYED_ITEMS,
      cronTrigger.CronExpression,
      'Inavlid cron expression'
    );
  }
  @IsTest
  static void checkDelayedItems() {
    Test.startTest();
    DelayedItems scheduler = new DelayedItems();
    scheduler.execute(null);
    Test.stopTest();

    List<Loan__c> updatedLoans = [
      SELECT Id, Status__c
      FROM Loan__c
      WHERE End_Of_Rental__c = :DELAYED_DATE
    ];

    for (Loan__c updatedLoan : updatedLoans) {
      Assert.areEqual(Consts.LOANS.STATUS.DELAY, updatedLoan.Status__c);
    }
  }

  @IsTest
  static void checkNoDelayedItems() {
    Test.startTest();
    DelayedItems scheduler = new DelayedItems();
    scheduler.execute(null);
    Test.stopTest();

    List<Loan__c> updatedLoans = [
      SELECT Id, Status__c
      FROM Loan__c
      WHERE End_Of_Rental__c = :NOT_DELAYED_DATE
    ];

    for (Loan__c updatedLoan : updatedLoans) {
      Assert.areEqual(Consts.LOANS.STATUS.BORROWED, updatedLoan.Status__c);
    }
  }

  @IsTest
  static void checkUpdateStatusFaildTest() {
    DelayedItems.shouldForceException = true;
    Test.startTest();
    DelayedItems delayedItems = new DelayedItems();
    delayedItems.execute(null);
    Test.stopTest();

    List<EmailMessage> emails = [
      SELECT TextBody, Subject, ToAddress, Id
      FROM EmailMessage
      WHERE Subject =: Consts.BATCHES.SUBJECT.DELAYED_ITEMS
    ];

    Assert.areEqual(1, emails.size());
    Assert.areEqual(
      Emails__c.getValues(Consts.BATCHES.EMAILS.ADMIN).AdminEmail__c,
      emails[0].ToAddress
    );
  }
}
