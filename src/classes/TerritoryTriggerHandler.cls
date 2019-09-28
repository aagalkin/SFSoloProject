public class TerritoryTriggerHandler {

	public static void BeforeInsert(List<Territory__c> territories) {

	}

	public static void AfterInsert(List<Territory__c> territories) {
		TerritoryService territoryService = new TerritoryService();
		territoryService.validate(territories);
		TerritorySharing territorySharing = new TerritorySharing();
		territorySharing.init(territories);
	}

	public static void AfterUpdate(List<Territory__c> oldList, List<Territory__c> newList) {
		TerritoryService territoryService = new TerritoryService();
		territoryService.validate(newList);
		TerritorySharing territorySharing = new TerritorySharing();
		territorySharing.reInit(oldList, newList);
	}

	public static void BeforeDelete(List<Territory__c> oldList) {
		TerritoryService territoryService = new TerritoryService();
		territoryService.RemovalPreparation(oldList);
		TerritorySharing territorySharing = new TerritorySharing();
		territorySharing.onDelete(oldList);
	}

	public static void AfterDelete(List<Territory__c> oldList) {

	}
}