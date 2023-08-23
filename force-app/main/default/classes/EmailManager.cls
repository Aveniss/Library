/**
 * Created by kamil on 27.07.2023.
 */

public with sharing class EmailManager {
  private static final String EMAIL_SENDER_NAME = 'Library Support';

  public static Messaging.SingleEmailMessage createSingleEmail(
    String emailAddress,
    String emailTextBody,
    String emailSubject
  ) {
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    String[] toAddresses = new List<String>{ emailAddress };
    mail.setToAddresses(toAddresses);
    mail.setSubject(emailSubject);
    mail.setPlainTextBody(emailTextBody);
    mail.setSenderDisplayName(EMAIL_SENDER_NAME);
    return mail;
  }

  public static Messaging.SingleEmailMessage createSingleEmailFromTemplate(
    String emailAddress,
    EmailTemplate emailTemplate,
    List<String> emailTemplateData
  ) {
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    String[] toAddresses = new List<String>{ emailAddress };

    mail.setToAddresses(toAddresses);
    mail.setSenderDisplayName(EMAIL_SENDER_NAME);
    mail.setSubject(emailTemplate.Subject);
    mail.setHtmlBody(String.format(emailTemplate.HtmlValue, emailTemplateData));

    return mail;
  }

  public static String createEmailContent(Map<String, List<String>> errorsMap) {
    List<String> records = new List<String>();

    for (String error : errorsMap.keySet()) {
      records.add(error + ' : ' + String.join(errorsMap.get(error), ','));
    }
    return String.join(records, '\n');
  }

  public static void sendErrorMessage(String subject, String body) {
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    mails.add(
      createSingleEmail(
        Emails__c.getValues(Consts.BATCHES.EMAILS.ADMIN).AdminEmail__c,
        body,
        subject
      )
    );
    Messaging.sendEmail(mails);
  }
}
