public class ReferenceService {

	public void validate(List<Reference__c> references) {
		List<Id> accIds = new List<Id>();
		List<Id> contIds = new List<Id>();
		for(Reference__c reference : references) {
			if(reference.Account__c == null || reference.Contact__c == null) {
				reference.addError('reference must have both fields');
				continue;
			}

			accIds.add(reference.Account__c);
			contIds.add(reference.Contact__c);
		}

		List<Reference__c> checkDuplicateList = [SELECT Account__c, Contact__c FROM Reference__c WHERE Account__c IN :accIds AND Contact__c IN :contIds];
		for(Reference__c ref : checkDuplicateList) {
			for(Reference__c r : references) {
				if(ref.Account__c == r.Account__c && ref.Contact__c == r.Contact__c) {
					r.addError('this contact is already tied on that territory');
				}
			}
		}
	}
}