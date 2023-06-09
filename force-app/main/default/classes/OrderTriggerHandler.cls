public with sharing class OrderTriggerHandler {

    /**
     * Method that will throw an error message if user tries to update an order Status to 'Activated' if there are no associated product
     * 
     * @param ordersList => List<Order> Trigger.New orders
     * @return void
     */
    public static void checkOderHasOrderItem(List<Order> ordersList) {
        Set<Id> orderWithItemsIdSet = new Set<Id>();
        List<Order> activatedOrderList = new List<Order>();

        for (Order ordr : ordersList) {
            if(ordr.Status == 'Activated') {
                activatedOrderList.add(ordr);
            }
        }

        for (OrderItem oi : [SELECT Id, OrderId FROM OrderItem WHERE OrderId IN : activatedOrderList]) {
            orderWithItemsIdSet.add(oi.OrderId);
        }

        for (Order ordr : activatedOrderList) {
            if(!orderWithItemsIdSet.contains(ordr.Id)) {
                ordr.addError('Please add a product to your order before changing the status to Activated');
            }
        }
    }


    public static void activateAccountField(List<Order> ordersList) {
        Set<Id> orderAccountIdSet = new Set<Id>();
        List<Account> accountsToUpdateList= new List<Account>();

        // Get all related AccountId
        for (Order odrd : ordersList) {
            orderAccountIdSet.add(odrd.AccountId);
        }

        // Change all Accounts with at least one Order and set Active__c field to true
        for (Account acc : [SELECT Id, Active__c FROM Account WHERE Id IN :orderAccountIdSet]) {
            acc.Active__c = true;
            accountsToUpdateList.add(acc);
        }

        update accountsToUpdateList;
    }


    public static void deactiveAccountField(List<Order> ordersList) {
        Set<Id> orderAccountIdSet = new Set<Id>();
        List<Account> accountsToUpdateList= new List<Account>();

        // Get all related AccountId
        for (Order odrd : ordersList) {
            orderAccountIdSet.add(odrd.AccountId);
        }

        // Change Accounts that previously had at least one Order and set Active__c field to false if acc.Orders.size() == 0
        for (Account acc : [SELECT Id, Active__c , (SELECT Id FROM Orders) FROM Account WHERE Id IN :orderAccountIdSet]) {
            if(acc.Orders.size() == 0){
                acc.Active__c = false;
                accountsToUpdateList.add(acc);
            }
        }

        update accountsToUpdateList;
    }

}