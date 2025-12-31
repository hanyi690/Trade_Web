package com.yourdomain.eshop;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

import com.yourdomain.eshop.repository.ProductRepository;
import com.yourdomain.eshop.repository.CategoryRepository;

@SpringBootApplication
public class EshopApplication extends SpringBootServletInitializer implements CommandLineRunner {
	private final ProductRepository productRepository;
	// 构造注入仓库
	public EshopApplication(ProductRepository productRepository, CategoryRepository categoryRepository) {
		this.productRepository = productRepository;
	}

	public static void main(String[] args) {

		SpringApplication.run(EshopApplication.class, args);
	
	}

	
	@Override
	public void run(String... args) {
	    try {
	        // 仅在产品表为空时插入示例数据，避免重复插入
	        if (productRepository.count() == 0) {
	        }
	    } catch (Exception e) {
	        System.err.println("数据初始化失败，但应用可以继续运行: " + e.getMessage());
	        // 不抛出异常，让应用继续启动
	    }
	}
}