public class ContactSharing {

	public void init(List<Contact> contacts) {
		List<Group> groups = new List<Group>();
		for(Contact contact : contacts) {
			groups.add(new Group(Name = contact.LastName + ' contact group'));
		}
		insert groups;

		List<ContactShare> contactShares = new List<ContactShare>();
		for(Integer i = 0; i < contacts.size(); i++) {
			contactShares.add(new ContactShare(ContactId = contacts[i].Id, UserOrGroupId = groups[i].Id, ContactAccessLevel ='edit'));
		}
		insert contactShares;
	}

	public void onDelete(List<Contact> contacts) {
		List<Reference__c> references = [SELECT Id FROM Reference__c WHERE Contact__c IN :contacts];
		delete references;
		List<ContactShare> shares = [SELECT UserOrGroupId FROM ContactShare WHERE ContactId IN :contacts AND RowCause = 'manual'];
		List<Id> groupIds = new List<Id>();
		for(ContactShare share : shares) {
			groupIds.add(share.UserOrGroupId);
		}
		List<Group> groups = [SELECT Id FROM Group WHERE Id IN :groupIds];
		SharingTools.deleteGroups(JSON.serialize(groups));
	}

}