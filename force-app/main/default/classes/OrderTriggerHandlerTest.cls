@isTest
public with sharing class OrderTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        List<Account> accList = TestDataFactory.generateAccountsList(2);
        List<Order> ordersList = TestDataFactory.generateOrdersList(accList);
        Product2 prodct = TestDataFactory.generateProduct();
        PricebookEntry pbe = TestDataFactory.generatePriceBookEntry(prodct);
    }

    @isTest
    static void updateOrderWithoutProductTest() {
        // Arrange
        String errorMessage;
        Order ordr = [SELECT Id, Status FROM Order LIMIT 1];
        ordr.Status = 'Activated';

        // Act
        Test.startTest();
        try {
            update ordr;
        } catch (Exception e) {
            errorMessage = e.getDmlMessage(0);
        }
        Test.stopTest();

        // Assert
        System.assertEquals('Please add a product to your order before changing the status to Activated', errorMessage);
    }

    @isTest
    static void updateOrderWithProductTest() {
        // Arrange
        String errorMessage;
        Order ordr = [SELECT Id, Status, (SELECT Id, OrderId FROM OrderItems) FROM Order LIMIT 1];
        Product2 prodct = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];

        OrderItem oi = TestDataFactory.generateOrderItem(ordr, prodct, pbe);
        Order ordrWithOi = [SELECT Id, Status, (SELECT Id, OrderId FROM OrderItems) FROM Order LIMIT 1];
        ordrWithOi.Status = 'Activated';
        
        // Act
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

    @isTest
    static void activateAccountFieldTest() {
        // Arrange
        List<Account> accs = [SELECT Id, Name, Active__c FROM Account];

        // Act add Orders an Account
        Test.startTest();
        List<Order> ordrList = TestDataFactory.generateOrdersList(accs);
        Test.stopTest();

        // Assert
        // Check that Active__c is now true
        Account acc = [SELECT Id, Name, Active__c FROM Account WHERE Id = :ordrList[0].AccountId LIMIT 1];
        System.assertEquals(true, acc.Active__c);
    }

    @isTest
    static void deactivateAccountFieldTest() {
        // Arrange
        Account acc = [SELECT Id, Name, Active__c FROM Account LIMIT 1];
        List<Order> ordrList = [SELECT Id, AccountId FROM Order WHERE AccountId = :acc.Id];

        // Act
        // Delete Account related Orders
        Test.startTest();
        delete ordrList;
        Test.stopTest();

        // Assert
        // Check that Active__c is now false
        acc = [SELECT Id, Name, Active__c FROM Account LIMIT 1];
        System.assertEquals(false, acc.Active__c);
    }

    @isTest
    static void changeOrderRelatedAccount() {
        // Arrange
        List<Account> accList = [SELECT Id, Active__c FROM Account LIMIT 2];

        List<Order> ordrList = [SELECT Id, AccountId FROM Order WHERE AccountId IN :accList];

        // Act
        // Transfert all orders to 2nd Account
        Test.startTest();
        for (Order ordr : ordrList) {
            ordr.AccountId = accList[1].Id;
        }
        update ordrList;
        Test.stopTest();

        // Assert
        accList = [SELECT Id, Active__c FROM Account LIMIT 2];
        System.assertEquals(false, accList[0].Active__c);
        System.assertEquals(true, accList[1].Active__c);
        
    }
    
}