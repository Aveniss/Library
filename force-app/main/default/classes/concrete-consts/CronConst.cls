/**
 * Created by kamil on 19.07.2023.
 */

public with sharing class CronConst {
    public static final CronConst INSTANCE = new CronConst();
    public final String API_NAME = CronTrigger.sObjectType.getDescribe().getName();

    public final Cron CRON = new Cron();
    public class Cron{
        public final String DELAYED_ITEMS = '0 0 0 * * ?';
        public final String RETURN_REMINDER = '0 0 0 ? * MON,TUE,WED,THU,FRI *';
        public final String PENALTY_CHARGE = '0 0 0 ? * MON,TUE,WED,THU,FRI *';
    }
}