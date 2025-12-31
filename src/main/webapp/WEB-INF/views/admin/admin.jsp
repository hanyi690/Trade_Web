<%@ page contentType="text/html;charset=UTF-8" language="java" session="false" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <title>管理员控制台 - E-Shop</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/site.css">
    
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
        
        <div class="dashboard" id="dashboard" style="opacity: 0;">
            <div class="sidebar">
                <h3 class="sidebar-title">
                    <i class="fas fa-cog"></i> 管理菜单
                </h3>
                <ul class="sidebar-menu">
                    <li><a href="javascript:void(0)" data-tab="overview" class="${currentTab == 'overview' || empty currentTab ? 'active' : ''}"><i class="fas fa-tachometer-alt"></i> 仪表盘</a></li>
                    <li><a href="javascript:void(0)" data-tab="shops" class="${currentTab == 'shops' ? 'active' : ''}"><i class="fas fa-store"></i> 店铺管理</a></li>
                    <li><a href="javascript:void(0)" data-tab="products" class="${currentTab == 'products' ? 'active' : ''}"><i class="fas fa-box"></i> 商品管理</a></li>
                    <li><a href="javascript:void(0)" data-tab="orders" class="${currentTab == 'orders' ? 'active' : ''}"><i class="fas fa-shopping-cart"></i> 订单管理</a></li>
                    <li><a href="javascript:void(0)" data-tab="users" class="${currentTab == 'users' ? 'active' : ''}"><i class="fas fa-users"></i> 用户管理</a></li>
                    <li><a href="javascript:void(0)" data-tab="statistics" class="${currentTab == 'statistics' ? 'active' : ''}"><i class="fas fa-chart-bar"></i> 平台统计</a></li>
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
            
            <div class="main-content">
                <input type="hidden" name="tab" value="${not empty currentTab ? currentTab : 'overview'}">
                
                <div id="overviewTab" class="tab-content ${currentTab == 'overview' || empty currentTab ? 'active' : ''}">
                
                    <h2 class="section-title"><i class="fas fa-tachometer-alt"></i> 平台概览</h2>
                    
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
                    </div>
                    
                    <div class="charts-row">
                        <!-- 复用statisticsTab的图表样式和图标 -->
                        <div class="chart-container">
                            <h3 class="chart-title">
                                <i class="fas fa-chart-line"></i> 销售趋势
                            </h3>
                            <canvas id="platformSalesChart"></canvas>
                        </div>
                        <div class="chart-container">
                            <h3 class="chart-title">
                                <i class="fas fa-chart-pie"></i> 订单状态分布
                            </h3>
                            <canvas id="shopDistributionChart"></canvas>
                        </div>
                    </div>
                    
                    <div class="recent-activities">
                        <h3 class="section-subtitle">最近活动</h3>
                        <div class="activity-list">
                            <c:forEach var="activity" items="${recentActivities}">
                                <div class="activity-item">
                                    <div class="activity-icon"><i class="fas ${activity.icon}"></i></div>
                                    <div class="activity-content">
                                        <div class="activity-text">${activity.description}</div>
                                        <div class="activity-time">${activity.time}</div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </div>
                
                <div id="shopsTab" class="tab-content ${currentTab == 'shops' ? 'active' : ''}">
                    <c:if test="${currentTab == 'shops'}">
                        <%@ include file="../common/shopTable.jsp" %>
                    </c:if>
                </div>
                
                <div id="productsTab" class="tab-content ${currentTab == 'products' ? 'active' : ''}">
                    <c:if test="${currentTab == 'products'}">
                        <%@ include file="../common/productTable.jsp" %>
                    </c:if>
                </div>
                
                <div id="ordersTab" class="tab-content ${currentTab == 'orders' ? 'active' : ''}">
                    <c:if test="${currentTab == 'orders'}">
                        <%@ include file="../common/orderTable.jsp" %>
                    </c:if>
                </div>
                
                <div id="usersTab" class="tab-content ${currentTab == 'users' ? 'active' : ''}">
                    <c:if test="${currentTab == 'users'}">
                        <%@ include file="../common/userTable.jsp" %>
                    </c:if>
                </div>
                
                <div id="statisticsTab" class="tab-content ${currentTab == 'statistics' ? 'active' : ''}">
                    <c:if test="${currentTab == 'statistics'}">
                        <h2 class="section-title"><i class="fas fa-chart-bar"></i> 详细统计报表</h2>
                        <div class="date-filter">
                            <form method="get" action="${pageContext.request.contextPath}/admin/statistics">
                                <div class="filter-group">
                                    <span class="filter-label">期间：</span>
                                    <input type="date" name="startDate" value="${startDate}">
                                    <span>至</span>
                                    <input type="date" name="endDate" value="${endDate}">
                                    <button type="submit" class="btn btn-primary">筛选</button>
                                </div>
                            </form>
                        </div>
                        <div class="charts-row">
                            <div class="chart-container">
                                <h3 class="chart-title">
                                    <i class="fas fa-chart-line"></i> 销售趋势
                                </h3>
                                <canvas id="salesTrendChart"></canvas>
                            </div>
                            <div class="chart-container">
                                <h3 class="chart-title">
                                    <i class="fas fa-chart-pie"></i> 订单状态分布
                                </h3>
                                <canvas id="orderStatusChart"></canvas>
                            </div>
                        </div>
                    </c:if>
                </div>
            </div> </div>
    </div>
    
    <jsp:include page="../common/footer.jsp" />

    <script>
        (function() {
            try {
                // 使用 JSON.parse 配合 JSP 字符串输出，增加兜底逻辑
                window.g_dailySalesData = JSON.parse('${not empty dailySalesDataJson ? dailySalesDataJson : "[]"}');
                window.g_statusData = JSON.parse('${not empty statusDistributionJson ? statusDistributionJson : "{}"}');
                window.g_platformDailySales = window.g_dailySalesData;
            } catch (e) {
                console.error("数据注入失败:", e);
                window.g_dailySalesData = [];
                window.g_statusData = {};
            }
        })();
    </script>

    <script src="${pageContext.request.contextPath}/resources/js/modules/admin-manage.js"></script>
</body>
</html>