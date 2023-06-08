public with sharing class OrderTriggerHandler {

    /**
     * Method that will throw an error message if user tries to update an order Status to 'Activated' if there are no associated product
     * 
     * @param ordersList => List<Order> Trigger.New orders
     * @return void
     */
    public static void checkOderHasOrderItem(List<Order> ordersList) {
        List<Order> activatedOrderList = new List<Order>();
        for (Order ordr : ordersList) {
            if(ordr.Status == 'Activated') {
                activatedOrderList.add(ordr);
            }
        }
        
        Set<Id> orderWithItemsIdSet = new Set<Id>();

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

        // I retrieve all related Accounts with Order
        for (Order odrd : ordersList) {
            orderAccountIdSet.add(odrd.AccountId);
        }

        List<Account> accountsToUpdateList= new List<Account>();
        // Setting Active__c to true
        for (Account acc : [SELECT Id, Active__c FROM Account WHERE Id IN :orderAccountIdSet]) {
            acc.Active__c = true;
            accountsToUpdateList.add(acc);
        }

        update accountsToUpdateList;
    }


    public static void deactiveAccountField(List<Order> ordersList) {
        //Je dois récupérer tout les accounts lié aux order supprimé
        Set<Id> orderAccountIdSet = new Set<Id>();

        // Je récupère Related account ID 
        for (Order odrd : ordersList) {
            orderAccountIdSet.add(odrd.AccountId);
        }
        List<Account> accountsToUpdateList= new List<Account>();

        // Je boucle sur 
        for (Account acc : [SELECT Id, Active__c ,(SELECT id from Orders) FROM Account WHERE Id IN :orderAccountIdSet]) {
            System.debug(acc.Orders);
            if(acc.Orders.size() == 0){
                System.debug('plouf');
                acc.Active__c = false;
                accountsToUpdateList.add(acc);
            }
        }
        update accountsToUpdateList;
    }
    
}