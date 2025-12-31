package com.yourdomain.eshop.controller;

import com.yourdomain.eshop.entity.*;
import com.yourdomain.eshop.service.*;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
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
    
    public AdminController(ShopService shopService, ProductService productService,
                          OrderService orderService, UserService userService,
                          StatisticsService statisticsService) {
        this.shopService = shopService;
        this.productService = productService;
        this.orderService = orderService;
        this.userService = userService;
        this.statisticsService = statisticsService;
    }
    
    @GetMapping("")
    public String adminDashboard(Model model) {
        model.addAttribute("platformStats", statisticsService.getPlatformStats());
        model.addAttribute("recentActivities", statisticsService.getRecentActivities(10));
        model.addAttribute("currentTab", "overview");
        return "admin/admin";
    }
    
    @GetMapping("/shops")
    public String manageShops(
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            Model model) {
        
        List<Shop> shops;
        if (keyword != null && !keyword.trim().isEmpty()) {
            shops = shopService.searchShops(keyword, page, size);
        } else {
            shops = shopService.getAllShops(page, size);
        }
        
        model.addAttribute("shops", shops);
        model.addAttribute("keyword", keyword);
        model.addAttribute("currentTab", "shops");
        return "admin/admin";
    }
    
    @GetMapping("/products")
    public String manageProducts(
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            Model model) {
        
        List<Product> products;
        if (keyword != null && !keyword.trim().isEmpty()) {
            products = productService.searchProducts(keyword, page, size);
        } else {
            products = productService.getAllProducts(page, size);
        }
        
        model.addAttribute("products", products);
        model.addAttribute("keyword", keyword);
        model.addAttribute("currentTab", "products");
        return "admin/admin";
    }
    
    @GetMapping("/orders")
    public String manageOrders(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            Model model) {
        
        if (startDate == null) startDate = LocalDate.now().minusDays(30);
        if (endDate == null) endDate = LocalDate.now();
        
        List<Order> orders = orderService.getOrdersByDateRange(startDate, endDate, page, size);
        
        model.addAttribute("orders", orders);
        model.addAttribute("startDate", startDate);
        model.addAttribute("endDate", endDate);
        model.addAttribute("currentTab", "orders");
        return "admin/admin";
    }
    
    @GetMapping("/users")
    public String manageUsers(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            Model model) {
        
        model.addAttribute("users", userService.getAllUsers(page, size));
        model.addAttribute("currentTab", "users");
        return "admin/admin";
    }
    
    @GetMapping("/statistics")
    public String platformStatistics(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            Model model) {
        
        if (startDate == null) startDate = LocalDate.now().minusDays(30);
        if (endDate == null) endDate = LocalDate.now();
        
        Map<String, Object> stats = statisticsService.getPlatformSalesStats(startDate, endDate);
        List<Map<String, Object>> dailySales = statisticsService.getPlatformDailySales(startDate, endDate);
        Map<String, Long> statusDistribution = statisticsService.getPlatformOrderStatusDistribution(startDate, endDate);
        
        model.addAttribute("statistics", stats);
        model.addAttribute("dailySalesData", dailySales);
        model.addAttribute("statusDistribution", statusDistribution);
        model.addAttribute("startDate", startDate);
        model.addAttribute("endDate", endDate);
        model.addAttribute("currentTab", "statistics");
        return "admin/admin";
    }
    
    @PostMapping("/shops/delete/{shopId}")
    public String deleteShop(@PathVariable Long shopId) {
        shopService.deleteShop(shopId);
        return "redirect:/admin/shops";
    }
    
    @GetMapping("/export")
    public String exportData() {
        return "redirect:/admin";
    }
}
