/**
 * Created by kamil on 05.08.2023.
 */
@IsTest
public with sharing class ItemSearcherControllerTest {
  private static final Integer NUMBER_OF_DATA = 5;

  @TestSetup
  public static void insertBasicData() {
    List<Item__c> allItemList = new List<Item__c>();
    List<Item__c> books = TestDataFactory.createItemsList(
      NUMBER_OF_DATA,
      false,
      'Example',
      Consts.ITEMS.TYPE.PAPER_BOOK,
      Consts.ITEMS.GENRE.NOVEL
    );
    List<Item__c> audiobooks = TestDataFactory.createItemsList(
      NUMBER_OF_DATA,
      false,
      'Test',
      Consts.ITEMS.TYPE.AUDIOBOOK,
      Consts.ITEMS.GENRE.SCIENCE_FICTIN
    );
    List<Item__c> magazines = TestDataFactory.createItemsList(
      NUMBER_OF_DATA,
      false,
      'Test',
      Consts.ITEMS.TYPE.MAGAZINE,
      Consts.ITEMS.GENRE.CRIME_FICTION
    );
    allItemList.addAll(books);
    allItemList.addAll(magazines);
    allItemList.addAll(audiobooks);
    insert allItemList;

    List<Person__c> people = new List<Person__c>();
    people.addAll(
      TestDataFactory.createPeopleList(1, false, 'Name', 'email', 5)
    );
    people.addAll(
      TestDataFactory.createPeopleList(1, false, 'Name', 'email', 1)
    );
    insert people;
  }

  @IsTest
  public static void searchAllItemsTest() {
    Test.startTest();
    List<Item__c> items = ItemSearcherController.searchItems(
      new Map<String, String>()
    );
    Test.stopTest();

    Assert.areEqual(15, items.size(), 'Incorrect number of returned items');
  }

  @IsTest
  public static void searchSpecificTypeTest() {
    Map<String, String> arguments = new Map<String, String>();
    arguments.put('Type__c', Consts.ITEMS.TYPE.AUDIOBOOK);
    Test.startTest();
    List<Item__c> items = ItemSearcherController.searchItems(arguments);
    Test.stopTest();

    Assert.areEqual(5, items.size(), 'Incorrect number of returned items');
    for (Item__c item : items) {
      Assert.areEqual(Consts.ITEMS.TYPE.AUDIOBOOK, item.Type__c);
    }
  }

  @IsTest
  public static void searchSpecificGenreTest() {
    Map<String, String> arguments = new Map<String, String>();
    arguments.put('Genre__c', Consts.ITEMS.GENRE.NOVEL);
    Test.startTest();
    List<Item__c> items = ItemSearcherController.searchItems(arguments);
    Test.stopTest();

    Assert.areEqual(5, items.size(), 'Incorrect number of returned items');
    for (Item__c item : items) {
      Assert.areEqual(Consts.ITEMS.GENRE.NOVEL, item.Genre__c);
    }
  }

  @IsTest
  public static void searchSpecificNameTest() {
    String namePart = 'Exa';
    Map<String, String> arguments = new Map<String, String>();
    arguments.put('Name', namePart);
    Test.startTest();
    List<Item__c> items = ItemSearcherController.searchItems(arguments);
    Test.stopTest();

    Assert.areEqual(5, items.size(), 'Incorrect number of returned items');
    for (Item__c item : items) {
      Assert.isTrue(item.Name.contains(namePart));
    }
  }

  @IsTest
  public static void searchSpecificTypeAndGenreTest() {
    Map<String, String> arguments = new Map<String, String>();
    arguments.put('Type__c', Consts.ITEMS.TYPE.PAPER_BOOK);
    arguments.put('Genre__c', Consts.ITEMS.GENRE.NOVEL);
    Test.startTest();
    List<Item__c> items = ItemSearcherController.searchItems(arguments);
    Test.stopTest();

    Assert.areEqual(5, items.size(), 'Incorrect number of returned items');
    for (Item__c item : items) {
      Assert.areEqual(Consts.ITEMS.GENRE.NOVEL, item.Genre__c);
      Assert.areEqual(Consts.ITEMS.TYPE.PAPER_BOOK, item.Type__c);
    }
  }

  @IsTest
  public static void createNewLoansTest() {
    Person__c borrower = [
      SELECT Id, Person_ID__c, Encrypted_PIN__c
      FROM Person__c
      LIMIT 1
    ];
    Map<Id, Item__c> items = new Map<Id, Item__c>(
      [SELECT Id FROM Item__c WHERE Type__c = :Consts.ITEMS.TYPE.PAPER_BOOK]
    );

    Test.startTest();
    ItemSearcherController.createNewLoans(
      items.values(),
      UserUtils.decryptUserPin(borrower),
      borrower.Person_ID__c
    );
    Test.stopTest();

    List<Loan__c> loans = [
      SELECT Status__c, End_Of_Rental__c, Borrower__c, Item__c
      FROM Loan__c
    ];

    Assert.areEqual(
      items.size(),
      loans.size(),
      'Incorrect number of created loans'
    );

    for (Loan__c loan : loans) {
      Assert.areEqual(borrower.Id, loan.Borrower__c, 'Incorrect borrower');
      Assert.isTrue(items.containsKey(loan.Item__c), 'Incorrect item');
      Assert.areEqual(
        Date.today().addDays(30),
        loan.End_Of_Rental__c,
        'Incorrect end of loan date'
      );
      Assert.areEqual(
        Consts.LOANS.STATUS.BORROWED,
        loan.Status__c,
        'Incorrect loan status'
      );
    }
  }

  @IsTest
  public static void createNewLoansWithIncorrectID() {
    Map<Id, Item__c> items = new Map<Id, Item__c>(
      [SELECT Id FROM Item__c WHERE Type__c = :Consts.ITEMS.TYPE.PAPER_BOOK]
    );
    Person__c borrower = [SELECT Encrypted_PIN__c FROM Person__c LIMIT 1];

    try {
      ItemSearcherController.createNewLoans(
        items.values(),
        UserUtils.decryptUserPin(borrower),
        'xxxxxxxxxx'
      );
      Assert.isTrue(false, 'The method should throw an error');
    } catch (IncorrectLoginDataException e) {
      Assert.areEqual(ItemSearcherController.ERROR_MESSAGE, e.getMessage());
    }
  }

  @IsTest
  public static void createNewLoansWithIncorrectPIN() {
    List<Item__c> items = [
      SELECT Id
      FROM Item__c
      WHERE Type__c = :Consts.ITEMS.TYPE.PAPER_BOOK
    ];
    Person__c borrower = [
      SELECT Id, Person_ID__c, Encrypted_PIN__c
      FROM Person__c
      LIMIT 1
    ];

    try {
      ItemSearcherController.createNewLoans(
        items,
        'xxxxxxxxxx',
        borrower.Person_ID__c
      );
      Assert.isTrue(false, 'The method should throw an error');
    } catch (IncorrectLoginDataException e) {
      Assert.areEqual(ItemSearcherController.ERROR_MESSAGE, e.getMessage());
    }
  }

  @IsTest
  public static void createNewLoansWithMaxNumberOfBorrowedItems() {
    Person__c borrower = [
      SELECT Id, Maximum_Number_Of_Rentals__c, Encrypted_PIN__c, Person_ID__c
      FROM Person__c
      WHERE Maximum_Number_Of_Rentals__c = 1
      LIMIT 1
    ];
    Map<Id, Item__c> items = new Map<Id, Item__c>(
      [SELECT Id FROM Item__c WHERE Type__c = :Consts.ITEMS.TYPE.PAPER_BOOK]
    );

    try {
      ItemSearcherController.createNewLoans(
        items.values(),
        UserUtils.decryptUserPin(borrower),
        borrower.Person_ID__c
      );
      Assert.isTrue(false, 'An error should be return');
    } catch (DmlException e) {
      Assert.areEqual(System.Label.MaxNumberOfBorrowing, e.getDmlMessage(0));
    }
  }
}
