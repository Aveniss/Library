/**
 * Created by kamil on 15.07.2023.
 */

public with sharing class ReturnReminder implements Database.Batchable<SObject>, Schedulable,Database.Stateful {
  public static final Integer DAYS_TO_RETURN = 3;
  public static final String JOB_NAME = 'Return Reminder Job';
  public static final String EMAIL_SUBJECT = 'End of Loan Reminder';
  @TestVisible
  private static Boolean shouldForceException = false;
  private final Map<String,List<String>> errorToAddress = new Map<String, List<String>>();

  public static Id scheduleMe() {
    ReturnReminder schedule = new ReturnReminder();
    return System.schedule(
      JOB_NAME,
      Consts.CRONS.CRON.RETURN_REMINDER,
      schedule
    );
  }

  public void execute(SchedulableContext context) {
    Database.executeBatch(new ReturnReminder(), 100);
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [
        SELECT Id, Borrower__r.Email__c, Item__r.Name, End_Of_Rental__c
        FROM Loan__c
        WHERE
          Status__c = :Consts.LOANS.STATUS.BORROWED
          AND End_Of_Rental__c = :addBusinessDays(Date.today(), DAYS_TO_RETURN)
      ]
    );
  }

  public void execute(Database.BatchableContext bc, List<Loan__c> loans) {
    Map<String, Container> emailToItems = generateEmailToItemsMap(loans);
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    for (String email : emailToItems.keySet()) {

      Messaging.SingleEmailMessage newEmail = EmailManager.createSingleEmail(
              email,
              String.format(
                      Label.ReturnReminder,
                      new List<String>{
                              String.join(emailToItems.get(email).stringsList, '\n'),
                              emailToItems.get(email).endOfRentalDate.format()
                      }
              ),
              EMAIL_SUBJECT
      );

      if((Test.isRunningTest() && shouldForceException)){
        newEmail.toAddresses = new List<String>{'exampleEmail'};
      }


      mails.add(newEmail);
    }
    List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(mails,false);

    for (Integer i = 0; i < emailResults.size(); i++) {
      if (!emailResults[i].isSuccess()) {
        String statusCode = emailResults[i].getErrors().get(0).getStatusCode().name();
        if(!errorToAddress.containsKey(statusCode)) {
          errorToAddress.put(statusCode,new List<String>());
        }
        errorToAddress.get(statusCode).add(mails[i].toAddresses[0]);
      }
    }
  }

  public void finish(Database.BatchableContext bc) {
    if (errorToAddress.size() > 0) {
      List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
      mails.add(
        EmailManager.createSingleEmail(
          Emails__c.getValues(Consts.BATCHES.EMAILS.ADMIN).AdminEmail__c,
          String.format(
            Label.ReturnReminderSendFaild,
            new List<String>{
              Date.today().format(),
              EmailManager.createEmailContent(errorToAddress)
            }
          ),
          Consts.BATCHES.SUBJECT.RETURN_REMINDER
        )
      );
      Messaging.sendEmail(mails);
    }
  }

  private static Map<String, Container> generateEmailToItemsMap(
    List<Loan__c> loans
  ) {
    Map<String, Container> emailToItems = new Map<String, Container>();

    for (Loan__c loan : loans) {
      if (!emailToItems.containsKey(loan.Borrower__r.Email__c)) {
        emailToItems.put(
          loan.Borrower__r.Email__c,
          new Container(new List<String>(), loan.End_Of_Rental__c)
        );
      }
      emailToItems.get(loan.Borrower__r.Email__c)
        .stringsList.add(loan.Item__r.Name);
    }

    return emailToItems;
  }

  @TestVisible
  private static Date addBusinessDays(Date yourDate, Integer additionalDays) {
    if (additionalDays <= 0) {
      return yourDate;
    }

    Datetime finalDate = yourDate;
    Integer addedDays = 0;
    while (addedDays != additionalDays) {
      finalDate = finalDate.addDays(1);
      if (
        !(finalDate.format('E').equals('Sat') ||
        finalDate.format('E').equals('Sun'))
      ) {
        addedDays++;
      }
    }

    return finalDate.date();
  }

  private class Container {
    public List<String> stringsList;
    public Date endOfRentalDate;

    Container(List<String> stringsList, Date endOfRentalDate) {
      this.stringsList = stringsList;
      this.endOfRentalDate = endOfRentalDate;
    }
  }
}
