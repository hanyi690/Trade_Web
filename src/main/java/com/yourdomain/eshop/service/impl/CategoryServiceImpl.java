package com.yourdomain.eshop.service.impl;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.yourdomain.eshop.entity.Category;
import com.yourdomain.eshop.repository.CategoryRepository;
import com.yourdomain.eshop.service.CategoryService;

@Service
@Transactional
public class CategoryServiceImpl implements CategoryService {

	private final CategoryRepository repo;

	public CategoryServiceImpl(CategoryRepository repo) {
		this.repo = repo;
	}

	@Override
	public List<Category> getAllCategories() {
		return repo.findAll();
	}

	@Override
	public Category getCategoryById(Long id) {
		Optional<Category> o = repo.findById(id);
		return o.orElse(null);
	}

	@Override
	public List<Category> listAll() {
		return getAllCategories();
	}

	@Override
	public Category getById(Long id) {
		return getCategoryById(id);
	}

	@Override
	public Category save(Category category) {
		return repo.save(category);
	}

	@Override
	public void deleteById(Long id) {
		repo.deleteById(id);
	}
}
