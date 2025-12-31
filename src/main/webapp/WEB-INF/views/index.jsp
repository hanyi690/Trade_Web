<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<html>
<head>
    <title>欢迎来到 E-Shop - 您的在线购物天堂</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- 引用统一样式 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/site.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pages/home.css">
</head>
<body>
    <!-- 顶部导航栏：统一为 productList.jsp 风格 -->
    <jsp:include page="/WEB-INF/views/common/header.jsp" />

    <div class="container">
        <!-- 主横幅区域 -->
        <section class="hero-section">
            <h1 class="hero-title">发现优质商品，尽在 E-Shop</h1>
            <p class="hero-subtitle">我们为您精选各类优质商品，从电子产品到家居用品，一站式满足您的购物需求</p>
            
            <div class="cta-buttons">
                <a href="${pageContext.request.contextPath}/products" class="btn-hero btn-primary-large">立即购物</a>
                <a href="${pageContext.request.contextPath}/categories" class="btn-hero btn-secondary-large">浏览分类</a>
            </div>
        </section>
        
        <!-- 特色商品预览 -->
        <section class="featured-products">
            <h2 class="section-title">热门商品类别</h2>
            <div class="product-preview">
                <div class="preview-card">
                    <div class="preview-icon">📱</div>
                    <h3>电子产品</h3>
                    <p>最新智能手机、笔记本电脑和智能设备</p>
                </div>
                <div class="preview-card">
                    <div class="preview-icon">👕</div>
                    <h3>服装配饰</h3>
                    <p>时尚服装、鞋类和配饰精选</p>
                </div>
                <div class="preview-card">
                    <div class="preview-icon">🏠</div>
                    <h3>家居生活</h3>
                    <p>提升生活品质的家居用品</p>
                </div>
                <div class="preview-card">
                    <div class="preview-icon">🎮</div>
                    <h3>娱乐休闲</h3>
                    <p>游戏、书籍和娱乐产品</p>
                </div>
            </div>
        </section>
        
        <!-- 统计数据 -->
        <section class="stats-section">
            <h2 class="section-title">为什么选择 E-Shop</h2>
            <div class="stats-grid">
                <div class="stat-item">
                    <div class="stat-number">1000+</div>
                    <h3>优质商品</h3>
                </div>
                <div class="stat-item">
                    <div class="stat-number">24/7</div>
                    <h3>全天候服务</h3>
                </div>
                <div class="stat-item">
                    <div class="stat-number">99%</div>
                    <h3>客户满意度</h3>
                </div>
                <div class="stat-item">
                    <div class="stat-number">48h</div>
                    <h3>快速配送</h3>
                </div>
            </div>
        </section>
    </div>
    
    <!-- 统一页脚 -->
    <jsp:include page="/WEB-INF/views/common/footer.jsp" />
    <script src="${pageContext.request.contextPath}/resources/js/site.js"></script>
</body>
</html>