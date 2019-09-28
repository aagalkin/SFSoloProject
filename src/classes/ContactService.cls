public class ContactService {

	public void validate(List<Contact> contacts) {
		Boolean needDummy = false;
		List<Contact> contactsWithoutDummy = new List<Contact>();
		for(Contact contact : contacts) {
			if(contact.AccountId == null) {
				needDummy = true;
				contactsWithoutDummy.add(contact);
			}
		}

		if(needDummy) {
			Account dummy = [SELECT Id FROM  Account WHERE Name = 'Dummy' LIMIT 1];
			for(Contact contact : contactsWithoutDummy) {
				contact.AccountId = dummy.Id;
			}
		}
	}
}