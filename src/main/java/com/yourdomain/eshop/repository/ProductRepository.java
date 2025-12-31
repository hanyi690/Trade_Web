package com.yourdomain.eshop.repository;


import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.yourdomain.eshop.entity.Product;
import com.yourdomain.eshop.entity.User;
import java.util.List;
import java.util.Optional;
public interface ProductRepository extends JpaRepository<Product, Long> {
	// 根据分类ID查询产品
	List<Product> findByCategoryId(Long categoryId);
	// 根据商家ID查询产品
	 @EntityGraph(attributePaths = "merchant") 
    List<Product> findByMerchantId(Long merchantId);
	// 修改：支持按ID获取产品时，连带加载商家和分类信息
	@Query("SELECT DISTINCT p FROM Product p " +
		"LEFT JOIN FETCH p.merchant " +
		"LEFT JOIN FETCH p.category " +
		"WHERE p.id = :id")
	Optional<Product> findByIdWithMerchantAndCategory(@Param("id") Long id);
	// 修改：支持商品名称和描述的近似搜索
	@Query("SELECT p FROM Product p WHERE LOWER(p.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(p.description) LIKE LOWER(CONCAT('%', :keyword, '%'))")
	List<Product> findByNameOrDescriptionContaining(@Param("keyword") String keyword);
	
	// 保留原有的名称搜索方法以保持向后兼容
	List<Product> findByNameContainingIgnoreCase(String keyword);

	List<Product> findByNameContainingAndMerchant(String name, User merchant);
	List<Product> findByMerchant(User merchant);

}