package com.yourdomain.eshop.controller;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.yourdomain.eshop.entity.User;
import com.yourdomain.eshop.entity.Order;
import com.yourdomain.eshop.service.OrderService;
import com.yourdomain.eshop.service.UserService;
import com.yourdomain.eshop.service.CartService;

import java.math.BigDecimal;
import java.util.List;
import java.time.LocalDate;

@Controller
@RequestMapping("/orders")
public class UserOrderController {

    private final OrderService orderService;
    private final UserService userService;
    private final CartService cartService;

    public UserOrderController(OrderService orderService,
                              UserService userService,
                              CartService cartService) {
        this.orderService = orderService;
        this.userService = userService;
        this.cartService = cartService;
    }

    // GET /orders - 用户订单列表（支持日期筛选）
    @GetMapping("")
    public String listOrders(@AuthenticationPrincipal User currentUser,
                             @RequestParam(value = "startDate", required = false) LocalDate startDate,
                             @RequestParam(value = "endDate", required = false) LocalDate endDate,
                             Model model, RedirectAttributes ra) {
        if (currentUser == null) {
            ra.addFlashAttribute("error", "请先登录");
            return "redirect:/user/login";
        }

        try {
            // 现在这个方法已经在OrderService中定义
            List<Order> orders = (startDate != null && endDate != null) ?
                orderService.getOrdersByUserIdAndDateRange(currentUser.getId(), startDate, endDate) :
                orderService.getOrdersByUserId(currentUser.getId());
            
            model.addAttribute("orders", orders);
            model.addAttribute("startDate", startDate != null ? startDate.toString() : "");
            model.addAttribute("endDate", endDate != null ? endDate.toString() : LocalDate.now().toString());
            model.addAttribute("context", "user");
            return "orders/myorders"; // 这个页面应该包含orderTable组件
        } catch (Exception e) {
            ra.addFlashAttribute("error", "获取订单失败: " + e.getMessage());
            return "redirect:/";
        }
    }

