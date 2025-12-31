package com.yourdomain.eshop.repository;

import com.yourdomain.eshop.entity.Shop;
import com.yourdomain.eshop.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ShopRepository extends JpaRepository<Shop, Long> {
    
  @Query("SELECT s FROM Shop s JOIN FETCH s.merchant WHERE s.merchant.id = :merchantId")
Optional<Shop> findByMerchantId(@Param("merchantId") Long merchantId);
    // 根据商家用户查找商店
    Optional<Shop> findByMerchant(User merchant);
    
    // 检查商家是否已有商店
    boolean existsByMerchantId(Long merchantId);
    
    // 根据商家用户名查找商店
    Optional<Shop> findByMerchantUsername(String username);

    // 根据ID获取商店并同时加载商家信息
    @Query("SELECT s FROM Shop s JOIN FETCH s.merchant WHERE s.id = :id")
    Optional<Shop> findByIdWithMerchant(@Param("id") Long id);
}
