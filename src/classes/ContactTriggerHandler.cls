public class ContactTriggerHandler {

	public static void BeforeInsert(List<Contact> contacts) {
		ContactService contactService = new ContactService();
		contactService.validate(contacts);
	}

	public static void AfterInsert(List<Contact> newList) {
		ContactSharing contactSharing = new ContactSharing();
		contactSharing.init(newList);
	}

	public static void BeforeUpdate(List<Contact> oldList, List<Contact> newList) {
		ContactService contactService = new ContactService();
		contactService.validate(newList);
	}

	public static void AfterDelete(List<Contact> oldList) {
		ContactSharing contactSharing = new ContactSharing();
		contactSharing.onDelete(oldList);
	}
}