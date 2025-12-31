<!-- filepath: f:\project\Trade_Web\src\main\webapp\WEB-INF\views\orders\myorders.jsp -->
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>我的订单 - 电商平台</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/resources/css/site.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/resources/css/modules/orders.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="../common/header.jsp" />
    
    <div class="container py-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="mb-1">我的订单</h2>
                <p class="text-muted mb-0">查看和管理您的所有订单</p>
            </div>
            <a href="${pageContext.request.contextPath}/products" class="btn btn-outline-primary">
                <i class="fas fa-shopping-bag"></i> 继续购物
            </a>
        </div>
        
        <!-- 使用公共订单组件 -->
        <c:set var="context" value="user" scope="request" />
        <jsp:include page="../common/orderTable.jsp" />
        
        <!-- 底部链接 -->
        <div class="text-center mt-4">
            <a href="${pageContext.request.contextPath}/user/profile" class="btn btn-outline-secondary me-2">
                <i class="fas fa-user"></i> 个人中心
            </a>
            <a href="${pageContext.request.contextPath}/cart" class="btn btn-outline-secondary">
                <i class="fas fa-shopping-cart"></i> 查看购物车
            </a>
        </div>
    </div>
    
    <jsp:include page="../common/footer.jsp" />
    
    <script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
</body>
</html>