package com.yourdomain.eshop.service;

import com.yourdomain.eshop.entity.Product;
import com.yourdomain.eshop.entity.User;
import java.util.List;

public interface ProductService {
    List<Product> listAll();
    Product getById(Long id);
    Product save(Product product);
    void deleteById(Long id);
    List<Product> listByCategoryId(Long categoryId);
    List<Product> listByMerchantId(Long merchantId);
    List<Product> searchByName(String keyword);
    List<Product> searchByNameAndMerchant(String keyword, User merchant);
    List<Product> listByMerchant(User merchant);
    
    // 新增：搜索商品（支持分页）
    List<Product> searchProducts(String keyword, int page, int size);
    
    // 新增：获取所有商品（支持分页）
    List<Product> getAllProducts(int page, int size);
}
