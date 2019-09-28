public class AccountService {

	public void validate(List<Account> accounts) {
		for(Account account : accounts) {
			if(account.Territory__c == null && account.Name != 'Dummy') account.addError('account must have a territory');
		}
	}

	public List<Account> removeDummy(List<Account> accounts) {
		List<Account> accountsWithoutDummy = new List<Account>();
		for(Account account : accounts) {
			if(account.Name != 'Dummy') accountsWithoutDummy.add(account);
		}
		return accountsWithoutDummy;
	}

	public void RemovalPreparation(List<Account> accounts) {
		for(Account account : accounts) {
			if(account.Name == 'Dummy') account.addError('dummy account cannot be deleted');
		}
	}
}