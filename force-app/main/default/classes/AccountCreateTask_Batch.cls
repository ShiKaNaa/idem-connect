/**
 * @description       : batch qui récupère les comptes n’ayant pas d’order associés ni des tâches de rappel 
 * et crée des tâches et les rattachent à ce compte.
 * @author            : Raphaël HOUDRY
 * @last modified on  : 09/06/23
**/
public with sharing class AccountCreateTask_Batch implements Database.Batchable<sObject> {
 

    // Return Accounts that are not Activated (that don't have an Order), and check if there is a related Task with Subject == Call
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [SELECT Id, OwnerId, 
            (SELECT Id FROM Tasks WHERE Subject = 'Call' LIMIT 1) 
             FROM Account WHERE Active__c = false]
            );
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        List<Task> tastList = new List<Task>();

        for (Account acc : scope) {
            if(acc.Tasks.size() == 0) {
                Task tsk = new Task(
                    OwnerId = acc.OwnerId,
                    WhatId = acc.Id,
                    Subject = 'Call',
                    Status = 'Nouvelle',
                    Priority = 'Normale',
                    IsReminderSet = true,
                    ReminderDateTime = System.now() + 5
                );
                tastList.add(tsk);
            }
        }
        insert tastList;
    }

    global void finish() {
        // No finish
    }

}