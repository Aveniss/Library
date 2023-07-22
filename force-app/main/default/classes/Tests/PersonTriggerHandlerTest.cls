/**
 * Created by kamil on 22.07.2023.
 */
@IsTest
public with sharing class PersonTriggerHandlerTest {
  private static final Integer NUMBER_OF_DATA = 5;
  private static final String EMAIL_PREFIX = 'testemail';

  @TestSetup
  private static void insertBasicData() {
    TestDataFactory.createPeopleList(
      NUMBER_OF_DATA,
      true,
      'Test',
      EMAIL_PREFIX,
      3
    );
  }

  @isTest
  static void testCheckEmailAvailabilityEmailAvailable() {
    List<Person__c> people = TestDataFactory.createPeopleList(
      NUMBER_OF_DATA,
      true,
      'Test',
      'ABC',
      3
    );

    for (Person__c person : people) {
      System.assertEquals(
        0,
        person.getErrors().size(),
        'Email should be available'
      );
    }
  }

  @isTest
  static void testCheckEmailAvailabilityEmailUnavailable() {
    List<Person__c> people = TestDataFactory.createPeopleList(
      NUMBER_OF_DATA,
      false,
      'Test',
      EMAIL_PREFIX,
      3
    );

    Test.startTest();
    PersonTriggerHandler.checkEmailAvailability(people);
    Test.stopTest();

    for (Person__c person : people) {
      System.assertEquals(
        System.Label.UnavailableEmail,
        people[1].getErrors()[0].getMessage(),
        'Error message should be "This email is already taken" for unavailable email'
      );
    }
  }
}
