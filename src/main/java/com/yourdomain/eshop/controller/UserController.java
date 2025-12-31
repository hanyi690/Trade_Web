package com.yourdomain.eshop.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;

import com.yourdomain.eshop.entity.User;
import com.yourdomain.eshop.entity.Shop;
import com.yourdomain.eshop.service.UserService;
import com.yourdomain.eshop.service.ShopService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/user")
public class UserController {

    private final UserService userService;
    private final ShopService shopService;

    public UserController(UserService userService, ShopService shopService) {
        this.userService = userService;
        this.shopService = shopService;
    }

    @GetMapping("/login")
    public String loginForm(@RequestParam(value = "error", required = false) String error, Model model) {
        if (error != null) {
            model.addAttribute("error", "用户名或密码错误");
        }
        return "user/login";
    }

    @GetMapping("/register")
    public String registerForm() {
        return "user/register";
    }

    @PostMapping("/register")
    public String registerSubmit(@RequestParam("username") String username,
                                 @RequestParam("password") String password,
                                 @RequestParam("confirmPassword") String confirmPassword,
                                 @RequestParam(value = "email") String email,
                                 @RequestParam(value = "phone", required = false) String phone,
                                 RedirectAttributes ra) {
        if (!validateRegistration(username, password, confirmPassword, email, phone, ra)) {
            return "redirect:/user/register";
        }

        try {
            userService.registerUser(username.trim(), password, email.trim(), phone != null ? phone.trim() : null);
            ra.addFlashAttribute("success", "注册成功，请登录");
            return "redirect:/user/login";
        } catch (Exception e) {
            ra.addFlashAttribute("error", "注册失败: " + e.getMessage());
            return "redirect:/user/register";
        }
    }

    @GetMapping("/profile")
    public String profile(@AuthenticationPrincipal User currentUser, Model model, RedirectAttributes ra) {
        if (currentUser == null) {
            ra.addFlashAttribute("error", "请先登录");
            return "redirect:/user/login";
        }

        User latestUser = userService.getUserById(currentUser.getId());
        model.addAttribute("user", latestUser);
        
        if (latestUser.getRole() == User.Role.CONSUMER) {
            model.addAttribute("canApplyMerchant", true);
        }
        
        if (latestUser.getRole() == User.Role.MERCHANT) {
            try {
                Shop userShop = shopService.getShopByMerchantId(latestUser.getId());
                model.addAttribute("shop", userShop);
            } catch (Exception e) {
                model.addAttribute("hasShop", false);
            }
        }

        return "user/profile";
    }

    @PostMapping("/unregister")
    public String unregister(@AuthenticationPrincipal User currentUser,
                             HttpServletRequest request,
                             RedirectAttributes ra) {
        if (currentUser == null) {
            ra.addFlashAttribute("error", "请先登录");
            return "redirect:/user/login";
        }

        try {
            userService.deleteUser(currentUser.getId());

            SecurityContextHolder.clearContext();
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }

            ra.addFlashAttribute("success", "您的账户已成功注销。");
            return "redirect:/";
        } catch (Exception e) {
            ra.addFlashAttribute("error", "注销账户失败: " + e.getMessage());
            return "redirect:/user/profile";
        }
    }
    
    private boolean validateRegistration(String username, String password, String confirmPassword,
                                       String email, String phone, RedirectAttributes ra) {
        if (username == null || username.trim().isEmpty()) {
            ra.addFlashAttribute("error", "用户名不能为空");
            return false;
        }
        if (password == null || password.isEmpty()) {
            ra.addFlashAttribute("error", "密码不能为空");
            return false;
        }
        if (!password.equals(confirmPassword)) {
            ra.addFlashAttribute("error", "两次输入的密码不一致");
            return false;
        }

        if (email == null || email.trim().isEmpty()) {
            ra.addFlashAttribute("error", "邮箱不能为空");
            return false;
        }

        if (phone != null && !phone.trim().isEmpty()) {
            String phoneRegex = "^1[3-9]\\d{9}$";
            if (!phone.trim().matches(phoneRegex)) {
                ra.addFlashAttribute("error", "手机号格式不正确，请输入11位有效手机号");
                return false;
            }
        }

        if (userService.existsByUsername(username)) {
            ra.addFlashAttribute("error", "用户名已存在");
            return false;
        }
        if (userService.existsByEmail(email.trim())) {
            ra.addFlashAttribute("error", "邮箱已被使用");
            return false;
        }
        
        return true;
    }
}
