package com.yourdomain.eshop.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "order_items")
public class OrderItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id")
    private Order order;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    private Product product;

    private Integer quantity;

    @Column(precision = 19, scale = 2)
    private BigDecimal price; // 单价（下单时快照）

    // 订单项状态枚举
    public enum Status {
        PENDING,    // 待发货
        SHIPPED,    // 已发货
        DELIVERED   // 已送达
    }

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private Status status = Status.PENDING;

    @Column(name = "shipped_time")
    private LocalDateTime shippedTime;

    @Column(name = "delivered_time")
    private LocalDateTime deliveredTime;

    public OrderItem() {}

    // 辅助方法：发货
    public void ship() {
        this.status = Status.SHIPPED;
        this.shippedTime = LocalDateTime.now();
    }

    // 辅助方法：确认送达
    public void deliver() {
        this.status = Status.DELIVERED;
        this.deliveredTime = LocalDateTime.now();
    }

    // 检查是否可以发货
    public boolean canShip() {
        return status == Status.PENDING;
    }

    // 检查是否可以确认收货
    public boolean canDeliver() {
        return status == Status.SHIPPED;
    }

    // getters / setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Order getOrder() { return order; }
    public void setOrder(Order order) { this.order = order; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public Status getStatus() { return status; }
    public void setStatus(Status status) { this.status = status; }

    public LocalDateTime getShippedTime() { return shippedTime; }
    public void setShippedTime(LocalDateTime shippedTime) { this.shippedTime = shippedTime; }

    public LocalDateTime getDeliveredTime() { return deliveredTime; }
    public void setDeliveredTime(LocalDateTime deliveredTime) { this.deliveredTime = deliveredTime; }
}
