package com.yourdomain.eshop.service.impl;

import com.yourdomain.eshop.entity.Shop;
import com.yourdomain.eshop.entity.User;
import com.yourdomain.eshop.repository.ShopRepository;
import com.yourdomain.eshop.repository.UserRepository;
import com.yourdomain.eshop.service.ShopService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class ShopServiceImpl implements ShopService {

    private final ShopRepository shopRepository;
    private final UserRepository userRepository;

    public ShopServiceImpl(ShopRepository shopRepository,
                          UserRepository userRepository) {
        this.shopRepository = shopRepository;
        this.userRepository = userRepository;
    }

    @Override
    public Shop createShop(Long merchantId, String shopName, String description, String contactPhone) {
        User merchant = userRepository.findById(merchantId)
            .orElseThrow(() -> new RuntimeException("商家用户不存在"));
        
        if (merchant.getRole() != User.Role.MERCHANT) {
            throw new RuntimeException("只有商家用户可以创建商店");
        }
        
        if (shopRepository.existsByMerchantId(merchantId)) {
            throw new RuntimeException("该商家已拥有商店");
        }
        
        Shop shop = new Shop();
        shop.setName(shopName);
        shop.setDescription(description);
        shop.setMerchant(merchant);
        shop.setContactPhone(contactPhone);
        
        Shop savedShop = shopRepository.save(shop);
        
        merchant.setShop(savedShop);
        userRepository.save(merchant);
        
        return savedShop;
    }

    @Override
    public Shop getShopById(Long id) {
         return shopRepository.findByIdWithMerchant(id)
        .orElseThrow(() -> new RuntimeException("商店不存在"));
    }

    @Override
    public Shop getShopByMerchantId(Long merchantId) {
        return shopRepository.findByMerchantId(merchantId)
            .orElseThrow(() -> new RuntimeException("该商家没有商店"));
    }

    @Override
    public Shop getShopByMerchantUsername(String username) {
        return shopRepository.findByMerchantUsername(username)
            .orElseThrow(() -> new RuntimeException("该商家没有商店"));
    }

    @Override
    public Shop updateShop(Long shopId, String name, String description, String contactPhone, 
                          String contactEmail, String address, String logoUrl) {
        Shop shop = getShopById(shopId);
        
        if (name != null && !name.trim().isEmpty()) {
            shop.setName(name);
        }
        
        if (description != null) {
            shop.setDescription(description);
        }
        
        if (contactPhone != null) {
            shop.setContactPhone(contactPhone);
        }
        
        if (contactEmail != null) {
            shop.setContactEmail(contactEmail);
        }
        
        if (address != null) {
            shop.setAddress(address);
        }
        
        if (logoUrl != null) {
            shop.setLogoUrl(logoUrl);
        }
        
        return shopRepository.save(shop);
    }

    @Override
    public void deleteShop(Long shopId) {
        Shop shop = getShopById(shopId);
        
        User merchant = shop.getMerchant();
        if (merchant != null) {
            merchant.setShop(null);
            userRepository.save(merchant);
        }
        
        shopRepository.delete(shop);
    }

    @Override
    public List<Shop> getAllShops() {
        return shopRepository.findAll();
    }

    @Override
    public boolean hasShop(Long merchantId) {
        return shopRepository.existsByMerchantId(merchantId);
    }

    @Override
    public Shop saveShop(Shop shop) {
        return shopRepository.save(shop);
    }

    @Override
    public List<Shop> searchShops(String keyword, int page, int size) {
        List<Shop> allShops = shopRepository.findAll();
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            String searchTerm = keyword.toLowerCase().trim();
            allShops = allShops.stream()
                .filter(shop -> 
                    (shop.getName() != null && shop.getName().toLowerCase().contains(searchTerm)) ||
                    (shop.getDescription() != null && shop.getDescription().toLowerCase().contains(searchTerm)) ||
                    (shop.getMerchant() != null && shop.getMerchant().getUsername() != null && 
                     shop.getMerchant().getUsername().toLowerCase().contains(searchTerm))
                )
                .collect(Collectors.toList());
        }
        
        return paginate(allShops, page, size);
    }
    
    @Override
    public List<Shop> getAllShops(int page, int size) {
        return paginate(shopRepository.findAll(), page, size);
    }
    
    private List<Shop> paginate(List<Shop> items, int page, int size) {
        int start = (page - 1) * size;
        int end = Math.min(start + size, items.size());
        
        if (start >= items.size()) {
            return List.of();
        }
        
        return items.subList(start, end);
    }
}
