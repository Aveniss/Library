/**
 * Created by kamil on 12.07.2023.
 */

public with sharing class CaseTriggerHandler {

    public static void addEmailSender(List<Case> newCases){
        Map<String, List<Case>> emailsMap = new Map<String,List<Case>>();

        for (Case casee : newCases) {
            if (!emailsMap.containsKey(casee.SuppliedEmail)) {
                emailsMap.put(casee.SuppliedEmail, new List<Case>());
            }
            emailsMap.get(casee.SuppliedEmail).add(casee);
        }

        for (Person__c person : [SELECT Id, Email__c FROM Person__c WHERE Email__c IN :emailsMap.keySet() AND Email__c != NULL]){
            for (Case casee : emailsMap.get(person.Email__c)){
                casee.Email_Sender__c = person.Id;
            }
        }

    }

}