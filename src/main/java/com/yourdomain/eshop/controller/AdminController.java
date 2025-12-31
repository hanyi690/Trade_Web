package com.yourdomain.eshop.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.yourdomain.eshop.entity.*;
import com.yourdomain.eshop.entity.User.Role;
import com.yourdomain.eshop.service.*;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;
import java.util.*;

@Controller
@RequestMapping("/admin")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final ShopService shopService;
    private final ProductService productService;
    private final OrderService orderService;
    private final UserService userService;
    private final StatisticsService statisticsService;
    private final ObjectMapper objectMapper;

    public AdminController(ShopService shopService, ProductService productService,
                           OrderService orderService, UserService userService,
                           StatisticsService statisticsService) {
        this.shopService = shopService;
        this.productService = productService;
        this.orderService = orderService;
        this.userService = userService;
        this.statisticsService = statisticsService;
        this.objectMapper = new ObjectMapper(); // 建议复用 ObjectMapper
    }

    /**
     * 每个方法执行前都会调用，确保侧边栏统计数据在所有页面刷新时都存在
     */
    @ModelAttribute
    public void addGlobalAttributes(Model model) {
        model.addAttribute("platformStats", statisticsService.getPlatformStats());
    }

    // --- 仪表盘 ---
    @GetMapping("")
    public String adminDashboard(Model model) {
        LocalDate end = LocalDate.now();
        LocalDate start = end.minusDays(7);
        
        model.addAttribute("recentActivities", statisticsService.getRecentActivities(10));
        addChartDataToModel(model, start, end);
        
        model.addAttribute("currentTab", "overview");
        return "admin/admin";
    }

    // --- 店铺管理 ---
    @GetMapping("/shops")
    public String manageShops(
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            Model model) {
        
        List<Shop> shops = (keyword != null && !keyword.trim().isEmpty()) 
                ? shopService.searchShops(keyword, page, size)
                : shopService.getAllShops(page, size);
        
        model.addAttribute("shops", shops);
        model.addAttribute("keyword", keyword);
        model.addAttribute("currentTab", "shops");
        model.addAttribute("showIdColumn", true); // 默认显示ID列
        model.addAttribute("showAddButton", true); // 显示添加按钮
        
        // 添加CSS资源引用
        model.addAttribute("additionalCss", Arrays.asList(
            "/resources/css/modules/shop-table.css"
        ));
        
        return "admin/admin";
    }

    // --- 商品管理 ---
    @GetMapping("/products")
    public String manageProducts(
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            Model model) {
        
        List<Product> products = (keyword != null && !keyword.trim().isEmpty())
                ? productService.searchProducts(keyword, page, size)
                : productService.getAllProducts(page, size);
        
        model.addAttribute("products", products);
        model.addAttribute("keyword", keyword);
        model.addAttribute("currentTab", "products");
        return "admin/admin";
    }

    // --- 订单管理 ---
    @GetMapping("/orders")
    public String manageOrders(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            Model model) {
        
        LocalDate start = (startDate != null) ? startDate : LocalDate.now().minusDays(30);
        LocalDate end = (endDate != null) ? endDate : LocalDate.now();
        
        model.addAttribute("orders", orderService.getOrdersByDateRange(start, end, page, size));
        model.addAttribute("startDate", start);
        model.addAttribute("endDate", end);
        model.addAttribute("currentTab", "orders");
        model.addAttribute("context", "admin"); // 添加上下文标识
        return "admin/admin";
    }

    // --- 管理员订单操作 ---
    
    // 强制取消（保留此功能）
    // URL: /admin/orders/{orderId}/force-cancel
    @PostMapping("/orders/{orderId}/force-cancel")
    public String adminForceCancel(@PathVariable Long orderId, RedirectAttributes ra) {
        try {
            orderService.forceCancelOrder(orderId); // 改为调用新的强制取消方法
            ra.addFlashAttribute("success", "订单已强制取消");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "取消失败: " + e.getMessage());
        }
        return "redirect:/admin/orders";
    }

    // --- 用户管理 ---
    @GetMapping("/users")
    public String manageUsers(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            Model model) {
        
        model.addAttribute("users", userService.getAllUsers(page, size));
        model.addAttribute("currentTab", "users");
        return "admin/admin";
    }

    // --- 编辑用户 ---
    @GetMapping("/users/edit/{userId}")
    public String editUser(@PathVariable Long userId, Model model) {
        User user = userService.getUserById(userId);
        model.addAttribute("user", user);
        model.addAttribute("isAdminEdit", true); // 标记为管理员编辑模式
        return "user/profile"; // 复用user/profile页面
    }



    // --- 设置用户角色 ---
    @PostMapping("/users/setRole")
    public String setUserRole(@RequestParam Long userId,
                            @RequestParam Role role,
                            RedirectAttributes ra) {
        try {
            // 获取当前用户以检查权限
            User currentUser = userService.getCurrentUserOrThrow();
            
            // 不能修改自己的角色
            if (currentUser.getId().equals(userId)) {
                ra.addFlashAttribute("error", "不能修改自己的角色");
                return "redirect:/admin/users";
            }
            
            // 更新用户角色
             userService.updateUser(userId, null, null, null, null, role);
            
            String roleName = "";
            switch(role) {
                case ADMIN: roleName = "管理员"; break;
                case MERCHANT: roleName = "商家"; break;
                case CONSUMER: roleName = "消费者"; break;
            }
            
            ra.addFlashAttribute("success", "用户角色已更新为: " + roleName);
            return "redirect:/admin/users";
        } catch (Exception e) {
            ra.addFlashAttribute("error", "设置角色失败: " + e.getMessage());
            return "redirect:/admin/users";
        }
    }

    
    // --- 平台统计 ---
    @GetMapping("/statistics")
    public String platformStatistics(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            Model model) {
        
        LocalDate start = (startDate != null) ? startDate : LocalDate.now().minusDays(30);
        LocalDate end = (endDate != null) ? endDate : LocalDate.now();
        
        model.addAttribute("statistics", statisticsService.getPlatformSalesStats(start, end));
        addChartDataToModel(model, start, end);
        
        model.addAttribute("startDate", start);
        model.addAttribute("endDate", end);
        model.addAttribute("currentTab", "statistics");
        return "admin/admin";
    }

    @PostMapping("/shops/delete/{shopId}")
    public String deleteShop(@PathVariable Long shopId) {
        shopService.deleteShop(shopId);
        return "redirect:/admin/shops";
    }

    /**
     * 辅助方法：统一处理图表数据的 JSON 序列化
     */
    private void addChartDataToModel(Model model, LocalDate start, LocalDate end) {
        List<Map<String, Object>> dailySales = statisticsService.getPlatformDailySales(start, end);
        Map<String, Long> statusDist = statisticsService.getPlatformOrderStatusDistribution(start, end);

        try {
            model.addAttribute("dailySalesDataJson", objectMapper.writeValueAsString(dailySales));
            model.addAttribute("statusDistributionJson", objectMapper.writeValueAsString(statusDist));
        } catch (JsonProcessingException e) {
            // 记录日志...
            model.addAttribute("dailySalesDataJson", "[]");
            model.addAttribute("statusDistributionJson", "{}");
        }
    }
}