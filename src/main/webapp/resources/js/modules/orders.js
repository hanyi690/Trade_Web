/* 订单相关页面JavaScript函数 */

// 支付页面功能
function initPaymentPage() {
    // 选择支付方式
    document.querySelectorAll('.payment-method').forEach(method => {
        method.addEventListener('click', function() {
            // 移除所有选中状态
            document.querySelectorAll('.payment-method').forEach(m => {
                m.classList.remove('selected');
            });
            // 添加当前选中状态
            this.classList.add('selected');
            // 更新隐藏字段
            const paymentMethodInput = document.getElementById('paymentMethod');
            if (paymentMethodInput) {
                paymentMethodInput.value = this.dataset.method;
            }
        });
    });
    
    // 表单提交处理
    const paymentForm = document.getElementById('paymentForm');
    if (paymentForm) {
        paymentForm.addEventListener('submit', function(e) {
            const payButton = document.getElementById('payButton');
            const agreeTerms = document.getElementById('agreeTerms');
            
            if (!agreeTerms || !agreeTerms.checked) {
                e.preventDefault();
                alert('请同意支付协议和退款政策');
                return false;
            }
            
            // 防止重复提交
            if (payButton) {
                payButton.disabled = true;
                payButton.innerHTML = '<i class="bi bi-hourglass-split"></i> 支付处理中...';
            }
            
            return true;
        });
    }
    
    // 页面加载时设置默认支付方式
    document.addEventListener('DOMContentLoaded', function() {
        const paymentMethodInput = document.getElementById('paymentMethod');
        if (paymentMethodInput && !paymentMethodInput.value) {
            paymentMethodInput.value = 'simulation';
        }
    });
}

// 订单表单页面功能
function initOrderForm() {
    // 订单表单验证 (创建模式)
    const orderForm = document.getElementById('orderForm');
    if (orderForm) {
        orderForm.addEventListener('submit', function(e) {
            const receiverName = document.getElementById('receiverName').value.trim();
            const receiverPhone = document.getElementById('receiverPhone').value.trim();
            const shippingAddress = document.getElementById('shippingAddress').value.trim();
            
            if (!receiverName || !receiverPhone || !shippingAddress) {
                e.preventDefault();
                alert('请填写所有必填字段！');
                return false;
            }
            
            // 手机号验证
            const phoneRegex = /^1[3-9]\d{9}$/;
            if (!phoneRegex.test(receiverPhone)) {
                e.preventDefault();
                alert('请输入有效的11位手机号码！');
                return false;
            }
            
            // 防止重复提交
            const submitBtn = document.getElementById('submitBtn');
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.innerHTML = '<i class="bi bi-hourglass-split"></i> 处理中...';
            }
            
            return true;
        });
        
        // 自动填充示例地址
        document.addEventListener('DOMContentLoaded', function() {
            const addressInput = document.getElementById('shippingAddress');
            const username = document.getElementById('username')?.value || '';
            if (addressInput && !addressInput.value && username) {
                addressInput.value = username + '的默认地址';
            }
        });
    }
    
    // 编辑表单验证
    const editOrderForm = document.getElementById('editOrderForm');
    if (editOrderForm) {
        editOrderForm.addEventListener('submit', function(e) {
            const receiverName = document.getElementById('editReceiverName')?.value.trim();
            const receiverPhone = document.getElementById('editReceiverPhone')?.value.trim();
            const shippingAddress = document.getElementById('editShippingAddress')?.value.trim();
            
            if (!receiverName || !receiverPhone || !shippingAddress) {
                e.preventDefault();
                alert('请填写所有必填字段！');
                return false;
            }
            
            const phoneRegex = /^1[3-9]\d{9}$/;
            if (!phoneRegex.test(receiverPhone)) {
                e.preventDefault();
                alert('请输入有效的11位手机号码！');
                return false;
            }
            
            const saveEditBtn = document.getElementById('saveEditBtn');
            if (saveEditBtn) {
                saveEditBtn.disabled = true;
                saveEditBtn.innerHTML = '<i class="bi bi-hourglass-split"></i> 保存中...';
            }
            
            return true;
        });
    }
    
    // 确认收货函数
    window.confirmReceipt = function(orderId) {
        if (confirm('确认已收到商品？')) {
            // 这里应该调用API更新订单状态
            alert('确认收货成功！');
            window.location.reload();
        }
    };
}

