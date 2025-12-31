<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<html>
<head>
    <title>商家店铺 - E-Shop</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/site.css">
    <!-- 新增：店铺列表模块CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modules/shop-list.css">
</head>
<body>
    <!-- 统一顶部导航栏 -->
    <jsp:include page="../common/header.jsp" />
    
    <div class="container">
        <h1 class="page-title">商家店铺</h1>
        
        
        <!-- 商店列表 -->
        <div class="shop-grid">
            <c:forEach var="shop" items="${shops}">
                <div class="shop-card">
                    <c:choose>
                        <c:when test="${not empty shop.logoUrl}">
                            <img src="${shop.logoUrl}" alt="${shop.name}" class="shop-logo"/>
                        </c:when>
                        <c:otherwise>
                            <img src="${pageContext.request.contextPath}/images/shop-default.png" 
                                 alt="默认店铺图片" class="shop-logo"/>
                        </c:otherwise>
                    </c:choose>
                    
                    <h3 class="shop-name">${shop.name}</h3>
                    
                    <c:if test="${not empty shop.description}">
                        <p class="shop-description">${shop.description}</p>
                    </c:if>
                    
                    <div class="shop-info">
                        <c:if test="${not empty shop.contactPhone}">
                            <div class="shop-info-item">
                                <span>📞</span>
                                <span>${shop.contactPhone}</span>
                            </div>
                        </c:if>
                        
                        <c:if test="${not empty shop.contactEmail}">
                            <div class="shop-info-item">
                                <span>✉️</span>
                                <span>${shop.contactEmail}</span>
                            </div>
                        </c:if>
                        
                        <c:if test="${not empty shop.address}">
                            <div class="shop-info-item">
                                <span>📍</span>
                                <span>${shop.address}</span>
                            </div>
                        </c:if>
                    </div>
                    
                    <div class="shop-stats">
                        <div class="stat-item">
                            <div class="stat-value">
                                 ${createdTimeFormatted}
                            </div>
                            <div class="stat-label">创建时间</div>
                        </div>
                    </div>
                    
                    <div class="shop-actions">
                        <a class="btn btn-primary" 
                           href="${pageContext.request.contextPath}/shops/${shop.id}">
                            店铺详情
                        </a>
                        <a class="btn btn-secondary" 
                           href="${pageContext.request.contextPath}/shops/${shop.id}/products">
                            浏览商品
                        </a>
                    </div>
                </div>
            </c:forEach>
            
            <c:if test="${empty shops}">
                <div class="empty-state">
                    <i class="fas fa-store-alt" style="font-size: 4rem; color: #bdc3c7; margin-bottom: 20px;"></i>
                    <h3>暂无店铺</h3>
                    <p>当前没有商家店铺可显示</p>
                    <sec:authorize access="hasRole('MERCHANT')">
                        <p>您可以创建自己的店铺</p>
                    </sec:authorize>
                </div>
            </c:if>
        </div>
    </div>
    
    <!-- 统一页脚 -->
    <jsp:include page="../common/footer.jsp" />
    <script src="${pageContext.request.contextPath}/resources/js/site.js"></script>
</body>
</html>
