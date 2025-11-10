trigger PLCK_PriceLineTrigger on PLCK_PriceLine__c (before insert, after insert, after update) {
    PLCK_TriggerFactory.createAndExecuteHandler(PLCK_PriceLineTriggerHandler.class);
}