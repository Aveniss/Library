/**
 * Created by kamil on 03.08.2023.
 */

public with sharing class PersonTriggerHandler {
  @TestVisible
  private static final String NEW_USER_EMAIL_TEMPLATE = 'Login Data Template';

  public static void generatePIN(List<Person__c> newPeople) {
    UserUtils.generatePIN(newPeople);
  }

  public static void sendLoginData(List<Person__c> newPeople) {
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    Set<Id> createdByUserIds = new Set<Id>();
    for (Person__c person : newPeople) {
      createdByUserIds.add(person.CreatedById);
    }
    Map<Id, User> usersMap = new Map<Id, User>(
      [SELECT Id, Name FROM User WHERE Id IN :createdByUserIds]
    );
    EmailTemplate emailTemplate = [
      SELECT Subject, HtmlValue
      FROM EmailTemplate
      WHERE Name = :NEW_USER_EMAIL_TEMPLATE
    ];
    for (Person__c person : newPeople) {
      mails.add(
        EmailManager.createSingleEmailFromTemplate(
          person.Email__c,
          emailTemplate,
          new List<String>{
            person.Name,
            person.Person_ID__c,
            UserUtils.decryptUserPin(person),
            usersMap.get(person.CreatedById).Name
          }
        )
      );
    }

    Messaging.sendEmail(mails);
  }
}
