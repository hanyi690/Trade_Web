package com.yourdomain.eshop.service;

import java.util.List;
import com.yourdomain.eshop.entity.Category;

public interface CategoryService {
	// 获取所有分类
	List<Category> getAllCategories();
	
	// 根据ID获取分类
	Category getCategoryById(Long id);
	
	// 原有的listAll方法（保持向后兼容）
	List<Category> listAll();
	
	// 原有的getById方法（保持向后兼容）
	Category getById(Long id);
	
	Category save(Category category);
	void deleteById(Long id);
}
