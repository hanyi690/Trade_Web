package com.yourdomain.eshop.service;

import com.yourdomain.eshop.entity.Order;
import com.yourdomain.eshop.entity.OrderItem;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface OrderService {
    List<Order> getOrdersByUserId(Long userId);
    Order getOrderById(Long orderId);
    Order createOrderFromCart(Long userId);
    Order updateOrderStatus(Long orderId, String status);
    void cancelOrder(Long orderId);
    List<OrderItem> getOrderItemsByProductIds(List<Long> productIds);
    List<Order> getOrdersByProductIds(List<Long> productIds);
    Map<String, Object> getOrderStatisticsByProductIds(List<Long> productIds, LocalDate startDate, LocalDate endDate);
    List<Map<String, Object>> getDailySalesData(List<Long> productIds, LocalDate startDate, LocalDate endDate);
    List<Order> getRecentOrdersByProductIds(List<Long> productIds, int limit);
    Order createOrderFromCartWithShippingInfo(Long userId, String shippingAddress, 
                                             String receiverName, String receiverPhone, 
                                             String paymentMethod);
    List<Order> getOrdersByProductIdsAndDateRange(List<Long> productIds, LocalDate startDate, LocalDate endDate);
    List<Order> getRecentOrdersByProductIdsAndDateRange(List<Long> productIds, int limit, LocalDate startDate, LocalDate endDate);
    Map<String, Object> getSalesStatisticsByProductIds(List<Long> productIds, LocalDate startDate, LocalDate endDate);
    Map<String, Long> getOrderStatusDistribution(List<Long> productIds, LocalDate startDate, LocalDate endDate);
    // 新增：按日期范围获取订单（支持分页）
    List<Order> getOrdersByDateRange(LocalDate startDate, LocalDate endDate, int page, int size);
    
    /**
     * 处理订单支付（简化版，模拟支付）
     */
    Order processPayment(Long orderId, Long userId);
    
    /**
     * 发货订单并发送邮件通知
     */
   //Order shipOrder(Long orderId, Long userId);

    /**
     * 发货订单项（商家操作）
     * @param orderItemId 订单项ID
     * @param merchantUserId 商家用户ID
     * @return 更新后的订单项
     */
    OrderItem shipOrderItem(Long orderItemId, Long merchantUserId);

    /**
     * 确认收货订单项（用户操作）
     * @param orderItemId 订单项ID
     * @param userId 用户ID
     * @return 更新后的订单项
     */
    OrderItem deliverOrderItem(Long orderItemId, Long userId);

    /**
     * 批量发货订单项（商家操作）
     * @param orderItemIds 订单项ID列表
     * @param merchantUserId 商家用户ID
     * @return 更新后的订单列表
     */
    List<OrderItem> batchShipOrderItems(List<Long> orderItemIds, Long merchantUserId);

    /**
     * 根据订单ID获取订单项列表
     * @param orderId 订单ID
     * @return 订单项列表
     */
    List<OrderItem> getOrderItemsByOrderId(Long orderId);


    /**
     * 按用户ID和日期范围获取订单
     */
    List<Order> getOrdersByUserIdAndDateRange(Long userId, LocalDate startDate, LocalDate endDate);
    
    /**
     * 用户取消订单（带权限检查）
     */
    Order cancelOrderByUser(Long orderId, Long userId);
    
    /**
     * 按订单ID和用户ID获取订单（带权限检查）
     */
    Order getOrderByIdAndUserId(Long orderId, Long userId);
    
    /**
     * 更新订单信息
     */
    Order updateOrderInfo(Long orderId, Long userId, String shippingAddress, 
                         String receiverName, String receiverPhone, String paymentMethod);

    /**
     * 强制取消订单（管理员操作，不检查订单状态）
     * @param orderId 订单ID
     */
    void forceCancelOrder(Long orderId);
}
