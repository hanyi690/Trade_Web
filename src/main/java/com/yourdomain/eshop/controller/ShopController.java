package com.yourdomain.eshop.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import com.yourdomain.eshop.entity.Product;
import com.yourdomain.eshop.entity.Shop;
import com.yourdomain.eshop.entity.User;
import com.yourdomain.eshop.entity.Order;
import com.yourdomain.eshop.service.ShopService;
import com.yourdomain.eshop.service.UserService;
import com.yourdomain.eshop.service.ProductService;
import com.yourdomain.eshop.service.OrderService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/shops")
public class ShopController {

    private final ShopService shopService;
    private final UserService userService;
    private final ProductService productService;
    private final OrderService orderService;
    private final DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy年MM月dd日");
    private final DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy年MM月dd日 HH:mm");

    public ShopController(ShopService shopService, UserService userService, 
                         ProductService productService, OrderService orderService) {
        this.shopService = shopService;
        this.userService = userService;
        this.productService = productService;
        this.orderService = orderService;
    }

    /**
     * 显示所有商店列表
     */
    @GetMapping
    public String listShops(Model model, @AuthenticationPrincipal UserDetails userDetails) {
        model.addAttribute("shops", shopService.getAllShops());
        
        if (userDetails != null) {
            User currentUser = userService.getUserByUsername(userDetails.getUsername());
            model.addAttribute("currentUserId", currentUser.getId());
            
            if (currentUser.getRole() == User.Role.MERCHANT) {
                Shop shop=shopService.getShopByMerchantId(currentUser.getId());
                if(shop!=null){
                  model.addAttribute("userShop", shop);}
            }
        }
        
        return "shops/shopList";
    }

    /**
     * 显示商店详情
     */
    @GetMapping("/{id}")
    public String shopDetail(@PathVariable Long id, Model model, 
                            @AuthenticationPrincipal UserDetails userDetails) {
        Shop shop = shopService.getShopById(id);
        model.addAttribute("shop", shop);
        model.addAttribute("shopProducts", productService.listByMerchantId(shop.getMerchant().getId()));
        
        formatShopDates(shop, model);
        
        if (userDetails != null) {
            User currentUser = userService.getUserByUsername(userDetails.getUsername());
            model.addAttribute("currentUserId", currentUser.getId());
            model.addAttribute("isOwner", currentUser.getId().equals(shop.getMerchant().getId()));
        }
        
        return "shops/shopDetail";
    }



    /**
     * 显示创建商店表单
     */
    @GetMapping("/create")
    public String createShopForm(Model model) {
        User currentUser = requireLogin();
        if (currentUser == null) return "redirect:/user/login";
        
        // 允许CONSUMER和MERCHANT访问
        if (currentUser.getRole() != User.Role.MERCHANT && currentUser.getRole() != User.Role.CONSUMER) {
            throw new RuntimeException("只有普通用户和商家可以创建店铺");
        }
        
        // 如果用户已经是商家，检查是否已有店铺
        if (currentUser.getRole() == User.Role.MERCHANT && shopService.hasShop(currentUser.getId())) {
            Shop shop = shopService.getShopByMerchantId(currentUser.getId());
            return "redirect:/shops/" + shop.getId();
        }
        
        // 如果用户是普通用户，显示申请成为商家的表单
        model.addAttribute("shop", new Shop());
        model.addAttribute("isConsumer", currentUser.getRole() == User.Role.CONSUMER);
        return "shops/shopForm";
    }

    /**
     * 处理创建商店请求
     */
    @PostMapping("/create")
    public String createShop(@ModelAttribute Shop shop, RedirectAttributes redirectAttributes) {
        User currentUser = requireLogin();
        if (currentUser == null) return "redirect:/user/login";
        
        try {
            // 如果是普通用户，先升级为商家角色
            if (currentUser.getRole() == User.Role.CONSUMER) {
                currentUser.setRole(User.Role.MERCHANT);
                userService.updateUser(currentUser.getId(), currentUser.getUsername(),
                    currentUser.getPassword(), currentUser.getEmail(),
                    currentUser.getPhone(), currentUser.getRole());
            }
            
            // 使用服务创建商店
            Shop createdShop = shopService.createShop(
                currentUser.getId(),
                shop.getName(),
                shop.getDescription(),
                shop.getContactPhone()
            );
            
            // 设置其他可选字段
            if (shop.getContactEmail() != null && !shop.getContactEmail().trim().isEmpty()) {
                createdShop.setContactEmail(shop.getContactEmail().trim());
            }
            if (shop.getAddress() != null && !shop.getAddress().trim().isEmpty()) {
                createdShop.setAddress(shop.getAddress().trim());
            }
            if (shop.getLogoUrl() != null && !shop.getLogoUrl().trim().isEmpty()) {
                createdShop.setLogoUrl(shop.getLogoUrl().trim());
            }
            shopService.saveShop(createdShop);
            
            redirectAttributes.addFlashAttribute("success", "店铺创建成功！您已成为商家用户。");
            return "redirect:/shops/" + createdShop.getId();
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/shops/create";
        }
    }

