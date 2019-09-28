trigger AccountTrigger on Account (before insert, after insert, before update, after update, before delete, after delete) {
    if(Trigger.isInsert) {
        if(Trigger.isBefore) {
            AccountTriggerHandler.BeforeInsert(Trigger.new);
        }
        
        if(Trigger.isAfter) {
            AccountTriggerHandler.AfterInsert(Trigger.new);
        }
    }

    if(Trigger.isUpdate) {
        if(Trigger.isBefore) {
            AccountTriggerHandler.BeforeUpdate(Trigger.old, Trigger.new);
        }

        if(Trigger.isAfter) {
            AccountTriggerHandler.AfterUpdate(Trigger.old, Trigger.new);
        }
    }

    if(Trigger.isDelete) {
        if(Trigger.isBefore) {

        }

        if(Trigger.isAfter) {
            AccountTriggerHandler.AfterDelete(Trigger.old);
        }
    }
}