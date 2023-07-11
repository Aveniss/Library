/**
 * Created by kamil on 11.07.2023.
 */

public with sharing class CaseConst {
    public static final CaseConst INSTANCE = new CaseConst();

    public final String API_NAME = Case.sObjectType.getDescribe().getName();

    public final Status STATUS = new Status();
    public final CaseOrigin CASE_ORIGIN = new CaseOrigin();

    public class Status {
        public final String NEW_CASE = 'New';
        public final String WORKING = 'Working';
        public final String ESCALATED = 'Escalated';
    }

    public class CaseOrigin{
        public final String PHONE = 'Phone';
        public final String EMAIL = 'Email';
        public final String WEB = 'Web';
    }
}