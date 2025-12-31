<%@ page contentType="text/html;charset=UTF-8" language="java" session="false" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
    <title>管理员控制台 - E-Shop</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" crossorigin="anonymous">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/site.css" preload>
    <!-- 引入管理员管理模块CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modules/admin-manage.css">
</head>
<body class="admin-page">
      <jsp:include page="../common/header.jsp" />
    
    <div class="container">
        <div class="page-header">
            <h1 class="page-title">
                <i class="fas fa-user-shield"></i> 管理员控制台
            </h1>
            <p class="page-subtitle">欢迎回来，管理员 ${currentUser.username}！</p>
        </div>
        
        <div class="dashboard" id="dashboard">
            <!-- 侧边栏菜单 -->
            <div class="sidebar">
                <h3 class="sidebar-title">
                    <i class="fas fa-cog"></i> 管理菜单
                </h3>
                <ul class="sidebar-menu">
                    <li><a href="javascript:void(0)" data-tab="overview" class="active"><i class="fas fa-tachometer-alt"></i> 仪表盘</a></li>
                    <li><a href="javascript:void(0)" data-tab="shops"><i class="fas fa-store"></i> 店铺管理</a></li>
                    <li><a href="javascript:void(0)" data-tab="products"><i class="fas fa-box"></i> 商品管理</a></li>
                    <li><a href="javascript:void(0)" data-tab="orders"><i class="fas fa-shopping-cart"></i> 订单管理</a></li>
                    <li><a href="javascript:void(0)" data-tab="users"><i class="fas fa-users"></i> 用户管理</a></li>
                    <li><a href="javascript:void(0)" data-tab="statistics"><i class="fas fa-chart-bar"></i> 平台统计</a></li>
                </ul>
                
                <div class="platform-stats">
                    <h4 class="stats-title">平台概览</h4>
                    <div class="stats-item">
                        <span class="stats-label">总店铺数:</span>
                        <span class="stats-value">${platformStats.totalShops}</span>
                    </div>
                    <div class="stats-item">
                        <span class="stats-label">总商品数:</span>
                        <span class="stats-value">${platformStats.totalProducts}</span>
                    </div>
                    <div class="stats-item">
                        <span class="stats-label">总订单数:</span>
                        <span class="stats-value">${platformStats.totalOrders}</span>
                    </div>
                    <div class="stats-item">
                        <span class="stats-label">总销售额:</span>
                        <span class="stats-value">¥<fmt:formatNumber value="${platformStats.totalSales}" minFractionDigits="2"/></span>
                    </div>
                </div>
            </div>
            
            <!-- 主内容区 -->
            <div class="main-content">
                <!-- 隐藏的tab状态存储 -->
                <input type="hidden" name="tab" value="overview">
                
                <!-- 仪表盘标签页 -->
                <div id="overviewTab" class="tab-content active">
                    <div class="quick-actions">
                        <a href="${pageContext.request.contextPath}/admin/shops/create" class="btn btn-success">
                            <i class="fas fa-plus"></i> 创建新店铺
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/users/create" class="btn btn-primary">
                            <i class="fas fa-user-plus"></i> 添加新用户
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/export" class="btn btn-secondary">
                            <i class="fas fa-download"></i> 导出数据
                        </a>
                    </div>
                    
                    <h2 class="section-title" id="overview">
                        <i class="fas fa-tachometer-alt"></i> 平台概览
                    </h2>
                    
                    <div class="stats-grid">
                        <div class="stat-card">
                            <div class="stat-value">${platformStats.totalShops}</div>
                            <div class="stat-label">总店铺数</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value">${platformStats.activeShops}</div>
                            <div class="stat-label">活跃店铺</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value">${platformStats.totalProducts}</div>
                            <div class="stat-label">总商品数</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value">${platformStats.todayOrders}</div>
                            <div class="stat-label">今日订单</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value">¥<fmt:formatNumber value="${platformStats.todaySales}" minFractionDigits="2"/></div>
                            <div class="stat-label">今日销售额</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value">${platformStats.totalUsers}</div>
                            <div class="stat-label">总用户数</div>
                        </div>
                    </div>
                    
                    <div class="charts-row">
                        <div class="chart-container">
                            <h3 class="chart-title">平台销售趋势</h3>
                            <canvas id="platformSalesChart" height="250"></canvas>
                        </div>
                        <div class="chart-container">
                            <h3 class="chart-title">店铺分布</h3>
                            <canvas id="shopDistributionChart" height="250"></canvas>
                        </div>
                    </div>
                    
                    <div class="recent-activities">
                        <h3 class="section-subtitle">最近活动</h3>
                        <c:if test="${not empty recentActivities}">
                            <div class="activity-list">
                                <c:forEach var="activity" items="${recentActivities}">
                                    <div class="activity-item">
                                        <div class="activity-icon">
                                            <i class="fas ${activity.icon}"></i>
                                        </div>
                                        <div class="activity-content">
                                            <div class="activity-text">${activity.description}</div>
                                            <div class="activity-time">${activity.time}</div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:if>
                    </div>
                </div>
                
                <!-- 店铺管理标签页 -->
                <div id="shopsTab" class="tab-content">
                    <h2 class="section-title" id="shops">
                        <i class="fas fa-store"></i> 店铺管理
                        <div class="search-box" style="display: inline-block; margin-left: 20px;">
                            <form method="get" action="${pageContext.request.contextPath}/admin/shops">
                                <input type="text" name="keyword" placeholder="搜索店铺名称..." value="${keyword}">
                                <button type="submit" class="btn btn-sm btn-secondary">
                                    <i class="fas fa-search"></i>
                                </button>
                                <c:if test="${not empty keyword}">
                                    <a href="${pageContext.request.contextPath}/admin/shops" class="btn btn-sm btn-secondary">清除</a>
                                </c:if>
                            </form>
                        </div>
                    </h2>
                    
                    <!-- 消息提示 -->
                    <c:if test="${not empty successMessage}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <i class="fas fa-check-circle me-2"></i> ${successMessage}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>
                    
                    <!-- 使用店铺表格组件 -->
                    <c:set var="showIdColumn" value="true" />
                    <c:set var="showAddButton" value="true" />
                    <%@ include file="../common/shopTable.jsp" %>
                </div>
                
                <!-- 商品管理标签页 -->
                <div id="productsTab" class="tab-content">
                    <h2 class="section-title" id="products">
                        <i class="fas fa-box"></i> 商品管理
                        <div class="search-box" style="display: inline-block; margin-left: 20px;">
                            <form method="get" action="${pageContext.request.contextPath}/admin/products">
                                <input type="text" name="keyword" placeholder="搜索商品名称..." value="${keyword}">
                                <button type="submit" class="btn btn-sm btn-secondary">
                                    <i class="fas fa-search"></i>
                                </button>
                                <c:if test="${not empty keyword}">
                                    <a href="${pageContext.request.contextPath}/admin/products" class="btn btn-sm btn-secondary">清除</a>
                                </c:if>
                            </form>
                        </div>
                    </h2>
                    
                    <!-- 使用商品表格组件 -->
                    <c:set var="showIdColumn" value="true" />
                    <c:set var="showCategoryColumn" value="true" />
                    <c:set var="showMerchantColumn" value="true" />
                    <c:set var="showStatusColumn" value="true" />
                    <c:set var="showAddButton" value="true" />
                    <%@ include file="../common/productTable.jsp" %>
                </div>
                
                <!-- 订单管理标签页 -->
                <div id="ordersTab" class="tab-content">
                    <h2 class="section-title" id="orders">
                        <i class="fas fa-shopping-cart"></i> 订单管理
                    </h2>
                    
                    <!-- 使用订单表格组件 -->
                    <c:set var="context" value="admin" scope="request" />
                    <c:set var="filterAction" value="${pageContext.request.contextPath}/admin/orders" scope="request" />
                    <c:set var="showDateFilter" value="true" scope="request" />
                    <c:set var="showOrderCount" value="true" scope="request" />
                    <%@ include file="../common/orderTable.jsp" %>
                </div>
                
                <!-- 用户管理标签页 -->
                <div id="usersTab" class="tab-content">
                    <h2 class="section-title" id="users">
                        <i class="fas fa-users"></i> 用户管理
                    </h2>
                    
                    <%-- 使用公共用户表格组件 --%>
                    <c:set var="showIdColumn" value="true" />
                    <c:set var="showStatusColumn" value="true" />
                    <c:set var="showActions" value="true" />
                    <c:set var="showAddButton" value="true" />
                    <%@ include file="../common/userTable.jsp" %>
                </div>
                
                <!-- 平台统计标签页 -->
                <div id="statisticsTab" class="tab-content">
                    <h2 class="section-title" id="statistics">
                        <i class="fas fa-chart-bar"></i> 平台统计报表
                    </h2>
                    
                    <div class="date-filter">
                        <form method="get" action="${pageContext.request.contextPath}/admin/statistics">
                            <div class="filter-group">
                                <span class="filter-label">统计期间：</span>
                                <input type="date" name="startDate" value="${startDate}">
                                <span>至</span>
                                <input type="date" name="endDate" value="${endDate}">
                                <button type="submit" class="btn btn-primary">筛选</button>
                            </div>
                        </form>
                    </div>
                    
                    <div class="stats-cards">
                        <div class="stats-card">
                            <div class="stats-value">${statistics.totalSales}</div>
                            <div class="stats-label">总销售额</div>
                        </div>
                        <div class="stats-card">
                            <div class="stats-value">${statistics.totalOrders}</div>
                            <div class="stats-label">总订单数</div>
                        </div>
                        <div class="stats-card">
                            <div class="stats-value">${statistics.totalUsers}</div>
                            <div class="stats-label">新增用户</div>
                        </div>
                        <div class="stats-card">
                            <div class="stats-value">${statistics.totalShops}</div>
                            <div class="stats-label">新增店铺</div>
                        </div>
                    </div>
                    
                    <div class="chart-container">
                        <h3 class="chart-title">平台销售趋势</h3>
                        <canvas id="salesTrendChart" height="300"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <jsp:include page="/WEB-INF/views/common/footer.jsp" />
    
    <!-- 引入管理员管理模块JS -->
    <script src="${pageContext.request.contextPath}/resources/js/modules/admin-manage.js"></script>
</body>
</html>ml>
