/**
 * Created by kamil on 15.07.2023.
 */
@IsTest
public with sharing class DataFactoryTest {

    private static final Integer numberOfData = 5;
    private static final Integer maxRentals = 2;
    private static final String prefix = 'Test';
    private static final String emailPrefix = 'testEmail';


    @IsTest
    public static void createItemsListTest(){
        DataFactory.createItemsList(numberOfData,true,prefix,Consts.ITEMS.TYPE.PAPER_BOOK,Consts.ITEMS.GENRE.SCIENCE_FICTIN);

        List<Item__c> books = [SELECT Name,Type__c,Genre__c FROM Item__c];

        Assert.areEqual(numberOfData,books.size(),'Incorrect number of inserted items');

        for(Integer i = 0; i < numberOfData;i++){
            Assert.areEqual(books.get(i).Name,prefix+' '+i,'Incorrect name of item #'+i);
            Assert.areEqual(books.get(i).Type__c,Consts.ITEMS.TYPE.PAPER_BOOK,'Incorrect type of item #'+i);
            Assert.areEqual(books.get(i).Genre__c,Consts.ITEMS.GENRE.SCIENCE_FICTIN,'Incorrect genre of item #'+i);
        }
    }

    @IsTest
    public static void createPeopleList(){
        DataFactory.createPeopleList(numberOfData,true,prefix,'testEmail',maxRentals);

        List<Person__c> people = [SELECT Name,Email__c,Maximum_Number_Of_Rentals__c FROM Person__c];

        Assert.areEqual(numberOfData,people.size(),'Incorrect number of inserted people');

        for(Integer i = 0; i < numberOfData;i++){
            Assert.areEqual(people.get(i).Name,prefix+' '+i,'Incorrect name of person #'+i);
            Assert.areEqual(people.get(i).Email__c,emailPrefix+i+'@gmail.com','Incorrect email of person #'+i);
            Assert.areEqual(people.get(i).Maximum_Number_Of_Rentals__c,maxRentals,'Incorrect number of maximum rentals of person #'+i);
        }
    }

    @IsTest
    public static void createLoansList(){
        List<Item__c> items = DataFactory.createItemsList(numberOfData,true,prefix,Consts.ITEMS.TYPE.PAPER_BOOK,Consts.ITEMS.GENRE.SCIENCE_FICTIN);

        List<Person__c> people = DataFactory.createPeopleList(numberOfData,true,prefix,'testEmail',maxRentals);

        DataFactory.createLoansList(numberOfData,true,items,people,Date.today(),Date.today()+1,Consts.LOANS.STATUS.BORROWED);


        List<Loan__c> loans = [SELECT Item__c,Borrower__c,Status__c FROM Loan__c];

        Assert.areEqual(numberOfData,loans.size(),'Incorrect number of inserted loans');

        for(Integer i = 0; i < numberOfData;i++){
            Assert.areEqual(loans.get(i).Item__c,items.get(i).Id+' '+i,'Incorrect Item of item #'+i);
            Assert.areEqual(loans.get(i).Borrower__c,people.get(i).Id+' '+i,'Incorrect Borrower of loan #'+i);
            Assert.areEqual(loans.get(i).Status__c,Consts.LOANS.STATUS.BORROWED,'Incorrect Status of loan #'+i);
        }
    }

}