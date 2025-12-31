package com.yourdomain.eshop.service.impl;

import com.yourdomain.eshop.entity.*;
import com.yourdomain.eshop.repository.*;
import com.yourdomain.eshop.service.StatisticsService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Transactional
public class StatisticsServiceImpl implements StatisticsService {
    
    private final ShopRepository shopRepository;
    private final ProductRepository productRepository;
    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    
    public StatisticsServiceImpl(ShopRepository shopRepository,
                                ProductRepository productRepository,
                                OrderRepository orderRepository,
                                UserRepository userRepository) {
        this.shopRepository = shopRepository;
        this.productRepository = productRepository;
        this.orderRepository = orderRepository;
        this.userRepository = userRepository;
    }
    
    @Override
    public Map<String, Object> getPlatformStats() {
        Map<String, Object> stats = new HashMap<>();
        
        long totalShops = shopRepository.count();
        stats.put("totalShops", totalShops);
        stats.put("activeShops", totalShops);
        
        stats.put("totalProducts", productRepository.count());
        
        LocalDateTime todayStart = LocalDate.now().atStartOfDay();
        LocalDateTime todayEnd = LocalDate.now().atTime(LocalTime.MAX);
        List<Order> todayOrders = orderRepository.findAll().stream()
            .filter(order -> !order.getCreateTime().isBefore(todayStart) && !order.getCreateTime().isAfter(todayEnd))
            .collect(Collectors.toList());
        
        stats.put("todayOrders", todayOrders.size());
        stats.put("todaySales", todayOrders.stream()
            .map(Order::getTotalAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add));
        
        List<Order> allOrders = orderRepository.findAll();
        stats.put("totalOrders", (long) allOrders.size());
        stats.put("totalSales", allOrders.stream()
            .map(Order::getTotalAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add));
        stats.put("totalUsers", userRepository.count());
        
        return stats;
    }
    
    @Override
    public Map<String, Object> getShopStats(Long shopId, LocalDate startDate, LocalDate endDate) {
        shopRepository.findById(shopId)
            .orElseThrow(() -> new RuntimeException("店铺不存在"));
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("todayOrders", 0);
        stats.put("todaySales", BigDecimal.ZERO);
        stats.put("totalOrders", 0);
        stats.put("totalSales", BigDecimal.ZERO);
        stats.put("totalQuantity", 0);
        stats.put("todayQuantity", 0);
        
        return stats;
    }
    
    @Override
    public Map<String, Object> getPlatformSalesStats(LocalDate startDate, LocalDate endDate) {
        if (startDate == null) startDate = LocalDate.now().minusDays(30);
        if (endDate == null) endDate = LocalDate.now();
        
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(LocalTime.MAX);
        
        List<Order> ordersInRange = orderRepository.findAll().stream()
            .filter(order -> !order.getCreateTime().isBefore(startDateTime) && !order.getCreateTime().isAfter(endDateTime))
            .collect(Collectors.toList());
        
        BigDecimal totalSales = ordersInRange.stream()
            .map(Order::getTotalAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        long totalOrders = ordersInRange.size();
        long totalQuantity = ordersInRange.stream()
            .flatMap(order -> order.getOrderItems().stream())
            .mapToLong(OrderItem::getQuantity)
            .sum();
        
        BigDecimal avgOrderAmount = totalOrders > 0 ? 
            totalSales.divide(BigDecimal.valueOf(totalOrders), 2, RoundingMode.HALF_UP) : 
            BigDecimal.ZERO;
        
        List<User> allUsers = userRepository.findAll();
        long newUsers = allUsers.stream()
            .filter(user -> user.getCreatedTime() != null &&
                           !user.getCreatedTime().isBefore(startDateTime) && 
                           !user.getCreatedTime().isAfter(endDateTime))
            .count();
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalSales", totalSales);
        stats.put("totalOrders", totalOrders);
        stats.put("totalQuantity", totalQuantity);
        stats.put("avgOrderAmount", avgOrderAmount);
        stats.put("totalUsers", newUsers);
        stats.put("totalShops", shopRepository.count());
        
        return stats;
    }
    
    @Override
    public List<Map<String, Object>> getPlatformDailySales(LocalDate startDate, LocalDate endDate) {
        List<Map<String, Object>> dailyData = new ArrayList<>();
        
        if (startDate == null || endDate == null) {
            return dailyData;
        }
        
        List<Order> allOrders = orderRepository.findAll();
        LocalDate currentDate = startDate;
        
        while (!currentDate.isAfter(endDate)) {
            LocalDateTime dayStart = currentDate.atStartOfDay();
            LocalDateTime dayEnd = currentDate.atTime(LocalTime.MAX);
            
            List<Order> dayOrders = allOrders.stream()
                .filter(order -> !order.getCreateTime().isBefore(dayStart) && !order.getCreateTime().isAfter(dayEnd))
                .collect(Collectors.toList());
            
            BigDecimal daySales = dayOrders.stream()
                .map(Order::getTotalAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
            
            Map<String, Object> dayData = new HashMap<>();
            dayData.put("date", currentDate.toString());
            dayData.put("sales", daySales.doubleValue());
            dayData.put("orders", dayOrders.size());
            
            dailyData.add(dayData);
            currentDate = currentDate.plusDays(1);
        }
        
        return dailyData;
    }
    
    @Override
    public Map<String, Long> getPlatformOrderStatusDistribution(LocalDate startDate, LocalDate endDate) {
        List<Order> allOrders = orderRepository.findAll();
        
        if (startDate != null && endDate != null) {
            LocalDateTime startDateTime = startDate.atStartOfDay();
            LocalDateTime endDateTime = endDate.atTime(LocalTime.MAX);
            
            allOrders = allOrders.stream()
                .filter(order -> !order.getCreateTime().isBefore(startDateTime) && !order.getCreateTime().isAfter(endDateTime))
                .collect(Collectors.toList());
        }
        
        Map<String, Long> distribution = new HashMap<>();
        for (Order order : allOrders) {
            String status = order.getStatus().name();
            distribution.put(status, distribution.getOrDefault(status, 0L) + 1);
        }
        
        return distribution;
    }
    
    @Override
    public List<Map<String, Object>> getRecentActivities(int limit) {
        List<Order> recentOrders = orderRepository.findAll().stream()
            .sorted((a, b) -> b.getCreateTime().compareTo(a.getCreateTime()))
            .limit(limit)
            .collect(Collectors.toList());
        
        return recentOrders.stream()
            .map(order -> {
                Map<String, Object> activity = new HashMap<>();
                activity.put("icon", "fa-shopping-cart");
                activity.put("description", String.format("用户 %s 创建了订单 #%d", 
                    order.getUser().getUsername(), order.getId()));
                activity.put("time", order.getCreateTime().toString());
                return activity;
            })
            .collect(Collectors.toList());
    }
}
