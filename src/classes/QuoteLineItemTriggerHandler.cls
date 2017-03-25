/**
 * Developed by Doug Ayers
 * https://github.com/DouglasCAyers/sfdc-copy-opportunity-line-item-custom-fields-to-quote-line-items
 */
public with sharing class QuoteLineItemTriggerHandler {

    // http://salesforce.stackexchange.com/questions/9292/access-to-the-related-quotelineitem-in-opportunitylineitem-trigger
    // http://salesforce.stackexchange.com/questions/47343/does-quote-line-item-reference-back-to-which-oli-it-relates-to#comment73055_47550
    // https://success.salesforce.com/ideaView?id=08730000000HpBH

    public QuoteLineItemTriggerHandler() {}

    // -------------------------------------------------------
    // INSERT
    // -------------------------------------------------------

    public void handleBeforeInsert( List<QuoteLineItem> newList ) {

        List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();

        for ( QuoteLineItem newLineItem : newList ) {
            if ( String.isNotBlank( newLineItem.opportunity_line_item_id__c ) ) {
                quoteLineItems.add( newLineItem );
            }
        }

        if ( quoteLineItems.size() > 0 ) {
            copyOpportunityLineItemFieldsToQuoteLineItemFields( quoteLineItems );
        }

    }

    public void handleAfterInsert( List<QuoteLineItem> newList, Map<ID, QuoteLineItem> newMap ) {
        // no logic yet
    }

    // -------------------------------------------------------
    // UPDATE
    // -------------------------------------------------------

    public void handleBeforeUpdate( List<QuoteLineItem> oldList, Map<ID, QuoteLineItem> oldMap,
                                    List<QuoteLineItem> newList, Map<ID, QuoteLineItem> newMap ) {

        List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();

        for ( QuoteLineItem newLineItem : newList ) {

            QuoteLineItem oldLineItem = oldMap.get( newLineItem.id );

            Boolean opptyLineItemIdChanged = String.isBlank( oldLineItem.opportunity_line_item_id__c ) &&
                                             String.isNotBlank( newLineItem.opportunity_line_item_id__c );

            if ( opptyLineItemIdChanged ) {
                quoteLineItems.add( newLineItem );
            }

        }

        if ( quoteLineItems.size() > 0 ) {
            copyOpportunityLineItemFieldsToQuoteLineItemFields( quoteLineItems );
        }

    }

    public void handleAfterUpdate( List<QuoteLineItem> oldList, Map<ID, QuoteLineItem> oldMap,
                                   List<QuoteLineItem> newList, Map<ID, QuoteLineItem> newMap ) {
        // no logic yet
    }

    // -------------------------------------------------------
    // DELETE
    // -------------------------------------------------------

    public void handleBeforeDelete( List<QuoteLineItem> oldList, Map<ID, QuoteLineItem> oldMap ) {
        // no logic yet
    }

    public void handleAfterDelete( List<QuoteLineItem> oldList, Map<ID, QuoteLineItem> oldMap ) {
        // no logic yet
    }

    // -------------------------------------------------------

    /**
     * Given some quote line items, use the formula field 'opportunity_line_item_id__c'
     * to query the related source opportunity line items to copy over custom fields.
     *
     * This workaround is needed because at this time only standard opportunity line item fields
     * are copied down to quote line items when a new quote is created. We must manually
     * sync or copy down any custom fields.
     *
     * The field mappings are defined in the custom metadata type 'Quote Line Item Field Mapping'.
     */
    public void copyOpportunityLineItemFieldsToQuoteLineItemFields( List<QuoteLineItem> quoteLineItems ) {

        System.debug( 'copying opportunity line item fields to quote line item fields' );

        List<Quote_Line_Item_Field_Mapping__c> fieldMappings = Quote_Line_Item_Field_Mapping__c.getAll().values();

        System.debug( 'configured field mappings: ' + fieldMappings );

        if ( fieldMappings.size() > 0 ) {

            System.debug( 'quote line items: ' + quoteLineItems );

            // build up set of oppty line item ids to get their source field data for copying down
            Set<ID> opptyLineItemIds = new Set<ID>();
            for ( QuoteLineItem qli : quoteLineItems ) {
                if ( String.isNotBlank( qli.opportunity_line_item_id__c ) ) {
                    opptyLineItemIds.add( qli.opportunity_line_item_id__c );
                }
            }

            if ( opptyLineItemIds.size() > 0 ) {

                // build up oppty line item fields to query for copying to quote line items
                Set<String> opptyLineItemFieldNames = new Set<String>();
                for ( Quote_Line_Item_Field_Mapping__c fieldMapping : fieldMappings ) {
                    opptyLineItemFieldNames.add( fieldMapping.opportunity_line_item_field__c );
                }

                // query source oppty line item data
                String opptyLineItemQuery = ' SELECT ' + String.join( new List<String>( opptyLineItemFieldNames ), ', ' ) + ' FROM OpportunityLineItem WHERE id IN :opptyLineItemIds ';
                List<OpportunityLineItem> opptyLineItems = Database.query( opptyLineItemQuery );

                System.debug( 'oppty line items: ' + opptyLineItems );

                // convert to map so can easily retrieve values when iterating over the quote line items
                Map<ID, OpportunityLineItem> opptyLineItemsMap = new Map<ID, OpportunityLineItem>( opptyLineItems );

                for ( QuoteLineItem qli : quoteLineItems ) {

                    OpportunityLineItem oli = opptyLineItemsMap.get( qli.opportunity_line_item_id__c );

                    System.debug( 'quoteLineItem: ' + qli );
                    System.debug( 'opptyLineItem: ' + oli );

                    if ( oli != null ) {

                        for ( Quote_Line_Item_Field_Mapping__c fieldMapping : fieldMappings ) {

                            System.debug( 'quoteLineItemFieldName: ' + fieldMapping.name );
                            System.debug( 'opptyLineItemFieldName: ' + fieldMapping.opportunity_line_item_field__c );

                            Object opptyLineItemFieldValue = oli.get( fieldMapping.opportunity_line_item_field__c );

                            System.debug( 'opptyLineItemFieldValue: ' + opptyLineItemFieldValue );

                            qli.put( fieldMapping.name, opptyLineItemFieldValue );

                        } // end loop field mappings

                    } // end does oppty line item exist

                } // end loop quote line items

            } // end quote line items have any oppty line item ids

        } // end field mappings size check

    }

}