package com.yourdomain.eshop.repository;

import com.yourdomain.eshop.entity.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {
    
    // 根据商品ID列表查询订单项
    @Query("SELECT oi FROM OrderItem oi WHERE oi.product.id IN :productIds")
    List<OrderItem> findByProductIds(@Param("productIds") List<Long> productIds);
     List<OrderItem> findByProductId(@Param("productId") Long productId);
    // 根据商品ID列表和订单创建时间范围查询订单项
    @Query("SELECT oi FROM OrderItem oi JOIN oi.order o WHERE oi.product.id IN :productIds AND o.createTime >= :startDate AND o.createTime <= :endDate")
    List<OrderItem> findByProductIdsAndOrderCreateTimeBetween(
            @Param("productIds") List<Long> productIds,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate);
    
    // 根据商品ID列表查询总销售额
    @Query("SELECT SUM(oi.price * oi.quantity) FROM OrderItem oi WHERE oi.product.id IN :productIds")
    BigDecimal sumTotalSalesByProductIds(@Param("productIds") List<Long> productIds);
    
    // 根据商品ID列表查询总销量（商品数量）
    @Query("SELECT SUM(oi.quantity) FROM OrderItem oi WHERE oi.product.id IN :productIds")
    Long sumTotalQuantityByProductIds(@Param("productIds") List<Long> productIds);
    
    // 根据商品ID列表查询订单数量（去重）
    @Query("SELECT COUNT(DISTINCT oi.order.id) FROM OrderItem oi WHERE oi.product.id IN :productIds")
    Long countDistinctOrdersByProductIds(@Param("productIds") List<Long> productIds);
}
