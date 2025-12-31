package com.yourdomain.eshop.entity;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "products")
@SQLDelete(sql = "UPDATE products SET deleted = 1 WHERE id = ?")
@SQLRestriction("deleted = 0") 
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @Column(length = 1000)
    private String description;

    @Column(precision = 19, scale = 2)
    private BigDecimal price;

    @Column(name = "image_urls", length = 1000)
    private String imageUrls;

    @Column(name = "image_filename", length = 255)
    private String imageFilename;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "merchant_id", nullable = false)
    private User merchant;

    @Column(name = "deleted", nullable = false)
    private Boolean deleted = false;

    @Column(name = "sales")
    private Integer sales = 0;

    @Column(name = "stock")
    private Integer stock = 0;

    @Column(name = "brand", length = 100)
    private String brand;

    @Column(name = "model", length = 100)
    private String model;

    @Column(name = "weight")
    private BigDecimal weight;

    @Column(name = "material", length = 100)
    private String material;

    public Product() {}

    public Product(String name, String description, BigDecimal price) {
        this.name = name;
        this.description = description;
        this.price = price;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    
    public String getImageUrl() { return imageUrls; }
    public void setImageUrl(String imageUrl) { this.imageUrls = imageUrl; }
    
    public String getImageFilename() { return imageFilename; }
    public void setImageFilename(String imageFilename) { this.imageFilename = imageFilename; }
    
    public Integer getSales() { return sales; }
    public void setSales(Integer sales) { this.sales = sales != null ? sales : 0; }
    
    public Integer getStock() { return stock; }
    public void setStock(Integer stock) { this.stock = stock != null ? stock : 0; }
    
    public String getBrand() { return brand; }
    public void setBrand(String brand) { this.brand = brand; }
    
    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }
    
    public BigDecimal getWeight() { return weight; }
    public void setWeight(BigDecimal weight) { this.weight = weight; }
    
    public String getMaterial() { return material; }
    public void setMaterial(String material) { this.material = material; }

    public Category getCategory() { return category; }
    public void setCategory(Category category) { this.category = category; }

    public User getMerchant() { return merchant; }
    public void setMerchant(User merchant) { this.merchant = merchant; }

    public void increaseStock(Integer quantity) {
        if (quantity != null && quantity > 0) {
            this.stock += quantity;
        }
    }

    public void decreaseStock(Integer quantity) {
        if (quantity != null && quantity > 0 && this.stock >= quantity) {
            this.stock -= quantity;
        }
    }

    public void increaseSales(Integer quantity) {
        if (quantity != null && quantity > 0) {
            this.sales += quantity;
        }
    }
}