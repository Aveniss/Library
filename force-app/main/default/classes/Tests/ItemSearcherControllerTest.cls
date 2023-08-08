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
}
