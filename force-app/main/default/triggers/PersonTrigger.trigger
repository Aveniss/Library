/**
 * Created by kamil on 20.07.2023.
 */

trigger PersonTrigger on Person__c(before insert) {
  if (Trigger.isBefore && Trigger.isInsert) {
    PersonTriggerHandler.checkEmailAvailability(Trigger.new);
  }

}
