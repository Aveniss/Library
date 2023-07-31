/**
 * Created by kamil on 28.07.2023.
 */

public with sharing class BatchConst {
  public static final BatchConst INSTANCE = new BatchConst();

  public final Subject SUBJECT = new Subject();
  public final Emails EMAILS = new Emails();

  public class Subject {
    public final String RETURN_REMINDER = 'ReturnReminder Error';
    public final String DELAYED_ITEMS = 'DelayedItems Error';
    public final String PENALTY_CHARGE = 'PenaltyCharge Error';
  }

  public class Emails{
    public final String ADMIN = 'Admin';
  }
}
