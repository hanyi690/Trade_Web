/* 管理员管理页面核心JavaScript */

// 标签页对应的URL映射
const tabUrlMap = {
    'overview': '/admin',
    'shops': '/admin/shops',
    'products': '/admin/products',
    'orders': '/admin/orders',
    'users': '/admin/users',
    'statistics': '/admin/statistics'
};

// 主初始化函数
function initAdminManagePage() {
    // 1. 立即显示dashboard
    const dashboard = document.getElementById('dashboard');
    if (dashboard) {
        dashboard.style.opacity = '1';
        dashboard.classList.add('loaded');
    }
    
    // 2. 初始化标签页切换
    initAdminTabSwitching();
    
    // 3. 初始化图表
    initAdminCharts();
}

// 标记已加载的标签页
function markLoadedTabs() {
    const tabContents = document.querySelectorAll('.admin-page .tab-content');
    tabContents.forEach(tab => {
        // 如果标签页内容区域已经有子元素，则认为已加载
        if (tab.children.length > 0) {
            tab.dataset.loaded = 'true';
        }
    });
}

// 加载标签页内容
function loadTabContent(tabId) {
    const contentElement = document.getElementById(tabId + 'Tab');
    if (!contentElement) {
        console.warn('未找到标签页内容区域:', tabId + 'Tab');
        return;
    }
    
    // 检查是否已加载
    if (contentElement.dataset.loaded === 'true') {
        return;
    }
    
    const url = tabUrlMap[tabId];
    if (!url) {
        console.warn('未知的标签页:', tabId);
        return;
    }
    
    fetch(url, {
        headers: {
            'X-Requested-With': 'XMLHttpRequest'
        }
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('网络响应异常');
        }
        return response.text();
    })
    .then(html => {
        // 将整个响应HTML转换为DOM
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, 'text/html');
        // 从新文档中提取对应的标签页内容
        const newContent = doc.getElementById(tabId + 'Tab');
        if (newContent) {
            // 替换现有内容区域的内容
            contentElement.innerHTML = newContent.innerHTML;
            // 标记为已加载
            contentElement.dataset.loaded = 'true';
            
            // 如果加载的是统计标签页，初始化图表
            if (tabId === 'statistics') {
                // 稍等片刻确保DOM已更新
                setTimeout(() => {
                    initAdminCharts();
                }, 50);
            }
            
            // 触发内容加载完成事件
            window.dispatchEvent(new CustomEvent('adminTabContentLoaded', { detail: { tabId } }));
        } else {
            console.error('在响应中未找到标签页内容:', tabId + 'Tab');
        }
    })
    .catch(error => {
        console.error('加载标签页失败:', error);
    });
}

// 标签页切换核心函数
function initAdminTabSwitching() {
    const tabLinks = document.querySelectorAll('.admin-page .sidebar-menu a[data-tab]');
    const tabContents = document.querySelectorAll('.admin-page .tab-content');
    
    // 获取当前活动的标签页ID
    let currentTabId = document.querySelector('.admin-page input[name="tab"]')?.value || 'overview';
    
    // 标记已加载的标签页
    markLoadedTabs();
    
    // 为每个标签链接添加点击事件
    tabLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const tabId = this.getAttribute('data-tab');
            
            // 如果点击的是当前已激活的标签，则不做任何操作
            if (tabId === currentTabId) return;
            
            // 更新当前标签ID
            currentTabId = tabId;
            
            // 更新隐藏的tab输入值
            const tabInput = document.querySelector('.admin-page input[name="tab"]');
            if (tabInput) tabInput.value = tabId;
            
            // 更新侧边栏链接的active状态
            tabLinks.forEach(tabLink => tabLink.classList.remove('active'));
            this.classList.add('active');
            
            // 切换标签页内容
            tabContents.forEach(tab => {
                tab.classList.remove('active');
                if (tab.id === tabId + 'Tab') {
                    tab.classList.add('active');
                }
            });
            
            // 更新URL hash（可选，便于直接链接到特定tab）
            window.history.replaceState(null, '', '#' + tabId);
            
            // 触发标签页切换后的自定义事件
            window.dispatchEvent(new CustomEvent('adminTabChanged', { detail: { tabId } }));
            
            // 加载标签页内容
            loadTabContent(tabId);
        });
    });
    
    // 如果URL中有hash，尝试切换到对应的tab
    const hash = window.location.hash.substring(1);
    if (hash && document.querySelector(`.admin-page .sidebar-menu a[data-tab="${hash}"]`)) {
        document.querySelector(`.admin-page .sidebar-menu a[data-tab="${hash}"]`).click();
    }
}

