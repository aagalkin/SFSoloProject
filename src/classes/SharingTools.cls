public class SharingTools {
	@future
	public static void saveMembers(String members) {
		System.debug(members);
		List<GroupMember> memberList = (List<GroupMember>)JSON.deserializeStrict(members, List<GroupMember>.class);
		System.debug(memberList);
		insert memberList;
	}

	@Future
	public static void deleteMembers(String members) {
		System.debug(members);
		List<GroupMember> memberList = (List<GroupMember>)JSON.deserializeStrict(members, List<GroupMember>.class);
		System.debug(memberList);
		delete memberList;
	}

	@Future
	public static void deleteGroups(String groups) {
		System.debug(groups);
		List<Group> groupList = (List<Group>)JSON.deserializeStrict(groups, List<Group>.class);
		System.debug(groupList);
		delete groupList;
	}
}