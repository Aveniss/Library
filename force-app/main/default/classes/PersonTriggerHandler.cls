/**
 * Created by kamil on 20.07.2023.
 */

public with sharing class PersonTriggerHandler {
  public static void checkEmailAvailability(List<Person__c> people) {
    Set<String> emails = new Set<String>();
    List<String> unavailableEmails = new List<String>();
    for (Person__c person : people) {
      emails.add(person.Email__c);
    }

    for (Person__c person : [
      SELECT Email__c
      FROM Person__c
      WHERE Email__c IN :emails
    ]) {
      unavailableEmails.add(person.Email__c);
    }

    for (Person__c person : people) {
      if (unavailableEmails.contains(person.Email__c)) {
        person.addError(System.Label.UnavailableEmail);
      }
    }
  }
}
