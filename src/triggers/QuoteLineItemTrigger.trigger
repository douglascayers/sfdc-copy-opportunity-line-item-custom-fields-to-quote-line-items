/**
 * Developed by Doug Ayers
 * https://github.com/DouglasCAyers/sfdc-copy-opportunity-line-item-custom-fields-to-quote-line-items
 */
trigger QuoteLineItemTrigger on QuoteLineItem ( before insert, before update, before delete,
                                                after insert, after update, after delete ) {

    QuoteLineItemTriggerHandler handler = new QuoteLineItemTriggerHandler();

    if ( Trigger.isBefore && Trigger.isInsert ) {
        handler.handleBeforeInsert( Trigger.new );
    }
    else if ( Trigger.isBefore && Trigger.isUpdate ) {
        handler.handleBeforeUpdate( Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap );
    }
    else if ( Trigger.isBefore && Trigger.isDelete ) {
        handler.handleBeforeDelete( Trigger.old, Trigger.oldMap );
    }
    else if ( Trigger.isAfter && Trigger.isInsert ) {
        handler.handleAfterInsert( Trigger.new, Trigger.newMap );
    }
    else if ( Trigger.isAfter && Trigger.isUpdate ) {
        handler.handleAfterUpdate( Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap );
    }
    else if ( Trigger.isAfter && Trigger.isDelete ) {
        handler.handleAfterDelete( Trigger.old, Trigger.oldMap );
    }

}