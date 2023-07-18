/**
 * Created by kamil on 07.07.2023.
 */

trigger LoanTrigger on Loan__c(before insert,after insert,after delete, after update ) {
  if (Trigger.isBefore && Trigger.isInsert) {
    LoanTriggerHandler.checkBookAvailability(Trigger.new);
    LoanTriggerHandler.checkBookLimit(Trigger.new);
  }

    if(Trigger.isDelete){
      LoanTriggerHandler.changeAvailabilityStatus(Trigger.old,Trigger.isDelete);
    }
    else {
      LoanTriggerHandler.changeAvailabilityStatus(Trigger.new,Trigger.isDelete);
    }
}
