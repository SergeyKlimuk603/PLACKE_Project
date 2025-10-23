public with sharing class PLCK_AccountTriggerHandler extends PLCK_TriggerHandler {

    public override void beforeInsert() {
        PLCK_AccountService.setPicklistValues((List<Account>) Trigger.new);
        PLCK_AccountService.setAccountOwner((List<Account>) Trigger.new, null);
        PLCK_AccountService.assignSalesOrgPricebookToCustomer((List<Account>) Trigger.new, null);
    }

    public override void beforeUpdate() {
        PLCK_AccountService.setPicklistValues((List<Account>) Trigger.new);
        PLCK_AccountService.setAccountOwner((List<Account>) Trigger.new, (Map<Id, Account>) Trigger.oldMap);
        PLCK_AccountService.assignSalesOrgPricebookToCustomer((List<Account>) Trigger.new, (Map<Id, Account>) Trigger.oldMap);
    }
}