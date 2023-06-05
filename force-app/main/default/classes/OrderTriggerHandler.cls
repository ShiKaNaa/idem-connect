public with sharing class OrderTriggerHandler {

    /**
     * Method that will throw an error message if user tries to update an order Status to 'Activated' if there are no associated product
     * 
     * @param ordersList => List<Order> Trigger.New orders
     * @return void
     */
    public static void checkOderHasProduct(List<Order> ordersList) {
        Set<Id> orderWithItemsIdSet = new Set<Id>();

        for (OrderItem oi : [SELECT Id, OrderId FROM OrderItem WHERE OrderId IN : ordersList]) {
            orderWithItemsIdSet.add(oi.OrderId);
        }

        for (Order ordr : ordersList) {
            Order oldOrdr = (Order)Trigger.oldMap.get(ordr.Id);
            if(!orderWithItemsIdSet.contains(ordr.Id) && oldOrdr.Status == 'Draft' && ordr.Status == 'Activated') {
                ordr.addError('Please add a product to your order before changing the status to Activated');
            }
        }
    }


}