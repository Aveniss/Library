@IsTest
public class EmailManagerTest {
  @TestSetup
  public static void insertBasicData() {
    TestDataFactory.createEmailCustomSetting(
      true,
      Consts.BATCHES.EMAILS.ADMIN,
      'kamilst934@gmail.com'
    );
    TestDataFactory.createPeopleList(1, true, 'Test', 'testemail', 3);
  }

  @IsTest
  public static void testCreateSingleEmail() {
    Messaging.SingleEmailMessage email = EmailManager.createSingleEmail(
      'recipient@example.com',
      'This is the email content.',
      'Test Email Subject'
    );

    System.assertEquals('recipient@example.com', email.getToAddresses()[0]);
    System.assertEquals('Test Email Subject', email.getSubject());
    System.assertEquals('This is the email content.', email.getPlainTextBody());
    System.assertEquals('Library Support', email.getSenderDisplayName());
  }

  @IsTest
  public static void testCreateSingleEmailEmptySubject() {
    Messaging.SingleEmailMessage email = EmailManager.createSingleEmail(
      'recipient@example.com',
      'This is the email content.',
      ''
    );

    System.assertEquals('recipient@example.com', email.getToAddresses()[0]);
    System.assertEquals('', email.getSubject());
    System.assertEquals('This is the email content.', email.getPlainTextBody());
    System.assertEquals('Library Support', email.getSenderDisplayName());
  }

  @IsTest
  public static void testCreateEmailContent() {
    Map<String, List<String>> errorsMap = new Map<String, List<String>>();
    errorsMap.put('Error1', new List<String>{ 'ID1', 'ID2' });
    errorsMap.put('Error2', new List<String>{ 'ID3', 'ID4', 'ID5' });

    String expectedContent = 'Error1 : ID1,ID2\nError2 : ID3,ID4,ID5';
    String actualContent = EmailManager.createEmailContent(errorsMap);

    System.assertEquals(expectedContent, actualContent);
  }

  @IsTest
  public static void testCreateEmailContentEmptyMap() {
    Map<String, List<String>> errorsMap = new Map<String, List<String>>();

    String expectedContent = '';
    String actualContent = EmailManager.createEmailContent(errorsMap);

    System.assertEquals(expectedContent, actualContent);
  }

  @IsTest
  public static void testSendErrorMessage() {
    String errorEmailSubject = 'Test Error Subject';
    Test.startTest();
    EmailManager.sendErrorMessage(
      errorEmailSubject,
      'This is the error message content.'
    );
    Test.stopTest();

    List<EmailMessage> sentEmails = [
      SELECT Id, ToAddress, Subject, TextBody
      FROM EmailMessage
      WHERE Subject = :errorEmailSubject
    ];
    System.assertEquals(1, sentEmails.size());
    EmailMessage email = sentEmails[0];

    System.assertEquals(
      Emails__c.getValues(Consts.BATCHES.EMAILS.ADMIN).AdminEmail__c,
      email.ToAddress
    );
    System.assertEquals('Test Error Subject', email.Subject);
    System.assertEquals('This is the error message content.', email.TextBody);
  }

  @IsTest
  public static void createSingleEmailFromTemplateTest() {
    Person__c person = [
      SELECT Person_ID__c, Email__c, Encrypted_PIN__c, LastModifiedBy.Name, Name
      FROM Person__c
      LIMIT 1
    ];
    EmailTemplate emailTemplate = [
      SELECT Subject, HtmlValue, Body
      FROM EmailTemplate
      WHERE Name = :UserUtils.NEW_PIN_TEMPLATE
    ];

    Messaging.SingleEmailMessage mail = EmailManager.createSingleEmailFromTemplate(
      person.Email__c,
      emailTemplate,
      new List<String>{
        person.Name,
        UserUtils.decryptUserPin(person),
        person.LastModifiedBy.Name
      }
    );

    Assert.areEqual(emailTemplate.Subject, mail.subject);
    Assert.areEqual(person.Email__c, mail.toAddresses.get(0));
    Assert.areEqual(
      String.format(
        emailTemplate.HtmlValue,
        new List<String>{
          person.Name,
          person.Encrypted_PIN__c,
          person.LastModifiedBy.Name
        }
      ),
      mail.htmlBody
    );
  }
}
