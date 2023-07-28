/**
 * Created by kamil on 23.07.2023.
 */

public with sharing class MultiLoanCreatorController {
  @AuraEnabled(Cacheable=true)
  public static List<Item__c> getItems(
    String name,
    String type,
    String genre,
    String additionalFiler
  ) {
    if (type.equals(Consts.ITEMS.TYPE.PAPER_BOOK)) {
      return [
        SELECT Id, Name, Type__c
        FROM Item__c
        WHERE
          Name LIKE :'%' + name + '%'
          AND Type__c = :type
          AND Genre__c LIKE :'%' + genre + '%'
      ];
    } else if (type.equals(Consts.ITEMS.TYPE.MAGAZINE)) {
      return [
        SELECT Id, Name, Type__c
        FROM Item__c
        WHERE
          Name LIKE :'%' + name + '%'
          AND Type__c = :type
          AND Publishing_House__c LIKE :'%' + additionalFiler + '%'
      ];
    } else if (type.equals(Consts.ITEMS.TYPE.AUDIOBOOK)) {
      return [
        SELECT Id, Name, Type__c
        FROM Item__c
        WHERE
          Name LIKE :'%' + name + '%'
          AND Type__c = :type
          AND Lector__c LIKE :'%' + additionalFiler + '%'
      ];
    } else {
      return [
        SELECT Id, Name, Type__c
        FROM Item__c
        WHERE Name LIKE :'%' + name + '%'
      ];
    }
  }

  @AuraEnabled
  public static void updateLoans(List<Loan__c> loans) {
    for (Loan__c loan : loans) {
      loan.Status__c = Consts.LOANS.STATUS.RETURNED;
    }

    update loans;
  }
}
