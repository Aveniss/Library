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


  public static String createEmailContent(Map<String,List<String>> errorsMap){
    List<String> records = new List<String>();

    for(String error : errorsMap.keySet()){
      records.add(error+' : '+String.join(errorsMap.get(error),','));
    }
    return String.join(records,'\n');
  }
}
