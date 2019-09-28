public class TerritorySharing {

	public void init(List<Territory__c> territories) {

		List<Id> ParentTerritoryIds = new List<Id>();

		List<Group> groups = new List<Group>();
		for(Territory__c territory : territories) {
			System.debug(territory.ParentTerritory__c);
			ParentTerritoryIds.add(territory.ParentTerritory__c);
			groups.add(new Group(Name = territory.Name + ' group'));
		}
		insert groups;

		List<Territory__Share> shares = new List<Territory__Share>();
		List<GroupMember> members = new List<GroupMember>();
		List<Territory__Share> ParentShares = null;

		System.debug(ParentTerritoryIds);

		if(!ParentTerritoryIds.isEmpty()) {
			ParentShares = new List<Territory__Share>([SELECT parentId, UserOrGroupId FROM Territory__Share WHERE parentId IN :ParentTerritoryIds AND RowCause != 'owner']);
		}
		System.debug(ParentShares);

		for(Integer i = 0; i < territories.size(); i++) {

			Territory__Share share = new Territory__Share();
			share.parentId = territories[i].Id;
			share.UserOrGroupId = groups[i].Id;
			share.AccessLevel = 'edit';
			shares.add(share);

			//bind to parent
			if(territories[i].ParentTerritory__c != null) {
				System.debug(territories[i].Name + ' have a parent!');
				GroupMember parentGroup = new GroupMember();
				Territory__Share parentShare = null;
				System.debug('parent territory id is: ' + territories[i].ParentTerritory__c);
				for(Territory__Share s : ParentShares) {
					System.debug('share parentId is: ' + s.parentId);
					if(s.parentId == territories[i].ParentTerritory__c) {
						System.debug('find!');
						parentShare = s;
						break;
					}
				}
				parentGroup.GroupId = groups[i].Id;
				parentGroup.UserOrGroupId = parentShare.UserOrGroupId;
				members.add(parentGroup);
			}
		}
		if(!members.isEmpty()) {
			SharingTools.saveMembers(JSON.serialize(members));
		}
		insert shares;
	}

	public void reInit(List<Territory__c> oldList, List<Territory__c> newList) {
		List<Territory__c> oldUpdateList = new List<Territory__c>();
		List<Territory__c> newUpdatedList = new List<Territory__c>();
		for(Integer i = 0; i < oldList.size(); i++) {
			System.debug(oldList.get(i).ParentTerritory__c);
			System.debug(newList.get(i).ParentTerritory__c);
			if(oldList.get(i).ParentTerritory__c != newList.get(i).ParentTerritory__c) {
				oldUpdateList.add(oldList.get(i));
				newUpdatedList.add(newList.get(i));
			}
		}
		System.debug('list size: ' + oldUpdateList.size());
		if(!oldUpdateList.isEmpty()) {
			removeParentGroupMembers(oldUpdateList);
			bindToParent(newUpdatedList);
		}
	}

	public void onDelete(List<Territory__c> territories) {
		removeParentGroupMembers(territories);
		List<Territory__Share> shares = [SELECT Id, UserOrGroupId FROM Territory__Share WHERE parentId IN :territories AND RowCause != 'owner'];
		List<Id> groupIds = new List<Id>();
		for(Territory__Share share : shares) {
			groupIds.add(share.UserOrGroupId);
		}
		List<Group> groups = [SELECT Id, Name FROM Group WHERE Id IN :groupIds];
		System.debug(groups);
		SharingTools.deleteGroups(JSON.serialize(groups));
	}

	private void removeParentGroupMembers(List<Territory__c> territories) {
		System.debug('remove parent members begin');
		List<Territory__c> territoriesWithoutNullParents = new List<Territory__c>();
		for(Territory__c terr : territories) if(terr.ParentTerritory__c != null) territoriesWithoutNullParents.add(terr);
		territories = territoriesWithoutNullParents;
		if(territories.isEmpty()) return;

		Set<Id> terrIds = new Set<Id>();
		Set<Id> myIds = new Set<Id>();
		Set<Id> parentIds = new Set<Id>();
		for(Territory__c terr : territories) {
			if(!terrIds.contains(terr.ParentTerritory__c)) terrIds.add(terr.ParentTerritory__c);
			if(!myIds.contains(terr.id)) myIds.add(terr.Id);
			if(!terrIds.contains(terr.Id))terrIds.add(terr.Id);
			if(!parentIds.contains(terr.ParentTerritory__c)) parentIds.add(terr.ParentTerritory__c);
		}
		List<Territory__Share> shares = [SELECT Id, UserOrGroupId, parentId FROM Territory__Share WHERE parentId IN :terrIds AND RowCause != 'owner'];
		System.debug(shares);

		List<Territory__Share> myShares = new List<Territory__Share>();
		List<Territory__Share> parentShares = new List<Territory__Share>();

		List<GroupMember> tmpMembers = new List<GroupMember>();
		List<Id> myGroupIds = new List<Id>();
		List<Id> parentGroupIds = new List<Id>();

		for(Territory__Share share : shares) {
			if(parentIds.contains(share.parentId) && !parentShares.contains(share)) parentShares.add(share);
			if(myIds.contains(share.parentId) && !myShares.contains(share)) myShares.add(share);
		}

		System.debug(myShares);
		System.debug(parentShares);

		for(Territory__c territory : territories) {
			Id groupId = null;
			Id userOrGroupId = null;
			for(Territory__Share myShare : myShares) {
				if(myShare.parentId == territory.Id) {
					groupId = myShare.UserOrGroupId;
					break;
				}
			}
			for(Territory__Share parentShare : parentShares) {
				if(parentShare.parentId == territory.ParentTerritory__c) {
					userOrGroupId = parentShare.UserOrGroupId;
					break;
				}
			}
			tmpMembers.add(new GroupMember(GroupId = groupId, UserOrGroupId = userOrGroupId));
			myGroupIds.add(groupId);
			parentGroupIds.add(userOrGroupId);
		}

		System.debug(myGroupIds);
		System.debug(parentGroupIds);

		List<GroupMember> members = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :myGroupIds AND UserOrGroupId IN :parentGroupIds];
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

	private void bindToParent(List<Territory__c> territories) {
		List<Territory__c> territoriesWithoutNullParents = new List<Territory__c>();
		for(Territory__c terr : territories) if(terr.ParentTerritory__c != null) territoriesWithoutNullParents.add(terr);
		territories = territoriesWithoutNullParents;
		if(territories.isEmpty()) return;

		Set<Id> terrIds = new Set<Id>();
		Set<Id> myIds = new Set<Id>();
		Set<Id> parentIds = new Set<Id>();
		for(Territory__c terr : territories) {
			if(!terrIds.contains(terr.ParentTerritory__c)) terrIds.add(terr.ParentTerritory__c);
			if(!myIds.contains(terr.id)) myIds.add(terr.Id);
			if(!terrIds.contains(terr.Id))terrIds.add(terr.Id);
			if(!parentIds.contains(terr.ParentTerritory__c)) parentIds.add(terr.ParentTerritory__c);
		}
		List<Territory__Share> shares = [SELECT Id, UserOrGroupId, parentId FROM Territory__Share WHERE parentId IN :terrIds AND RowCause != 'owner'];
		System.debug(shares);

		List<Territory__Share> myShares = new List<Territory__Share>();
		List<Territory__Share> parentShares = new List<Territory__Share>();

		List<GroupMember> members = new List<GroupMember>();

		for(Territory__Share share : shares) {
			if(parentIds.contains(share.parentId) && !parentShares.contains(share)) parentShares.add(share);
			if(myIds.contains(share.parentId) && !myShares.contains(share)) myShares.add(share);
		}

		System.debug(myShares);
		System.debug(parentShares);

		for(Territory__c territory : territories) {
			Id groupId = null;
			Id parentGroupId = null;

			for(Territory__Share myShare : myShares) {
				if(territory.id == myShare.parentId) {
					groupId = myShare.UserOrGroupId;
					break;
				}
			}
			for(Territory__Share parentShare : parentShares) {
				if(territory.ParentTerritory__c == parentShare.parentId) {
					parentGroupId = parentShare.UserOrGroupId;
					break;
				}
			}
			members.add(new GroupMember(GroupId = groupId, UserOrGroupId = parentGroupId));
		}

		SharingTools.saveMembers(JSON.serialize(members));
	}
}