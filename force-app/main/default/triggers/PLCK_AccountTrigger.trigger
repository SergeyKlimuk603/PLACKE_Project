trigger PLCK_AccountTrigger on Account (before update, before insert, after insert) {
    PLCK_TriggerFactory.createAndExecuteHandler(PLCK_AccountTriggerHandler.class);
}