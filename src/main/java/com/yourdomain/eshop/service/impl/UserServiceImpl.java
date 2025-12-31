package com.yourdomain.eshop.service.impl;

import com.yourdomain.eshop.entity.User;
import com.yourdomain.eshop.repository.UserRepository;
import com.yourdomain.eshop.service.UserService;
import com.yourdomain.eshop.entity.Product;
import com.yourdomain.eshop.entity.Order;
import com.yourdomain.eshop.repository.CartItemRepository;
import com.yourdomain.eshop.repository.OrderRepository;
import com.yourdomain.eshop.repository.ProductRepository;
import com.yourdomain.eshop.repository.ShopRepository;
import com.yourdomain.eshop.repository.OrderItemRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;

import java.util.List;

@Service
@Transactional
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final CartItemRepository cartItemRepository;
    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final ShopRepository shopRepository;
    //private final OrderItemRepository orderItemRepository;

    public UserServiceImpl(UserRepository userRepository, PasswordEncoder passwordEncoder,
                          CartItemRepository cartItemRepository,
                          OrderRepository orderRepository,
                          ProductRepository productRepository,
                          ShopRepository shopRepository,
                          OrderItemRepository orderItemRepository) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.cartItemRepository = cartItemRepository;
        this.orderRepository = orderRepository;
        this.productRepository = productRepository;
        this.shopRepository = shopRepository;
        //this.orderItemRepository = orderItemRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        return userRepository.findByUsername(username)
            .orElseThrow(() -> new UsernameNotFoundException("用户不存在: " + username));
    }

    @Override
    public User registerUser(String username, String password, String email, String phone) {
        if (userRepository.findByUsername(username).isPresent()) {
            throw new RuntimeException("用户名已存在");
        }
        
        if (email != null && !email.isEmpty() && userRepository.findByEmail(email).isPresent()) {
            throw new RuntimeException("邮箱已被使用");
        }
        
        User user = new User();
        user.setUsername(username);
        user.setPassword(passwordEncoder.encode(password));
        user.setEmail(email);
        user.setPhone(phone);
        user.setRole(User.Role.CONSUMER);
        
        return userRepository.save(user);
    }

    @Override
    public User getUserById(Long id) {
        return userRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("用户不存在"));
    }

    @Override
    public User getUserByUsername(String username) {
        return userRepository.findByUsername(username)
            .orElseThrow(() -> new RuntimeException("用户不存在"));
    }

    @Override
    public User updateUser(Long id, String username, String password, String email, String phone, User.Role role) {
        Long currentUserId = getCurrentUserId();
        
        User user = getUserById(id);
        
        if (username != null && !username.isEmpty() && !username.equals(user.getUsername())) {
            userRepository.findByUsername(username)
                .ifPresent(existingUser -> {
                    if (!existingUser.getId().equals(id)) {
                        throw new RuntimeException("用户名已被其他用户使用");
                    }
                });
            user.setUsername(username);
        }
        
        if (email != null && !email.isEmpty() && !email.equals(user.getEmail())) {
            userRepository.findByEmail(email)
                .ifPresent(existingUser -> {
                    if (!existingUser.getId().equals(id)) {
                        throw new RuntimeException("邮箱已被其他用户使用");
                    }
                });
            user.setEmail(email);
        }
        
        if (password != null && !password.isEmpty() && !password.equals(user.getPassword())) {
            user.setPassword(passwordEncoder.encode(password));
        }
        
        if (phone != null) {
            user.setPhone(phone);
        }
        
        if (role != null) {
            user.setRole(role);
        }
        
        User updatedUser = userRepository.save(user);
        
        if (currentUserId != null && currentUserId.equals(id)) {
            refreshAuthentication(updatedUser);
        }
        
        return updatedUser;
    }

    @Override
    public void deleteUser(Long id) {
        User user = getUserById(id);
        
        cartItemRepository.deleteByUserId(id);
        
        List<Order> userOrders = orderRepository.findByUserId(id);
        orderRepository.deleteAll(userOrders);
        
        if (user.getRole() == User.Role.MERCHANT) {
            shopRepository.findByMerchantId(id).ifPresent(shop -> {
                user.setShop(null);
                userRepository.save(user);
                shopRepository.delete(shop);
            });
            
            List<Product> merchantProducts = productRepository.findByMerchantId(id);
            merchantProducts.forEach(product -> {
                cartItemRepository.deleteAll(cartItemRepository.findByProductId(product.getId()));
                productRepository.delete(product);
            });
        }
        
        userRepository.deleteById(id);
    }

    @Override
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @Override
    public boolean existsByUsername(String username) {
        return userRepository.findByUsername(username).isPresent();
    }

    @Override
    public boolean existsByEmail(String email) {
        return userRepository.findByEmail(email).isPresent();
    }

    @Override
    public User saveUser(User user) {
        if (user.getPassword() != null && !user.getPassword().startsWith("{")) {
            user.setPassword(passwordEncoder.encode(user.getPassword()));
        }

        if (user.getRole() == null) {
            user.setRole(User.Role.CONSUMER);
        }

        return userRepository.save(user);
    }

    @Override
    public User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        
        if (authentication == null || !authentication.isAuthenticated()) {
            return null;
        }
        
        Object principal = authentication.getPrincipal();
        String username;
        
        if (principal instanceof UserDetails) {
            username = ((UserDetails) principal).getUsername();
        } else if (principal instanceof String) {
            username = (String) principal;
        } else {
            return null;
        }
        
        if ("anonymousUser".equals(username)) {
            return null;
        }
        
        try {
            return userRepository.findByUsername(username).orElse(null);
        } catch (Exception e) {
            return null;
        }
    }

    @Override
    public User getCurrentUserOrThrow() {
        User currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("用户未登录");
        }
        return currentUser;
    }

    @Override
    public Long getCurrentUserId() {
        User currentUser = getCurrentUser();
        return currentUser != null ? currentUser.getId() : null;
    }

    @Override
    public Long getCurrentUserIdOrThrow() {
        return getCurrentUserOrThrow().getId();
    }

    @Override
    public boolean isCurrentUserAdmin() {
        return hasRole(User.Role.ADMIN);
    }

    @Override
    public boolean isCurrentUserMerchant() {
        return hasRole(User.Role.MERCHANT);
    }

    @Override
    public boolean isCurrentUserConsumer() {
        return hasRole(User.Role.CONSUMER);
    }

    @Override
    public List<User> getAllUsers(int page, int size) {
        List<User> allUsers = userRepository.findAll();
        
        int start = (page - 1) * size;
        int end = Math.min(start + size, allUsers.size());
        
        if (start >= allUsers.size()) {
            return List.of();
        }
        
        return allUsers.subList(start, end);
    }
    
    private boolean hasRole(User.Role role) {
        User currentUser = getCurrentUser();
        return currentUser != null && currentUser.getRole() == role;
    }
    
    private void refreshAuthentication(User user) {
        Authentication currentAuth = SecurityContextHolder.getContext().getAuthentication();
        if (currentAuth != null && currentAuth.isAuthenticated()) {
            Authentication newAuth = new UsernamePasswordAuthenticationToken(
                user,
                currentAuth.getCredentials(),
                user.getAuthorities()
            );
            SecurityContextHolder.getContext().setAuthentication(newAuth);
        }
    }
}