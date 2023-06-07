@isTest
public with sharing class OrderTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        List<Account> accList = TestDataFactory.generateAccountsList(1);
        List<Order> ordersList = TestDataFactory.generateOrdersList(accList);
        Product2 prodct = TestDataFactory.generateProduct();
        PricebookEntry pbe = TestDataFactory.generatePriceBookEntry(prodct);
    }

    @isTest
    static void updateOrderWithoutProductTest() {
        String errorMessage = '';
        Order ordr = [SELECT Id, Status FROM Order LIMIT 1];
        ordr.Status = 'Activated';

        Test.startTest();
        try {
            update ordr;
        } catch (Exception e) {
            errorMessage = e.getDmlMessage(0);
        }
        Test.stopTest();

        System.assertEquals('Please add a product to your order before changing the status to Activated', errorMessage);
    }

    @isTest
    static void updateOrderWithProductTest() {
       String errorMessage;
        Order ordr = [SELECT Id, Status, (SELECT Id, OrderId FROM OrderItems) FROM Order LIMIT 1];
        Product2 prodct = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];

        OrderItem oi = TestDataFactory.generateOrderItem(ordr, prodct, pbe);
        Order ordrWithOi = [SELECT Id, Status, (SELECT Id, OrderId FROM OrderItems) FROM Order LIMIT 1];
        ordrWithOi.Status = 'Activated';
        // add a product before update
        Test.startTest();
        try {
            update ordrWithOi;
            errorMessage = 'noError';
        } catch (Exception e) {
            errorMessage = e.getDmlMessage(0);
        }
        Test.stopTest();

        // Assert update did work
        System.assertEquals('noError', errorMessage);
        System.assertEquals('Activated', ordrWithOi.status);
    }
    
}