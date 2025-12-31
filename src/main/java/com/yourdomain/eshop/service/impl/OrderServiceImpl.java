package com.yourdomain.eshop.service.impl;

import com.yourdomain.eshop.service.EmailService;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;
import java.util.stream.Collectors;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.yourdomain.eshop.entity.CartItem;
import com.yourdomain.eshop.entity.Order;
import com.yourdomain.eshop.entity.OrderItem;
import com.yourdomain.eshop.entity.User;
import com.yourdomain.eshop.repository.CartItemRepository;
import com.yourdomain.eshop.repository.OrderItemRepository;
import com.yourdomain.eshop.repository.OrderRepository;
import com.yourdomain.eshop.repository.UserRepository;
import com.yourdomain.eshop.service.OrderService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
@Transactional
public class OrderServiceImpl implements OrderService {
    
    private static final Logger logger = LoggerFactory.getLogger(OrderServiceImpl.class);

    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final CartItemRepository cartItemRepository;
    private final OrderItemRepository orderItemRepository;
    private final EmailService emailService;

    public OrderServiceImpl(OrderRepository orderRepository,
                           UserRepository userRepository,
                           CartItemRepository cartItemRepository,
                           OrderItemRepository orderItemRepository,
                           EmailService emailService) {
        this.orderRepository = orderRepository;
        this.userRepository = userRepository;
        this.cartItemRepository = cartItemRepository;
        this.orderItemRepository = orderItemRepository;
        this.emailService = emailService;
    }

    @Override
    public List<Order> getOrdersByUserId(Long userId) {
        return orderRepository.findByUserId(userId);
    }

    @Override
    public Order getOrderById(Long orderId) {
        return orderRepository.findById(orderId)
            .orElseThrow(() -> new RuntimeException("订单不存在"));
    }

    @Override
    public Order createOrderFromCart(Long userId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("用户不存在"));
        
        List<CartItem> cartItems = cartItemRepository.findByUserId(userId);
        if (cartItems.isEmpty()) {
            throw new RuntimeException("购物车为空");
        }
        
        Order order = new Order();
        order.setUser(user);
        order.setStatus(Order.Status.PENDING);
        order.setCreateTime(LocalDateTime.now());
        
        BigDecimal totalAmount = BigDecimal.ZERO;
        
        for (CartItem cartItem : cartItems) {
            OrderItem orderItem = new OrderItem();
            orderItem.setProduct(cartItem.getProduct());
            orderItem.setQuantity(cartItem.getQuantity());
            
            BigDecimal itemTotal = cartItem.getProduct().getPrice()
                .multiply(BigDecimal.valueOf(cartItem.getQuantity()));
            totalAmount = totalAmount.add(itemTotal);
            
            order.addItem(orderItem);
        }
        
        order.setTotalAmount(totalAmount);
        
        Order savedOrder = orderRepository.save(order);
        
        cartItemRepository.deleteByUserId(userId);
        
