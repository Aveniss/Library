@IsTest
public class ConstsTest {
  @IsTest
  static void loanConsts() {
    Assert.areNotEqual(null, Consts.LOANS);
    Assert.areEqual('Reservation', Consts.LOANS.STATUS.RESERVATION);
    Assert.areEqual('Borrowed', Consts.LOANS.STATUS.BORROWED);
    Assert.areEqual('Returned', Consts.LOANS.STATUS.RETURNED);
    Assert.areEqual('Delay', Consts.LOANS.STATUS.DELAY);
  }
  @IsTest
  static void itemTypesConsts() {
    Assert.areNotEqual(null, Consts.ITEMS);
    Assert.areEqual('Paper Book', Consts.ITEMS.TYPE.PAPER_BOOK);
    Assert.areEqual('Magazine', Consts.ITEMS.TYPE.MAGAZINE);
    Assert.areEqual('Audiobook', Consts.ITEMS.TYPE.AUDIOBOOK);
  }
  @IsTest
  static void itemGenreConsts() {
    Assert.areNotEqual(null, Consts.ITEMS);
    Assert.areEqual('Novel', Consts.ITEMS.GENRE.NOVEL);
    Assert.areEqual('Tragedy', Consts.ITEMS.GENRE.TRAGEDY);
    Assert.areEqual('Science Fiction', Consts.ITEMS.GENRE.SCIENCE_FICTIN);
    Assert.areEqual('Adventure Novel', Consts.ITEMS.GENRE.ADVENTURE_NOVEL);
  }
  @IsTest
  static void caseStatusConsts() {
    Assert.areNotEqual(null, Consts.CASES);
    Assert.areEqual('Escalated', Consts.CASES.STATUS.ESCALATED);
    Assert.areEqual('New', Consts.CASES.STATUS.NEW_CASE);
    Assert.areEqual('Working', Consts.CASES.STATUS.WORKING);
  }
  @IsTest
  static void caseOriginConsts() {
    Assert.areNotEqual(null, Consts.CASES);
    Assert.areEqual('Phone', Consts.CASES.CASE_ORIGIN.PHONE);
    Assert.areEqual('Email', Consts.CASES.CASE_ORIGIN.EMAIL);
    Assert.areEqual('Web', Consts.CASES.CASE_ORIGIN.WEB);
  }

  @IsTest
  static void loanChargeConsts() {
    Assert.areNotEqual(null, Consts.LOANS);
    Assert.areEqual(15, Consts.LOANS.CHARGE.BOOK_CHARGE);
    Assert.areEqual(10, Consts.LOANS.CHARGE.MAGAZINE_CHARGE);
    Assert.areEqual(5, Consts.LOANS.CHARGE.AUDIOBOOK_CHARGE);
  }

  @IsTest
  static void batchSubjectConsts() {
    Assert.areNotEqual(null, Consts.BATCHES);
    Assert.areEqual(
      Consts.BATCHES.SUBJECT.RETURN_REMINDER,
      'ReturnReminder Error'
    );
    Assert.areEqual(Consts.BATCHES.SUBJECT.DELAYED_ITEMS, 'DelayedItems Error');
    Assert.areEqual(
      Consts.BATCHES.SUBJECT.PENALTY_CHARGE,
      'PenaltyCharge Error'
    );
  }
}