    /**
     * 显示编辑商店表单
     */
    @GetMapping("/edit/{id}")
    public String editShopForm(@PathVariable Long id, Model model) {
        User currentUser = requireLogin();
        if (currentUser == null) return "redirect:/user/login";
        
        Shop shop = shopService.getShopById(id);
        
        // 权限检查：只有店铺拥有者或管理员可以编辑
        if (!isOwnerOrAdmin(currentUser, shop)) {
            throw new RuntimeException("您没有权限编辑此店铺");
        }
        
        model.addAttribute("shop", shop);
        return "shops/shopForm";
    }

    /**
     * 处理更新商店请求
     */
    @PostMapping("/update/{id}")
    public String updateShop(@PathVariable Long id, @ModelAttribute Shop shop,
                            RedirectAttributes redirectAttributes) {
        User currentUser = requireLogin();
        if (currentUser == null) return "redirect:/user/login";
        
        Shop existingShop = shopService.getShopById(id);
        
        // 权限检查
        if (!isOwnerOrAdmin(currentUser, existingShop)) {
            throw new RuntimeException("您没有权限编辑此店铺");
        }

        try {
            // 更新商店信息
            Shop updatedShop = shopService.updateShop(
                id,
                shop.getName(),
                shop.getDescription(),
                shop.getContactPhone(),
                shop.getContactEmail(),
                shop.getAddress(),
                shop.getLogoUrl()
            );
            
            redirectAttributes.addFlashAttribute("success", "店铺更新成功！");
            return "redirect:/shops/" + updatedShop.getId();
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/shops/edit/" + id;
        }
    }

    /**
     * 删除商店
     */
    @PostMapping("/delete/{id}")
    public String deleteShop(@PathVariable Long id,
                            @AuthenticationPrincipal UserDetails userDetails,
                            RedirectAttributes redirectAttributes) {
        if (userDetails == null) {
            return "redirect:/user/login";
        }
        
        try {
            shopService.deleteShop(id);
            redirectAttributes.addFlashAttribute("success", "店铺删除成功！");
            return "redirect:/shops";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/shops/" + id;
        }
    }

    /**
     * 显示我的店铺（当前登录商家的店铺）
     */
    @GetMapping("/my")
    public String myShop(Model model) {
        User currentUser = requireLogin();
        if (currentUser == null) return "redirect:/user/login";
        
        if (currentUser.getRole() != User.Role.MERCHANT) {
            throw new RuntimeException("只有商家用户可以查看我的店铺");
        }
        
        try {
            Shop shop = shopService.getShopByMerchantId(currentUser.getId());
            return "redirect:/shops/" + shop.getId();
        } catch (Exception e) {
            // 商家还没有店铺，重定向到创建页面
            return "redirect:/shops/create";
        }
    }

    /**
     * 管理我的店铺（合并了商品管理）
     */
    @GetMapping("/{id}/manage")
    public String manageShop(@PathVariable Long id, Model model,
                            @RequestParam(value = "tab", defaultValue = "overview") String tab,
                            @RequestParam(value = "startDate", required = false) String startDateStr,
                            @RequestParam(value = "endDate", required = false) String endDateStr,
                            @RequestParam(value = "success", required = false) String success,
                            @RequestParam(value = "error", required = false) String error) {
        User currentUser = requireLogin();
        if (currentUser == null) return "redirect:/user/login";
        
        Shop shop = shopService.getShopById(id);
        
        // 权限检查：只有店铺拥有者可以管理
        if (!currentUser.getId().equals(shop.getMerchant().getId())) {
            throw new RuntimeException("您没有权限管理此店铺");
        }
        
        // 新增：处理日期参数
        LocalDate startDate = startDateStr != null ? LocalDate.parse(startDateStr) : LocalDate.now().minusDays(30);
        LocalDate endDate = endDateStr != null ? LocalDate.parse(endDateStr) : LocalDate.now();
        model.addAttribute("startDate", startDate);
        model.addAttribute("endDate", endDate);
        
        // 获取店铺的商品列表
        List<Product> products = productService.listByMerchantId(currentUser.getId());
        model.addAttribute("shop", shop);
        model.addAttribute("products", products);
        model.addAttribute("currentTab", tab);
        
        // 新增：处理商品操作消息参数
        if (success != null) {
            model.addAttribute("successMessage", getProductSuccessMessage(success));
        }
        if (error != null) {
            model.addAttribute("errorMessage", getProductErrorMessage(error));
        }
        
        // 优化：在后端计算店铺统计信息
        int totalProductCount = products.size();
        int activeProductCount = 0;
        int totalSalesCount = 0;
        
        for (Product product : products) {
            if(product.getStock() > 0)
                {activeProductCount++;}
            if (product.getSales() != null) {
                totalSalesCount += product.getSales();
            }
        }
        
        model.addAttribute("totalProductCount", totalProductCount);
        model.addAttribute("activeProductCount", activeProductCount);
        model.addAttribute("totalSalesCount", totalSalesCount);
        
        // 优化：在后端格式化日期
        DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy年MM月dd日 HH:mm");
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy年MM月dd日");
        
        if (shop.getCreatedTime() != null) {
            model.addAttribute("shopCreatedTimeFull", shop.getCreatedTime().format(dateTimeFormatter));
            model.addAttribute("shopCreatedTimeShort", shop.getCreatedTime().format(dateFormatter));
        } else {
            model.addAttribute("shopCreatedTimeFull", "未知");
            model.addAttribute("shopCreatedTimeShort", "未知");
        }
        
        // 新增：获取订单管理数据（支持日期筛选）
        List<Long> productIds = products.stream()
                .map(Product::getId)
                .toList();
        
        if (!productIds.isEmpty() ) {
            loadOrderData(productIds, startDate, endDate, model);
        }
        
        return "shops/shopManage";
    }

