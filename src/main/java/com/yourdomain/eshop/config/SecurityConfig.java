package com.yourdomain.eshop.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

import com.yourdomain.eshop.service.UserService;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private UserService userService;

	public SecurityConfig(UserService userService) {
        this.userService = userService;
	}

	@Bean
	public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
		return config.getAuthenticationManager();
	}

	@Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    http
        .authorizeHttpRequests(authorize -> authorize
            // 1. 优先放行所有静态资源（使用 requestMatchers 的多个参数时，顺序生效）
            .requestMatchers(
                "/resources/**","/images/**"
            ).permitAll()
            .requestMatchers("/WEB-INF/views/**").permitAll()

            .requestMatchers(
                "/", "/home",
                "/user/login", "/user/register", "/user/auth",
                "/error", "/products", "/products/**","/categories", "/categories/**",
                "/shops", "/shops/**"
            ).permitAll()
            // 3. 需要特定权限的路径
            .requestMatchers(
                "/shops/create", "/shops/manage/**", "/shops/edit/**",
                "/shops/delete/**", "/shops/my"
            ).hasAnyRole("MERCHANT", "CONSUMER")  // 修改：允许CONSUMER和MERCHANT
            .requestMatchers(
                "/admin/**",
                "/categories/new", "/categories/edit/**", "/categories/delete/**"
            ).hasRole("ADMIN")
            // 新增：/products/manage/** 允许 ADMIN 和 MERCHANT 访问
            .requestMatchers("/products/manage/**").hasAnyRole("ADMIN", "MERCHANT")
            // 4. 需要认证（登录）的路径 - 更新订单相关路径
            .requestMatchers(
                "/cart/**", "/user/profile", 
                "/orders", "/orders/**",  // 所有订单相关路径都需要认证
                "/orders/create", "/user/unregister"
            ).authenticated()
            // 5. 其他所有请求
            .anyRequest().authenticated()
        )
        .formLogin(form -> form
            .loginPage("/user/login")
            .loginProcessingUrl("/user/auth")
            .defaultSuccessUrl("/products", true)
            .failureUrl("/user/login?error=true")
            .permitAll()
        )
        .logout(logout -> logout
            .logoutUrl("/user/logout")
            .logoutSuccessUrl("/?logout=true")  // 添加注销成功参数
            .invalidateHttpSession(true)
            .clearAuthentication(true)           // 明确清除认证信息
            .deleteCookies("JSESSIONID")
            .permitAll()
        )
        .userDetailsService(userService)
        .csrf(csrf -> csrf.disable()); // 开发环境可禁用，生产环境建议开启

    return http.build();
	}
}