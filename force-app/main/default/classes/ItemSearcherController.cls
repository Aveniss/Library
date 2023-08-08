public with sharing class ItemSearcherController {
  private static final String TYPE_FIELD_TEMPLATE = '{0} AND {1} = \'\'{2}\'\'';
  private static final String VERSION_FIELD_TEMPLATE = '{0} AND {1} = {2}';
  private static final String TEXT_FIELD_TEMPLATE = '{0} AND {1} LIKE \'\'{2}%\'\'';
  @AuraEnabled
  public static List<Item__c> searchItems(
    Map<String, String> searchProperties
  ) {
    Map<String, String> templates = new Map<String, String>();
    templates.put(Item__c.Type__c.getDescribe().name, TYPE_FIELD_TEMPLATE);
    templates.put(
      Item__c.Version__c.getDescribe().name,
      VERSION_FIELD_TEMPLATE
    );
    String baseQuery = 'SELECT Id,Name,Type__c,Genre__c FROM Item__c WHERE Is_Available__c = TRUE';

    for (String field : searchProperties.keySet()) {
      if (String.isNotBlank(searchProperties.get(field))) {
        String escaped = String.escapeSingleQuotes(searchProperties.get(field));
        if (templates.containsKey(field)) {
          baseQuery = String.format(
            templates.get(field),
            new List<String>{ baseQuery, field, escaped }
          );
        } else {
          baseQuery = String.format(
            TEXT_FIELD_TEMPLATE,
            new List<String>{ baseQuery, field, escaped }
          );
        }
      }
    }
    return Database.query(baseQuery);
  }
}
