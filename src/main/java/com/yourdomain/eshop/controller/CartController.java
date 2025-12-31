package com.yourdomain.eshop.controller;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.yourdomain.eshop.entity.User;
import com.yourdomain.eshop.entity.CartItem;
import com.yourdomain.eshop.service.CartService;

@Controller
@RequestMapping("/cart")
public class CartController {

    private final CartService cartService;

    public CartController(CartService cartService) {
        this.cartService = cartService;
    }

    @GetMapping
    public String viewCart(@AuthenticationPrincipal User currentUser, Model model, RedirectAttributes ra) {
       if (currentUser == null) {
            ra.addFlashAttribute("error", "请先登录");
            return "redirect:/user/login";
        }

        try {
            List<CartItem> cartItems = cartService.getCartItemsForCurrentUser();
            model.addAttribute("cartItems", cartItems);

            BigDecimal total = cartItems.stream()
                .map(item -> item.getProduct().getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
            model.addAttribute("total", total);

            return "cart";
        } catch (Exception e) {
            ra.addFlashAttribute("error", "系统错误: " + e.getMessage());
            return "redirect:/";
        }
    }

    @PostMapping("/add")
    public String addToCart(@AuthenticationPrincipal User authUser,
                            @RequestParam Long productId,
                            @RequestParam(defaultValue = "1") Integer quantity,
                            RedirectAttributes ra) {
        if (authUser == null) {
            ra.addFlashAttribute("error", "请先登录");
            return "redirect:/user/login";
        }

        try {
            cartService.addToCart(productId, quantity);
            ra.addFlashAttribute("success", "已添加到购物车");
        } catch (RuntimeException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }

        return "redirect:/cart";
    }

    @PostMapping("/update")
    public String updateQuantity(@AuthenticationPrincipal User authUser,
                                 @RequestParam Long cartItemId,
                                 @RequestParam Integer quantity,
                                 RedirectAttributes ra) {
        if (authUser == null) {
            ra.addFlashAttribute("error", "请先登录");
            return "redirect:/user/login";
        }

        try {
            cartService.updateCartItemQuantity(cartItemId, quantity);
            ra.addFlashAttribute("success", "购物车已更新");
        } catch (RuntimeException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }

        return "redirect:/cart";
    }

    @PostMapping("/remove")
    public String removeFromCart(@AuthenticationPrincipal User authUser,
                                 @RequestParam Long cartItemId,
                                 RedirectAttributes ra) {
        if (authUser == null) {
            ra.addFlashAttribute("error", "请先登录");
            return "redirect:/user/login";
        }

        try {
            cartService.removeFromCart(cartItemId);
            ra.addFlashAttribute("success", "已从购物车移除");
        } catch (RuntimeException e) {
            ra.addFlashAttribute("error", "移除失败: " + e.getMessage());
        }

        return "redirect:/cart";
    }

    @PostMapping("/clear")
    public String clearCart(@AuthenticationPrincipal User authUser, RedirectAttributes ra) {
        if (authUser == null) {
            ra.addFlashAttribute("error", "请先登录");
            return "redirect:/user/login";
        }

        try {
            cartService.clearCart();
            ra.addFlashAttribute("success", "购物车已清空");
        } catch (RuntimeException e) {
            ra.addFlashAttribute("error", "清空失败: " + e.getMessage());
        }

        return "redirect:/cart";
    }
}