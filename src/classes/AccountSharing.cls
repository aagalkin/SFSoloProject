public class AccountSharing {

	public void init(List<Account> accounts) {

		List<Group> groups = new List<Group>();
		for(Account a : accounts) {
			groups.add(new Group(Name = a.Name + ' account group'));
		}
		insert groups;

		List<AccountShare> accountShares = new List<AccountShare>();

		Set<Id> territoryIds = new Set<Id>();
		for(Account account : accounts) {
			if(!territoryIds.contains(account.Territory__c)) {
				territoryIds.add(account.Territory__c);
			}
		}

		List<Territory__Share> shares = [SELECT parentId, UserOrGroupId, RowCause FROM Territory__Share WHERE parentId IN :territoryIds AND RowCause != 'owner'];

		List<GroupMember> members = new List<GroupMember>();

		for(Integer i = 0; i < accounts.size(); i++) {
			AccountShare share = new AccountShare();
			share.AccountId = accounts[i].Id;
			share.AccountAccessLevel = 'edit';
			share.OpportunityAccessLevel = 'edit';
			share.UserOrGroupId = groups[i].Id;
			accountShares.add(share);

			Id parentTerritoryGroupId = null;
			for(Territory__Share parentShare : shares) {
				if(parentShare.parentId == accounts[i].Territory__c) {
					parentTerritoryGroupId = parentShare.UserOrGroupId;
					break;
				}
			}

			GroupMember member = new GroupMember();
			member.GroupId = groups[i].Id;
			member.UserOrGroupId = parentTerritoryGroupId;
			members.add(member);
		}
		insert accountShares;

		if(!members.isEmpty()) {
			SharingTools.saveMembers(JSON.serialize(members));
		}
	}

	public void reInit(List<Account> oldList, List<Account> newList) {
		List<Account> oldUpdateList = new List<Account>();
		List<Account> newUpdateList = new List<Account>();
		for(Integer i = 0; i < oldList.size(); i++) {
			if(oldList.get(i).Territory__c != newList.get(i).Territory__c) {
				oldUpdateList.add(oldList.get(i));
				newUpdateList.add(newList.get(i));
			}
		}
		if(!oldUpdateList.isEmpty()) {
			removeTerritoryMember(oldUpdateList);
			bindNewTerritoryMember(newUpdateList);
		}
	}

	public void onDelete(List<Account> accounts) {
		removeTerritoryMember(accounts);
		deleteReferences(accounts);
		List<AccountShare> shares = [SELECT UserOrGroupId FROM AccountShare WHERE AccountId IN :accounts];
		List<Id> groupIds = new List<Id>();
		for(AccountShare share : shares) {
			groupIds.add(share.UserOrGroupId);
		}
		List<Group> groups = [SELECT Id FROM Group WHERE Id IN :groupIds];
		SharingTools.deleteGroups(JSON.serialize(groups));
	}

	private void removeTerritoryMember(List<Account> accounts) {
		List<AccountShare> accountShares = [SELECT AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN :accounts AND RowCause = 'manual'];
		List<Id> territoryIds = new List<Id>();
		for(Account account : accounts) {
			territoryIds.add(account.Territory__c);
		}
		List<Territory__Share> terrShares = [SELECT parentId, UserOrGroupId FROM Territory__Share WHERE parentId IN : territoryIds AND RowCause != 'owner'];

		List<GroupMember> tmpMembers = new List<GroupMember>();
		List<Id> accountGroupIds = new List<Id>();
		List<Id> terrGroupIds = new List<Id>();

		for(Account account : accounts) {
			Id groupId = null;
			Id userOrGroupId = null;
			for(AccountShare accountShare : accountShares) {
				if(accountShare.AccountId == account.Id) {
					groupId = accountShare.UserOrGroupId;
					break;
				}
			}
			for(Territory__Share terrShare : terrShares) {
				if(terrShare.parentId == account.Territory__c) {
					userOrGroupId = terrShare.UserOrGroupId;
					break;
				}
			}
			tmpMembers.add(new GroupMember(GroupId = groupId, UserOrGroupId = userOrGroupId));
			accountGroupIds.add(groupId);
			terrGroupIds.add(userOrGroupId);
		}

		List<GroupMember> members = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :accountGroupIds AND UserOrGroupId IN :terrGroupIds];
		System.debug(members);

		List<GroupMember> membersToDelete = new List<GroupMember>();
		for(GroupMember tmpMember : tmpMembers) {
			for(GroupMember member : members) {
				if(tmpMember.GroupId == member.GroupId && tmpMember.UserOrGroupId == member.UserOrGroupId) {
					membersToDelete.add(member);
					break;
				}
			}
		}
		System.debug(membersToDelete);
		SharingTools.deleteMembers(JSON.serialize(membersToDelete));
	}

	private void bindNewTerritoryMember(List<Account> accounts){
		List<AccountShare> accountShares = [SELECT AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN :accounts AND RowCause = 'manual'];
		List<Id> terrIds = new List<Id>();
		for(Account account : accounts) {
			terrIds.add(account.Territory__c);
		}
		List<Territory__Share> terrShares = [SELECT parentId, UserOrGroupId FROM Territory__Share WHERE parentId IN :terrIds AND RowCause = 'manual'];

		List<GroupMember> members = new List<GroupMember>();

		for(Account account : accounts) {
			Id groupId = null;
			Id terrGroupId = null;

			for(AccountShare share : accountShares) {
				if(share.AccountId == account.Id) {
					groupId = share.UserOrGroupId;
					break;
				}
			}

			for(Territory__Share share : terrShares) {
				if(share.parentId == account.Territory__c) {
					terrGroupId = share.UserOrGroupId;
					break;
				}
			}

			members.add(new GroupMember(GroupId = groupId, UserOrGroupId = terrGroupId));
		}
		SharingTools.saveMembers(JSON.serialize(members));
	}

	private void deleteReferences(List<Account> oldAccounts) {
		List<Reference__c> references = [SELECT Id FROM Reference__c WHERE Account__c IN :oldAccounts];
		delete references;
	}
}