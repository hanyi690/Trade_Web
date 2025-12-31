package com.yourdomain.eshop.service;

import com.yourdomain.eshop.entity.Shop;
import java.util.List;

public interface ShopService {
    
    // 创建商店（仅限商家用户）
    Shop createShop(Long merchantId, String shopName, String description, String contactPhone);
    
    // 根据ID获取商店
    Shop getShopById(Long id);
    
    // 根据商家用户ID获取商店
    Shop getShopByMerchantId(Long merchantId);
    
    // 根据商家用户名获取商店
    Shop getShopByMerchantUsername(String username);
    
    // 更新商店信息
    Shop updateShop(Long shopId, String name, String description, String contactPhone, 
                   String contactEmail, String address, String logoUrl);
    
    // 删除商店
    void deleteShop(Long shopId);
    
    // 获取所有商店列表
    List<Shop> getAllShops();
    
    // 检查商家是否有商店
    boolean hasShop(Long merchantId);
    
    // 保存商店（用于更新）
    Shop saveShop(Shop shop);
    
    // 新增：搜索店铺（支持分页）
    List<Shop> searchShops(String keyword, int page, int size);
    
    // 新增：获取所有店铺（支持分页）
    List<Shop> getAllShops(int page, int size);

}

