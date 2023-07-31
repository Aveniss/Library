@IsTest
public class DateTimeUtilsTest {
  @IsTest
  public static void testIsWeekendSaturday() {
    Datetime saturday = Datetime.newInstanceGmt(2023, 7, 29, 12, 0, 0);
    System.assertEquals(true, DateTimeUtils.isWeekend(saturday));
  }

  @IsTest
  public static void testIsWeekendSunday() {
    Datetime sunday = Datetime.newInstanceGmt(2023, 7, 30, 12, 0, 0);
    System.assertEquals(true, DateTimeUtils.isWeekend(sunday));
  }

  @IsTest
  public static void testIsWeekendWeekday() {
    Datetime weekday = Datetime.newInstanceGmt(2023, 7, 31, 12, 0, 0);
    System.assertEquals(false, DateTimeUtils.isWeekend(weekday));
  }

  @IsTest
  public static void testIsWeekendNullDatetime() {
    Datetime nullDatetime = null;
    System.assertEquals(false, DateTimeUtils.isWeekend(nullDatetime));
  }
}
