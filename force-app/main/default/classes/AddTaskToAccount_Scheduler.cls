/**
 * @description Schedulable class for batch process
 * @author Raphaël HOUDRY
 * @last modified 12-06-2023
 */
global with sharing class AddTaskToAccount_Scheduler implements Schedulable {

    /**
     * Execute batch AccountCreateTask_Batch 
     * 
     * @param ctx => SchedulableContext (https://developer.salesforce.com/forums/?id=906F0000000BKExIAO)
     * @return void
     */
    global void execute(SchedulableContext ctx) {
        AccountCreateTask_Batch accountsBatch = new AccountCreateTask_Batch();
        Database.executeBatch(accountsBatch);
    }
}