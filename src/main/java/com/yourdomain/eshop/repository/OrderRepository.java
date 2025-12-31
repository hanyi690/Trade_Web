package com.yourdomain.eshop.repository;

import java.util.List;
import java.time.LocalDateTime;
import org.springframework.data.domain.Pageable;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.yourdomain.eshop.entity.Order;

public interface OrderRepository extends JpaRepository<Order, Long> {
    
    // 根据用户ID查找订单列表，使用JOIN FETCH立即加载orderItems和product
    @Query("SELECT DISTINCT o FROM Order o LEFT JOIN FETCH o.orderItems oi LEFT JOIN FETCH oi.product WHERE o.user.id = :userId")
    List<Order> findByUserId(@Param("userId") Long userId);
    
    // 根据商品ID列表查询订单（通过订单项关联），使用JOIN FETCH立即加载orderItems和product
    @Query("SELECT DISTINCT o FROM Order o JOIN FETCH o.orderItems oi JOIN FETCH oi.product WHERE oi.product.id IN :productIds")
    List<Order> findOrdersByProductIds(@Param("productIds") List<Long> productIds);
    
    // 根据商品ID列表和时间范围查询订单，使用JOIN FETCH立即加载orderItems和product
    @Query("SELECT DISTINCT o FROM Order o JOIN FETCH o.orderItems oi JOIN FETCH oi.product WHERE oi.product.id IN :productIds AND o.createTime >= :startDate AND o.createTime <= :endDate")
    List<Order> findOrdersByProductIdsAndDateRange(
            @Param("productIds") List<Long> productIds,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate);
    
    // 根据商品ID列表、时间范围和限制数量查询最新订单，按创建时间降序排序
    @Query("SELECT DISTINCT o FROM Order o JOIN FETCH o.orderItems oi JOIN FETCH oi.product WHERE oi.product.id IN :productIds AND o.createTime >= :startDate AND o.createTime <= :endDate ORDER BY o.createTime DESC")
    List<Order> findRecentOrdersByProductIdsAndDateRange(
            @Param("productIds") List<Long> productIds,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate,
            Pageable pageable);
    
    // 根据商品ID列表和状态查询订单，使用JOIN FETCH立即加载orderItems和product
    @Query("SELECT DISTINCT o FROM Order o JOIN FETCH o.orderItems oi JOIN FETCH oi.product WHERE oi.product.id IN :productIds AND o.status = :status")
    List<Order> findOrdersByProductIdsAndStatus(
            @Param("productIds") List<Long> productIds,
            @Param("status") String status);
    
    // 可选：根据用户ID和状态查找订单
    // List<Order> findByUserIdAndStatus(Long userId, String status);
    
    // 新增：根据用户ID和日期范围查询订单，使用JOIN FETCH立即加载orderItems和product
    @Query("SELECT DISTINCT o FROM Order o LEFT JOIN FETCH o.orderItems oi LEFT JOIN FETCH oi.product WHERE o.user.id = :userId AND o.createTime >= :startDate AND o.createTime <= :endDate")
    List<Order> findByUserIdAndCreateTimeBetween(
            @Param("userId") Long userId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate);
    
    // 新增：根据订单ID和用户ID查询订单，使用JOIN FETCH立即加载orderItems和product
    @Query("SELECT DISTINCT o FROM Order o LEFT JOIN FETCH o.orderItems oi LEFT JOIN FETCH oi.product WHERE o.id = :orderId AND o.user.id = :userId")
    Order findByIdAndUserId(@Param("orderId") Long orderId, @Param("userId") Long userId);
}
