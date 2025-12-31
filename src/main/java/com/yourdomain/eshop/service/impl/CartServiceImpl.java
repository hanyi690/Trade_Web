package com.yourdomain.eshop.service.impl;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.yourdomain.eshop.entity.CartItem;
import com.yourdomain.eshop.entity.User;
import com.yourdomain.eshop.repository.CartItemRepository;
import com.yourdomain.eshop.service.CartService;
import com.yourdomain.eshop.service.UserService;
import com.yourdomain.eshop.repository.ProductRepository;
import java.util.List;

@Service
@Transactional
public class CartServiceImpl implements CartService {

    private final CartItemRepository cartItemRepository;
    private final UserService userService;  // 新增
    private final ProductRepository  productRepository; // 新增

    public CartServiceImpl(CartItemRepository cartItemRepository,
                          UserService userService,
                            ProductRepository productRepository
                        ) {  // 修改
        this.cartItemRepository = cartItemRepository;
        this.userService = userService;  // 新增
        this.productRepository = productRepository; // 新增
    }

    @Override
    public List<CartItem> getCartItemsForCurrentUser() {
        User currentUser = userService.getCurrentUser();
        if (currentUser == null) {
            return List.of();
        }
        return cartItemRepository.findByUserIdWithProducts(currentUser.getId());
    }

    @Override
    public void addToCart(Long productId, Integer quantity) {
        User currentUser = userService.getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("用户未登录");
        }
        
        // 检查购物车是否已存在该商品
        CartItem existingItem = cartItemRepository.findByUserIdAndProductId(
            currentUser.getId(), productId);
            
        if (existingItem != null) {
            // 更新数量
            existingItem.setQuantity(existingItem.getQuantity() + quantity);
            cartItemRepository.save(existingItem);
        } else {
            // 创建新的购物车项
            CartItem cartItem = new CartItem();
            // 这里需要设置商品和用户
            cartItem.setProduct(productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("商品不存在")));
            cartItem.setUser(currentUser);
            cartItem.setQuantity(quantity);
            cartItemRepository.save(cartItem);
        }
    }

    @Override
    public void updateCartItemQuantity(Long cartItemId, Integer quantity) {
        User currentUser = userService.getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("用户未登录");
        }
        
        CartItem cartItem = cartItemRepository.findById(cartItemId)
            .orElseThrow(() -> new RuntimeException("购物车项不存在"));
            
        // 检查权限
        if (!cartItem.getUser().getId().equals(currentUser.getId())) {
            throw new RuntimeException("无权修改此购物车项");
        }
        
        if (quantity <= 0) {
            cartItemRepository.delete(cartItem);
        } else {
            cartItem.setQuantity(quantity);
            cartItemRepository.save(cartItem);
        }
    }

    @Override
    public void removeFromCart(Long cartItemId) {
        User currentUser = userService.getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("用户未登录");
        }
        
        CartItem cartItem = cartItemRepository.findById(cartItemId)
            .orElseThrow(() -> new RuntimeException("购物车项不存在"));
            
        // 检查权限
        if (!cartItem.getUser().getId().equals(currentUser.getId())) {
            throw new RuntimeException("无权删除此购物车项");
        }
        
        cartItemRepository.delete(cartItem);
    }

    @Override
    public void clearCart() {
        User currentUser = userService.getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("用户未登录");
        }
        
        cartItemRepository.deleteByUserId(currentUser.getId());
    }


}
