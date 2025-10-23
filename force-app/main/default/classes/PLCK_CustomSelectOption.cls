public with sharing virtual class PLCK_CustomSelectOption implements Comparable {

    @TestVisible
    private static final String INVALID_FIELD_TYPE = '{0} is not a Picklist type of field.';

    public static List<PLCK_CustomSelectOption> getSelectOptionsForPicklistField(SObjectField sobject_field) {
        List<PLCK_CustomSelectOption> custom_select_options = new List<PLCK_CustomSelectOption>();
        DescribeFieldResult field_describe = sobject_field.getDescribe();
        if (field_describe.getType() != DisplayType.PICKLIST && field_describe.getType() != DisplayType.MULTIPICKLIST) {
            throw new CustomSelectOptionException(
                    String.format(INVALID_FIELD_TYPE, new List<String>{field_describe.getName()})
            );
        }
        for (PicklistEntry picklist_entry : field_describe.getPicklistValues()) {
            if (picklist_entry.isActive()) {
                custom_select_options.add(new PLCK_CustomSelectOption(picklist_entry));
            }
        }
        return custom_select_options;
    }

    @AuraEnabled
    public String value;
    @AuraEnabled
    public String label;

    public PLCK_CustomSelectOption(String option_value, String option_label) {
        value = option_value;
        label = option_label;
    }

    public PLCK_CustomSelectOption(PicklistEntry picklist_entry) {
        value = picklist_entry.getValue();
        label = picklist_entry.getLabel();
    }

    public virtual Integer compareTo(Object compare_to) {
        PLCK_CustomSelectOption compare_to_object = (PLCK_CustomSelectOption) compare_to;
        if (String.isBlank(this.value)) {
            return -1;
        }
        if (String.isBlank(compare_to_object.value)) {
            return 1;
        }
        if (this.label < compare_to_object.label) {
            return -1;
        }
        if (this.label > compare_to_object.label) {
            return 1;
        }
        return 0;
    }

    public class CustomSelectOptionException extends Exception {

    }

}