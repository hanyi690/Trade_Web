package com.yourdomain.eshop.entity;

import jakarta.persistence.*;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.Collections;

@Entity
@Table(name = "users")
public class User implements UserDetails {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(nullable = false, unique = true, length = 100)
	private String username;

	@Column(nullable = false, length = 255)
	private String password; // 请在业务层进行加密存储

	@Column(length = 200)
	private String email;

	// 新增：手机号字段
	@Column(length = 20)
	private String phone;

	@Column(name = "created_time")
	private LocalDateTime createdTime;

	// 新增：角色枚举（仅两种角色）
	public enum Role {
		ADMIN,      // 管理员 - 完全权限
		CONSUMER,   // 消费者 - 只读权限
		MERCHANT    // 商家 - 商品管理权限
	}

	// 新增：角色字段
	@Enumerated(EnumType.STRING)
	@Column(nullable = false,length = 20)
	private Role role = Role.CONSUMER;

	// 新增：商店引用（双向关联）
	@OneToOne(mappedBy = "merchant", fetch = FetchType.EAGER, cascade = CascadeType.ALL)
	private Shop shop;

	public User() {}

	@PrePersist
	public void prePersist() {
		if (createdTime == null) {
			createdTime = LocalDateTime.now();
		}
	}

// getters / setters
	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public void setUsername(String username) { this.username = username; }

	public void setPassword(String password) { this.password = password; }

	public String getEmail() { return email; }
	public void setEmail(String email) { this.email = email; }

	// 新增：phone的getter和setter
	public String getPhone() { return phone; }
	public void setPhone(String phone) { this.phone = phone; }

	public LocalDateTime getCreatedTime() { return createdTime; }
	public void setCreatedTime(LocalDateTime createdTime) { this.createdTime = createdTime; }

	public Role getRole() { return role; }
	public void setRole(Role role) { this.role = role; }

	// 新增：Shop的getter和setter
	public Shop getShop() { return shop; }
	public void setShop(Shop shop) { this.shop = shop; }

	// 辅助方法：判断是否为商家
	public boolean isMerchant() {
		return this.role == Role.MERCHANT;
	}

	// UserDetails 接口方法
	@Override
	public Collection<? extends GrantedAuthority> getAuthorities() {
		// 根据 enum role 返回对应的角色权限，供 Spring Security 使用
		if (this.role == Role.ADMIN) {
			return Collections.singletonList(new SimpleGrantedAuthority("ROLE_ADMIN"));
		} else if (this.role == Role.MERCHANT) {
			return Collections.singletonList(new SimpleGrantedAuthority("ROLE_MERCHANT"));
		}
		// 默认以普通用户身份授权
		return Collections.singletonList(new SimpleGrantedAuthority("ROLE_CONSUMER"));
	}

	@Override
	public String getPassword() {
		return this.password; // 假设有 password 字段
	}

	@Override
	public String getUsername() {
		return this.username; // 假设有 username 字段
	}

	@Override
	public boolean isAccountNonExpired() {
		return true;
	}

	@Override
	public boolean isAccountNonLocked() {
		return true;
	}

	@Override
	public boolean isCredentialsNonExpired() {
		return true;
	}

	@Override
	public boolean isEnabled() {
		return true;
	}

}
