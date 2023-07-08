global class ParseEmail implements Messaging.InboundEmailHandler {
  global Messaging.InboundEmailResult handleInboundEmail(
    Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope
  ) {
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

    Case newCase = new Case(
      Status = 'New',
      Reason = 'Email',
      SuppliedEmail = email.fromAddress,
      Subject = email.subject,
      Description = email.htmlBody.stripHtmlTags()
    );
    insert newCase;

    return result;
  }
}
