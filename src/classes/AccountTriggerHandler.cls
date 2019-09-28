public class AccountTriggerHandler {
	public static void AfterInsert(List<Account> accounts) {
		AccountService accountService = new AccountService();
		accounts = accountService.removeDummy(accounts);
		AccountSharing accountSharing = new AccountSharing();
		accountSharing.init(accounts);
	}

	public static void BeforeInsert(List<Account> accounts) {
		AccountService accountService = new AccountService();
		accountService.validate(accounts);
	}

	public static void BeforeUpdate(List<Account> oldList, List<Account> newList) {
		AccountService accountService = new AccountService();
		accountService.validate(newList);
	}

	public static void AfterUpdate(List<Account> oldList, List<Account> newList) {
		AccountService accountService = new AccountService();
		newList = accountService.removeDummy(newList);
		oldList = accountService.removeDummy(oldList);
		AccountSharing accountSharing = new AccountSharing();
		accountSharing.reInit(oldList, newList);
	}

	public static void BeforeDelete(List<Account> accounts) {
		AccountService accountService = new AccountService();
		accountService.RemovalPreparation(accounts);
	}

	public static void AfterDelete(List<Account> oldAccounts) {
		AccountSharing accountSharing = new AccountSharing();
		accountSharing.onDelete(oldAccounts);
	}
}