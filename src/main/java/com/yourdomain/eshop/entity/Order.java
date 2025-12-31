package com.yourdomain.eshop.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "orders")
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    // 状态枚举定义 - 简化版本
    public enum Status {
        PENDING,     // 待支付/待处理
        COMPLETED,   // 已完成（所有商品已送达）
        CANCELLED    // 已取消
    }

    @Enumerated(EnumType.STRING)
    @Column(length = 50)
    private Status status;

    @Column(name = "total_amount", precision = 19, scale = 2)
    private BigDecimal totalAmount;

    @Column(name = "create_time")
    private LocalDateTime createTime;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OrderItem> orderItems = new ArrayList<>();

    // 新增收货信息字段
    @Column(name = "shipping_address", length = 500)
    private String shippingAddress;

    @Column(name = "receiver_name", length = 100)
    private String receiverName;

    @Column(name = "receiver_phone", length = 20)
    private String receiverPhone;

    @Column(name = "payment_method", length = 50)
    private String paymentMethod;

    // 新增支付时间字段
    @Column(name = "paid_time")
    private LocalDateTime paidTime;

    public Order() {}

    @PrePersist
    public void prePersist() {
        if (createTime == null) {
            createTime = LocalDateTime.now();
        }
    }

    // 辅助方法：将字符串状态转换为枚举
    public static Status fromString(String status) {
        if (status == null) {
            return null;
        }
        try {
            // 直接尝试转换（如数据库已存储为枚举名）
            return Status.valueOf(status.toUpperCase());
        } catch (IllegalArgumentException e) {
            // 兼容旧的字符串状态
            switch (status) {
                case "待支付":
                case "待处理":
                    return Status.PENDING;
                case "已完成":
                    return Status.COMPLETED;
                case "已取消":
                    return Status.CANCELLED;
                default:
                    throw new IllegalArgumentException("无效的订单状态: " + status);
            }
        }
    }

    // 检查订单是否已支付
    public boolean isPaid() {
        return paidTime != null;
    }

    // 检查订单是否可以取消
    public boolean canCancel() {
        return status == Status.PENDING && !isPaid();
    }

    // 检查订单是否可以发货
    public boolean canShip() {
        return status == Status.PENDING && isPaid();
    }

    // 检查订单是否可以确认收货
    public boolean canConfirmReceipt() {
        if (status != Status.PENDING) {
            return false;
        }
        // 只要有一个订单项已发货，就可以确认收货
        return orderItems.stream().anyMatch(item -> 
            item.getStatus() == OrderItem.Status.SHIPPED);
    }

    // 检查订单是否所有商品都已送达
    public boolean areAllItemsDelivered() {
        if (orderItems.isEmpty()) {
            return false;
        }
        return orderItems.stream().allMatch(item -> 
            item.getStatus() == OrderItem.Status.DELIVERED);
    }

    // 辅助方法：更新订单状态
    public void updateStatus() {
        if (areAllItemsDelivered()) {
            status = Status.COMPLETED;
        }
    }

    // helpers
    public void addItem(OrderItem item) {
        item.setOrder(this);
        orderItems.add(item);
    }

    // getters / setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public Status getStatus() { return status; }
    public void setStatus(Status status) { this.status = status; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }

    public List<OrderItem> getOrderItems() { return orderItems; }
    public void setOrderItems(List<OrderItem> orderItems) { this.orderItems = orderItems; }

    public String getShippingAddress() { return shippingAddress; }
    public void setShippingAddress(String shippingAddress) { this.shippingAddress = shippingAddress; }

    public String getReceiverName() { return receiverName; }
    public void setReceiverName(String receiverName) { this.receiverName = receiverName; }

    public String getReceiverPhone() { return receiverPhone; }
    public void setReceiverPhone(String receiverPhone) { this.receiverPhone = receiverPhone; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public LocalDateTime getPaidTime() { return paidTime; }
    public void setPaidTime(LocalDateTime paidTime) { this.paidTime = paidTime; }
}
