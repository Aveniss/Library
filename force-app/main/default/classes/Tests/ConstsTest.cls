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
    Assert.areNotEqual(null, Consts.CASE_CONST);
    Assert.areEqual('Escalated', Consts.CASE_CONST.STATUS.ESCALATED);
    Assert.areEqual('New', Consts.CASE_CONST.STATUS.NEW_CASE);
    Assert.areEqual('Working', Consts.CASE_CONST.STATUS.WORKING);
  }

  @IsTest
  static void caseOriginConsts() {
    Assert.areNotEqual(null, Consts.CASE_CONST);
    Assert.areEqual('Phone', Consts.CASE_CONST.CASE_ORIGIN.PHONE);
    Assert.areEqual('Email',Consts.CASE_CONST.CASE_ORIGIN.EMAIL);
    Assert.areEqual('Web', Consts.CASE_CONST.CASE_ORIGIN.WEB);
  }
}