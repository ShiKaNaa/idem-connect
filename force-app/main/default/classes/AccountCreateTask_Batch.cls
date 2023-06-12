/**
 * @description       : Batch class to process Accounts that don't have related Order and no Tasks to remind Owners to call Account
 * 
 * @author            : Raphaël HOUDRY
 * @last modified on  : 09/06/23
**/
global with sharing class AccountCreateTask_Batch implements Database.Batchable<sObject> {
 

    // Return Accounts that are not Activated (that don't have an Order), and check if there is a related Task with Subject == Call
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [SELECT Id, OwnerId, 
            (SELECT Id FROM Tasks WHERE Subject = 'Call' LIMIT 1) 
             FROM Account WHERE Active__c = false]
            );
    }

    // For each Account without a call Task and without an Order, create a new Task and assign it to Account owner
    global void execute(Database.BatchableContext bc, List<Account> scope) {
        List<Task> taskList = new List<Task>();
        Date datePlusFiveDays = Date.today().addDays(5);

        for (Account acc : scope) {
            if(acc.Tasks.size() == 0) {
                Task tsk = new Task(
                    OwnerId = acc.OwnerId,
                    WhatId = acc.Id,
                    Subject = 'Call',
                    Status = 'New',
                    Priority = 'Normal',
                    IsReminderSet = true,
                    ReminderDateTime = datePlusFiveDays
                );
                taskList.add(tsk);
            }
        }
        insert taskList;
    }

    // No finish method to execute
    global void finish(Database.BatchableContext bc) {
        // No finish
    }

}