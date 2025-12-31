<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<html>
<head>
    <title>${shop.name} - 店铺商品 - E-Shop</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/site.css">
</head>
<body>
    <!-- 顶部导航栏 -->
    <jsp:include page="../common/header.jsp" />
    
    <!-- 商店头部信息 -->
    <div class="shop-header">
        <div class="shop-header-content">
            <h1 class="shop-header-name">${shop.name} - 商品列表</h1>
            
            <div class="shop-header-meta">
                <span>店主: ${shop.merchant.username}</span>
                <c:if test="${not empty shop.contactPhone}">
                    <span>📞 ${shop.contactPhone}</span>
                </c:if>
                <c:if test="${not empty shop.contactEmail}">
                    <span>✉️ ${shop.contactEmail}</span>
                </c:if>
            </div>
            
            <div style="display: flex; gap: 10px; justify-content: center; flex-wrap: wrap; margin-top: 15px;">
                <a href="${pageContext.request.contextPath}/shops/${shop.id}" class="back-btn">
                    <i class="fas fa-arrow-left"></i> 返回店铺详情
                </a>
                
                <!-- 新增：管理店铺入口（仅对店铺拥有者显示） -->
                <c:if test="${not empty isOwner and isOwner}">
                    <a href="${pageContext.request.contextPath}/shops/${shop.id}/manage" 
                       class="back-btn" style="background: linear-gradient(135deg, #e74c3c, #c0392b);">
                        <i class="fas fa-cog"></i> 管理店铺
                    </a>
                    <!-- 新增：管理商品入口 -->
                    <a href="${pageContext.request.contextPath}/products/manage" 
                       class="back-btn" style="background: linear-gradient(135deg, #27ae60, #229954);">
                        <i class="fas fa-boxes"></i> 管理商品
                    </a>
                </c:if>
            </div>

        </div>
    </div>
    
    <div class="container">
        <div class="product-count">
            共找到 <strong style="color: #667eea;">${not empty products ? products.size() : 0}</strong> 件商品
        </div>
        
        <!-- 商品列表网格 -->
        <div class="product-grid">
            <c:if test="${not empty products}">
                <c:forEach var="p" items="${products}">
                    <div class="product-card">
                        <c:choose>
                            <c:when test="${not empty p.imageUrl}">
                                <img src="${p.imageUrl}" alt="${p.name}" class="product-image" loading="lazy"/>
                            </c:when>
                            <c:when test="${not empty p.imageFilename}">
                                <img src="${pageContext.request.contextPath}/images/products/${p.imageFilename}" 
                                     alt="${p.name}" class="product-image" loading="lazy"/>
                            </c:when>
                            <c:otherwise>
                                <img src="${pageContext.request.contextPath}/images/default-product.png" 
                                     alt="默认图片" class="product-image" loading="lazy"/>
                            </c:otherwise>
                        </c:choose>
                        
                        <h3 class="product-name">${p.name}</h3>
                        <div class="product-price">
                            ¥<fmt:formatNumber value="${p.price}" type="number" minFractionDigits="2" maxFractionDigits="2"/>
                        </div>
                        
                        <c:if test="${not empty p.description}">
                            <p class="product-description">${p.description}</p>
                        </c:if>
                        
                        <div class="product-meta">
                            <span>销量: ${not empty p.sales ? p.sales : '0'}</span>
                            <span>库存: ${not empty p.stock ? p.stock : '充足'}</span>
                        </div>
                        
                        <div class="product-actions">
                            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/products/${p.id}">
                                <i class="fas fa-eye"></i> 查看详情
                            </a>
                            <form action="${pageContext.request.contextPath}/cart/add" method="post" style="display:inline; flex:1;">
                                <input type="hidden" name="productId" value="${p.id}"/>
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-cart-plus"></i> 加入购物车
                                </button>
                            </form>
                        </div>
                    </div>
                </c:forEach>
            </c:if>
            
            <c:if test="${empty products}">
                <div class="empty-state">
                    <i class="fas fa-box-open" style="font-size: 4rem; color: #bdc3c7; margin-bottom: 20px;"></i>
                    <h3>暂无商品</h3>
                    <p>此店铺暂时没有上架商品</p>
                    <a href="${pageContext.request.contextPath}/shops" class="btn btn-secondary" 
                       style="margin-top: 15px; display: inline-block;">
                        <i class="fas fa-store"></i> 浏览其他店铺
                    </a>
                </div>
            </c:if>
        </div>
    </div>
    
    <!-- 页脚 -->
    <jsp:include page="../common/footer.jsp" />
    <script src="${pageContext.request.contextPath}/resources/js/site.js"></script>
</body>
</html>
