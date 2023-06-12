trigger OrderTrigger on Order (before update, after update, after insert, after delete) {



    if(Trigger.isUpdate) {
        if(Trigger.isBefore) {
            OrderTriggerHandler.checkOderHasOrderItem(Trigger.new);
            OrderTriggerHandler.activateAccountField(Trigger.new);
        }
        if(Trigger.isAfter) {
            OrderTriggerHandler.deactiveAccountField(Trigger.old);
        }
    }

    if(Trigger.isInsert) {
        OrderTriggerHandler.activateAccountField(Trigger.new);
    }

    if(Trigger.isDelete) {
        OrderTriggerHandler.deactiveAccountField(Trigger.old);
    }

}