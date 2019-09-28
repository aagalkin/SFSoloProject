trigger ReferenceTrigger on Reference__c(before insert, after insert, before update, after update, before delete, after delete) {

	if(Trigger.isInsert) {
		if(Trigger.isBefore) {
			ReferenceTriggerHandler.BeforeInsert(Trigger.new);
		}

		if(Trigger.isAfter) {
			ReferenceTriggerHandler.AfterInsert(Trigger.new);
		}
	}

	if(Trigger.isUpdate) {
		if(Trigger.isBefore) {
			ReferenceTriggerHandler.BeforeUpdate(Trigger.old, Trigger.new);
		}

		if(Trigger.isAfter) {
			ReferenceTriggerHandler.AfterUpdate(Trigger.old, Trigger.new);
		}
	}

	if(Trigger.isDelete) {
		if(Trigger.isBefore) {

		}

		if(Trigger.isAfter) {
			ReferenceTriggerHandler.AfterDelete(Trigger.old);
		}
	}
}