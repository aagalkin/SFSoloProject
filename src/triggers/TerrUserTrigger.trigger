trigger TerrUserTrigger on TerrUser__c(before insert, after insert, before update, after update, before delete, after delete) {

	if(Trigger.isInsert) {
		if(Trigger.isBefore) {
			TerrUserTriggerHandler.BeforeInsert(Trigger.new);
		}

		if(Trigger.isAfter) {
			TerrUserTriggerHandler.AfterInsert(Trigger.new);
		}
	}

	if(Trigger.isUpdate) {
		if(Trigger.isBefore) {
			TerrUserTriggerHandler.BeforeUpdate(Trigger.old, Trigger.new);
		}

		if(Trigger.isAfter) {
			TerrUserTriggerHandler.AfterUpdate(Trigger.old, Trigger.new);
		}
	}

	if(Trigger.isDelete) {
		if(Trigger.isAfter) {
			TerrUserTriggerHandler.AfterDelete(Trigger.old);
		}
	}
}