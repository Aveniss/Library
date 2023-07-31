/**
 * Created by kamil on 31.07.2023.
 */

public with sharing class DateTimeUtils {
  public static Boolean isWeekend(Datetime now) {
    return now == null
      ? false
      : (now.format('E').equals('Sat') || now.format('E').equals('Sun'));
  }
}
