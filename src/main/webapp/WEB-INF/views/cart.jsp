<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<html>
<head>
    <title>我的购物车 - E-Shop</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/site.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pages/cart.css">
</head>
<body>
    <!-- 顶部导航栏（与 productList.jsp 统一） -->
    <jsp:include page="/WEB-INF/views/common/header.jsp"/>
    
    <div class="container">
        <h1 class="page-title">我的购物车</h1>
        
        <div class="cart-container">
            <div class="cart-header">
                <h1><i class="fas fa-shopping-cart"></i> 购物车清单</h1>
                <p>查看并管理您的商品</p>
            </div>
            
            <div class="cart-content">
                <!-- 消息提示 -->
                <c:if test="${not empty success}">
                    <div class="message success">
                        <i class="fas fa-check-circle"></i> ${success}
                    </div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="message error">
                        <i class="fas fa-exclamation-circle"></i> ${error}
                    </div>
                </c:if>

                <!-- 购物车内容 -->
                <c:choose>
                    <c:when test="${empty cartItems}">
                        <div class="empty-cart">
                            <i class="fas fa-shopping-cart"></i>
                            <h2>您的购物车是空的</h2>
                            <p>快去挑选心仪的商品吧！</p>
                            <a href="<c:url value='/products'/>" class="btn btn-primary">
                                <i class="fas fa-shopping-bag"></i> 继续购物
                            </a>
                        </div>
                    </c:when>
                    
                    <c:otherwise>
                        <div class="cart-items">
                            <c:forEach var="item" items="${cartItems}">
                                <div class="cart-item">
                                    <!-- 商品图片 -->
                                    <c:choose>
                                        <c:when test="${not empty item.product.imageUrl}">
                                            <img src="${item.product.imageUrl}" alt="${item.product.name}" class="cart-item-image"/>
                                        </c:when>
                                        <c:when test="${not empty item.product.imageFilename}">
                                            <img src="${pageContext.request.contextPath}/images/products/${item.product.imageFilename}" 
                                                 alt="${item.product.name}" class="cart-item-image"/>
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${pageContext.request.contextPath}/images/default-product.png" 
                                                 alt="默认图片" class="cart-item-image"/>
                                        </c:otherwise>
                                    </c:choose>
                                    
                                    <div class="cart-item-info">
                                        <div class="item-details">
                                            <div class="cart-item-name">${item.product.name}</div>
                                            <div class="cart-item-price">
                                                ¥<fmt:formatNumber value="${item.product.price}" 
                                                                   type="number" 
                                                                   minFractionDigits="2" 
                                                                   maxFractionDigits="2"/>
                                            </div>
                                        </div>
                                        
                                        <div class="cart-item-controls">
                                            <!-- 数量控制 -->
                                            <div class="quantity-controls">
                                                <form id="updateForm-${item.id}" action="<c:url value='/cart/update'/>" method="post" style="display:none;">
                                                    <input type="hidden" name="cartItemId" value="${item.id}"/>
                                                    <input type="hidden" name="quantity" id="qty-${item.id}" value="${item.quantity}"/>
                                                </form>
                                                
                                                <button type="button" class="quantity-btn" onclick="changeQuantity('${item.id}', -1)">
                                                    <i class="fas fa-minus"></i>
                                                </button>
                                                <input id="visible-${item.id}" type="number" value="${item.quantity}" min="1" 
                                                       class="quantity-input" onchange="setQuantity('${item.id}', this.value)"/>
                                                <button type="button" class="quantity-btn" onclick="changeQuantity('${item.id}', 1)">
                                                    <i class="fas fa-plus"></i>
                                                </button>
                                            </div>
                                            
                                            <!-- 小计 -->
                                            <div class="item-subtotal">
                                                ¥<fmt:formatNumber value="${item.product.price * item.quantity}" 
                                                                   type="number" 
                                                                   minFractionDigits="2" 
                                                                   maxFractionDigits="2"/>
                                            </div>
                                            
                                            <!-- 删除按钮 -->
                                            <form action="<c:url value='/cart/remove'/>" method="post">
                                                <input type="hidden" name="cartItemId" value="${item.id}"/>
                                                <button type="submit" class="btn btn-danger">
                                                    <i class="fas fa-trash"></i> 删除
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                        
                        <!-- 购物车汇总 -->
                        <div class="cart-summary">
                            <div class="total-row">
                                <span>商品总计：</span>
                                <span class="total-amount">
                                    ¥<fmt:formatNumber value="${total}" 
                                                      type="number" 
                                                      minFractionDigits="2" 
                                                      maxFractionDigits="2"/>
                                </span>
                            </div>
                        </div>
                        
                        <!-- 操作按钮 -->
                        <div class="cart-actions">
                            <a href="<c:url value='/products'/>" class="continue-shopping">
                                <i class="fas fa-arrow-left"></i> 继续购物
                            </a>
                            
                            <div class="action-group">
                                <form action="<c:url value='/cart/clear'/>" method="post">
                                    <button type="submit" class="btn btn-danger">
                                        <i class="fas fa-broom"></i> 清空购物车
                                    </button>
                                </form>
                                
                                <form action="<c:url value='orders/create'/>" method="post">
                                    <button type="submit" class="btn btn-success">
                                        <i class="fas fa-credit-card"></i> 立即结算
                                    </button>
                                </form>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <!-- 统一页脚 -->
    <jsp:include page="/WEB-INF/views/common/footer.jsp" />

    <!-- 公共脚本 site.js 提供 changeQuantity / setQuantity -->
    <script src="${pageContext.request.contextPath}/resources/js/site.js"></script>
</body>
</html>