trigger OpportunityTrigger on Opportunity (before update, after update, before delete) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        for (Opportunity o : Trigger.new) {
            if (o.Amount <= 5000) {
                o.addError('Opportunity amount must be greater than 5000');
            }
    }
}

    if (Trigger.isBefore && Trigger.isDelete) {
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity o : Trigger.old) {
            accountIds.add(o.AccountId);
        }

        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Industry FROM Account WHERE Id IN :accountIds]);
        
        for (Opportunity o : Trigger.old) {
        Account acc = accountMap.get(o.AccountId);
        if (o.StageName == 'Closed Won' && acc.Industry == 'Banking') {
            o.addError('Cannot delete closed opportunity for a banking account that is won');
        }
    }
}

    if (Trigger.isAfter && Trigger.isUpdate) {
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : Trigger.new) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }

        Map<Id, Contact> ceoMap = new Map<Id, Contact>();
        for (Contact c : [SELECT Id, AccountId FROM Contact WHERE Title = 'CEO' AND AccountId IN :accountIds]) {
            if (!ceoMap.containsKey(c.AccountId)) {
                ceoMap.put(c.AccountId, c);
            }
        }

        List<Opportunity> toUpdate = new List<Opportunity>();
        for (Opportunity opp : Trigger.new) {
            Contact ceo = ceoMap.get(opp.AccountId);
            if (ceo != null && opp.Primary_Contact__c != ceo.Id) {
                toUpdate.add(new Opportunity(Id = opp.Id, Primary_Contact__c = ceo.Id));
            }
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }
}