        return savedOrder;
    }

    @Override
    public Order updateOrderStatus(Long orderId, String status) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new RuntimeException("订单不存在"));
        
        Order.Status statusEnum = Order.fromString(status);
        order.setStatus(statusEnum);
        return orderRepository.save(order);
    }

    @Override
    public void cancelOrder(Long orderId) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new RuntimeException("订单不存在"));
        
        if (order.getStatus() != Order.Status.PENDING) {
            throw new RuntimeException("只有待支付订单可以取消");
        }
        
        order.setStatus(Order.Status.CANCELLED);
        orderRepository.save(order);
    }
    
    @Override
    public List<OrderItem> getOrderItemsByProductIds(List<Long> productIds) {
        if (productIds == null || productIds.isEmpty()) {
            return new ArrayList<>();
        }
        return orderItemRepository.findByProductIds(productIds);
    }
    
    @Override
    public List<Order> getOrdersByProductIds(List<Long> productIds) {
        if (productIds == null || productIds.isEmpty()) {
            return new ArrayList<>();
        }
        return orderRepository.findOrdersByProductIds(productIds);
    }

    @Override
    public Map<String, Object> getOrderStatisticsByProductIds(List<Long> productIds, LocalDate startDate, LocalDate endDate) {
        Map<String, Object> stats = new HashMap<>();
        
        if (productIds == null || productIds.isEmpty()) {
            stats.put("totalSales", BigDecimal.ZERO);
            stats.put("totalOrders", 0L);
            stats.put("totalQuantity", 0L);
            stats.put("avgOrderAmount", BigDecimal.ZERO);
            stats.put("topProducts", new ArrayList<>());
            return stats;
        }
        
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(LocalTime.MAX);
        
        List<Order> ordersInRange = orderRepository.findOrdersByProductIdsAndDateRange(
                productIds, startDateTime, endDateTime);
        
        Map<Long, ProductStats> productStatsMap = new HashMap<>();
        
        for (Order order : ordersInRange) {
            for (OrderItem item : order.getOrderItems()) {
                if (productIds.contains(item.getProduct().getId())) {
                    BigDecimal itemTotal = item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
                    
                    ProductStats productStats = productStatsMap.getOrDefault(
                            item.getProduct().getId(), new ProductStats(item.getProduct()));
                    productStats.addSales(item.getQuantity());
                    productStats.addRevenue(itemTotal);
                    productStatsMap.put(item.getProduct().getId(), productStats);
                }
            }
        }
        
        // 计算统计值
        BigDecimal totalSales = productStatsMap.values().stream()
            .map(ProductStats::getRevenue)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        long totalQuantity = productStatsMap.values().stream()
            .mapToLong(ProductStats::getSales)
            .sum();
        
        BigDecimal avgOrderAmount = !ordersInRange.isEmpty() ? 
            totalSales.divide(BigDecimal.valueOf(ordersInRange.size()), 2, RoundingMode.HALF_UP) : 
            BigDecimal.ZERO;
        
        List<Map<String, Object>> topProducts = productStatsMap.values().stream()
                .sorted((a, b) -> b.getRevenue().compareTo(a.getRevenue()))
                .limit(10)
                .map(ProductStats::toMap)
                .collect(Collectors.toList());
        
        stats.put("totalSales", totalSales);
        stats.put("totalOrders", (long) ordersInRange.size());
        stats.put("totalQuantity", totalQuantity);
        stats.put("avgOrderAmount", avgOrderAmount);
        stats.put("topProducts", topProducts);
        
        return stats;
    }

    @Override
    public List<Map<String, Object>> getDailySalesData(List<Long> productIds, LocalDate startDate, LocalDate endDate) {
        List<Map<String, Object>> dailyData = new ArrayList<>();
        
        if (productIds == null || productIds.isEmpty()) {
            return dailyData;
        }
        
        LocalDate currentDate = startDate;
        while (!currentDate.isAfter(endDate)) {
            LocalDateTime dayStart = currentDate.atStartOfDay();
            LocalDateTime dayEnd = currentDate.atTime(LocalTime.MAX);
            
            List<OrderItem> dayOrderItems = orderItemRepository.findByProductIdsAndOrderCreateTimeBetween(
                    productIds, dayStart, dayEnd);
            
            BigDecimal daySales = dayOrderItems.stream()
                .map(item -> item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
            
            long dayOrders = dayOrderItems.stream()
                    .map(item -> item.getOrder().getId())
                    .distinct()
                    .count();
            
            Map<String, Object> dayData = new HashMap<>();
            dayData.put("date", currentDate.toString());
            dayData.put("sales", daySales.doubleValue());
            dayData.put("orders", dayOrders);
            
            dailyData.add(dayData);
            currentDate = currentDate.plusDays(1);
        }
        
        return dailyData;
    }

    @Override
    public Map<String, Long> getOrderStatusDistribution(List<Long> productIds, LocalDate startDate, LocalDate endDate) {
        Map<String, Long> distribution = new HashMap<>();
        
        if (productIds == null || productIds.isEmpty()) {
            return distribution;
        }
        
        List<Order> orders = getOrdersByProductIdsAndDateRange(productIds, startDate, endDate);
        
        for (Order order : orders) {
            String status = order.getStatus().name();
            distribution.put(status, distribution.getOrDefault(status, 0L) + 1);
        }
        
        return distribution;
    }

    @Override
    public List<Order> getRecentOrdersByProductIds(List<Long> productIds, int limit) {
        if (productIds == null || productIds.isEmpty()) {
            return new ArrayList<>();
        }
        
        List<Order> allOrders = orderRepository.findOrdersByProductIds(productIds);
        
        return allOrders.stream()
                .sorted((a, b) -> b.getCreateTime().compareTo(a.getCreateTime()))
                .limit(limit)
                .collect(Collectors.toList());
    }

    @Override
    public Order createOrderFromCartWithShippingInfo(Long userId, String shippingAddress, 
                                                    String receiverName, String receiverPhone, 
                                                    String paymentMethod) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("用户不存在"));
        
        List<CartItem> cartItems = cartItemRepository.findByUserId(userId);
        if (cartItems.isEmpty()) {
            throw new RuntimeException("购物车为空");
        }
        
        Order order = new Order();
        order.setUser(user);
        order.setStatus(Order.Status.PENDING);
        order.setCreateTime(LocalDateTime.now());
        order.setShippingAddress(shippingAddress);
        order.setReceiverName(receiverName);
        order.setReceiverPhone(receiverPhone);
        order.setPaymentMethod(paymentMethod);
        
        BigDecimal totalAmount = BigDecimal.ZERO;
        
        for (CartItem cartItem : cartItems) {
            OrderItem orderItem = new OrderItem();
            orderItem.setProduct(cartItem.getProduct());
            orderItem.setQuantity(cartItem.getQuantity());
            orderItem.setPrice(cartItem.getProduct().getPrice());
            orderItem.setStatus(OrderItem.Status.PENDING);
            
            BigDecimal itemTotal = cartItem.getProduct().getPrice()
                .multiply(BigDecimal.valueOf(cartItem.getQuantity()));
            totalAmount = totalAmount.add(itemTotal);
            
            order.addItem(orderItem);
        }
        
        order.setTotalAmount(totalAmount);
        
        Order savedOrder = orderRepository.save(order);
        
        cartItemRepository.deleteByUserId(userId);
        
        try {
            emailService.sendOrderConfirmation(savedOrder);
            logger.info("订单确认邮件发送成功，订单号: {}", savedOrder.getId());
        } catch (Exception e) {
            logger.error("发送订单确认邮件失败: {}", e.getMessage(), e);
        }
        
        return savedOrder;
    }

    @Override
    public Order processPayment(Long orderId, Long userId) {
        Order order = orderRepository.findByIdAndUserId(orderId, userId);
        if (order == null) {
            throw new RuntimeException("订单不存在或不属于当前用户");
        }
        
        if (order.getStatus() != Order.Status.PENDING) {
            throw new RuntimeException("订单状态不允许支付");
        }
        
        if (order.isPaid()) {
            throw new RuntimeException("订单已支付，无需重复支付");
        }
        
        order.setPaidTime(LocalDateTime.now());
        Order updatedOrder = orderRepository.save(order);
        
        try {
            emailService.sendPaymentConfirmation(updatedOrder);
        } catch (Exception e) {
            logger.error("发送支付成功邮件失败: {}", e.getMessage(), e);
        }
        
        return updatedOrder;
    }

    @Override
    public OrderItem shipOrderItem(Long orderItemId, Long merchantUserId) {
        OrderItem orderItem = orderItemRepository.findById(orderItemId)
            .orElseThrow(() -> new RuntimeException("订单项不存在"));
        
        Order order = orderItem.getOrder();
        
        if (!orderItem.getProduct().getMerchant().getId().equals(merchantUserId)) {
            throw new RuntimeException("只能对自己店铺的商品进行发货");
        }
        
        if (!order.isPaid()) {
            throw new RuntimeException("订单未支付，不能发货");
        }
        
        if (!orderItem.canShip()) {
            throw new RuntimeException("订单项状态不允许发货");
        }
        
        orderItem.ship();
        OrderItem updatedOrderItem = orderItemRepository.save(orderItem);
        
        try {
            emailService.sendShippingNotification(order);
        } catch (Exception e) {
            logger.error("发送发货通知邮件失败: {}", e.getMessage(), e);
        }
        
        return updatedOrderItem;
    }

    @Override
    public OrderItem deliverOrderItem(Long orderItemId, Long userId) {
        OrderItem orderItem = orderItemRepository.findById(orderItemId)
            .orElseThrow(() -> new RuntimeException("订单项不存在"));
        
        Order order = orderItem.getOrder();
        
        if (!order.getUser().getId().equals(userId)) {
            throw new RuntimeException("只能确认自己的订单收货");
        }
        
        if (!orderItem.canDeliver()) {
            throw new RuntimeException("订单项状态不允许确认收货");
        }
        
        orderItem.deliver();
        OrderItem updatedOrderItem = orderItemRepository.save(orderItem);
        
        if (order.areAllItemsDelivered()) {
            order.updateStatus();
            orderRepository.save(order);
        }
        
        return updatedOrderItem;
    }

    @Override
    public List<OrderItem> batchShipOrderItems(List<Long> orderItemIds, Long merchantUserId) {
        return orderItemIds.stream()
            .map(orderItemId -> {
                try {
                    return shipOrderItem(orderItemId, merchantUserId);
                } catch (Exception e) {
                    logger.error("发货订单项失败: {}, orderItemId: {}", e.getMessage(), orderItemId);
                    return null;
                }
            })
            .filter(Objects::nonNull)
            .collect(Collectors.toList());
    }

    @Override
    public List<OrderItem> getOrderItemsByOrderId(Long orderId) {
        return orderRepository.findById(orderId)
            .map(Order::getOrderItems)
            .orElseThrow(() -> new RuntimeException("订单不存在"));
    }

    @Override
    public List<Order> getOrdersByProductIdsAndDateRange(List<Long> productIds, LocalDate startDate, LocalDate endDate) {
        if (productIds == null || productIds.isEmpty()) {
            return new ArrayList<>();
        }
        
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(LocalTime.MAX);
        
        return orderRepository.findOrdersByProductIdsAndDateRange(productIds, startDateTime, endDateTime);
    }

    @Override
    public List<Order> getRecentOrdersByProductIdsAndDateRange(List<Long> productIds, int limit, 
                                                              LocalDate startDate, LocalDate endDate) {
        if (productIds == null || productIds.isEmpty()) {
            return new ArrayList<>();
        }
        
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(LocalTime.MAX);
        
        Pageable pageable = PageRequest.of(0, limit);
        return orderRepository.findRecentOrdersByProductIdsAndDateRange(
                productIds, startDateTime, endDateTime, pageable);
    }

    @Override
    public Map<String, Object> getSalesStatisticsByProductIds(List<Long> productIds, 
                                                             LocalDate startDate, LocalDate endDate) {
        Map<String, Object> stats = new HashMap<>();
        
        if (productIds == null || productIds.isEmpty()) {
            stats.put("totalOrders", 0L);
            stats.put("totalSales", BigDecimal.ZERO);
            stats.put("totalQuantity", 0L);
            return stats;
        }
        
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(LocalTime.MAX);
        
        List<Order> orders = orderRepository.findOrdersByProductIdsAndDateRange(productIds, startDateTime, endDateTime);
        
        BigDecimal totalSales = BigDecimal.ZERO;
        long totalQuantity = 0L;
        
        for (Order order : orders) {
            for (OrderItem item : order.getOrderItems()) {
                if (productIds.contains(item.getProduct().getId())) {
                    totalQuantity += item.getQuantity();
                    totalSales = totalSales.add(item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
                }
            }
        }
        
        stats.put("totalOrders", (long) orders.size());
        stats.put("totalSales", totalSales);
        stats.put("totalQuantity", totalQuantity);
        
        return stats;
    }

    @Override
    public List<Order> getOrdersByDateRange(LocalDate startDate, LocalDate endDate, int page, int size) {
        if (startDate == null || endDate == null) {
            Pageable pageable = PageRequest.of(page - 1, size);
            return orderRepository.findAll(pageable).getContent();
        }
        
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(LocalTime.MAX);
        
        List<Order> allOrders = orderRepository.findAll().stream()
                .filter(order -> !order.getCreateTime().isBefore(startDateTime) && 
                                !order.getCreateTime().isAfter(endDateTime))
                .collect(Collectors.toList());
        
        int start = (page - 1) * size;
        int end = Math.min(start + size, allOrders.size());
        
        if (start >= allOrders.size()) {
            return new ArrayList<>();
        }
        
        return allOrders.subList(start, end);
    }


    @Override
    public List<Order> getOrdersByUserIdAndDateRange(Long userId, LocalDate startDate, LocalDate endDate) {
        if (startDate == null || endDate == null) {
            return getOrdersByUserId(userId);
        }
        
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(LocalTime.MAX);
        
        return orderRepository.findByUserIdAndCreateTimeBetween(userId, startDateTime, endDateTime);
    }

    @Override
    public Order cancelOrderByUser(Long orderId, Long userId) {
        Order order = getOrderByIdAndUserId(orderId, userId);
        
        if (order.getStatus() != Order.Status.PENDING) {
            throw new RuntimeException("只有待支付订单可以取消");
        }
        
        order.setStatus(Order.Status.CANCELLED);
        return orderRepository.save(order);
    }

    @Override
    public Order getOrderByIdAndUserId(Long orderId, Long userId) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new RuntimeException("订单不存在"));
        
        if (!order.getUser().getId().equals(userId)) {
            throw new RuntimeException("无权访问此订单");
        }
        
        return order;
    }

    @Override
    public Order updateOrderInfo(Long orderId, Long userId, String shippingAddress, 
                                String receiverName, String receiverPhone, String paymentMethod) {
        Order order = getOrderByIdAndUserId(orderId, userId);
        
        // 检查订单状态是否允许编辑
        if (order.getStatus() != Order.Status.PENDING) {
            throw new RuntimeException("当前订单状态不允许编辑");
        }
        
        // 更新订单信息
        order.setShippingAddress(shippingAddress);
        order.setReceiverName(receiverName);
        order.setReceiverPhone(receiverPhone);
        order.setPaymentMethod(paymentMethod);
        
        return orderRepository.save(order);
    }
    
    // 辅助类：用于统计单个商品的销售数据
    private static class ProductStats {
        private final com.yourdomain.eshop.entity.Product product;
        private long sales;
        private BigDecimal revenue;
        
        public ProductStats(com.yourdomain.eshop.entity.Product product) {
            this.product = product;
            this.sales = 0L;
            this.revenue = BigDecimal.ZERO;
        }
        
        public void addSales(long quantity) {
            this.sales += quantity;
        }
        
        public void addRevenue(BigDecimal amount) {
            this.revenue = this.revenue.add(amount);
        }
        
        public long getSales() {
            return sales;
        }
        
        public BigDecimal getRevenue() {
            return revenue;
        }
        
        public Map<String, Object> toMap() {
            Map<String, Object> map = new HashMap<>();
            map.put("id", product.getId());
            map.put("name", product.getName());
            map.put("sales", sales);
            map.put("revenue", revenue);
            return map;
        }
    }
}
