package com.yourdomain.eshop.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.yourdomain.eshop.entity.Category;

public interface CategoryRepository extends JpaRepository<Category, Long> {
	// 可按需添加自定义查询方法，例如：Optional<Category> findByName(String name);
}
