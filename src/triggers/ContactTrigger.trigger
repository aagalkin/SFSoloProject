trigger ContactTrigger on Contact(before insert, after insert, before delete, after delete) {

	if(Trigger.isInsert) {

		if(Trigger.isBefore) {
			ContactTriggerHandler.BeforeInsert(Trigger.new);
		}

		if(Trigger.isAfter) {
			ContactTriggerHandler.AfterInsert(Trigger.new);
		}
	}

	if(Trigger.isUpdate) {
		if(Trigger.isBefore) {
			ContactTriggerHandler.BeforeUpdate(Trigger.old, Trigger.new);
		}
	}

	if(Trigger.isDelete) {
		if(Trigger.isAfter) {
			ContactTriggerHandler.AfterDelete(Trigger.old);
		}
	}
}