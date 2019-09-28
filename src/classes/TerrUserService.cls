public class TerrUserService {

	public void validate(List<TerrUser__c> users) {

		List<Id> terrIds = new List<Id>();
		List<Id> userIds = new List<Id>();
		for(TerrUser__c tu : users) {
			if(tu.User__c == null || tu.Territory__c == null) {
				tu.addError('territory and user fields are required!');
				continue;
			}
			terrIds.add(tu.Territory__c);
			userIds.add(tu.User__c);
		}
		List<TerrUser__c> checkDuplicateList = [SELECT Territory__c, User__c FROM TerrUser__c WHERE Territory__c IN :terrIds AND User__c IN :userIds];
		for(TerrUser__c tu : checkDuplicateList) {
			for(TerrUser__c u : users) {
				if(tu.User__c == u.User__c && tu.Territory__c == u.Territory__c) {
					u.addError('this user is already exist on that territory');
				}
			}
		}
	}
}