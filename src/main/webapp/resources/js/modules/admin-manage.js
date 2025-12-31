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
        // 这里应该从后端获取数据并渲染图表
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
}

// 加载图表通用函数
function loadChart(canvasElement) {
    // 这里应该是具体的图表渲染逻辑
    // 暂时只标记为已加载
    canvasElement.dataset.loaded = 'true';
}

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', initAdminManagePage);
