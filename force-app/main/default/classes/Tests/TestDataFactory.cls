/**
 * Created by kamil on 15.07.2023.
 */
@isTest
public with sharing class TestDataFactory {
    public static List<Item__c> createItemsList(Integer numberOfItems,Boolean insertData,String itemNamePrefix, String itemType,String itemGenre){
        List<Item__c> items = new List<Item__c>();

        for (Integer i = 0; i<numberOfItems;i++){
            items.add(new Item__c(Name = itemNamePrefix+' '+i,Type__c = itemType,Genre__c = itemGenre));
        }
        if(insertData)
            insert items;
        return items;
    }

    public static List<Person__c> createPeopleList(Integer numberOfPeople,Boolean insertData,String NamePrefix,String emailPrefix,Integer maxRentals){
        List<Person__c> people = new List<Person__c>();

        for (Integer i = 0; i<numberOfPeople;i++){
            people.add(new Person__c(Name = NamePrefix+' '+i,Last_Name__c = 'Borrower',Email__c = emailPrefix+i+'@gmail.com',Maximum_Number_Of_Rentals__c = maxRentals));
        }
        if(insertData)
            insert people;
        return people;
    }

    public static List<Loan__c> createLoansList(Integer numberOfLoans,Boolean insertData,List<Item__c> items,List<Person__c> people,Date rentalDate,Date endOfRental,String status){
        if((items.size()!=people.size()) || numberOfLoans > items.size()) {
            return null;
        }

        List<Loan__c> loans = new List<Loan__c>();

        for (Integer i = 0; i<numberOfLoans;i++){
            loans.add(new Loan__c(Item__c = items.get(i).Id,Borrower__c = people.get(i).Id,Rental_Date__c = rentalDate,End_Of_Rental__c = endOfRental, Status__c = status));
        }
        if(insertData)
            insert loans;
        return loans;
    }

    public static List<Supplier__c> createSuppliersList(Integer numberOfItems,Boolean insertData,String supplierNamePrefix){
        List<Supplier__c> suppliers = new List<Supplier__c>();

        for (Integer i = 0; i<numberOfItems;i++){
            suppliers.add(new Supplier__c(Name = supplierNamePrefix+' '+i));
        }
        if(insertData)
            insert suppliers;
        return suppliers;
    }



}