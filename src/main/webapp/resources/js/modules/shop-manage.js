/* 店铺管理页面核心JavaScript - 精简版 */

// 主初始化函数
function initShopManagePage() {
    // 1. 立即显示dashboard
    const dashboard = document.getElementById('dashboard');
    if (dashboard) {
        dashboard.style.opacity = '1';
        dashboard.classList.add('loaded');
    }
    
    // 2. 初始化标签页切换
    initTabSwitching();
    
    // 3. 设置日期筛选器初始显示状态（已通过服务器端类控制，无需JS设置）
}

// 标签页切换核心函数
function initTabSwitching() {
    const tabLinks = document.querySelectorAll('.sidebar-menu a[data-tab]');
    const tabContents = document.querySelectorAll('.tab-content');
    
    // 获取当前活动的标签页ID
    let currentTabId = document.querySelector('input[name="tab"]')?.value || 'overview';
    
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
            const tabInput = document.querySelector('input[name="tab"]');
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
            
            // 处理日期筛选器的显示/隐藏 - 改为通过类控制
            const dateFilter = document.getElementById('dateFilterSection');
            if (dateFilter) {
                if (tabId === 'statistics') {
                    dateFilter.classList.add('active');
                } else {
                    dateFilter.classList.remove('active');
                }
            }
            
            // 更新URL hash（可选，便于直接链接到特定tab）
            window.history.replaceState(null, '', '#' + tabId);
            
            // 触发标签页切换后的自定义事件（供其他模块使用）
            window.dispatchEvent(new CustomEvent('tabChanged', { detail: { tabId } }));
            
            // 如果是统计标签页，自动加载统计图表
            if (tabId === 'statistics') {
                setTimeout(() => {
                    loadStatisticsCharts();
                }, 50);
            }
        });
    });
    
    // 如果URL中有hash，尝试切换到对应的tab
    const hash = window.location.hash.substring(1);
    if (hash && document.querySelector(`.sidebar-menu a[data-tab="${hash}"]`)) {
        document.querySelector(`.sidebar-menu a[data-tab="${hash}"]`).click();
    }
}

// 新增：加载统计数据的函数
function loadStatisticsData() {
    // 查找统计标签页
    const statisticsTab = document.getElementById('statisticsTab');
    if (!statisticsTab) return;
    
    // 尝试查找统计筛选表单
    const statisticsFilterForm = statisticsTab.querySelector('.filter-form');
    if (statisticsFilterForm) {
        // 获取当前筛选参数
        const startDateInput = statisticsFilterForm.querySelector('input[name="startDate"]');
        const endDateInput = statisticsFilterForm.querySelector('input[name="endDate"]');
        
        // 如果日期参数存在，自动提交表单以加载统计数据和图表
        if (startDateInput && endDateInput) {
            // 自动提交表单以加载统计数据
            statisticsFilterForm.submit();
            return;
        }
    }
    
    // 如果找不到表单或日期参数，尝试直接加载图表
    loadStatisticsCharts();
}

// 新增：加载统计图表
function loadStatisticsCharts() {
    // 尝试加载销售趋势图
    const salesChart = document.getElementById('salesChart');
    if (salesChart && salesChart.dataset.loaded !== 'true') {
        loadChart(salesChart);
    }
    
    // 尝试加载状态分布图
    const statusChart = document.getElementById('statusChart');
    if (statusChart && statusChart.dataset.loaded !== 'true') {
        loadChart(statusChart);
    }
    
    // 尝试调用统计模块的初始化函数（如果存在）
    if (typeof window.initStatisticsCharts === 'function') {
        window.initStatisticsCharts();
    }
}

// 重置统计页面日期筛选器
window.resetDateFilter = function() {
    const today = new Date();
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(today.getDate() - 30);
    
    const formatDate = (date) => date.toISOString().split('T')[0];
    
    const startDateInput = document.querySelector('#dateFilterSection input[name="startDate"]');
    const endDateInput = document.querySelector('#dateFilterSection input[name="endDate"]');
    
    if (startDateInput) startDateInput.value = formatDate(thirtyDaysAgo);
    if (endDateInput) endDateInput.value = formatDate(today);
    
    const filterForm = document.querySelector('#dateFilterSection .filter-form');
    if (filterForm) filterForm.submit();
};

// 重置订单页面日期筛选器
window.resetOrdersDateFilter = function() {
    if (typeof window.resetDateFilter === 'function') {
        window.resetDateFilter();
    }
};
// 实现真正的图表加载函数
function loadChart(canvasElement) {
    if (!canvasElement) return;

    // 获取从后端传来的数据字符串 (假设你已经在 JSP 中定义了全局变量)
    // 或者直接从全局 window 对象读取
    const chartId = canvasElement.id;
    
    try {
        if (chartId === 'salesChart') {
            renderSalesChart(canvasElement);
        } else if (chartId === 'statusChart') {
            renderStatusChart(canvasElement);
        }
        // 标记为已加载，防止重复渲染
        canvasElement.dataset.loaded = 'true';
    } catch (e) {
        console.error("图表渲染失败:", e);
    }
}

// 渲染销售趋势图
function renderSalesChart(canvas) {
    // 从 JSP 注入的全局变量获取数据（需在 JSP 中先定义）
    if (typeof g_dailySalesData === 'undefined' || g_dailySalesData.length === 0) return;

    new Chart(canvas, {
        type: 'line',
        data: {
            labels: g_dailySalesData.map(item => item.date),
            datasets: [{
                label: '销售额 (¥)',
                data: g_dailySalesData.map(item => item.sales),
                borderColor: '#4e73df',
                backgroundColor: 'rgba(78, 115, 223, 0.05)',
                fill: true,
                tension: 0.3
            }]
        },
        options: {
                responsive: true,
                maintainAspectRatio: true, // 改为 true，强制保持比例
                aspectRatio: 2, // 设置宽高比为 2:1（宽度是高度的两倍）
                plugins: {
                    legend: { display: true, position: 'top' }
                }
            }
    });
}

// 渲染订单状态分布图
function renderStatusChart(canvas) {
    if (typeof g_statusData === 'undefined' || Object.keys(g_statusData).length === 0) return;

    new Chart(canvas, {
        type: 'doughnut',
        data: {
            labels: Object.keys(g_statusData),
            datasets: [{
                data: Object.values(g_statusData),
                backgroundColor: ['#4e73df', '#1cc88a', '#36b9cc', '#f6c23e', '#e74a3b']
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            aspectRatio: 1, // 饼图强制正方形，防止变成椭圆
            plugins: {
                legend: { position: 'bottom' }
            }
        }
    });
}
// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', initShopManagePage);
