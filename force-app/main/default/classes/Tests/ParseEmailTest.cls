@isTest
public class ParseEmailTest {
  @isTest
  static void testHandleInboundEmail() {
    Messaging.InboundEmail testEmail = new Messaging.InboundEmail();
    testEmail.fromAddress = 'test@example.com';
    testEmail.subject = 'Test Subject';
    testEmail.htmlBody = '<html><body>This is a test email.</body></html>';

    Messaging.InboundEnvelope testEnvelope = new Messaging.InboundEnvelope();
    ParseEmail emailHandler = new ParseEmail();
    Messaging.InboundEmailResult result = emailHandler.handleInboundEmail(
      testEmail,
      testEnvelope
    );

    System.assertEquals(true, result.success);

    Case newCase = [
      SELECT Status, Reason, SuppliedEmail, Subject, Description
      FROM Case
    ];

    System.assertEquals('New', newCase.Status);
    System.assertEquals('Email', newCase.Reason);
    System.assertEquals('test@example.com', newCase.SuppliedEmail);
    System.assertEquals('Test Subject', newCase.Subject);
    System.assertEquals('This is a test email.', newCase.Description);
  }
}
