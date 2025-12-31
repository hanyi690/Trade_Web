package com.yourdomain.eshop.controller;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.yourdomain.eshop.entity.Category;
import com.yourdomain.eshop.service.CategoryService;
import com.yourdomain.eshop.service.ProductService;

@Controller
@RequestMapping("/categories")
@PreAuthorize("hasRole('ADMIN')")
public class CategoryController {

	private final CategoryService categoryService;
	private final ProductService productService;

	public CategoryController(CategoryService categoryService, ProductService productService) {
		this.categoryService = categoryService;
		this.productService = productService;
    }

	// 列表页：显示所有分类
    @GetMapping
	public String list(Model model) {
		model.addAttribute("categories", categoryService.listAll());
		return "categories/categoryList";
	}

	// 新建表单
	@GetMapping("/new")
	public String createForm(Model model) {
		model.addAttribute("category", new Category());
		return "categories/categoryForm";
    }

	// 编辑表单
	@GetMapping("/edit/{id}")
	public String editForm(@PathVariable Long id, Model model, RedirectAttributes ra) {
		Category c = categoryService.getById(id);
		if (c == null) {
			ra.addFlashAttribute("error", "分类未找到");
			return "redirect:/categories";
		}
		model.addAttribute("category", c);
		return "categories/categoryForm";
    }

	// 保存（新建/更新）
	@PostMapping("/save")
	public String save(@ModelAttribute Category category, RedirectAttributes ra) {
		try {
			categoryService.save(category);
			ra.addFlashAttribute("success", "保存成功");
		} catch (Exception e) {
			ra.addFlashAttribute("error", "保存失败: " + e.getMessage());
        }
		return "redirect:/categories";
    }

	// 删除（注意：若存在产品关联，可能触发 FK 约束）
	@PostMapping("/delete/{id}")
	public String delete(@PathVariable Long id, RedirectAttributes ra) {
		try {
			categoryService.deleteById(id);
			ra.addFlashAttribute("success", "删除成功");
		} catch (Exception e) {
			ra.addFlashAttribute("error", "删除失败: " + e.getMessage());
        }
		return "redirect:/categories";
    }

	// 展示某个分类下的商品
	@GetMapping("/{id}/products")
	public String productsByCategory(@PathVariable Long id, Model model, RedirectAttributes ra) {
		Category c = categoryService.getById(id);
		if (c == null) {
			ra.addFlashAttribute("error", "分类未找到");
			return "redirect:/categories";
        }
		model.addAttribute("category", c);
		model.addAttribute("products", productService.listByCategoryId(id));
		return "categories/categoryProducts";
        }
    
}
