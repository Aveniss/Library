@IsTest
public class MultiLoanCreatorControllerTest {
  private static final Integer NUMBER_OF_DATA = 5;
  private static final String EMAIL_PREFIX = 'testemail';
  private static final String BOOK_NAME = 'Test';

  @TestSetup
  public static void insertBasicData() {
    TestDataFactory.createItemsList(
      NUMBER_OF_DATA,
      true,
      BOOK_NAME,
      Consts.ITEMS.TYPE.PAPER_BOOK,
      Consts.ITEMS.GENRE.SCIENCE_FICTIN
    );
    TestDataFactory.createPeopleList(1, true, 'Test', EMAIL_PREFIX, 3);
  }

  @IsTest
  public static void testGetItemsWithTypeEmptyAndExistingIdsEmpty() {
    List<Item__c> items = [SELECT Id FROM Item__c];
    List<Item__c> searchedItems = MultiLoanCreatorController.getItems(
      BOOK_NAME,
      '',
      new List<String>{ items[0].Id, items[1].Id }
    );

    Assert.areEqual(
      3,
      searchedItems.size(),
      'Incorrect number of returned items'
    );
    for (Integer i = 0; i < searchedItems.size(); i++) {
      Assert.areEqual(
        String.format(
          '{0} {1}',
          new List<String>{ BOOK_NAME, (i + 2).format() }
        ),
        searchedItems.get(i).Name
      );
    }
  }

  @IsTest
  public static void testCreateLoansWithException() {
    Person__c borrower = [SELECT Id FROM Person__c];
    List<Item__c> items = [SELECT Name, Id FROM Item__c];

    Date endOfRental = Date.today().addDays(-7);
    String status = Consts.LOANS.STATUS.BORROWED;

    Test.startTest();
    try {
      MultiLoanCreatorController.createLoans(
        borrower.Id,
        items,
        endOfRental,
        status
      );
      Assert.isTrue(false, 'Method should throw exception');
    } catch (DmlException e) {
      Assert.areEqual(
        'FIELD_CUSTOM_VALIDATION_EXCEPTION',
        e.getDmlStatusCode(0)
      );
    }
    Test.stopTest();

    Assert.areEqual(
      0,
      [SELECT Id FROM Loan__c].size(),
      'No loan should be inserted'
    );
  }
}