// 初始化管理员图表
function initAdminCharts() {
    console.log('初始化管理员图表');
    
    // 平台销售趋势图
    const platformSalesChart = document.getElementById('platformSalesChart');
    if (platformSalesChart && platformSalesChart.dataset.loaded !== 'true') {
        loadChart(platformSalesChart);
        platformSalesChart.dataset.loaded = 'true';
    }
    
    // 店铺分布图
    const shopDistributionChart = document.getElementById('shopDistributionChart');
    if (shopDistributionChart && shopDistributionChart.dataset.loaded !== 'true') {
        loadChart(shopDistributionChart);
        shopDistributionChart.dataset.loaded = 'true';
    }
    
    // 销售趋势图
    const salesTrendChart = document.getElementById('salesTrendChart');
    if (salesTrendChart && salesTrendChart.dataset.loaded !== 'true') {
        loadChart(salesTrendChart);
        salesTrendChart.dataset.loaded = 'true';
    }
    
    // 订单状态分布图
    const orderStatusChart = document.getElementById('orderStatusChart');
    if (orderStatusChart && orderStatusChart.dataset.loaded !== 'true') {
        loadChart(orderStatusChart);
        orderStatusChart.dataset.loaded = 'true';
    }
}

// 实现真正的图表加载函数
function loadChart(canvasElement) {
    if (!canvasElement) return;

    const chartId = canvasElement.id;
    
    try {
        if (chartId === 'salesTrendChart' || chartId === 'platformSalesChart') {
            renderSalesChart(canvasElement);
        } else if (chartId === 'shopDistributionChart') {
            renderShopDistributionChart(canvasElement);
        } else if (chartId === 'orderStatusChart') {
            renderOrderStatusChart(canvasElement);
        }
        // 标记为已加载，防止重复渲染
        canvasElement.dataset.loaded = 'true';
    } catch (e) {
        console.error("图表渲染失败:", e, chartId);
    }
}

// 渲染销售趋势图 - 增强健壮性
function renderSalesChart(canvas) {
    // 兼容处理：检查全局变量是否存在
    const chartData = window.g_dailySalesData || [];
    if (!chartData || chartData.length === 0) {
        console.warn("销售数据为空，无法渲染图表");
        renderEmptyChart(canvas, '暂无销售数据');
        return;
    }

    try {
        new Chart(canvas, {
            type: 'line',
            data: {
                labels: chartData.map(item => item.date || item.day),
                datasets: [{
                    label: '销售额 (¥)',
                    data: chartData.map(item => item.sales || item.amount || 0),
                    borderColor: '#4e73df',
                    backgroundColor: 'rgba(78, 115, 223, 0.1)',
                    fill: true,
                    tension: 0.3,
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true, // 改为true，保持比例
                aspectRatio: 2, // 设置宽高比为2:1
                plugins: {
                    legend: { display: true, position: 'top' }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                return '¥' + value.toLocaleString();
                            }
                        }
                    }
                }
            }
        });
    } catch (error) {
        console.error('渲染销售图表失败:', error);
        renderEmptyChart(canvas, '图表渲染失败');
    }
}

// 渲染店铺分布图 - 使用后端数据
function renderShopDistributionChart(canvas) {
    // 如果有店铺分布数据，优先使用，否则使用默认数据
    const distributionData = window.g_statusData || {
        '活跃店铺': 85,
        '待审核': 12,
        '已关闭': 3
    };

    try {
        new Chart(canvas, {
            type: 'doughnut',
            data: {
                labels: Object.keys(distributionData),
                datasets: [{
                    data: Object.values(distributionData),
                    backgroundColor: ['#4e73df', '#1cc88a', '#36b9cc', '#f6c23e', '#e74a3b']
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true, // 改为true，保持比例
                aspectRatio: 1, // 饼图强制正方形，防止变成椭圆
                plugins: {
                    legend: { position: 'bottom' }
                }
            }
        });
    } catch (error) {
        console.error('渲染店铺分布图表失败:', error);
        renderEmptyChart(canvas, '店铺数据加载失败');
    }
}

// 渲染订单状态分布图
function renderOrderStatusChart(canvas) {
    const statusData = window.g_statusData || {};
    
    if (Object.keys(statusData).length === 0) {
        renderEmptyChart(canvas, '暂无订单状态数据');
        return;
    }

    try {
        new Chart(canvas, {
            type: 'pie',
            data: {
                labels: Object.keys(statusData),
                datasets: [{
                    data: Object.values(statusData),
                    backgroundColor: ['#4e73df', '#1cc88a', '#f6c23e', '#e74a3b', '#6c757d']
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true, // 改为true，保持比例
                aspectRatio: 1, // 饼图强制正方形，防止变成椭圆
                plugins: {
                    legend: { position: 'right' }
                }
            }
        });
    } catch (error) {
        console.error('渲染订单状态图表失败:', error);
        renderEmptyChart(canvas, '订单数据加载失败');
    }
}

// 渲染空图表占位
function renderEmptyChart(canvas, message) {
    const ctx = canvas.getContext('2d');
    ctx.font = '16px Arial';
    ctx.fillStyle = '#666';
    ctx.textAlign = 'center';
    ctx.fillText(message, canvas.width / 2, canvas.height / 2);
}

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', function() {
    // 确保Chart.js已加载
    if (typeof Chart === 'undefined') {
        console.error('Chart.js未加载，请检查库引入');
        return;
    }
    
    initAdminManagePage();
    
    // 监听标签页内容加载事件
    window.addEventListener('adminTabContentLoaded', function(event) {
        const tabId = event.detail.tabId;
        if (tabId === 'statistics') {
            // 稍等片刻确保DOM已更新
            setTimeout(() => {
                initAdminCharts();
            }, 100);
        }
    });
});
