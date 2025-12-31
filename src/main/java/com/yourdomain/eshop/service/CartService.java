package com.yourdomain.eshop.service;

import java.util.List;
import com.yourdomain.eshop.entity.CartItem;

public interface CartService {
    List<CartItem> getCartItemsForCurrentUser();
    void addToCart(Long productId, Integer quantity);
    void updateCartItemQuantity(Long cartItemId, Integer quantity);
    void removeFromCart(Long cartItemId);
    void clearCart();
}
