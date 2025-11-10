trigger PLCK_Product2Trigger on Product2 (after insert) {
    PLCK_TriggerFactory.createAndExecuteHandler(PLCK_Product2TriggerHandler.class);
}