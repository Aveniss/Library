/**
 * Created by kamil on 15.07.2023.
 */

public with sharing class ReturnReminder implements Database.Batchable<SObject>, Schedulable {
  public static final Integer DAYS_TO_RETURN = 3;
  public static final String JOB_NAME = 'Return Reminder Job';
  public static final String EMAIL_SUBJECT = 'End of Loan Reminder';
  private static final String EMAIL_SENDER_NAME = 'Library Support';
  private static final String ADMIN_EMAIL = 'kamilst934@gmail.com';
  private static final String REMIND_STATUS = Consts.LOANS.STATUS.BORROWED;
  private static final Date RETURN_DATE = addBusinessDays(
    Date.today(),
    DAYS_TO_RETURN
  );
  private static final String QUERY =
    'SELECT Id,Borrower__r.Email__c, Item__r.Name, End_Of_Rental__c FROM Loan__c WHERE ' +
    'Status__c =: REMIND_STATUS AND End_Of_Rental__c =: RETURN_DATE';
  private static final List<Id> notSentAdresses = new List<Id>();

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
    return Database.getQueryLocator(QUERY);
  }

  public void execute(Database.BatchableContext bc, List<Loan__c> loans) {
    Map<String, Container> emailToItems = generateEmailToItemsMap(loans);
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    for (String email : emailToItems.keySet()) {
      mails.add(
        emailCreator(
          email,
          String.format(
            Label.ReturnReminder,
            new List<String>{
              String.join(emailToItems.get(email).stringsList, '\n'),
              emailToItems.get(email).endOfRentalDate.format()
            }
          ),
          EMAIL_SUBJECT,
          EMAIL_SENDER_NAME
        )
      );
    }

    List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(mails);
    for (Integer i = 0; i < emailResults.size(); i++) {
      if (!emailResults[i].isSuccess()) {
        notSentAdresses.add(mails[i].toAddresses[0]);
      }
    }
  }

  public void finish(Database.BatchableContext bc) {
    if (notSentAdresses.size() > 0) {
      List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
      mails.add(
        emailCreator(
          ADMIN_EMAIL,
          String.format(
            Label.ReturnReminderSendFaild,
            new List<String>{
              Date.today().format(),
              String.join(notSentAdresses, ',')
            }
          ),
          'ReturnReminder Error',
          EMAIL_SENDER_NAME
        )
      );
      Messaging.sendEmail(mails);
    }
  }

  private static Messaging.SingleEmailMessage emailCreator(
    String emailAddress,
    String emailTextBody,
    String emailSubject,
    String emailSenderName
  ) {
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    String[] toAddresses = new List<String>{ emailAddress };
    mail.setToAddresses(toAddresses);
    mail.setSubject(emailSubject);
    mail.setPlainTextBody(emailTextBody);
    mail.setSenderDisplayName(emailSenderName);
    return mail;
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
