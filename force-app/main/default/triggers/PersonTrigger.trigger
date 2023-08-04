/**
 * Created by kamil on 03.08.2023.
 */

trigger PersonTrigger on Person__c(before insert, after insert) {
  if (Trigger.isInsert && Trigger.isBefore) {
    PersonTriggerHandler.generatePIN(Trigger.new);
  }

  if (Trigger.isInsert && Trigger.isAfter) {
    PersonTriggerHandler.sendLoginData(Trigger.new);
  }
}