    /**
     * 显示商店的商品列表
     * 对应访问路径：/shops/{id}/products
     */
    @GetMapping("/{id}/products")
    public String shopProducts(@PathVariable Long id, Model model,
                              @AuthenticationPrincipal UserDetails userDetails) {
        Shop shop = shopService.getShopById(id);
        model.addAttribute("shop", shop);
        model.addAttribute("products", productService.listByMerchantId(shop.getMerchant().getId()));
        
        formatShopDates(shop, model);
        
        if (userDetails != null) {
            User currentUser = userService.getUserByUsername(userDetails.getUsername());
            model.addAttribute("currentUserId", currentUser.getId());
            model.addAttribute("isOwner", currentUser.getId().equals(shop.getMerchant().getId()));
        }
        
        return "shops/shopProducts";
    }

    /**
     * 根据success参数获取友好的成功消息
     */
    private String getProductSuccessMessage(String success) {
        return switch (success) {
            case "created" -> "商品创建成功！";
            case "updated" -> "商品更新成功！";
            case "deleted" -> "商品删除成功！";
            default -> "操作成功！";
        };
    }
    
    /**
     * 根据error参数获取友好的错误消息
     */
    private String getProductErrorMessage(String error) {
        return switch (error) {
            case "unauthorized" -> "您没有权限执行此操作！";
            default -> "操作失败，请重试！";
        };
    }
    
    private void formatShopDates(Shop shop, Model model) {
        if (shop.getCreatedTime() != null) {
            model.addAttribute("fullcreatedTimeFormatted", shop.getCreatedTime().format(dateTimeFormatter));
            model.addAttribute("createdTimeFormatted", shop.getCreatedTime().format(dateFormatter));
        }
        if (shop.getUpdatedTime() != null) {
            model.addAttribute("fullupdatedTimeFormatted", shop.getUpdatedTime().format(dateTimeFormatter));
            model.addAttribute("updatedTimeFormatted", shop.getUpdatedTime().format(dateFormatter));
        }
    }
    /* 
    private void calculateShopStats(List<Product> products, Model model) {
        int totalProductCount = products.size();
        int activeProductCount = (int) products.stream().filter(p -> p.getStock() > 0).count();
        int totalSalesCount = products.stream()
            .filter(p -> p.getSales() != null)
            .mapToInt(Product::getSales)
            .sum();
        
        model.addAttribute("totalProductCount", totalProductCount);
        model.addAttribute("activeProductCount", activeProductCount);
        model.addAttribute("totalSalesCount", totalSalesCount);
    }
    */
    private void loadOrderData(List<Long> productIds, LocalDate startDate, LocalDate endDate, Model model) {
        List<Order> orders = orderService.getOrdersByProductIdsAndDateRange(productIds, startDate, endDate);
        model.addAttribute("orders", orders);
        
        Map<String, Object> orderStats = orderService.getOrderStatisticsByProductIds(productIds, startDate, endDate);
        model.addAttribute("orderStats", orderStats);
        
        List<Map<String, Object>> dailySalesData = orderService.getDailySalesData(productIds, startDate, endDate);
        try {
            model.addAttribute("dailySalesDataJson", new ObjectMapper().writeValueAsString(dailySalesData));
        } catch (JsonProcessingException e) {
            model.addAttribute("dailySalesDataJson", "[]");
        }

        Map<String, Long> statusDistribution = orderService.getOrderStatusDistribution(productIds, startDate, endDate);
        try {
            model.addAttribute("statusDistributionJson", new ObjectMapper().writeValueAsString(statusDistribution));
        } catch (JsonProcessingException e) {
            model.addAttribute("statusDistributionJson", "{}");
        }
        
        List<Order> recentOrders = orderService.getRecentOrdersByProductIdsAndDateRange(productIds, 10, startDate, endDate);
        model.addAttribute("recentOrders", recentOrders);
        
        Map<String, Object> salesStats = orderService.getSalesStatisticsByProductIds(productIds, startDate, endDate);
        model.addAttribute("salesStats", salesStats);
    }
    
    private User requireLogin() {
        return userService.getCurrentUser();
    }
    
    private boolean isOwnerOrAdmin(User user, Shop shop) {
        return user.getId().equals(shop.getMerchant().getId()) || user.getRole() == User.Role.ADMIN;
    }
}
