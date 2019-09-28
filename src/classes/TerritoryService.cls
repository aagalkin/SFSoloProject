public class TerritoryService {

	public void RemovalPreparation(List<Territory__c> territories) {
		List<Territory__c> allChildren = [SELECT Id, ParentTerritory__c FROM Territory__c WHERE ParentTerritory__c IN :territories];
		for(Territory__c territory : territories) {
			List<Territory__c> currentTerritoryChildren = new List<Territory__c>();
			for(Territory__c childTerritory : allChildren) {
				if(childTerritory.ParentTerritory__c == territory.Id) {
					currentTerritoryChildren.add(childTerritory);
				}
			}
			System.debug(currentTerritoryChildren);
			if(!currentTerritoryChildren.isEmpty()) {
				territory.addError('cannot delete territory with child territories');
			}
		}
	}

	public void validate(List<Territory__c> territories) {

		String error = 'name already exists at this hierarchy level';

		Set<Id> parentIds = new Set<Id>();
		Boolean withoutParent = false;
		List<Territory__c> territoriesWithoutParent = new List<Territory__c>();
		for(Territory__c territory : territories) {
			if(territory.ParentTerritory__c == null) {
				territoriesWithoutParent.add(territory);
				withoutParent = true;
				continue;
			}
			if(!parentIds.contains(territory.ParentTerritory__c)) {
				parentIds.add(territory.ParentTerritory__c);
			}
		}

		List<Territory__c> parentTerritories = [SELECT Id, Name, (SELECT Name FROM ChildTerritories__r) FROM Territory__c WHERE Id IN :parentIds];

		for(Territory__c territory : territories) {
			for(Territory__c parentTerritory : parentTerritories) {
				if(territory.ParentTerritory__c == parentTerritory.Id) {
					for(Territory__c childTerritory : parentTerritory.ChildTerritories__r) {
						if(territory.Name == childTerritory.Name && territory.Id != childTerritory.Id) {
							territory.addError(error);
							break;
						}
					}
					break;
				}
			}
		}

		if(withoutParent) {
			territories = [SELECT Name FROM Territory__c WHERE ParentTerritory__c = null];
			for(Territory__c territory : territoriesWithoutParent) {
				for(Territory__c terr : territories) {
					if(terr.Id != territory.Id && terr.Name == territory.Name) {
						territory.addError(error);
						break;
					}
				}
			}

		}
	}
}