// 我的订单页面功能
function initMyOrders() {
    // 重置订单日期筛选器
    window.resetOrdersDateFilter = function() {
        document.querySelector('input[name="startDate"]').value = '';
        document.querySelector('input[name="endDate"]').value = '';
        const filterForm = document.querySelector('.filter-form');
        if (filterForm) {
            filterForm.submit();
        }
    };
    
    // 刷新订单
    window.refreshOrders = function() {
        window.location.reload();
    };
    
    // 查看订单详情
    window.viewOrderDetail = function(orderId) {
        window.location.href = window.ctxPath + '/orders/' + orderId;
    };
    
    // 取消订单
    window.cancelOrder = function(orderId) {
        if (confirm('确定要取消此订单吗？取消后无法恢复。')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = window.ctxPath + '/orders/' + orderId + '/cancel';
            
            // 添加CSRF令牌
            const csrfToken = document.querySelector('meta[name="_csrf"]')?.content || 
                              document.querySelector('input[name="_csrf"]')?.value;
            if (csrfToken) {
                const csrfInput = document.createElement('input');
                csrfInput.type = 'hidden';
                csrfInput.name = '_csrf';
                csrfInput.value = csrfToken;
                form.appendChild(csrfInput);
            }
            
            document.body.appendChild(form);
            form.submit();
        }
    };
    
    // 确认收货
    window.confirmReceipt = function(orderId) {
        if (confirm('确认已收到商品吗？')) {
            alert('确认收货功能开发中...');
            // 这里可以添加确认收货的API调用
        }
    };
    
    // 发货订单项（商家使用）
    window.shipOrderItem = function(orderId, orderItemId) {
        if (confirm('确认要发货此商品吗？')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = window.ctxPath + '/orders/' + orderId + '/items/' + orderItemId + '/ship';
            
            // 添加CSRF令牌
            const csrfToken = document.querySelector('meta[name="_csrf"]')?.content || 
                              document.querySelector('input[name="_csrf"]')?.value;
            if (csrfToken) {
                const csrfInput = document.createElement('input');
                csrfInput.type = 'hidden';
                csrfInput.name = '_csrf';
                csrfInput.value = csrfToken;
                form.appendChild(csrfInput);
            }
            
            document.body.appendChild(form);
            form.submit();
        }
    };
    
    // 确认收货订单项（用户使用）
    window.deliverOrderItem = function(orderId, orderItemId) {
        if (confirm('确认已收到此商品？')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = window.ctxPath + '/orders/' + orderId + '/items/' + orderItemId + '/deliver';
            
            // 添加CSRF令牌
            const csrfToken = document.querySelector('meta[name="_csrf"]')?.content || 
                              document.querySelector('input[name="_csrf"]')?.value;
            if (csrfToken) {
                const csrfInput = document.createElement('input');
                csrfInput.type = 'hidden';
                csrfInput.name = '_csrf';
                csrfInput.value = csrfToken;
                form.appendChild(csrfInput);
            }
            
            document.body.appendChild(form);
            form.submit();
        }
    };
    
    // 批量发货
    window.batchShipOrderItems = function(orderId) {
        const pendingItems = [];
        document.querySelectorAll('.order-item-checkbox:checked').forEach(checkbox => {
            if (checkbox.dataset.status === 'PENDING') {
                pendingItems.push(checkbox.value);
            }
        });
        
        if (pendingItems.length === 0) {
            alert('请选择待发货的商品');
            return;
        }
        
        if (confirm(`确定要发货选中的 ${pendingItems.length} 个商品吗？`)) {
            // 这里可以调用批量发货API
            alert('批量发货功能开发中');
        }
    };
    
    // 批量确认收货
    window.batchDeliverOrderItems = function(orderId) {
        const deliveredItems = [];
        document.querySelectorAll('.order-item-checkbox:checked').forEach(checkbox => {
            if (checkbox.dataset.status === 'DELIVERED') {
                deliveredItems.push(checkbox.value);
            }
        });
        
        if (deliveredItems.length === 0) {
            alert('请选择已发货的商品');
            return;
        }
        
        if (confirm(`确认已收到选中的 ${deliveredItems.length} 个商品？`)) {
            // 这里可以调用批量确认收货API
            alert('批量确认收货功能开发中');
        }
    };
    
    // 页面加载完成后初始化
    document.addEventListener('DOMContentLoaded', function() {
        // 高亮当前页面
        const currentPage = 'orders';
        const navLinks = document.querySelectorAll('.nav-link');
        navLinks.forEach(link => {
            if (link.getAttribute('href')?.includes(currentPage)) {
                link.classList.add('active');
            }
        });
        
        // 初始化日期输入的最大值
        const today = new Date().toISOString().split('T')[0];
        const endDateInput = document.querySelector('input[name="endDate"]');
        if (endDateInput && !endDateInput.max) {
            endDateInput.max = today;
        }
    });
}
