/**
 * Created by kamil on 12.07.2023.
 */

trigger CaseTrigger on Case(before insert) {
  if (Trigger.isInsert && Trigger.isBefore) {
    CaseTriggerHandler.addEmailSender(Trigger.new);
  }
}
