global class ParseEmail implements Messaging.InboundEmailHandler {
  global Messaging.InboundEmailResult handleInboundEmail(
    Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope
  ) {
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

    EmailMessage emailMessage = new EmailMessage();
    emailMessage.Subject = email.subject;
    emailMessage.TextBody = email.htmlBody.stripHtmlTags();
    emailMessage.FromAddress = email.fromAddress;

    Case newCase = new Case(
      Status = CaseConst.INSTANCE.STATUS.NEW_CASE,
      Reason = CaseConst.INSTANCE.CASE_ORIGIN.EMAIL,
      SuppliedEmail = email.fromAddress,
      Subject = email.subject,
      Description = email.htmlBody.stripHtmlTags()
    );
    insert newCase;

    emailMessage.ParentId = newCase.Id;

    insert emailMessage;

    return result;
  }
}
