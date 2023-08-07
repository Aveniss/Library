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
    allItemList.addAll(books);
    allItemList.addAll(audiobooks);
    insert allItemList;
  }

  @IsTest
  public static void searchAllItemsTest() {
    Test.startTest();
    List<Item__c> items = ItemSearcherController.searchItems(
      '',
      '',
      '',
      0,
      '',
      ''
    );
    Test.stopTest();

    Assert.areEqual(10, items.size(), 'Incorrect number of returned items');
  }

  @IsTest
  public static void searchItemsWithSpecificNameTest() {
    Test.startTest();
    List<Item__c> items = ItemSearcherController.searchItems(
      'ample',
      '',
      '',
      0,
      '',
      ''
    );
    Test.stopTest();

    Assert.areEqual(
      NUMBER_OF_DATA,
      items.size(),
      'Incorrect number of returned items'
    );
  }

  @IsTest
  public static void searchItemsWithSpecificTypeTest() {
    Test.startTest();
    List<Item__c> items = ItemSearcherController.searchItems(
      '',
      Consts.ITEMS.TYPE.AUDIOBOOK,
      '',
      0,
      '',
      ''
    );
    Test.stopTest();

    Assert.areEqual(
      NUMBER_OF_DATA,
      items.size(),
      'Incorrect number of returned items'
    );
  }

  @IsTest
  public static void searchItemsWithSpecificGenreTest() {
    Test.startTest();
    List<Item__c> items = ItemSearcherController.searchItems(
      '',
      Consts.ITEMS.TYPE.PAPER_BOOK,
      Consts.ITEMS.GENRE.NOVEL,
      0,
      '',
      ''
    );
    Test.stopTest();

    Assert.areEqual(
      NUMBER_OF_DATA,
      items.size(),
      'Incorrect number of returned items'
    );
  }
}
