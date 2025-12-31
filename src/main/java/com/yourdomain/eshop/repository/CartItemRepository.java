package com.yourdomain.eshop.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import com.yourdomain.eshop.entity.CartItem;


import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface CartItemRepository extends JpaRepository<CartItem, Long> {
    

    List<CartItem> findByUserId(Long userId);

    List<CartItem> findByProductId(Long Id);
    // 修复方法2：同时根据用户ID和产品ID查询，并通过关联对象访问
    @Query("SELECT ci FROM CartItem ci JOIN FETCH ci.product WHERE ci.user.id = :userId AND ci.product.id = :productId")
    Optional<CartItem> findByUserIdAndProductIdWithProduct(@Param("userId") Long userId, @Param("productId") Long productId);
    void deleteByUserId(Long userId);
    // 在 CartRepository 中
    @Query("SELECT DISTINCT ci FROM CartItem ci " +
        "LEFT JOIN FETCH ci.product p " +
        "LEFT JOIN FETCH p.category " + // 如果需要分类信息
        "LEFT JOIN FETCH p.merchant " +     // 如果需要商家信息
        "WHERE ci.user.id = :userId")
    List<CartItem> findByUserIdWithProducts(@Param("userId") Long userId);
    CartItem findByUserIdAndProductId( Long userId, Long productId);
    // 如果需要加载更多关联，可以这样写：
    // @Query("SELECT ci FROM CartItem ci JOIN FETCH ci.product p JOIN FETCH p.category WHERE ci.userId = :userId")
    // List<CartItem> findByUserIdWithProductAndCategory(@Param("userId") Long userId);
}
