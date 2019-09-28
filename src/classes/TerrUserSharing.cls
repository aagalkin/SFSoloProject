public class TerrUserSharing {

	public void init(List<TerrUser__c> newList) {

		List<Id> parentIds = new List<Id>();
		for(TerrUser__c u : newList) {
			parentIds.add(u.Territory__c);
		}
		List<Territory__Share> parentShares = [SELECT parentId, UserOrGroupId, RowCause FROM Territory__Share WHERE parentId IN :parentIds AND RowCause != 'owner'];

		Set<GroupMember> members = new Set<GroupMember>();

		for(TerrUser__c u : newList) {
			Id parentGroupId = null;
			for(Territory__Share share : parentShares) {
				if(share.parentId == u.Territory__c) {
					parentGroupId = share.UserOrGroupId;
					break;
				}
			}

			System.debug(u.User__c);
			System.debug(parentGroupId);
			GroupMember member = new GroupMember();
			member.GroupId = parentGroupId;
			member.UserOrGroupId = u.User__c;
			members.add(member);
		}

		SharingTools.saveMembers(JSON.serialize(members));
	}

	public void removeMembers(List<TerrUser__c> terrUserList) {
		List<Id> terrIds = new List<Id>();
		List<Id> userIds = new List<Id>();
		for(TerrUser__c user : terrUserList) {
			terrIds.add(user.Territory__c);
			userIds.add(user.User__c);
		}

		List<Territory__Share> shares = [SELECT parentId, UserOrGroupId FROM Territory__Share WHERE parentId IN :terrIds AND RowCause != 'owner'];
		List<Id> parentGroupIds = new List<Id>();

		for(Territory__Share share : shares) {
			parentGroupIds.add(share.UserOrGroupId);
		}

		System.debug(parentGroupIds);
		System.debug(userIds);
		List<GroupMember> members = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :parentGroupIds AND UserOrGroupId IN :userIds];

		List<GroupMember> membersToDelete = new List<GroupMember>();

		for(GroupMember member : members) {
			for(TerrUser__c tu : terrUserList) {
				if(member.UserOrGroupId == tu.User__c && member.GroupId == getGroupIdByParentId(shares, tu.Territory__c)) {
					membersToDelete.add(member);
					break;
				}
			}
		}

		System.debug(members);
		SharingTools.deleteMembers(JSON.serialize(membersToDelete));
	}

	public void reInit(List<TerrUser__c> oldList, List<TerrUser__c> newList) {
		removeMembers(oldList);
		init(newList);
	}

	private static Id getGroupIdByParentId(List<Territory__Share> shares, String parentId) {
		for(Territory__Share share : shares) {
			if(share.parentId == parentId) return share.UserOrGroupId;
		}
		return null;
	}
}