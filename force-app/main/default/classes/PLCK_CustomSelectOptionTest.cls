@IsTest
private class PLCK_CustomSelectOptionTest {

    @IsTest
    private static void shouldRaiseExceptionWhenRequestedCustomSelectOptionsForNonPicklistField() {
        Test.startTest();
        try {
            PLCK_CustomSelectOption.getSelectOptionsForPicklistField(Opportunity.Id);
            System.assert(false, 'Should throw exception because Id is not a Picklist type of field.');
        } catch (PLCK_CustomSelectOption.CustomSelectOptionException e) {
            System.assertEquals(String.format(PLCK_CustomSelectOption.INVALID_FIELD_TYPE, new List<String>{Opportunity.Id.getDescribe().getName()}), e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    private static void shouldReturnValidListOfCustomSelectOptionsForPicklistField() {
        Test.startTest();
        List<PLCK_CustomSelectOption> select_options = PLCK_CustomSelectOption.getSelectOptionsForPicklistField(Opportunity.StageName);
        Test.stopTest();

        System.assertNotEquals(null, select_options);
        System.assertEquals([SELECT COUNT() FROM OpportunityStage WHERE IsActive = true], select_options.size());
    }

    @IsTest
    private static void shouldInitializeCustomSelectOption() {
        Test.startTest();
        PLCK_CustomSelectOption option = new PLCK_CustomSelectOption('option_value', 'option_label');
        Test.stopTest();

        System.assertEquals('option_value', option.value);
        System.assertEquals('option_label', option.label);
    }

    @IsTest
    private static void shouldCompareSelectOptionsAndReturnEquals() {
        PLCK_CustomSelectOption option1 = new PLCK_CustomSelectOption('opt1', 'AAA Label');
        PLCK_CustomSelectOption option2 = new PLCK_CustomSelectOption('opt2', 'AAA Label');

        Test.startTest();
        Integer result = option1.compareTo(option2);
        Test.stopTest();

        System.assertEquals(0, result);
    }

    @IsTest
    private static void shouldCompareSelectOptionsAndReturnOptionOneGoesBeforeOptionTwo() {
        PLCK_CustomSelectOption option1 = new PLCK_CustomSelectOption('opt1', 'AAA Label');
        PLCK_CustomSelectOption option2 = new PLCK_CustomSelectOption('opt2', 'ZZZ Label');

        Test.startTest();
        Integer result = option1.compareTo(option2);
        Test.stopTest();

        System.assertEquals(-1, result);
    }

    @IsTest
    private static void shouldCompareSelectOptionsAndReturnOptionTwoGoesBeforeOptionOne() {
        PLCK_CustomSelectOption option1 = new PLCK_CustomSelectOption('opt1', 'ZZZ Label');
        PLCK_CustomSelectOption option2 = new PLCK_CustomSelectOption('opt2', 'AAA Label');

        Test.startTest();
        Integer result = option1.compareTo(option2);
        Test.stopTest();

        System.assertEquals(1, result);
    }
}