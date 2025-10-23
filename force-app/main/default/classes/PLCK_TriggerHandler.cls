public virtual without sharing class PLCK_TriggerHandler {

    public PLCK_TriggerHandler() {}

    public virtual void preparation() {}

    public virtual void beforePrepare() {}
    public virtual void beforeInsert() {}
    public virtual void beforeUpdate() {}
    public virtual void beforeDelete() {}
    public virtual void beforeUndelete() {}
    public virtual void beforeAll() {}

    public virtual void afterPrepare() {}
    public virtual void afterInsert() {}
    public virtual void afterUpdate() {}
    public virtual void afterDelete() {}
    public virtual void afterUndelete() {}
    public virtual void afterAll() {}

    public virtual void cleanup() {}

    public virtual void execute() {

        this.preparation();

        if (Trigger.isBefore) {
            this.beforePrepare();
            if (Trigger.isDelete) {
                this.beforeDelete();
            } else if (Trigger.isUndelete) {
                this.beforeUndelete();
            } else if (Trigger.isInsert) {
                this.beforeInsert();
            } else if (Trigger.isUpdate) {
                this.beforeUpdate();
            }
            this.beforeAll();
        } else if (Trigger.isAfter) {
            this.afterPrepare();
            if (Trigger.isDelete) {
                this.afterDelete();
            } else if (Trigger.isUndelete) {
                this.afterUndelete();
            } else if (Trigger.isInsert) {
                this.afterInsert();
            } else if (Trigger.isUpdate) {
                this.afterUpdate();
            }
            this.afterAll();
        }
        this.cleanup();
    }
}