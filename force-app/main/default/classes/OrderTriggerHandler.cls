public with sharing class OrderTriggerHandler {

    /**
     * Method that will throw an error message if user tries to update an order Status to 'Activated' if there are no associated product
     * 
     * @param ordersList => List<Order> Trigger.New orders
     * @return void
     */
    public static void checkOderHasProduct(List<Order> ordersList) {
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
        System.debug('^mpfezf');

        for (Order ordr : activatedOrderList) {
            if(!orderWithItemsIdSet.contains(ordr.Id)) {
                ordr.addError('Please add a product to your order before changing the status to Activated');
            }
        }
    }


}