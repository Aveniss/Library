/**
 * Created by kamil on 12.07.2023.
 */

public with sharing class CaseTriggerHandler {

    public static void addEmailSender(List<Case> newCases){
        Map<String, Id> emailsMap = new Map<String, Id>();

        for (Case casee : newCases){
            emailsMap.put(casee.SuppliedEmail, null);
        }

        for (Person__c person : [SELECT Id, Email__c FROM Person__c WHERE Email__c IN :emailsMap.keySet()]){
            emailsMap.put(person.Email__c, person.Id);
        }

        for (Case casee : newCases){
            if (emailsMap.containsKey(casee.SuppliedEmail)) {
                casee.Email_Sender__c = emailsMap.get(casee.SuppliedEmail);
            }
        }
    }

}