trigger TerritoryTrigger on Territory__c(before insert, after insert, before update, after update, before delete, after delete) {

	if (Trigger.isInsert) {
		if(Trigger.isBefore) {
			TerritoryTriggerHandler.BeforeInsert(Trigger.new);
		}

		if(Trigger.isAfter) {
			TerritoryTriggerHandler.AfterInsert(Trigger.new);
		}
	}

	if (Trigger.isUpdate) {
		if(Trigger.isBefore) {

		}

		if(Trigger.isAfter) {
			TerritoryTriggerHandler.AfterUpdate(Trigger.old, Trigger.new);
		}
	}

	if(Trigger.isDelete) {
		if(Trigger.isBefore) {
			TerritoryTriggerHandler.BeforeDelete(Trigger.old);
		}

		if(Trigger.isAfter) {
			TerritoryTriggerHandler.AfterDelete(Trigger.old);
		}

	}
}