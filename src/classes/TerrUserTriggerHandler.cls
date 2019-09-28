public class TerrUserTriggerHandler {

	public static void BeforeInsert(List<TerrUser__c> users) {
		TerrUserService terrUserService = new TerrUserService();
		terrUserService.validate(users);
	}

	public static void AfterInsert(List<TerrUser__c> users) {
		TerrUserSharing terrUserSharing = new TerrUserSharing();
		terrUserSharing.init(users);
	}

	public static void BeforeUpdate(List<TerrUser__c> oldList, List<TerrUser__c> newList) {
		TerrUserService terrUserService = new TerrUserService();
		terrUserService.validate(newList);
	}

	public static void AfterUpdate(List<TerrUser__c> oldList, List<TerrUser__c> newList) {
		TerrUserSharing terrUserSharing = new TerrUserSharing();
		terrUserSharing.reInit(oldList, newList);
	}

	public static void AfterDelete(List<TerrUser__c> users) {
		TerrUserSharing terrUserSharing = new TerrUserSharing();
		terrUserSharing.removeMembers(users);
	}
}