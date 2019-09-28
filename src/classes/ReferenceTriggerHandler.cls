public class ReferenceTriggerHandler {

	public static void BeforeInsert(List<Reference__c> newList) {
		ReferenceService referenceService = new ReferenceService();
		referenceService.validate(newList);
	}

	public static void AfterInsert(List<Reference__c> newList) {
		ReferenceSharing referenceSharing = new ReferenceSharing();
		referenceSharing.init(newList);
	}

	public static void BeforeUpdate(List<Reference__c> oldReferences, List<Reference__c> newReferences) {
		ReferenceService referenceService = new ReferenceService();
		referenceService.validate(newReferences);
	}

	public static void AfterUpdate(List<Reference__c> oldReferences, List<Reference__c> newReferences) {
		ReferenceSharing referenceSharing = new ReferenceSharing();
		referenceSharing.reInit(oldReferences, newReferences);
	}

	public static void AfterDelete(List<Reference__c> oldReferences) {
		ReferenceSharing referenceSharing = new ReferenceSharing();
		referenceSharing.removeMembers(oldReferences);
	}
}