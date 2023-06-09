trigger OrderTrigger on Order (before update, after update, after insert, after delete) {


    // Check if order has order item
    if(Trigger.isUpdate) {
        if(Trigger.isBefore) {
            OrderTriggerHandler.checkOderHasOrderItem(Trigger.new);
            OrderTriggerHandler.activateAccountField(Trigger.new);
        }
        if(Trigger.isAfter) {
            OrderTriggerHandler.deactiveAccountField(Trigger.old);
        }
    }

    // Activate Account.Active_c 
    if(Trigger.isInsert) {
        OrderTriggerHandler.activateAccountField(Trigger.new);
    }

    // Deactivate Account.Active_c if there are no more related Order
    if(Trigger.isDelete) {
        OrderTriggerHandler.deactiveAccountField(Trigger.old);
    }

}