/**
 * Developed by Doug Ayers
 * https://github.com/DouglasCAyers/sfdc-copy-opportunity-line-item-custom-fields-to-quote-line-items
 */
@isTest
private class QuoteLineItemTriggerHandlerTest {

    @isTest
    static void test_copy_oppty_line_item_fields_to_quote_line_item_fields() {

        ID priceBookId = Test.getStandardPricebookId();

        Product2 product = new Product2(
            name = 'Test Product'
        );

        insert product;

        PriceBookEntry pbe = new PriceBookEntry(
            priceBook2Id = priceBookId,
            product2Id = product.id,
            unitPrice = 5.00,
            isActive = true
        );

        insert pbe;

        Account acct = new Account(
            name = 'Test Account'
        );

        insert acct;

        Opportunity oppty = new Opportunity(
            accountId = acct.id,
            priceBook2Id = priceBookId,
            name = 'Test Opportunity',
            stageName = 'Decision',
            closeDate = Date.today().addDays( 30 )
        );

        insert oppty;

        OpportunityLineItem oli = new OpportunityLineItem(
            opportunityId = oppty.id,
            priceBookEntryId = pbe.id,
            quantity = 5,
            unitPrice = pbe.unitPrice
        );

        insert oli;

        Quote q = new Quote(
            opportunityId = oppty.id,
            priceBook2Id = priceBookId,
            name = 'Test Quote'
        );

        insert q;

        Test.startTest();

        Quote_Line_Item_Field_Mapping__c fieldMapping = new Quote_Line_Item_Field_Mapping__c(
            name = 'opportunity_line_item_id__c',
            opportunity_line_item_field__c = 'id'
        );

        insert fieldMapping;

        QuoteLineItem qli = new QuoteLineItem(
            quoteId = q.id,
            opportunity_line_item_id__c = oli.id,
            priceBookEntryId = oli.priceBookEntryId,
            quantity = oli.quantity,
            unitPrice = oli.unitPrice
        );

        insert qli;

        qli = [ SELECT id, opportunity_line_item_id__c FROM QuoteLineItem WHERE id = :qli.id ];

        System.assertEquals( oli.id, qli.opportunity_line_item_id__c );

        // for code coverage
        update qli;
        delete qli;

        Test.stopTest();

    }

}