/**
 * Created by kamil on 04.08.2023.
 */
@IsTest
public with sharing class GenerateNewPinControllerTest {
  @IsTest
  public static void generateNewPinTest() {
    List<Person__c> person = TestDataFactory.createPeopleList(
      1,
      true,
      'Test',
      'testemail',
      3
    );
    String oldPin = person.get(0).Encrypted_PIN__c;

    Test.startTest();
    GenerateNewPinController.generateNewPin(person.get(0).Id);
    Test.stopTest();

    person = [
      SELECT Id, Encrypted_PIN__c
      FROM Person__c
      WHERE Id = :person.get(0).Id
    ];

    Assert.areNotEqual(oldPin, person.get(0).Encrypted_PIN__c);
  }
}
