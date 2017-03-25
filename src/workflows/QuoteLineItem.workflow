<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Opportunity_Line_Item_ID</fullName>
        <field>Opportunity_Line_Item_ID__c</field>
        <formula>OpportunityLineItem.Id</formula>
        <name>Set Opportunity Line Item ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Opportunity Line Item ID</fullName>
        <actions>
            <name>Set_Opportunity_Line_Item_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>QuoteLineItem.Opportunity_Line_Item_ID__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>For quote line items automatically created in Salesforce UI, populate the source opportunity line item id.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
