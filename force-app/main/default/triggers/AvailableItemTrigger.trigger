trigger AvailableItemTrigger on Loan__c(before insert) {
  List<Id> requiredIDs = new List<Id>();

  List<Loan__c> loans;

  for (Loan__c loan : Trigger.new) {
    requiredIDs.add(loan.Item__c);
    requiredIDs.add(loan.Borrower__c);
  }

  loans = [
    SELECT Borrower__r.Maximum_Number_Of_Rentals__c, Item__r.Type__c, Status__c
    FROM Loan__c
    WHERE Item__c IN :requiredIDs OR Borrower__c IN :requiredIDs
  ];

  for (Loan__c newLoan : Trigger.new) {
    Integer numberOfBorrows = 0;
    for (Loan__c loan : loans) {
      if (loan.Item__c == newLoan.Item__c && loan.Status__c != 'Returned') {
        newLoan.addError(
          'This ' + loan.Item__r.Type__c + ' is currently borrowed'
        );
        break;
      } else if (
        loan.Borrower__c == newLoan.Borrower__c &&
        loan.Status__c != 'Returned'
      ) {
        numberOfBorrows++;
        if (numberOfBorrows >= loan.Borrower__r.Maximum_Number_Of_Rentals__c) {
          newLoan.addError(
            'You have achieved maximum number of borrowing items'
          );
          break;
        }
      }
    }
  }

}
