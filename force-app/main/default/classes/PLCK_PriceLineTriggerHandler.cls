public with sharing class PLCK_PriceLineTriggerHandler extends PLCK_TriggerHandler {

    public override void beforeInsert() {
        PLCK_PriceLineService.linkPriceLineToAccount((List<PLCK_PriceLine__c>) Trigger.New);
    }

}