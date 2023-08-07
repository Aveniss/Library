public with sharing class ItemSearcherController {
  @AuraEnabled
  public static List<Item__c> searchItems(
    String name,
    String type,
    String genre,
    Double version,
    String publishingHouse,
    String lector
  ) {
    if (type.equals(Consts.ITEMS.TYPE.PAPER_BOOK)) {
      return [
        SELECT Id, Name, Type__c, Genre__c
        FROM Item__c
        WHERE
          Is_Available__c = TRUE
          AND Name LIKE :'%' + name + '%'
          AND Type__c = :type
          AND Genre__c LIKE :'%' + genre + '%'
      ];
    } else if (type.equals(Consts.ITEMS.TYPE.AUDIOBOOK)) {
      if (version == 0) {
        return [
          SELECT Id, Name, Type__c, Genre__c
          FROM Item__c
          WHERE
            Is_Available__c = TRUE
            AND Name LIKE :'%' + name + '%'
            AND Type__c = :type
            AND Lector__c LIKE :'%' + lector + '%'
        ];
      } else {
        return [
          SELECT Id, Name, Type__c, Genre__c
          FROM Item__c
          WHERE
            Is_Available__c = TRUE
            AND Name LIKE :'%' + name + '%'
            AND Type__c = :type
            AND Lector__c LIKE :'%' + lector + '%'
            AND Version__c = :version
        ];
      }
    } else if (type.equals(Consts.ITEMS.TYPE.MAGAZINE)) {
      return [
        SELECT Id, Name, Type__c, Genre__c
        FROM Item__c
        WHERE
          Is_Available__c = TRUE
          AND Name LIKE :'%' + name + '%'
          AND Type__c = :type
          AND Publishing_House__c LIKE :'%' + publishingHouse + '%'
      ];
    } else {
      return [
        SELECT Id, Name, Type__c, Genre__c
        FROM Item__c
        WHERE Is_Available__c = TRUE AND Name LIKE :'%' + name + '%'
      ];
    }
  }
}
