/**
 * Created by kamil on 22.07.2023.
 */
@IsTest
public with sharing class ItemReturnPanelControllerTest {
  private static final Integer NUMBER_OF_DATA = 5;
  private static final Date RENTAL_DATE = Date.newInstance(2023, 7, 10);
  private static final Date END_OF_RENTAL = Date.newInstance(2023, 7, 15);
  private static final String EMAIL_PREFIX = 'testemail';
  private static final String TEST_EMAIL = String.format(
    '{0}0{1}',
    new List<String>{ EMAIL_PREFIX, TestDataFactory.EMAIL_SUFFIX }
  );

  @TestSetup
  private static void insertBasicData() {
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
    List<Item__c> returnedBooks = TestDataFactory.createItemsList(
      NUMBER_OF_DATA,
      false,
      'Test',
      Consts.ITEMS.TYPE.PAPER_BOOK,
      Consts.ITEMS.GENRE.SCIENCE_FICTIN
    );

    allItems.addAll(delayedBooks);
    allItems.addAll(delayedMagazines);
    allItems.addAll(returnedBooks);

    insert allItems;

    List<Person__c> borrowers = TestDataFactory.createPeopleList(
      NUMBER_OF_DATA,
      true,
      'Test',
      EMAIL_PREFIX,
      3
    );

    List<Loan__c> allLoans = new List<Loan__c>();
    allLoans.addAll(
      TestDataFactory.createLoansList(
        NUMBER_OF_DATA,
        false,
        delayedBooks,
        borrowers,
        RENTAL_DATE,
        END_OF_RENTAL,
        Consts.LOANS.STATUS.DELAY
      )
    );
    allLoans.addAll(
      TestDataFactory.createLoansList(
        NUMBER_OF_DATA,
        false,
        delayedMagazines,
        borrowers,
        Date.today(),
        Date.today().addDays(3),
        Consts.LOANS.STATUS.BORROWED
      )
    );
    allLoans.addAll(
      TestDataFactory.createLoansList(
        NUMBER_OF_DATA,
        false,
        returnedBooks,
        borrowers,
        RENTAL_DATE,
        END_OF_RENTAL,
        Consts.LOANS.STATUS.RETURNED
      )
    );

    insert allLoans;
  }

  @isTest
  static void testGetLoansWithEmailEmpty() {
    List<Loan__c> loans = ItemReturnPanelController.getLoans('', 'All');
    System.assertEquals(
      null,
      loans,
      'getLoans should return null when email is empty'
    );
  }

  @isTest
  static void testGetLoansWithAllStatus() {
    Test.startTest();
    List<Loan__c> loans = ItemReturnPanelController.getLoans(TEST_EMAIL, 'All');
    Test.stopTest();

    System.assertEquals(
      3,
      loans.size(),
      'getLoans should return all loans for the given email and status "All"'
    );
  }

  @isTest
  static void testGetLoansWithSpecificStatus() {
    Test.startTest();
    List<Loan__c> loans = ItemReturnPanelController.getLoans(
      TEST_EMAIL,
      Consts.LOANS.STATUS.RETURNED
    );
    Test.stopTest();

    System.assertEquals(
      1,
      loans.size(),
      'getLoans should return loans with specific status for the given email'
    );
    System.assertEquals(
      Consts.LOANS.STATUS.RETURNED,
      loans[0].Status__c,
      'getLoans should return loans with correct status for the given email'
    );
  }

  @isTest
  static void testUpdateLoans() {
    List<Loan__c> loansToUpdate = [SELECT Status__c FROM Loan__c];

    Test.startTest();
    ItemReturnPanelController.updateLoans(loansToUpdate);
    Test.stopTest();

    for (Loan__c loan : loansToUpdate) {
      System.assertEquals(
        Consts.LOANS.STATUS.RETURNED,
        loan.Status__c,
        'updateLoans should update loan status to "Returned"'
      );
    }
  }
}
