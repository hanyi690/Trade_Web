<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<div class="header">
    <div class="header-content">
        <div class="logo">
            <a href="${pageContext.request.contextPath}/">E-Shop</a>
        </div>
        
        <div class="nav">
            <a href="${pageContext.request.contextPath}/">首页</a>
            <a href="${pageContext.request.contextPath}/products">商品</a>
            <a href="${pageContext.request.contextPath}/shops">店铺</a>
            <a href="${pageContext.request.contextPath}/categories">分类</a>
            <a href="${pageContext.request.contextPath}/cart">购物车</a>
        </div>
        
        <div class="user-panel">
            <sec:authorize access="isAuthenticated()">
                <span>欢迎，<sec:authentication property="principal.username" /></span>
                <a href="${pageContext.request.contextPath}/user/profile">个人中心</a>
                <sec:authorize access="hasRole('MERCHANT')">
                    <a href="${pageContext.request.contextPath}/shops/my">我的店铺</a>
                </sec:authorize>
                <sec:authorize access="hasRole('ADMIN')">
                    <a href="${pageContext.request.contextPath}/admin">管理后台</a>
                </sec:authorize>
                <a href="${pageContext.request.contextPath}/orders">我的订单</a>
                <a href="${pageContext.request.contextPath}/user/logout">登出</a>
            </sec:authorize>
            <sec:authorize access="!isAuthenticated()">
                <a href="${pageContext.request.contextPath}/user/login">登录</a>
                <a href="${pageContext.request.contextPath}/user/register">注册</a>
            </sec:authorize>
        </div>
    </div>
</div>