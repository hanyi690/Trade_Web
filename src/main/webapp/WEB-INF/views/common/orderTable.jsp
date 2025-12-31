<!-- filepath: f:\project\Trade_Web\src\main\webapp\WEB-INF\views\common\orderTable.jsp -->
<%@ page contentType="text/html;charset=UTF-8" language="java" session="false" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%-- 组件参数定义 --%>
<c:if test="${empty context}">
    <c:set var="context" value="user" scope="request" />
</c:if>

<!-- 订单日期筛选器 -->
<div class="date-filter mb-4">
    <form class="filter-form d-flex align-items-center gap-3" method="get" action="${pageContext.request.contextPath}/orders">
        <div class="form-group mb-0">
            <label class="form-label">订单日期：</label>
            <input type="date" name="startDate" class="form-control form-control-sm" 
                   value="${startDate}" max="${endDate}">
        </div>
        <span>至</span>
        <div class="form-group mb-0">
            <input type="date" name="endDate" class="form-control form-control-sm" 
                   value="${endDate}" min="${startDate}">
        </div>
        <button type="submit" class="btn btn-sm btn-primary">
            <i class="fas fa-filter"></i> 筛选
        </button>
        <button type="button" class="btn btn-sm btn-secondary" onclick="resetOrdersDateFilter()">
            <i class="fas fa-redo"></i> 重置
        </button>
    </form>
</div>

<!-- 订单列表 -->
<c:if test="${not empty orders}">
    <div class="order-list">
        <div class="order-summary mb-3">
            <span class="order-count">共找到 ${fn:length(orders)} 个订单</span>
            <c:if test="${not empty startDate and not empty endDate}">
                <span class="stat-date-range">${startDate} 至 ${endDate}</span>
            </c:if>
        </div>
        
        <c:forEach var="order" items="${orders}">
            <div class="order-card card mb-3">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-start mb-3">
                        <div>
                            <h5 class="card-title mb-1">订单号: ${order.id}</h5>
                            <small class="text-muted">下单时间: ${order.createTime}</small>
                            <c:if test="${context == 'shop'}">
                                <div class="mt-1">
                                    <small class="text-muted">买家: ${order.user.username}</small>
                                </div>
                            </c:if>
                        </div>
                        <div class="text-end">
                            <span class="badge status-${fn:toLowerCase(order.status)} mb-2">
                                <c:choose>
                                    <c:when test="${order.status == 'PENDING'}">
                                        <c:choose>
                                            <c:when test="${order.paidTime != null}">已支付</c:when>
                                            <c:otherwise>待支付</c:otherwise>
                                        </c:choose>
                                    </c:when>
                                    <c:when test="${order.status == 'COMPLETED'}">已完成</c:when>
                                    <c:when test="${order.status == 'CANCELLED'}">已取消</c:when>
                                </c:choose>
                            </span>
                            <div class="text-muted">
                                <strong>¥<fmt:formatNumber value="${order.totalAmount}" minFractionDigits="2"/></strong>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <p class="mb-1"><strong>收货人:</strong> ${order.receiverName}</p>
                            <p class="mb-1"><strong>电话:</strong> ${order.receiverPhone}</p>
                        </div>
                        <div class="col-md-6">
                            <p class="mb-1"><strong>地址:</strong> ${order.shippingAddress}</p>
                            <p class="mb-1"><strong>支付方式:</strong> ${order.paymentMethod}</p>
                        </div>
                    </div>
                    
                    <!-- 商品列表 -->
                    <div class="order-items">
                        <h6 class="mb-2">商品清单</h6>
                        <c:forEach var="item" items="${order.orderItems}" varStatus="status">
                            <div class="d-flex align-items-center py-2 border-bottom">
                                <div class="flex-shrink-0 me-3">
                                    <c:if test="${not empty item.product.imageUrl}">
                                        <img src="${item.product.imageUrl}" alt="${item.product.name}" 
                                             class="product-thumbnail" style="width: 50px; height: 50px; object-fit: cover;">
                                    </c:if>
                                </div>
                                <div class="flex-grow-1">
                                    <div class="d-flex justify-content-between">
                                        <div>
                                            <strong>${item.product.name}</strong>
                                            <c:if test="${context == 'user'}">
                                                <small class="text-muted d-block">店铺: ${item.product.merchant.shop.name}</small>
                                            </c:if>
                                        </div>
                                        <div class="text-end">
                                            <div>×${item.quantity}</div>
                                            <div class="text-primary">
                                                ¥<fmt:formatNumber value="${item.price * item.quantity}" minFractionDigits="2"/>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                    
                    <!-- 操作按钮 -->
                    <div class="d-flex justify-content-between align-items-center mt-3 pt-3 border-top">
                        <div>
                            <button class="btn btn-sm btn-outline-primary" onclick="viewOrderDetail('${order.id}')">
                                <i class="fas fa-eye"></i> 查看详情
                            </button>
                        </div>
                        <div>
                            <c:choose>
                                <c:when test="${context == 'user'}">
                                    <!-- 用户订单操作 -->
                                    <c:if test="${order.status == 'PENDING' and order.paidTime == null}">
                                        <a href="${pageContext.request.contextPath}/orders/${order.id}/pay" class="btn btn-sm btn-success">
                                            <i class="fas fa-credit-card"></i> 去支付
                                        </a>
                                        <button class="btn btn-sm btn-warning" onclick="cancelOrder('${order.id}')">
                                            <i class="fas fa-times"></i> 取消
                                        </button>
                                    </c:if>
                                    <c:if test="${order.status == 'PENDING' and order.paidTime != null}">
                                        <!-- 已支付的订单显示等待发货 -->
                                        <span class="badge bg-info">等待发货</span>
                                    </c:if>
                                    <c:if test="${order.status == 'COMPLETED'}">
                                        <a href="${pageContext.request.contextPath}/products/${order.orderItems[0].product.id}/review" class="btn btn-sm btn-info">
                                            <i class="fas fa-star"></i> 评价
                                        </a>
                                    </c:if>
                                </c:when>
                                <c:when test="${context == 'shop'}">
                                    <!-- 商家订单操作 -->
                                    <c:if test="${order.status == 'PENDING' and order.paidTime == null}">
                                        <button class="btn btn-sm btn-success" onclick="markAsPaid('${order.id}')">
                                            <i class="fas fa-check"></i> 标记已支付
                                        </button>
                                        <button class="btn btn-sm btn-warning" onclick="cancelOrder('${order.id}')">
                                            <i class="fas fa-times"></i> 取消
                                        </button>
                                    </c:if>
                                    <c:if test="${order.status == 'PENDING' and order.paidTime != null}">
                                        <!-- 商家处理已支付的订单 -->
                                        <a href="${pageContext.request.contextPath}/orders/${order.id}" class="btn btn-sm btn-primary">
                                            <i class="fas fa-truck"></i> 处理发货
                                        </a>
                                    </c:if>
                                    <c:if test="${order.status == 'COMPLETED'}">
                                        <span class="badge bg-success">已完成</span>
                                    </c:if>
                                </c:when>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>
