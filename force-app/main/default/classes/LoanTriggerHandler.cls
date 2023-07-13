/**
 * Created by kamil on 07.07.2023.
 */

public class LoanTriggerHandler {
  public static void checkBookAvailability(List<Loan__c> newLoans) {
    Set<Id> requiredIDs = new Set<Id>();
    Map<Id, Loan__c> existingLoans = new Map<Id, Loan__c>();

    for (Loan__c loan : newLoans) {
      requiredIDs.add(loan.Item__c);
    }

    for (Loan__c existingLoan : [
      SELECT
        Item__c,
        Borrower__c,
        Item__r.Type__c,
        Borrower__r.Maximum_Number_Of_Rentals__c,
        Status__c
      FROM Loan__c
      WHERE
        Item__c IN :requiredIDs
        AND Status__c != :Consts.LOANS.STATUS.RETURNED
    ]) {
      existingLoans.put(existingLoan.Item__c, existingLoan);
    }

    for (Loan__c loan : newLoans) {
      if (existingLoans.containsKey(loan.Item__c)) {
        loan.addError(
          String.format(
            System.Label.CurrentlyBorrowedItem,
            new List<String>{ existingLoans.get(loan.Item__c).Item__r.Type__c }
          )
        );
      }
    }
  }

  public static void checkBookLimit(List<Loan__c> newLoans) {
    Set<Id> requiredIDs = new Set<Id>();
    Map<Id, Decimal> borrowers = new Map<Id, Decimal>();
    Map<Id, Decimal> maxLimitOfBooks = new Map<Id, Decimal>();

    for (Loan__c loan : newLoans) {
      requiredIDs.add(loan.Borrower__c);
    }

    for (Loan__c existingLoan : [
      SELECT
        Item__c,
        Borrower__c,
        Borrower__r.Maximum_Number_Of_Rentals__c,
        Status__c
      FROM Loan__c
      WHERE
        Borrower__c IN :requiredIDs
        AND Status__c != :Consts.LOANS.STATUS.RETURNED
    ]) {
      if (borrowers.containsKey(existingLoan.Borrower__c)) {
        borrowers.put(
          existingLoan.Borrower__c,
          borrowers.get(existingLoan.Borrower__c) + 1
        );
      } else {
        borrowers.put(existingLoan.Borrower__c, 1);
        maxLimitOfBooks.put(
          existingLoan.Borrower__c,
          existingLoan.Borrower__r.Maximum_Number_Of_Rentals__c
        );
      }
    }

    for (Loan__c loan : newLoans) {
      System.debug('Max wyporzyczen: ' + maxLimitOfBooks.get(loan.Borrower__c));
      if (
        borrowers.containsKey(loan.Borrower__c) &&
        borrowers.get(loan.Borrower__c) >= maxLimitOfBooks.get(loan.Borrower__c)
      ) {
        loan.addError(System.Label.MaxNumberOfBorrowing);
      }
    }
  }

  public static void changeAvailabilityStatus(List<Loan__c> loans, Boolean isDeleted){
    for(Loan__c loan : loans){
        if(loan.Status__c == Consts.LOANS.STATUS.RETURNED || isDeleted){
          loan.Item__r.Is_Available__c = true;
        }
      else{
        loan.Item__r.Is_Available__c = false;
      }
    }
  }
}
