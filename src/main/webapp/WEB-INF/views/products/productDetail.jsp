<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${product.name} - 商品详情 - E-Shop</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/site.css">
    <!-- 修改：使用新的商品详情模块CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modules/product-detail.css">
</head>
<body class="product-detail-page">
   <jsp:include page="../common/header.jsp" />
    
    <div class="container">
        <h1 class="page-title">
            <i class="fas fa-box"></i> ${product.name}
        </h1>
        
        <!-- 返回和操作链接 -->
        <div class="detail-actions-header">
            <a href="${pageContext.request.contextPath}/products" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> 返回商品列表
            </a>
            
            <sec:authorize access="hasRole('ADMIN')">
                <a href="${pageContext.request.contextPath}/products/edit/${product.id}" 
                   class="btn btn-warning admin-edit-btn">
                    <i class="fas fa-edit"></i> 编辑商品
                </a>
            </sec:authorize>
        </div>
        
        <div class="product-detail-container">
            <!-- 商品图片区域 -->
            <div class="product-image-section">
                <c:choose>
                    <c:when test="${not empty product.imageUrl}">
                        <img src="${product.imageUrl}" alt="${product.name}" class="main-product-image" id="mainProductImage">
                    </c:when>
                    <c:when test="${not empty product.imageFilename}">
                        <img src="${pageContext.request.contextPath}/images/products/${product.imageFilename}" 
                             alt="${product.name}" class="main-product-image" id="mainProductImage">
                    </c:when>
                    <c:otherwise>
                        <div class="no-image">
                            <i class="fas fa-image"></i>
                            <p>暂无图片</p>
                        </div>
                    </c:otherwise>
                </c:choose>
                
                <!-- 缩略图区域 -->
                <div class="thumbnail-gallery">
                    <c:forEach var="i" begin="1" end="3">
                        <img src="${pageContext.request.contextPath}/images/product-thumb${i}.jpg" 
                             alt="缩略图${i}" 
                             class="thumbnail"
                             onmouseover="changeImage(this.src)">
                    </c:forEach>
                </div>
            </div>
            
            <!-- 商品信息区域 -->
            <div class="product-info-content">
                <!-- 商品基本信息 -->
                <div class="product-info-section">
                    <h2>商品信息</h2>
                    
                    <div class="info-row">
                        <span class="info-label">商品名称：</span>
                        <span class="info-value">${product.name}</span>
                    </div>
                    
                    <div class="info-row">
                        <span class="info-label">商品描述：</span>
                        <span class="info-value">${product.description}</span>
                    </div>
                    
                    <div class="info-row">
                        <span class="info-label">价格：</span>
                        <span class="info-value">
                            ¥<fmt:formatNumber value="${product.price}" minFractionDigits="2" maxFractionDigits="2"/>
                        </span>
                    </div>
                    
                    <div class="info-row">
                        <span class="info-label">库存：</span>
                        <span class="info-value">
                            <c:choose>
                                <c:when test="${empty product.stock}">
                                    <span class="stock-unknown">未知</span>
                                </c:when>
                                <c:when test="${product.stock > 10}">
                                    <span class="stock-high">${product.stock}件</span>
                                </c:when>
                                <c:when test="${product.stock > 0}">
                                    <span class="stock-medium">${product.stock}件</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="stock-low">缺货</span>
                                </c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    
                    <div class="info-row">
                        <span class="info-label">销量：</span>
                        <span class="info-value">${not empty product.sales ? product.sales : 0}件</span>
                    </div>
                </div>
                
                <!-- 商品规格 -->
                <div class="product-specs-section">
                    <h2>商品规格</h2>
                    
                    <c:if test="${not empty product.brand}">
                        <div class="info-row">
                            <span class="info-label">品牌：</span>
                            <span class="info-value">${product.brand}</span>
                        </div>
                    </c:if>
                    
                    <c:if test="${not empty product.model}">
                        <div class="info-row">
                            <span class="info-label">型号：</span>
                            <span class="info-value">${product.model}</span>
                        </div>
                    </c:if>
                    
                    <c:if test="${not empty product.weight}">
                        <div class="info-row">
                            <span class="info-label">重量：</span>
                            <span class="info-value">
                                <fmt:formatNumber value="${product.weight}" minFractionDigits="2" maxFractionDigits="2"/> kg
                            </span>
                        </div>
                    </c:if>
                    
                    <c:if test="${not empty product.material}">
                        <div class="info-row">
                            <span class="info-label">材质：</span>
                            <span class="info-value">${product.material}</span>
                        </div>
                    </c:if>
                </div>
                
                <!-- 商家信息 -->
                <c:if test="${not empty product.merchant}">
                    <div class="info-row">
                        <span class="info-label">商家：</span>
                        <span class="info-value">
                            <a href="${pageContext.request.contextPath}/shops/${product.merchant.id}">
                                ${product.merchant.username}
                            </a>
                        </span>
                    </div>
                </c:if>
                
                <!-- 分类信息 -->
                <c:if test="${not empty product.category}">
                    <div class="info-row">
                        <span class="info-label">分类：</span>
                        <span class="info-value">
                            <a href="${pageContext.request.contextPath}/categories/${product.category.id}">
                                ${product.category.name}
                            </a>
                        </span>
                    </div>
                </c:if>
                
                <!-- 购买操作 -->
                <div class="product-action-buttons">
                    <form action="${pageContext.request.contextPath}/cart/add" method="post" class="add-to-cart-form">
                        <input type="hidden" name="productId" value="${product.id}">
                        <input type="hidden" name="quantity" value="1">
                        <button type="submit" class="btn btn-primary add-to-cart-btn">
                            <i class="fas fa-cart-plus"></i> 加入购物车
                        </button>
                    </form>
                    
                    <a href="${pageContext.request.contextPath}/products" class="btn btn-secondary continue-shopping-btn">
                        <i class="fas fa-list"></i> 继续购物
                    </a>
                </div>
                
                <!-- 管理员操作区域 -->
                <sec:authorize access="hasRole('ADMIN')">
                    <div class="admin-actions">
                        <h3><i class="fas fa-cog"></i> 管理操作</h3>
                        <div class="admin-action-buttons">
                            <a href="${pageContext.request.contextPath}/products/edit/${product.id}" 
                               class="btn btn-warning btn-sm">
                                <i class="fas fa-edit"></i> 编辑
                            </a>
                            <a href="${pageContext.request.contextPath}/admin" 
                               class="btn btn-secondary btn-sm">
                                <i class="fas fa-cog"></i> 管理后台
                            </a>
                            <form action="${pageContext.request.contextPath}/products/delete/${product.id}" 
                                  method="post" class="delete-form">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                <button type="submit" 
                                        class="btn btn-danger btn-sm" 
                                        onclick="return confirm('确定要删除此商品吗？此操作不可恢复！')">
                                    <i class="fas fa-trash"></i> 删除
                                </button>
                            </form>
                        </div>
                    </div>
                </sec:authorize>
            </div>
        </div>
    </div>
    
  <jsp:include page="../common/footer.jsp" />
    
    <script src="${pageContext.request.contextPath}/resources/js/site.js"></script>
    <script>
        function changeImage(src) {
            const mainImage = document.getElementById('mainProductImage');
            if (mainImage) {
                mainImage.src = src;
            }
        }
    </script>
</body>
</html>