public class LoanConst {
  public static final LoanConst INSTANCE = new LoanConst();

  public final String API_NAME = Loan__c.sObjectType.getDescribe().getName();

  public final Status STATUS = new Status();
  public final Charge CHARGE = new Charge();

  public class Status {
    public final String RESERVATION = 'Reservation';
    public final String BORROWED = 'Borrowed';
    public final String RETURNED = 'Returned';
    public final String DELAY = 'Delay';
  }

  public class Charge{
    public final Double BOOK_CHARGE = 15;
    public final Double MAGAZINE_CHARGE = 10;
    public final Double AUDIOBOOK_CHARGE = 5;
  }
}
