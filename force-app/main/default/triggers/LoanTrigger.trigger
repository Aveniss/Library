/**
 * Created by kamil on 07.07.2023.
 */

trigger LoanTrigger on Loan__c(
  before insert,
  after insert,
  after delete,
  after update
) {
  if (Trigger.isBefore && Trigger.isInsert) {
    LoanTriggerHandler.checkBookAvailability(Trigger.new);
    LoanTriggerHandler.checkBookLimit(Trigger.new);
  }

  if (Trigger.isDelete && Trigger.isAfter) {
    LoanTriggerHandler.changeAvailabilityStatus(Trigger.old);
  } else if (Trigger.isAfter) {
    LoanTriggerHandler.changeAvailabilityStatus(Trigger.new);
  }
}
