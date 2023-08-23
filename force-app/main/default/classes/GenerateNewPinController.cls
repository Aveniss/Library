/**
 * Created by kamil on 04.08.2023.
 */

public with sharing class GenerateNewPinController {
  @AuraEnabled
  public static void generateNewPin(String personId) {
    List<Person__c> person = [
      SELECT
        Id,
        Email__c,
        Name,
        LastModifiedBy.Name,
        Person_ID__c,
        Encrypted_PIN__c
      FROM Person__c
      WHERE Id = :personId
    ];
    UserUtils.generatePIN(person);
    update person;
    UserUtils.sendNewPinData(person);
  }
}
