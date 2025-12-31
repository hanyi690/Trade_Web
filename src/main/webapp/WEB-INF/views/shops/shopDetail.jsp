<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<html>
<head>
    <title>${shop.name} - E-Shop</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/site.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pages/shops.css">
</head>
<body>
    <!-- 统一顶部导航栏 -->
    <jsp:include page="../common/header.jsp" />
    
    <!-- 商店头部信息 -->
    <div class="shop-header">
        <div class="shop-header-content">
            <c:choose>
                <c:when test="${not empty shop.logoUrl}">
                    <img src="${shop.logoUrl}" alt="${shop.name}" class="shop-logo-large"/>
                </c:when>
                <c:otherwise>
                    <img src="${pageContext.request.contextPath}/images/shop-default.png" 
                         alt="默认店铺图片" class="shop-logo-large"/>
                </c:otherwise>
            </c:choose>
            
            <div class="shop-header-info">
                <h1 class="shop-header-name">${shop.name}</h1>
                <div class="shop-header-meta">
                    <span>📅 创建于: 
                        <c:if test="${not empty createdTimeFormatted}">
                           ${createdTimeFormatted}
                        </c:if>
                    </span>
                    <span>👨‍💼 店主: ${shop.merchant.username}</span>
                </div>
                <c:if test="${not empty shop.description}">
                    <p class="shop-description-header">${shop.description}</p>
                </c:if>
            </div>
        </div>
    </div>
    
    <div class="container">
        <div class="shop-content">
            <!-- 左侧：商店详细信息 -->
            <div class="shop-card">
                <h2 class="section-title">店铺信息</h2>
                
                <div class="detail-item">
                    <span class="detail-label">店铺名称:</span>
                    <span class="detail-value">${shop.name}</span>
                </div>
                
                <c:if test="${not empty shop.description}">
                    <div class="detail-item">
                        <span class="detail-label">店铺描述:</span>
                        <span class="detail-value">${shop.description}</span>
                    </div>
                </c:if>
                
                <c:if test="${not empty shop.contactPhone}">
                    <div class="detail-item">
                        <span class="detail-label">联系电话:</span>
                        <span class="detail-value">${shop.contactPhone}</span>
                    </div>
                </c:if>
                
                <c:if test="${not empty shop.contactEmail}">
                    <div class="detail-item">
                        <span class="detail-label">联系邮箱:</span>
                        <span class="detail-value">${shop.contactEmail}</span>
                    </div>
                </c:if>
                
                <c:if test="${not empty shop.address}">
                    <div class="detail-item">
                        <span class="detail-label">店铺地址:</span>
                        <span class="detail-value">${shop.address}</span>
                    </div>
                </c:if>
                
                <div class="detail-item">
                    <span class="detail-label">创建时间:</span>
                    <span class="detail-value">
                        <c:if test="${not empty fullcreatedTimeFormatted}">
                           ${fullcreatedTimeFormatted}
                        </c:if>
                    </span>
                </div>
                
                <c:if test="${not empty fullupdatedTimeFormatted}">
                    <div class="detail-item">
                        <span class="detail-label">更新时间:</span>
                        <span class="detail-value">
                           ${fullupdatedTimeFormatted}
                    </span>
                    </div>
                </c:if>
                
                <!-- 店铺操作按钮 -->
                <div class="shop-actions">
                    <a href="${pageContext.request.contextPath}/shops/${shop.id}/products" 
                       class="btn btn-success">
                        <i class="fas fa-shopping-bag"></i> 浏览商品
                    </a>
                    
                    <!-- 只有店铺拥有者才能编辑店铺 -->
                    <sec:authorize access="hasRole('MERCHANT')">
                        <c:if test="${not empty currentUserId and currentUserId == shop.merchant.id}">
                            <a href="${pageContext.request.contextPath}/shops/edit/${shop.id}" 
                               class="btn btn-primary">
                                <i class="fas fa-edit"></i> 编辑店铺
                            </a>
                            
                            <!-- 新增：管理店铺入口 -->
                            <a href="${pageContext.request.contextPath}/shops/${shop.id}/manage" 
                               class="btn btn-danger">
                                <i class="fas fa-cog"></i> 管理店铺
                            </a>
                        </c:if>
                    </sec:authorize>
                    
                    <!-- 管理员可以管理所有店铺 -->
                    <sec:authorize access="hasRole('ADMIN')">
                        <a href="${pageContext.request.contextPath}/admin/shops/edit/${shop.id}" 
                           class="btn btn-secondary">
                            <i class="fas fa-cog"></i> 管理店铺
                        </a>
                    </sec:authorize>
                </div>
            </div>
            
            <!-- 右侧：店主信息和店铺统计 -->
            <div class="shop-card">
                <h3 class="section-title">店主信息</h3>
                
                <div class="detail-item">
                    <span class="detail-label">用户名:</span>
                    <span class="detail-value">${shop.merchant.username}</span>
                </div>
                
                <c:if test="${not empty shop.merchant.email}">
                    <div class="detail-item">
                        <span class="detail-label">邮箱:</span>
                        <span class="detail-value">${shop.merchant.email}</span>
                    </div>
                </c:if>
                
                <c:if test="${not empty createdTimeFormatted}">
                    <div class="detail-item">
                        <span class="detail-label">注册时间:</span>
                        <span class="detail-value">
                            ${createdTimeFormatted}
                        </span>
                    </div>
                </c:if>
                
                <h3 class="section-title" style="margin-top: 30px;">店铺统计</h3>
                
                <div class="shop-stats">
                    <div class="stat-number">${not empty shopProducts ? shopProducts.size() : '0'}</div>
                    <div class="stat-label">在售商品</div>
                </div>
            </div>
        </div>
        
        <!-- 店铺商品列表（如果有） -->
        <c:if test="${not empty shopProducts}">
            <div class="shop-products">
                <h2 class="section-title">热门商品</h2>
                
                <div class="product-grid-small">
                    <c:forEach var="product" items="${shopProducts}" begin="0" end="5">
                        <div class="product-card-small">
                            <c:choose>
                                <c:when test="${not empty product.imageUrl}">
                                    <img src="${product.imageUrl}" alt="${product.name}" 
                                         class="product-image-small"/>
                                </c:when>
                                <c:when test="${not empty product.imageFilename}">
                                    <img src="${pageContext.request.contextPath}/images/products/${product.imageFilename}" 
                                         alt="${product.name}" 
                                         class="product-image-small"/>
                                </c:when>
                                <c:otherwise>
                                    <div class="default-image">
                                        <i class="fas fa-image"></i>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                            
                            <h4 class="product-name-small">${product.name}</h4>
                            <div class="product-price-small">
                                ¥<fmt:formatNumber value="${product.price}" type="number" minFractionDigits="2" maxFractionDigits="2"/>
                            </div>
                            
                            <a href="${pageContext.request.contextPath}/products/${product.id}" 
                               class="btn-view-detail">
                                查看详情
                            </a>
                        </div>
                    </c:forEach>
                </div>
                
                <div class="view-all-products">
                    <a href="${pageContext.request.contextPath}/shops/${shop.id}/products" 
                       class="btn btn-primary">
                        <i class="fas fa-eye"></i> 查看所有商品
                    </a>
                </div>
            </div>
        </c:if>
    </div>
    
    <!-- 统一页脚 -->
    <jsp:include page="../common/footer.jsp" />
    <script src="${pageContext.request.contextPath}/resources/js/site.js"></script>
</body>
</html>
