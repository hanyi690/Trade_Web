<!-- filepath: f:\project\Trade_Web\src\main\webapp\WEB-INF\views\shops\shopManage.jsp -->
<%@ page contentType="text/html;charset=UTF-8" language="java" session="false" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
    <title>${shop.name} - 店铺管理 - E-Shop</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- 预加载关键CSS -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" crossorigin="anonymous">
    <!-- Chart.js 使用异步加载 -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js" crossorigin="anonymous" async></script>
    <!-- 引用统一 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/site.css" preload>
    <!-- 引入店铺管理模块CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modules/shop-manage.css">
    <!-- 引入订单模块CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modules/orders.css">
</head>
<body class="shop-manage-page">
    <!-- 顶部导航栏 -->
    <%@ include file="../common/header.jsp" %>
    
    <div class="container">
        <!-- 页面标题 -->
        <div class="page-header">
            <h1 class="page-title">
                <i class="fas fa-store"></i> ${shop.name} - 店铺管理中心
            </h1>
            <p class="page-subtitle">欢迎回来，店主 ${shop.merchant.username}！</p>
        </div>
        
        <div class="dashboard" id="dashboard">
            <!-- 侧边栏菜单 -->
            <div class="sidebar">
                <h3 class="sidebar-title">
                    <i class="fas fa-cog"></i> 管理菜单
                </h3>
                <ul class="sidebar-menu">
                    <li><a href="javascript:void(0)" data-tab="overview" class="${currentTab == 'overview' ? 'active' : ''}"><i class="fas fa-tachometer-alt"></i> 仪表盘</a></li>
                    <li><a href="javascript:void(0)" data-tab="products" class="${currentTab == 'products' ? 'active' : ''}"><i class="fas fa-box"></i> 商品管理</a></li>
                    <li><a href="javascript:void(0)" data-tab="orders" class="${currentTab == 'orders' ? 'active' : ''}"><i class="fas fa-shopping-cart"></i> 订单管理</a></li>
                    <li><a href="javascript:void(0)" data-tab="statistics" class="${currentTab == 'statistics' ? 'active' : ''}"><i class="fas fa-chart-bar"></i> 销售统计</a></li>
                    <li><a href="${pageContext.request.contextPath}/shops/edit/${shop.id}"><i class="fas fa-edit"></i> 店铺设置</a></li>
                    <li><a href="${pageContext.request.contextPath}/shops/${shop.id}"><i class="fas fa-external-link-alt"></i> 查看店铺</a></li>
                </ul>
                
                <div class="shop-status">
                    <h4 class="shop-status-title">店铺状态</h4>
                    <div class="status-indicator">
                        <div class="status-dot status-open"></div>
                        <span>正常营业</span>
                    </div>
                    <div class="shop-created-time">
                        创建于: ${shopCreatedTimeFull}
                    </div>
                </div>
            </div>
            
            <!-- 主内容区 -->
            <div class="main-content">
                <!-- 隐藏的tab状态存储 -->
                <input type="hidden" name="tab" value="${currentTab}">
                
                <!-- 日期筛选器 -->
                <div class="date-filter ${currentTab == 'statistics' ? 'active' : ''}" id="dateFilterSection">
                    <form class="filter-form" method="get" action="${pageContext.request.contextPath}/shops/${shop.id}/manage">
                        <input type="hidden" name="tab" value="${currentTab}">
                        <div class="filter-group">
                            <span class="filter-label">统计期间：</span>
                            <input type="date" name="startDate" class="filter-input" 
                                   value="${startDate}" max="${endDate}">
                            <span>至</span>
                            <input type="date" name="endDate" class="filter-input" 
                                   value="${endDate}" min="${startDate}" max="<%= java.time.LocalDate.now() %>">
                        </div>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-filter"></i> 筛选
                        </button>
                        <button type="button" class="btn btn-secondary" onclick="resetDateFilter()">
                            <i class="fas fa-redo"></i> 重置
                        </button>
                    </form>
                </div>
                
                <!-- 标签页内容 -->
                
                <!-- 仪表盘标签页 -->
                <div id="overviewTab" class="tab-content ${currentTab == 'overview' ? 'active' : ''}">
                    <!-- 快速操作 -->
                    <div class="quick-actions">
                        <a href="${pageContext.request.contextPath}/products/create" class="btn btn-success">
                            <i class="fas fa-plus"></i> 添加新商品
                        </a>
                        <a href="${pageContext.request.contextPath}/shops/edit/${shop.id}" class="btn btn-primary">
                            <i class="fas fa-edit"></i> 编辑店铺信息
                        </a>
                        <a href="${pageContext.request.contextPath}/shops/${shop.id}/products" class="btn btn-secondary">
                            <i class="fas fa-eye"></i> 预览商品页面
                        </a>
                    </div>
                    
                    <!-- 统计概览 -->
                    <h2 class="section-title" id="overview">
                        <i class="fas fa-tachometer-alt"></i> 店铺概览
                    </h2>
                    
                    <div class="stats-grid">
                        <div class="stat-card">
                            <div class="stat-value">${totalProductCount}</div>
                            <div class="stat-label">在售商品</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value" id="today-orders">
                                <c:if test="${not empty salesStats}">${salesStats.todayOrders}</c:if>
                                <c:if test="${empty salesStats}">0</c:if>
                            </div>
                            <div class="stat-label">今日订单</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value" id="today-sales">
                                <c:if test="${not empty salesStats}">¥<fmt:formatNumber value="${salesStats.todaySales}" minFractionDigits="2" maxFractionDigits="2"/></c:if>
                                <c:if test="${empty salesStats}">¥0.00</c:if>
                            </div>
                            <div class="stat-label">今日销售额</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value" id="total-orders">
                                <c:if test="${not empty salesStats}">${salesStats.totalOrders}</c:if>
                                <c:if test="${empty salesStats}">0</c:if>
                            </div>
                            <div class="stat-label">总订单数</div>
                        </div>
                    </div>
                    
                    <!-- 销售统计 -->
                    <h2 class="section-title" style="margin-top: 30px;">
                        <i class="fas fa-chart-line"></i> 销售统计
                    </h2>
                    
                    <div class="stats-grid">
                        <div class="stat-card">
                            <div class="stat-value" style="color: #27ae60;">
                                <c:if test="${not empty salesStats}">¥<fmt:formatNumber value="${salesStats.totalSales}" minFractionDigits="2" maxFractionDigits="2"/></c:if>
                                <c:if test="${empty salesStats}">¥0.00</c:if>
                            </div>
                            <div class="stat-label">总销售额</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value" style="color: #3498db;">
                                <c:if test="${not empty salesStats}">${salesStats.totalQuantity}</c:if>
                                <c:if test="${empty salesStats}">0</c:if>
                            </div>
                            <div class="stat-label">总销量</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value" style="color: #9b59b6;">
                                <c:if test="${not empty avgOrderAmount}">¥<fmt:formatNumber value="${avgOrderAmount}" minFractionDigits="2" maxFractionDigits="2"/></c:if>
                                <c:if test="${empty avgOrderAmount}">¥0.00</c:if>
                            </div>
                            <div class="stat-label">平均订单金额</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value" style="color: #e74c3c;">
                                <c:if test="${not empty salesStats}">${salesStats.todayQuantity}</c:if>
                                <c:if test="${empty salesStats}">0</c:if>
                            </div>
                            <div class="stat-label">今日销量</div>
                        </div>
                    </div>
                </div>
                
                <!-- 商品管理标签页 -->
                <div id="productsTab" class="tab-content ${currentTab == 'products' ? 'active' : ''}">
                    <h2 class="section-title" id="products">
                        <i class="fas fa-box"></i> 商品管理
                    </h2>
                    
                    <!-- 新增：商品操作消息显示区域 -->
                    <c:if test="${not empty successMessage}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <i class="fas fa-check-circle me-2"></i> ${successMessage}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-circle me-2"></i> ${errorMessage}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>
                    
                    <%-- 使用通用商品表格组件 --%>
                    <c:set var="showIdColumn" value="false" />
                    <c:set var="showCategoryColumn" value="false" />
                    <c:set var="showMerchantColumn" value="false" />
                    <c:set var="showStatusColumn" value="false" />
                    <c:set var="showAddButton" value="true" />
                    <%@ include file="../common/productTable.jsp" %>
                </div>
                
                <!-- 订单管理标签页 -->
                <div id="ordersTab" class="tab-content ${currentTab == 'orders' ? 'active' : ''}">
                    <h2 class="section-title" id="orders">
                        <i class="fas fa-shopping-cart"></i> 订单管理
                        <span class="order-count">(共 ${not empty orders ? fn:length(orders) : 0} 个订单)</span>
                        <span class="stat-date-range">${startDate} 至 ${endDate}</span>
                    </h2>
                    
                    <%-- 使用公共订单组件 --%>
                    <c:set var="context" value="shop" scope="request" />
                    <c:set var="filterAction" value="${pageContext.request.contextPath}/shops/${shop.id}/manage" scope="request" />
                    <c:set var="tabParam" value="orders" scope="request" />
                    <c:set var="resetFunction" value="resetOrdersDateFilter" scope="request" />
                    <c:set var="showDateFilter" value="true" scope="request" />
                    <c:set var="showOrderCount" value="false" scope="request" />
                    
                    <%@ include file="../common/orderTable.jsp" %>
                </div>
                
                <!-- 销售统计标签页 -->
                <div id="statisticsTab" class="tab-content ${currentTab == 'statistics' ? 'active' : ''}">
                    <h2 class="section-title" id="statistics">
                        <i class="fas fa-chart-bar"></i> 销售统计报表
                        <span class="stat-date-range">${startDate} 至 ${endDate}</span>
                    </h2>
                    
                    <!-- 统计概览 -->
                    <div class="stats-cards">
                        <div class="stats-card">
                            <div class="stats-value">
                                <c:if test="${not empty orderStats.totalSales}">¥<fmt:formatNumber value="${orderStats.totalSales}" minFractionDigits="2"/></c:if>
                                <c:if test="${empty orderStats.totalSales}">¥0.00</c:if>
                            </div>
                            <div class="stats-label">总销售额</div>
                        </div>
                        <div class="stats-card">
                            <div class="stats-value">${not empty orderStats.totalOrders ? orderStats.totalOrders : 0}</div>
                            <div class="stats-label">总订单数</div>
                        </div>
                        <div class="stats-card">
                            <div class="stats-value">${not empty orderStats.totalQuantity ? orderStats.totalQuantity : 0}</div>
                            <div class="stats-label">总销量</div>
                        </div>
                        <div class="stats-card">
                            <div class="stats-value">
                                <c:if test="${not empty orderStats.avgOrderAmount}">¥<fmt:formatNumber value="${orderStats.avgOrderAmount}" minFractionDigits="2"/></c:if>
                                <c:if test="${empty orderStats.avgOrderAmount}">¥0.00</c:if>
                            </div>
                            <div class="stats-label">平均订单金额</div>
                        </div>
                    </div>
                    
                    <!-- 每日销售趋势图 -->
                    <div class="chart-container">
                        <h3 class="chart-title">每日销售趋势</h3>
                        <canvas id="salesChart" height="300" class="lazy-chart"></canvas>
                    </div>
                    
                    <!-- 订单状态分布 -->
                    <div class="chart-container">
                        <h3 class="chart-title">订单状态分布</h3>
                        <div class="chart-wrapper">
                            <canvas id="statusChart" width="200" height="200" class="lazy-chart"></canvas>
                            <div class="status-distribution">
                                <c:if test="${not empty statusDistribution}">
                                    <c:forEach var="entry" items="${statusDistribution}">
                                        <div class="status-item">
                                            <span class="status-name">${entry.key}:</span>
                                            <span class="status-count">${entry.value} 单</span>
                                        </div>
                                    </c:forEach>
                                </c:if>
                            </div>
                        </div>
                    </div>
                    
                    <!-- 最新订单 -->
                    <div class="chart-container">
                        <h3 class="chart-title">最新订单</h3>
                        <c:if test="${not empty recentOrders}">
                            <div class="recent-orders-table">
                                <table>
                                    <thead>
                                        <tr>
                                            <th>订单号</th>
                                            <th>买家</th>
                                            <th>金额</th>
                                            <th>状态</th>
                                            <th>时间</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="order" items="${recentOrders}">
                                            <tr>
                                                <td>${order.id}</td>
                                                <td>${order.user.username}</td>
                                                <td class="order-amount-cell">
                                                    ¥<fmt:formatNumber value="${order.totalAmount}" minFractionDigits="2"/>
                                                </td>
                                                <td>
                                                    <span class="order-status status-${fn:toLowerCase(order.status)}">
                                                        ${order.status}
                                                    </span>
                                                </td>
                                                <td>
                                                    ${order.createTime}
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:if>
                        <c:if test="${empty recentOrders}">
                            <p class="no-data-message">暂无最近订单</p>
                        </c:if>
                    </div>
                    
                    <!-- 销售排行榜 -->
                    <div class="chart-container">
                        <h3 class="chart-title">商品销售排行榜</h3>
                        <c:if test="${not empty orderStats.topProducts}">
                            <div class="top-products-table">
                                <table>
                                    <thead>
                                        <tr>
                                            <th>排名</th>
                                            <th>商品名称</th>
                                            <th>销量</th>
                                            <th>销售额</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="product" items="${orderStats.topProducts}" varStatus="status">
                                            <tr>
                                                <td>${status.index + 1}</td>
                                                <td>${product.name}</td>
                                                <td>${product.sales}</td>
                                                <td class="product-revenue-cell">
                                                    ¥<fmt:formatNumber value="${product.revenue}" minFractionDigits="2"/>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:if>
                        <c:if test="${empty orderStats.topProducts}">
                            <p class="no-data-message">暂无销售数据</p>
                        </c:if>
                    </div>
                </div>
                
                <!-- 店铺信息 -->
                <div class="shop-info-section">
                    <h2 class="section-title">
                        <i class="fas fa-info-circle"></i> 店铺信息
                    </h2>
                    <div class="info-grid">
                        <div class="info-panel">
                            <h4>基本信息</h4>
                            <p><strong>店铺名称:</strong> ${shop.name}</p>
                            <p><strong>店主:</strong> ${shop.merchant.username}</p>
                            <c:if test="${not empty shop.contactPhone}">
                                <p><strong>联系电话:</strong> ${shop.contactPhone}</p>
                            </c:if>
                            <p><strong>店铺ID:</strong> ${shop.id}</p>
                        </div>
                        
                        <div class="info-panel">
                            <h4>联系信息</h4>
                            <c:if test="${not empty shop.contactEmail}">
                                <p><strong>邮箱:</strong> ${shop.contactEmail}</p>
                            </c:if>
                            <c:if test="${not empty shop.address}">
                                <p><strong>地址:</strong> ${shop.address}</p>
                            </c:if>
                            <p><strong>创建时间:</strong> ${shopCreatedTimeShort}</p>
                        </div>
                        
                        <div class="info-panel">
                            <h4>店铺统计</h4>
                            <p><strong>商品总数:</strong> ${totalProductCount}</p>
                            <p><strong>在售商品:</strong> ${activeProductCount}</p>
                            <p><strong>总销量:</strong> ${totalSalesCount}</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <%@ include file="../common/footer.jsp" %>

    <!-- 注：为 site.js 提供 contextPath 与 CSRF token -->
    <input type="hidden" id="ctxPath" value="${pageContext.request.contextPath}">
    <input type="hidden" id="csrfToken" value="${_csrf.token}">
    

    <script>
    // 使用 escapeXml="false" 确保 JSON 引号不被转义成 &quot;
    window.g_dailySalesData = <c:out value="${dailySalesDataJson}" escapeXml="false" default="[]" />;
    window.g_statusData = <c:out value="${statusDistributionJson}" escapeXml="false" default="{}" />;
</script>

    <!-- 引入公共脚本 -->
    <script src="${pageContext.request.contextPath}/resources/js/site.js" defer></script>
    <!-- 引入店铺管理模块JS -->
    <script src="${pageContext.request.contextPath}/resources/js/modules/shop-manage.js"></script>
    <!-- 引入订单模块JS -->
    <script src="${pageContext.request.contextPath}/resources/js/modules/orders.js"></script>
    
</body>
</html>