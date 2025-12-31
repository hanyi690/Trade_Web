<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- 导入 JSTL 核心标签库 --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- 导入 JSTL 函数标签库 --%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%-- 导入 Spring 表单标签库 --%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%-- 导入 Spring 通用标签库 --%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<html>
<head>
    <title>商品列表 - E-Shop</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- 引用统一样式 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/site.css">
</head>
<body class="product-list-page">
    <!-- 顶部导航栏 -->
    <jsp:include page="../common/header.jsp" />
    
    <div class="container">
        <h1 class="page-title">精选商品</h1>
        
        <c:if test="${not empty products}">
            <div class="product-count">
                共找到 <strong>${fn:length(products)}</strong> 个商品
            </div>
        </c:if>
        <!-- 搜索框 -->
        <div class="search-container">
            <form method="get" action="${pageContext.request.contextPath}/products" class="search-box">
                <input type="text" name="keyword" 
                       placeholder="输入商品名称或描述搜索..." 
                       value="${keyword}">
                <button type="submit">
                    <i class="fas fa-search"></i> 搜索
                </button>
            </form>
            
            <c:if test="${not empty keyword}">
                <div class="search-results">
                    搜索 "<strong>${keyword}</strong>" 的结果：
                    <c:choose>
                        <c:when test="${empty products}">
                            未找到相关商品
                        </c:when>
                        <c:otherwise>
                            找到 ${fn:length(products)} 个商品
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:if>
        </div>
        
        <!-- 消息提示（新增） -->
        <c:if test="${not empty success}">
            <div class="message success" style="max-width: 800px; margin: 0 auto 30px auto;">
                <i class="fas fa-check-circle"></i> ${success}
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="message error" style="max-width: 800px; margin: 0 auto 30px auto;">
                <i class="fas fa-exclamation-circle"></i> ${error}
            </div>
        </c:if>
        
        <!-- 商品列表 -->
        <div class="product-grid">
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
                        ¥<fmt:formatNumber value="${p.price}" 
                                          type="number" 
                                          minFractionDigits="2" 
                                          maxFractionDigits="2"/>
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
            
            <c:if test="${empty products}">
                <div class="empty-state">
                    <i class="fas fa-box-open" style="font-size: 4rem; color: #bdc3c7; margin-bottom: 20px;"></i>
                    <h3>暂无商品</h3>
                    <p>
                        <c:choose>
                            <c:when test="${not empty keyword}">
                                未找到与"${keyword}"相关的商品
                            </c:when>
                            <c:otherwise>
                                当前没有商品可显示，请稍后再试
                            </c:otherwise>
                        </c:choose>
                    </p>
                    <c:if test="${empty keyword}">
                        <a href="${pageContext.request.contextPath}/products" class="btn btn-primary">
                            <i class="fas fa-redo"></i> 刷新页面
                        </a>
                    </c:if>
                </div>
            </c:if>
        </div>
    </div>
    
    <!-- 页脚 -->
    <jsp:include page="../common/footer.jsp" />

    <!-- 公共脚本 -->
    <script src="${pageContext.request.contextPath}/resources/js/site.js"></script>
</body>
</html>