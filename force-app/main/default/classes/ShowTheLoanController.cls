/**
 * Created by kamil on 20.07.2023.
 */

public with sharing class ShowTheLoanController {
  @AuraEnabled(Cacheable=true)
  public static List<Loan__c> getLoans(String email, String status) {
    if (String.isBlank(email)) {
      return new List<Loan__c>();
    }

    if (status.toLowerCase().equals('all')) {
      return [
        SELECT
          Id,
          Status__c,
          Borrower__c,
          Item__c,
          Item__r.Name,
          Item__r.Type__c,
          Rental_Date__c,
          End_Of_Rental__c,
          Penalty__c
        FROM Loan__c
        WHERE Borrower__r.Email__c = :email
      ];
    } else {
      return [
        SELECT
          Id,
          Status__c,
          Item__r.Name,
          Item__r.Type__c,
          Rental_Date__c,
          End_Of_Rental__c,
          Penalty__c
        FROM Loan__c
        WHERE Borrower__r.Email__c = :email AND Status__c = :status
      ];
    }
  }

  @AuraEnabled
  public static void updateLoans(List<Loan__c> loans) {
    for (Loan__c loan : loans) {
      loan.Status__c = Consts.LOANS.STATUS.RETURNED;
    }

    update loans;
  }
}
