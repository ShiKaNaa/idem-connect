@isTest
public with sharing class AccountCreateTask_BatchTest {

    // Test class for Batch

    @TestSetup
    static void makeData(){
        List<Account> accList = TestDataFactory.generateAccountsList(1);
    }

    @isTest
    public static void addTaskToAccountOwner() {
        // Arrange
        Account accWithoutTask = [SELECT Id, OwnerId, (SELECT OwnerId, Subject, Status, Priority, ReminderDateTime FROM Tasks) FROM Account LIMIT 1];
        AccountCreateTask_Batch accountTaskBatchTest = new AccountCreateTask_Batch();
        Date datePlusFiveDays = Date.today().addDays(5);
        Task expectedTask = new Task(
            OwnerId = accWithoutTask.OwnerId,
            WhatId = accWithoutTask.Id,
            Subject = 'Call',
            Status = 'New',
            Priority = 'Normal',
            IsReminderSet = true,
            ReminderDateTime = datePlusFiveDays
        );

        // Act
        Test.startTest();
        Id batchId = Database.executeBatch(accountTaskBatchTest);
        Test.stopTest();

        // Assert
        Account accWithTaskFromBatch = [SELECT Id, (SELECT OwnerId, Subject, Status, Priority, ReminderDateTime FROM Tasks) FROM Account WHERE Id = :accWithoutTask.Id LIMIT 1];
        System.assertNotEquals(accWithoutTask.Tasks.size(), accWithTaskFromBatch.Tasks.size());
        System.assertEquals(expectedTask.OwnerId, accWithTaskFromBatch.Tasks[0].OwnerId);
        System.assertEquals(expectedTask.ReminderDateTime, accWithTaskFromBatch.Tasks[0].ReminderDateTime);
    }

    @isTest
    public static void accountAlreadyHasTaskWithCall() {
        // Arrange
        AccountCreateTask_Batch accountTaskBatchTest = new AccountCreateTask_Batch();
        Account accWithTask = [SELECT Id, OwnerId, (SELECT OwnerId, Subject, Status, Priority, ReminderDateTime FROM Tasks) FROM Account LIMIT 1];
        Date datePlusFiveDays = Date.today().addDays(5);
        Task expectedTask = new Task(
            OwnerId = accWithTask.OwnerId,
            WhatId = accWithTask.Id,
            Subject = 'Call',
            Status = 'New',
            Priority = 'Normal',
            IsReminderSet = true,
            ReminderDateTime = datePlusFiveDays
        );
        insert expectedTask;

        // Act
        Test.startTest();
        Id batchId = Database.executeBatch(accountTaskBatchTest);
        Test.stopTest();

        // Assert
        accWithTask = [SELECT Id, OwnerId, (SELECT OwnerId, Subject, Status, Priority, ReminderDateTime FROM Tasks) FROM Account LIMIT 1];
        System.assertEquals(1, accWithTask.Tasks.size());
    }

}