    // POST /orders/{orderId}/cancel - 用户取消订单
    @PostMapping("/{orderId}/cancel")
    public String cancelOrder(@PathVariable Long orderId,
                             @AuthenticationPrincipal User currentUser,
                             RedirectAttributes ra) {
        if (currentUser == null) {
            ra.addFlashAttribute("error", "请先登录");
            return "redirect:/user/login";
        }

        try {
            orderService.cancelOrderByUser(orderId, currentUser.getId());
            ra.addFlashAttribute("success", "订单已成功取消");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "取消订单失败: " + e.getMessage());
        }
        return "redirect:/orders";
    }

    // GET /orders/{orderId} - 查看订单详情
    @GetMapping("/{orderId}")
    public String viewOrderDetail(@PathVariable Long orderId,
                                 @AuthenticationPrincipal User currentUser,
                                 Model model, RedirectAttributes ra) {
        if (currentUser == null) {
            ra.addFlashAttribute("error", "请先登录");
            return "redirect:/user/login";
        }

        try {
            Order order = orderService.getOrderById(orderId);
            model.addAttribute("order", order);
            model.addAttribute("currentUser", currentUser); // 添加当前用户到模型
            model.addAttribute("mode", "view");
            return "orders/orderForm";
        } catch (Exception e) {
            ra.addFlashAttribute("error", "获取订单详情失败: " + e.getMessage());
            return "redirect:/orders";
        }
    }

    // GET /orders/{orderId}/edit - 显示编辑订单表单
    @GetMapping("/{orderId}/edit")
    public String showEditOrderForm(@PathVariable Long orderId,
                                   @AuthenticationPrincipal User currentUser,
                                   Model model, RedirectAttributes ra) {
        if (currentUser == null) {
            ra.addFlashAttribute("error", "请先登录");
            return "redirect:/user/login";
        }

        try {
            Order order = orderService.getOrderByIdAndUserId(orderId, currentUser.getId());
            // 检查订单状态是否允许编辑（例如，仅限待支付或取消状态）
            if (order.getStatus() != Order.Status.PENDING) {
                ra.addFlashAttribute("error", "当前订单状态不允许编辑");
                return "redirect:/orders/" + orderId;
            }
            model.addAttribute("order", order);
            model.addAttribute("currentUser", currentUser); // 添加当前用户到模型
            model.addAttribute("mode", "edit");
            return "orders/orderForm";
        } catch (Exception e) {
            ra.addFlashAttribute("error", "获取订单失败: " + e.getMessage());
            return "redirect:/orders";
        }
    }

    // POST /orders/{orderId}/edit - 更新订单信息
    @PostMapping("/{orderId}/edit")
    public String updateOrder(@PathVariable Long orderId,
                             @AuthenticationPrincipal User currentUser,
                             @RequestParam(value = "shippingAddress", required = false) String shippingAddress,
                             @RequestParam(value = "receiverName", required = false) String receiverName,
                             @RequestParam(value = "receiverPhone", required = false) String receiverPhone,
                             @RequestParam(value = "paymentMethod", required = false) String paymentMethod,
                             RedirectAttributes redirectAttributes) {
        if (currentUser == null) {
            redirectAttributes.addFlashAttribute("error", "请先登录");
            return "redirect:/user/login";
        }

        if (!validateOrderParams(shippingAddress, receiverName, receiverPhone, paymentMethod, redirectAttributes)) {
            return "redirect:/orders/" + orderId + "/edit";
        }

        try {
            // 调用服务更新订单信息
           orderService.updateOrderInfo(orderId, currentUser.getId(),
                    shippingAddress.trim(), receiverName.trim(), receiverPhone.trim(), paymentMethod.trim());
            redirectAttributes.addFlashAttribute("successMessage", "订单信息更新成功！");
            return "redirect:/orders/" + orderId;
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "更新订单失败：" + e.getMessage());
            return "redirect:/orders/" + orderId + "/edit";
        }
    }

    // GET /orders/create - 显示创建订单表单
    @GetMapping("/create")
    public String showOrderForm(@AuthenticationPrincipal UserDetails userDetails,
                                Model model) {
        if (userDetails == null) {
            return "redirect:/user/login";
        }
        
        // 使用 UserService 获取当前用户
        User currentUser = userService.getCurrentUserOrThrow();
        
        // 获取当前用户的购物车信息
        var cartItems = cartService.getCartItemsForCurrentUser();
        if (cartItems.isEmpty()) {
            return "redirect:/cart?empty=true";
        }
        // 计算购物车总金额
        var totalAmount = cartItems.stream()
            .map(item -> item.getProduct().getPrice().multiply(new BigDecimal(item.getQuantity())))
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        model.addAttribute("cartItems", cartItems);
        model.addAttribute("totalAmount", totalAmount);
        model.addAttribute("itemCount", cartItems.size());
        model.addAttribute("currentUser", currentUser);
        model.addAttribute("mode", "create");
        
        return "orders/orderForm";
    }

    // POST /orders/create - 创建订单
    @PostMapping("/create")
    public String createOrder(@AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(value = "shippingAddress", required = false) String shippingAddress,
            @RequestParam(value = "receiverName", required = false) String receiverName,
            @RequestParam(value = "receiverPhone", required = false) String receiverPhone,
            @RequestParam(value = "paymentMethod", required = false) String paymentMethod,
            RedirectAttributes redirectAttributes) {
        
        if (userDetails == null) {
            return "redirect:/user/login";
        }
        
        if (!validateOrderParams(shippingAddress, receiverName, receiverPhone, paymentMethod, redirectAttributes)) {
            return "redirect:/orders/create";
        }
        
        try {
            // 使用 UserService 获取当前用户ID
            Long userId = userService.getCurrentUserIdOrThrow();
            
            // 调用服务创建订单
            Order order = orderService.createOrderFromCartWithShippingInfo(
                userId, 
                shippingAddress.trim(), 
                receiverName.trim(), 
                receiverPhone.trim(), 
                paymentMethod.trim());
            
            redirectAttributes.addFlashAttribute("successMessage", 
                String.format("订单创建成功！订单号：%s，总金额：¥%s", 
                    order.getId(), order.getTotalAmount()));
            return "redirect:/orders";
            
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", 
                "创建订单失败：" + e.getMessage());
            return "redirect:/orders/create";
        }
    }

    // GET /orders/{orderId}/pay - 显示支付页面
    @GetMapping("/{orderId}/pay")
    public String showPaymentPage(@PathVariable Long orderId,
                                 @AuthenticationPrincipal User currentUser,
                                 Model model, RedirectAttributes ra) {
        if (currentUser == null) {
            ra.addFlashAttribute("error", "请先登录");
            return "redirect:/user/login";
        }

        try {
            Order order = orderService.getOrderByIdAndUserId(orderId, currentUser.getId());
            
            // 检查订单状态是否允许支付
            if (order.getStatus() != Order.Status.PENDING) {
                ra.addFlashAttribute("error", "订单状态不允许支付");
                return "redirect:/orders/" + orderId;
            }
            
            model.addAttribute("order", order);
            model.addAttribute("mode", "payment");
            return "orders/payment";
        } catch (Exception e) {
            ra.addFlashAttribute("error", "获取订单失败: " + e.getMessage());
            return "redirect:/orders";
        }
    }

    // POST /orders/{orderId}/pay - 处理支付
    @PostMapping("/{orderId}/pay")
    public String processPayment(@PathVariable Long orderId,
                               @AuthenticationPrincipal User currentUser,
                               RedirectAttributes ra) {
        if (currentUser == null) {
            ra.addFlashAttribute("error", "请先登录");
            return "redirect:/user/login";
        }

        try {
            Order order = orderService.processPayment(orderId, currentUser.getId());
            ra.addFlashAttribute("success", "支付成功！订单号: " + order.getId());
            return "redirect:/orders/" + orderId;
        } catch (Exception e) {
            ra.addFlashAttribute("error", "支付失败: " + e.getMessage());
            return "redirect:/orders/" + orderId + "/pay";
        }
    }

    // POST /orders/{orderId}/items/{orderItemId}/ship - 发货订单项
    @PostMapping("/{orderId}/items/{orderItemId}/ship")
    public String shipOrderItem(@PathVariable Long orderId,
                               @PathVariable Long orderItemId,
                               @AuthenticationPrincipal User currentUser,
                               RedirectAttributes ra) {
        if (currentUser == null) {
            ra.addFlashAttribute("error", "请先登录");
            return "redirect:/user/login";
        }

        // 检查当前用户是否为商家
        if (!currentUser.isMerchant()) {
            ra.addFlashAttribute("error", "只有商家才能执行发货操作");
            return "redirect:/orders/" + orderId;
        }
        try {
            orderService.shipOrderItem(orderItemId, currentUser.getId());
            ra.addFlashAttribute("success", "商品已发货！");
            return "redirect:/orders/" + orderId;
        } catch (Exception e) {
            ra.addFlashAttribute("error", "发货失败: " + e.getMessage());
            return "redirect:/orders/" + orderId;
        }
    }

    // POST /orders/{orderId}/items/{orderItemId}/deliver - 确认收货
    @PostMapping("/{orderId}/items/{orderItemId}/deliver")
    public String deliverOrderItem(@PathVariable Long orderId,
                                  @PathVariable Long orderItemId,
                                  @AuthenticationPrincipal User currentUser,
                                  RedirectAttributes ra) {
        if (currentUser == null) {
            ra.addFlashAttribute("error", "请先登录");
            return "redirect:/user/login";
        }

        try {
            orderService.deliverOrderItem(orderItemId, currentUser.getId());
            ra.addFlashAttribute("success", "确认收货成功！");
            return "redirect:/orders/" + orderId;
        } catch (Exception e) {
            ra.addFlashAttribute("error", "确认收货失败: " + e.getMessage());
            return "redirect:/orders/" + orderId;
        }
    }
    
    private boolean validateOrderParams(String shippingAddress, String receiverName, 
                                       String receiverPhone, String paymentMethod,
                                       RedirectAttributes redirectAttributes) {
        if (shippingAddress == null || shippingAddress.trim().isEmpty()) {
            redirectAttributes.addFlashAttribute("errorMessage", "收货地址不能为空");
            return false;
        }
        
        if (receiverName == null || receiverName.trim().isEmpty()) {
            redirectAttributes.addFlashAttribute("errorMessage", "收货人姓名不能为空");
            return false;
        }
        
        if (receiverPhone == null || receiverPhone.trim().isEmpty()) {
            redirectAttributes.addFlashAttribute("errorMessage", "联系电话不能为空");
            return false;
        }
        
        if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
            redirectAttributes.addFlashAttribute("errorMessage", "请选择支付方式");
            return false;
        }
        
        return true;
    }
}
