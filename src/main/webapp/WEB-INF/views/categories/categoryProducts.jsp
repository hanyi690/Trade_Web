<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<html>
<head>
    <title>${category.name} - 商品分类 - E-Shop</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/site.css">
</head>
<body>
    <!-- 顶部导航栏 -->
   <jsp:include page="../common/header.jsp" />
    
    <div class="container">
        <div class="breadcrumb">
            <a href="${pageContext.request.contextPath}/">首页</a>
            <span>›</span>
            <a href="${pageContext.request.contextPath}/categories">分类</a>
            <span>›</span>
            <span>${category.name}</span>
        </div>
        
        <h1 class="page-title">${category.name}</h1>
        
        <div class="category-info">
            <div class="category-name">📦 ${category.name}</div>
            <div class="product-count">共 ${not empty products ? products.size() : 0} 件商品</div>
        </div>
        
        <c:if test="${empty products}">
            <div class="empty-state">
                <h3>暂无商品</h3>
                <p>当前分类下还没有商品，敬请期待</p>
                <a href="${pageContext.request.contextPath}/products" class="btn btn-primary" style="margin-top:15px;">
                    浏览所有商品
                </a>
            </div>
        </c:if>
        
        <div class="product-grid">
            <c:forEach var="p" items="${products}">
                <div class="product-card">
                    <c:choose>
                        <c:when test="${not empty p.imageUrl}">
                            <img src="${p.imageUrl}" alt="${p.name}" class="product-image" loading="lazy"/>
                        </c:when>
                        <c:when test="${not empty p.imageFilename}">
                            <img src="${pageContext.request.contextPath}/images/${p.imageFilename}" alt="${p.name}" class="product-image" loading="lazy"/>
                        </c:when>
                        <c:otherwise>
                            <img src="${pageContext.request.contextPath}/images/default.png" alt="默认图片" class="product-image" loading="lazy"/>
                        </c:otherwise>
                    </c:choose>
                    
                    <h3 class="product-name">${p.name}</h3>
                    <div class="product-price">
                        ¥<fmt:formatNumber value="${p.price}" type="number" minFractionDigits="2" maxFractionDigits="2"/>
                    </div>
                    
                    <div class="product-actions">
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/products/${p.id}">查看详情</a>
                        <form action="${pageContext.request.contextPath}/cart/add" method="post" style="display:inline; flex:1;">
                            <input type="hidden" name="productId" value="${p.id}"/>
                            <button type="submit" class="btn btn-primary">加入购物车</button>
                        </form>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
    
    <!-- 页脚 -->
    <jsp:include page="../common/footer.jsp" />
    <script src="${pageContext.request.contextPath}/resources/js/site.js"></script>
</body>
</html>