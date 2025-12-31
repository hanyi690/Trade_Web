package com.yourdomain.eshop.controller;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.yourdomain.eshop.entity.Product;
import com.yourdomain.eshop.entity.Category;
import com.yourdomain.eshop.entity.User;
import com.yourdomain.eshop.service.ProductService;
import com.yourdomain.eshop.service.CategoryService;

import java.util.List;

@Controller
@RequestMapping("/products")
public class ProductController {

	private final ProductService productService;
	private final CategoryService categoryService;
	

	public ProductController(ProductService productService, 
							CategoryService categoryService) {
		this.productService = productService;
		this.categoryService = categoryService;
	}

	@GetMapping
	public String list(Model model, @RequestParam(value = "keyword", required = false) String keyword) {
		List<Product> products = (keyword != null && !keyword.trim().isEmpty()) ?
			productService.searchByName(keyword) : productService.listAll();
		
		model.addAttribute("products", products);
		model.addAttribute("keyword", keyword);
		return "products/productList";
	}

	@GetMapping("/{id}")
	public String detail(@PathVariable Long id, Model model) {
		Product p = productService.getById(id);
		model.addAttribute("product", p);
		return "products/productDetail";
	}

	@GetMapping("/edit/{id}")
	@PreAuthorize("hasAnyRole('ADMIN', 'MERCHANT')")
	public String editForm(@PathVariable Long id, Model model,
						  @AuthenticationPrincipal User currentUser) {
		Product p = productService.getById(id);
		
		if (!canEditProduct(currentUser, p)) {
			return "redirect:/shops/" + currentUser.getShop().getId() + "/manage?error=unauthorized&tab=products";
		}
		
		model.addAttribute("product", p);
		model.addAttribute("isEdit", true);
		model.addAttribute("categories", categoryService.getAllCategories());
		return "products/productForm";
	}

	@GetMapping("/create")
	@PreAuthorize("hasAnyRole('ADMIN', 'MERCHANT')")
	public String createForm(Model model,
							@AuthenticationPrincipal User currentUser) {
		model.addAttribute("product", new Product());
		model.addAttribute("isEdit", false);
		model.addAttribute("categories", categoryService.getAllCategories());
		
		if (currentUser.getRole() == User.Role.MERCHANT) {
			model.addAttribute("currentMerchant", currentUser);
		}
		return "products/productForm";
	}

	@PostMapping("/save")
	@PreAuthorize("hasAnyRole('ADMIN', 'MERCHANT')")
	public String saveProduct(@ModelAttribute Product product, 
						@RequestParam("categoryId") Long categoryId,
						@AuthenticationPrincipal User currentUser) {
		Category category = categoryService.getCategoryById(categoryId);
		product.setCategory(category);
		
		if (currentUser.getRole() == User.Role.MERCHANT) {
			if (product.getId() == null) {
				product.setMerchant(currentUser);
			} else {
				Product existingProduct = productService.getById(product.getId());
				if (!existingProduct.getMerchant().getId().equals(currentUser.getId())) {
					return "redirect:/shops" + currentUser.getShop().getId() + "/manage?error=unauthorized&tab=products";
				}
				product.setMerchant(currentUser);
			}
		} else if (currentUser.getRole() == User.Role.ADMIN && product.getMerchant() == null) {
			product.setMerchant(currentUser);
		}
		
		productService.save(product);
		
		String redirectUrl = getRedirectUrl(currentUser);
		if (product.getId() == null) {
			redirectUrl += "&success=created";
		} else {
			redirectUrl += "&success=updated";
		}
		
		return "redirect:" + redirectUrl;
	}
    
    @PostMapping("/delete/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'MERCHANT')")
    public String deleteProduct(@PathVariable Long id,
                               @AuthenticationPrincipal User currentUser) {
        if (currentUser.getRole() == User.Role.MERCHANT) {
            Product product = productService.getById(id);
            if (product.getMerchant() == null || !product.getMerchant().getId().equals(currentUser.getId())) {
                return "redirect:/shops/" + currentUser.getShop().getId() + "/manage?error=unauthorized&tab=products";
            }
        }
        
        productService.deleteById(id);
        return "redirect:" + getRedirectUrl(currentUser) + "&success=deleted";
    }
    
    private boolean canEditProduct(User currentUser, Product product) {
        if (currentUser.getRole() == User.Role.MERCHANT) {
            return product.getMerchant() != null && product.getMerchant().getId().equals(currentUser.getId());
        }
        return true;
    }
    
    private String getRedirectUrl(User currentUser) {
        if (currentUser.getRole() == User.Role.MERCHANT) {
            return "/shops/" + currentUser.getShop().getId() + "/manage?tab=products";
        } else {
            return "/admin?tab=products";
        }
    }
}
