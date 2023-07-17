/**
 * Created by kamil on 15.07.2023.
 */

public with sharing class ReturnReminder implements Schedulable {
    private static final Integer daysToReturnTheItem = 3;
    public static final String CRON_EXPRESSION = '0 0 * * 1-5';
    public static final String JOB_NAME = 'Return Reminder Job';


    public static Id scheduleMe() {
        ReturnReminder schedule = new ReturnReminder();
        return System.schedule(JOB_NAME, CRON_EXPRESSION, schedule);
    }

    public void execute(SchedulableContext context) {
        Map<String,Container> emailToItems = generateEmailToItemsMap([SELECT Borrower__r.Email__c,Item__r.Name FROM Loan__c WHERE Status__c =: Consts.LOANS.STATUS.BORROWED AND End_Of_Rental__c =: addBusinessDays(Date.today(),daysToReturnTheItem)]);

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for (String email : emailToItems.keySet()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('End of Loan Reminder');
            mail.setPlainTextBody(String.format(Label.ReturnReminder,new List<String>{itemsToString(emailToItems.get(email).stringsList),emailToItems.get(email).endOfRentalDate.format()}));
            mail.setSenderDisplayName('Library Support');
            mails.add(mail);
        }

        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
    }

    private static String itemsToString(List<String> itemsList){
        String result = '\n';
        for (String str : itemsList){
            result+= (str + '\n');
        }
        return result;
    }


    private static Map<String,Container> generateEmailToItemsMap(List<Loan__c> loans){
        Map<String,Container> emailToItems = new Map<String,Container>();

        for (Loan__c loan : loans){
            if(!emailToItems.containsKey(loan.Borrower__r.Email__c)){
                emailToItems.put(loan.Borrower__r.Email__c,new Container(new List<String>(),loan.End_Of_Rental__c));
            }
            emailToItems.get(loan.Borrower__r.Email__c).stringsList.add(loan.Item__r.Name);
        }

        return emailToItems;
    }

    private static Date addBusinessDays(Date yourDate,Integer additionalDays){
        if(additionalDays<=0) {
            return Date.today();
        }

        Datetime finalDate = yourDate;
        Integer addedDays = 0;
        while(addedDays!=additionalDays){
            finalDate = finalDate.addDays(1);
            if(!(finalDate.format('E').equals('Sat') || finalDate.format('E').equals('Sun'))){
                addedDays++;
            }
        }

        return finalDate.date();
    }

    private class Container{
        public List<String> stringsList;
        public Date endOfRentalDate;

        Container(List<String> stringsList,Date endOfRentalDate){
            this.stringsList = stringsList;
            this.endOfRentalDate = endOfRentalDate;
        }
    }
}