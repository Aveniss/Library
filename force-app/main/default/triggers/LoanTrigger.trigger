/**
 * Created by kamil on 07.07.2023.
 */

trigger LoanTrigger on Loan__c(before insert) {
  if (Trigger.isBefore && Trigger.isInsert) {
    LoanTriggerHandler.checkBookAvailability(Trigger.new);
    LoanTriggerHandler.checkBookLimit(Trigger.new);
  }

}
