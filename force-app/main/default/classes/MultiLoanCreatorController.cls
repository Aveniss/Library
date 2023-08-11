/**
 * Created by kamil on 23.07.2023.
 */

public with sharing class MultiLoanCreatorController {
  @AuraEnabled
  public static List<Item__c> getItems(
    String name,
    String type,
    List<String> existingIDs
  ) {
    if (!String.isBlank(type)) {
      return [
        SELECT Id, Name, Type__c, Genre__c
        FROM Item__c
        WHERE
          Is_Available__c = TRUE
          AND Name LIKE :'%' + name + '%'
          AND Type__c = :type
          AND Id NOT IN :existingIDs
      ];
    } else {
      return [
        SELECT Id, Name, Type__c, Genre__c
        FROM Item__c
        WHERE
          Is_Available__c = TRUE
          AND Name LIKE :'%' + name + '%'
          AND Id NOT IN :existingIDs
      ];
    }
  }

  @AuraEnabled
  public static void createLoans(
    String borrowerId,
    List<Item__c> items,
    Date endOfRental,
    String status
  ) {
    insert UserUtils.createLoans(borrowerId, items, endOfRental, status);
  }
}
