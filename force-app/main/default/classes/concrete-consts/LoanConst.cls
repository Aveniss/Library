public class LoanConst {
  public static final LoanConst INSTANCE = new LoanConst();

  public final String API_NAME = Loan__c.sObjectType.getDescribe().getName();

  public final Status STATUS = new Status();

  public class Status {
    public final String RESERVATION = 'Reservation';
    public final String BORROWED = 'Borrowed';
    public final String RETURNED = 'Returned';
    public final String DELAY = 'Delay';
  }
}
