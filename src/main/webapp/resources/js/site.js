(function(window, document){
    'use strict';

    // 安全解析 JSON（返回 null/[]/{})
    function safeParse(jsonStr, fallback) {
        try {
            if (!jsonStr) return fallback;
            return JSON.parse(jsonStr);
        } catch (e) {
            console.warn('safeParse failed', e);
            return fallback;
        }
    }

    // 消息自动消失
    function autoDismissMessages(timeout = 5000) {
        const messages = document.querySelectorAll('.message');
        messages.forEach(message => {
            setTimeout(() => {
                message.style.transition = 'all 0.5s ease';
                message.style.opacity = '0';
                message.style.transform = 'translateY(-20px)';
                setTimeout(() => message.remove(), 500);
            }, timeout);
        });
    }

    // 购物车：增减数量（与原页面保持函数名以便直接使用）
    window.changeQuantity = function(cartItemId, delta) {
        const visibleInput = document.getElementById('visible-' + cartItemId);
        if (!visibleInput) return;
        let current = parseInt(visibleInput.value) || 1;
        let newQty = current + delta;
        if (newQty < 1) newQty = 1;
        visibleInput.value = newQty;
        const hiddenQty = document.getElementById('qty-' + cartItemId);
        if (hiddenQty) hiddenQty.value = newQty;
        const updateForm = document.getElementById('updateForm-' + cartItemId);
        if (updateForm) updateForm.submit();
    };

    window.setQuantity = function(cartItemId, value) {
        let newValue = parseInt(value) || 1;
        if (newValue < 1) newValue = 1;
        const visible = document.getElementById('visible-' + cartItemId);
        if (visible) visible.value = newValue;
        const hiddenQty = document.getElementById('qty-' + cartItemId);
        if (hiddenQty) hiddenQty.value = newValue;
        const updateForm = document.getElementById('updateForm-' + cartItemId);
        if (updateForm) updateForm.submit();
    };

    // 商品详情：图片切换
    window.changeImage = function(src, thumbElement) {
        const main = document.getElementById('mainImage');
        if (main && src) main.src = src;
        if (thumbElement) {
            document.querySelectorAll('.thumbnail').forEach(t => t.classList.remove('active'));
            try { thumbElement.classList.add('active'); } catch(e){}
        }
    };

    // 商品详情数量选择（页面上也可能直接调用 changeQuantityProductDetail）
    window.changeQuantityProductDetail = function(delta) {
        const quantityInput = document.getElementById('quantity');
        const formQuantity = document.getElementById('formQuantity');
        if (!quantityInput) return;
        let quantity = parseInt(quantityInput.value) + delta;
        if (isNaN(quantity) || quantity < 1) quantity = 1;
        if (quantity > 99) quantity = 99;
        quantityInput.value = quantity;
        if (formQuantity) formQuantity.value = quantity;
    };

    window.initProductDetailQuantityListener = function() {
        const q = document.getElementById('quantity');
        if (!q) return;
        q.addEventListener('change', function(){
            let quantity = parseInt(this.value);
            if (isNaN(quantity) || quantity < 1) quantity = 1;
            if (quantity > 99) quantity = 99;
            this.value = quantity;
            const formQuantity = document.getElementById('formQuantity');
            if (formQuantity) formQuantity.value = quantity;
        });
    };

    // Chart 初始化包装（依赖 Chart.js 已加载）
    window.initSalesChart = function(canvasId, dailySalesJson) {
        try {
            const ctx = document.getElementById(canvasId)?.getContext('2d');
            if (!ctx) return;
            const daily = safeParse(dailySalesJson, []);
            if (!daily || daily.length === 0) return;
            const labels = daily.map(item => item.date);
            const sales = daily.map(item => item.sales);
            const orders = daily.map(item => item.orders);
            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [
                        { label: '销售额', data: sales, borderColor: '#e74c3c', backgroundColor: 'rgba(231,76,60,0.08)', tension:0.35, fill:true },
                        { label: '订单数', data: orders, borderColor: '#3498db', backgroundColor: 'rgba(52,152,219,0.08)', tension:0.35, fill:true }
                    ]
                },
                options: { responsive:true, plugins:{ legend:{ position:'top' } }, scales:{ y:{ beginAtZero:true } } }
            });
        } catch(e) { console.error('initSalesChart error', e); }
    };

    window.initStatusChart = function(canvasId, statusJson) {
        try {
            const ctx = document.getElementById(canvasId)?.getContext('2d');
            if (!ctx) return;
            const statusData = safeParse(statusJson, {});
            if (!statusData || Object.keys(statusData).length === 0) return;
            const labels = Object.keys(statusData);
            const data = Object.values(statusData);
            const colors = ['#f39c12', '#3498db', '#9b59b6', '#2ecc71', '#e74c3c'];
            new Chart(ctx, {
                type: 'doughnut',
                data: { labels: labels, datasets:[{ data:data, backgroundColor: colors.slice(0, data.length), borderWidth:1 }] },
                options: { responsive:true, plugins:{ legend:{ position:'right' } } }
            });
        } catch(e) { console.error('initStatusChart error', e); }
    };

    
    // 商品管理相关函数
    window.initProductManagement = function() {
        // 表格排序
        const tableHeaders = document.querySelectorAll('.product-table th');
        tableHeaders.forEach((header, index) => {
            if (header.textContent.trim() !== '操作') {
                header.style.cursor = 'pointer';
                header.addEventListener('click', () => {
                    sortProductTable(index);
                });
            }
        });
        
        // 初始化确认删除对话框
        initDeleteConfirmation();
    };

    function sortProductTable(columnIndex) {
        const table = document.querySelector('.product-table');
        const tbody = table.querySelector('tbody');
        const rows = Array.from(tbody.querySelectorAll('tr'));
        const isNumeric = columnIndex === 0 || columnIndex === 3 || columnIndex === 4; // ID, 价格, 库存, 销量列
        
        rows.sort((a, b) => {
            const aCell = a.children[columnIndex];
            const bCell = b.children[columnIndex];
            const aText = aCell.textContent.trim();
            const bText = bCell.textContent.trim();
            
            if (isNumeric) {
                const aNum = parseFloat(aText.replace(/[^\d.]/g, '')) || 0;
                const bNum = parseFloat(bText.replace(/[^\d.]/g, '')) || 0;
                return aNum - bNum;
            }
            return aText.localeCompare(bText, 'zh-CN');
        });
        
        // 清空并重新添加排序后的行
        while (tbody.firstChild) {
            tbody.removeChild(tbody.firstChild);
        }
        
        rows.forEach(row => tbody.appendChild(row));
    }

    function initDeleteConfirmation() {
        document.querySelectorAll('.btn-danger').forEach(function(btn) {
            btn.addEventListener('click', function(e) {
                const productName = this.closest('tr').querySelector('td:nth-child(3) strong').textContent;
                if (!confirm(`确定要删除商品【${productName}】吗？此操作不可恢复！`)) {
                    e.preventDefault();
                }
            });
        });
    }

    // 初始化入口
    document.addEventListener('DOMContentLoaded', function(){
        autoDismissMessages();
        // 产品详情页面数量监听
        try { initProductDetailQuantityListener(); } catch(e){}
        // 初始化商品管理功能
        try { if (document.querySelector('.product-table')) initProductManagement(); } catch(e){}
    });

})(window, document);
