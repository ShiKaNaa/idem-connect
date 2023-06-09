public with sharing class AddTaskToAccount_Scheduler implements Schedulable {

    global void execute(SchedulableContext ctx) {
        AccountCreateTask_Batch accountsBatch = new AccountCreateTask_Batch();
        Database.executeBatch(accountsBatch);
    }
}