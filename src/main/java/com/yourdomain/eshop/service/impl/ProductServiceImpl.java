package com.yourdomain.eshop.service.impl;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.yourdomain.eshop.entity.CartItem;
import com.yourdomain.eshop.entity.Product;
import com.yourdomain.eshop.entity.User;
import com.yourdomain.eshop.repository.ProductRepository;
import com.yourdomain.eshop.service.ProductService;
import com.yourdomain.eshop.repository.CartItemRepository;

@Service
@Transactional
public class ProductServiceImpl implements ProductService {

	private final ProductRepository repo;
	private final CartItemRepository cartItemRepository;

	public ProductServiceImpl(ProductRepository repo,
							  CartItemRepository cartItemRepository) {
		this.repo = repo;
		this.cartItemRepository = cartItemRepository;
	}

	@Override
	public List<Product> listAll() {
		return repo.findAll();
	}

	@Override
	public Product getById(Long id) {
		Optional<Product> o = repo.findByIdWithMerchantAndCategory(id);
		return o.orElse(null);
	}

	@Override
	public Product save(Product product) {
		return repo.save(product);
	}

	@Override
	public void deleteById(Long id) {
        List<CartItem> cartItems = cartItemRepository.findByProductId(id);
        cartItemRepository.deleteAll(cartItems);
		repo.deleteById(id);
	}

	@Override
	public List<Product> listByCategoryId(Long categoryId) {
		return repo.findByCategoryId(categoryId);
	}

	@Override
	public List<Product> listByMerchantId(Long merchantId) {
		return repo.findByMerchantId(merchantId);
	}

	@Override
	public List<Product> searchByName(String keyword) {
		if (keyword == null || keyword.trim().isEmpty()) {
			return repo.findAll();
		}
		return repo.findByNameOrDescriptionContaining(keyword.trim());
	}

    @Override
    public List<Product> searchByNameAndMerchant(String keyword, User merchant) {
        return repo.findByNameContainingAndMerchant(keyword, merchant);
    }

    @Override
    public List<Product> listByMerchant(User merchant) {
        return repo.findByMerchant(merchant);
    }

    @Override
    public List<Product> searchProducts(String keyword, int page, int size) {
        List<Product> products = searchByName(keyword);
        return paginate(products, page, size);
    }
    
    @Override
    public List<Product> getAllProducts(int page, int size) {
        return paginate(listAll(), page, size);
    }
    
    private List<Product> paginate(List<Product> items, int page, int size) {
        int start = (page - 1) * size;
        int end = Math.min(start + size, items.size());
        
        if (start >= items.size()) {
            return List.of();
        }
        
        return items.subList(start, end);
    }
}