</c:if>

<!-- 空状态显示 -->
<c:if test="${empty orders}">
    <div class="text-center py-5">
        <i class="fas fa-shopping-cart fa-4x text-muted mb-3"></i>
        <h4 class="text-muted mb-3">
            <c:choose>
                <c:when test="${not empty startDate or not empty endDate}">
                    筛选条件下暂无订单
                </c:when>
                <c:otherwise>
                    <c:choose>
                        <c:when test="${context == 'user'}">暂无订单</c:when>
                        <c:when test="${context == 'shop'}">暂无订单</c:when>
                        <c:otherwise>暂无数据</c:otherwise>
                    </c:choose>
                </c:otherwise>
            </c:choose>
        </h4>
        <p class="text-muted mb-4">
            <c:choose>
                <c:when test="${not empty startDate or not empty endDate}">
                    在 ${startDate} 至 ${endDate} 期间没有找到订单
                </c:when>
                <c:otherwise>
                    <c:choose>
                        <c:when test="${context == 'user'}">您还没有任何订单记录，快去选购商品吧！</c:when>
                        <c:when test="${context == 'shop'}">您的店铺还没有收到任何订单</c:when>
                        <c:otherwise>没有相关数据</c:otherwise>
                    </c:choose>
                </c:otherwise>
            </c:choose>
        </p>
        <c:if test="${context == 'user'}">
            <a href="${pageContext.request.contextPath}/products" class="btn btn-primary">
                <i class="fas fa-shopping-bag"></i> 去购物
            </a>
        </c:if>
    </div>
</c:if>

<script>
// 重置订单日期筛选器
function resetOrdersDateFilter() {
    document.querySelector('input[name="startDate"]').value = '';
    document.querySelector('input[name="endDate"]').value = '';
    document.querySelector('.filter-form').submit();
}

// 查看订单详情
function viewOrderDetail(orderId) {
    window.location.href = '${pageContext.request.contextPath}/orders/' + orderId;
}

// 取消订单
function cancelOrder(orderId) {
    if (confirm('确定要取消此订单吗？取消后无法恢复。')) {
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '${pageContext.request.contextPath}/orders/' + orderId + '/cancel';
        
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
}

// 商家标记为已支付
function markAsPaid(orderId) {
    if (confirm('确定标记为已支付吗？')) {
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '${pageContext.request.contextPath}/orders/' + orderId + '/mark-paid';
        
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
}
</script>