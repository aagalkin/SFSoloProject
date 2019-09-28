public class ReferenceSharing {

	public void init(List<Reference__c> references) {
		List<Id> accountIds = new List<Id>();
		List<Id> contactIds = new List<Id>();
		for(Reference__c ref : references) {
			accountIds.add(ref.Account__c);
			contactIds.add(ref.Contact__c);
		}
		List<AccountShare> accountShares = [SELECT AccountId, UserOrGroupId, RowCause FROM AccountShare WHERE AccountId IN :accountIds AND RowCause != 'owner' AND RowCause = 'manual'];
		List<ContactShare> contactShares = [SELECT ContactId, UserOrGroupId, RowCause FROM ContactShare WHERE ContactId IN :contactIds AND RowCause != 'owner' AND RowCause = 'manual'];
		System.debug(accountShares);
		System.debug(contactShares);

		Set<GroupMember> members = new Set<GroupMember>();

		for(Reference__c ref : references) {
			Id accountGroupId = null;
			Id contactGroupId = null;
			for(AccountShare share : accountShares) {
				if(share.AccountId == ref.Account__c) {
					accountGroupId = share.UserOrGroupId;
					break;
				}
			}

			for(ContactShare share : contactShares) {
				if(share.ContactId == ref.Contact__c) {
					contactGroupId = share.UserOrGroupId;
					break;
				}
			}
			System.debug(accountGroupId);
			System.debug(contactGroupId);

			GroupMember member = new GroupMember();
			member.GroupId = contactGroupId;
			member.UserOrGroupId = accountGroupId;
			members.add(member);
		}
		System.debug(members);
		SharingTools.saveMembers(JSON.serialize(members));
	}

	public void reInit(List<Reference__c> oldReferences, List<Reference__c> newReferences) {
		removeMembers(oldReferences);
		init(newReferences);
	}

	public void removeMembers(List<Reference__c> references) {
		List<Id> accountIds = new List<Id>();
		List<Id> contactIds = new List<Id>();
		for(Reference__c reference : references) {
			accountIds.add(reference.Account__c);
			contactIds.add(reference.Contact__c);
		}

		List<AccountShare> accountShares = [SELECT AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN :accountIds AND RowCause = 'manual'];
		List<Id> accountGroupIds = new List<Id>();

		for(AccountShare share : accountShares) {
			accountGroupIds.add(share.UserOrGroupId);
		}

		List<ContactShare> contactShares = [SELECT ContactId, UserOrGroupId FROM ContactShare WHERE ContactId IN :contactIds AND RowCause = 'manual'];
		List<Id> contactGroupIds = new List<Id>();

		for(ContactShare share : contactShares) {
			contactGroupIds.add(share.UserOrGroupId);
		}

		List<GroupMember> members = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :contactGroupIds AND UserOrGroupId IN :accountGroupIds];

		List<GroupMember> membersToDelete = new List<GroupMember>();

		for(GroupMember member : members) {
			for(Reference__c reference : references) {
				if(member.UserOrGroupId == getAccountGroupIdByAccountId(accountShares, reference.Account__c) && member.GroupId == getContactGroupIdByContactId(contactShares, reference.Contact__c)) {
					membersToDelete.add(member);
					break;
				}
			}
		}

		System.debug(members);
		SharingTools.deleteMembers(JSON.serialize(membersToDelete));
	}

	private static Id getAccountGroupIdByAccountId(List<AccountShare> shares, String parentId) {
		for(AccountShare share : shares) {
			if(share.AccountId == parentId) return share.UserOrGroupId;
		}
		return null;
	}
	private static Id getContactGroupIdByContactId(List<ContactShare> shares, String parentId) {
		for(ContactShare share : shares) {
			if(share.ContactId == parentId) return share.UserOrGroupId;
		}
		return null;
	}
}