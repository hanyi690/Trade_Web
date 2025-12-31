<!-- filepath: f:\project\Trade_Web\src\main\webapp\WEB-INF\views\orders\orderForm.jsp -->
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>
        <c:choose>
            <c:when test="${mode == 'create'}">创建订单</c:when>
            <c:when test="${mode == 'edit'}">编辑订单</c:when>
            <c:otherwise>订单详情</c:otherwise>
        </c:choose>
        - 电商平台
    </title>
    <link href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/resources/css/site.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modules/orders.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modules/order-form.css">
</head>
<body>
    <jsp:include page="../common/header.jsp" />

    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-lg-10">
                <div class="card">
                    <div class="card-header bg-white">
                        <div class="d-flex justify-content-between align-items-center">
                            <h4 class="mb-0">
                                <c:choose>
                                    <c:when test="${mode == 'create'}">创建订单</c:when>
                                    <c:when test="${mode == 'edit'}">编辑订单 #${order.id}</c:when>
                                    <c:otherwise>订单详情 #${order.id}</c:otherwise>
                                </c:choose>
                            </h4>
                            <a href="${pageContext.request.contextPath}/orders" class="btn btn-outline-secondary btn-sm">
                                <i class="fas fa-arrow-left"></i> 返回
                            </a>
                        </div>
                    </div>
                    
                    <div class="card-body">
                        <c:if test="${not empty successMessage}">
                            <div class="alert alert-success">${successMessage}</div>
                        </c:if>
                        <c:if test="${not empty errorMessage}">
                            <div class="alert alert-danger">${errorMessage}</div>
                        </c:if>
                        
                        <!-- 订单状态栏 -->
                        <c:if test="${mode != 'create'}">
                            <div class="d-flex justify-content-between align-items-center mb-4 p-3 bg-light rounded">
                                <div>
                                    <span class="me-3">订单状态:</span>
                                    <span class="badge status-${fn:toLowerCase(order.status)}">
                                        <c:choose>
                                            <c:when test="${order.status == 'PENDING'}">
                                                <c:choose>
                                                    <c:when test="${order.paidTime != null}">已支付，等待发货</c:when>
                                                    <c:otherwise>待支付</c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:when test="${order.status == 'COMPLETED'}">已完成</c:when>
                                            <c:when test="${order.status == 'CANCELLED'}">已取消</c:when>
                                        </c:choose>
                                    </span>
                                </div>
                                <div>
                                    <small class="text-muted">下单时间: ${order.createTime}</small>
                                </div>
                            </div>
                        </c:if>
                        
                        <!-- 商品清单 -->
                        <div class="mb-4">
                            <h5 class="mb-3">商品清单</h5>
                            <c:choose>
                                <c:when test="${mode == 'create'}">
                                    <c:forEach var="item" items="${cartItems}">
                                        <div class="d-flex align-items-center py-3 border-bottom">
                                            <div class="flex-shrink-0 me-3">
                                                <c:if test="${not empty item.product.imageUrl}">
                                                    <img src="${item.product.imageUrl}" alt="${item.product.name}" 
                                                         style="width: 80px; height: 80px; object-fit: cover;" class="rounded">
                                                </c:if>
                                            </div>
                                            <div class="flex-grow-1">
                                                <h6 class="mb-1">${item.product.name}</h6>
                                                <small class="text-muted d-block">店铺: ${item.product.merchant.shop.name}</small>
                                            </div>
                                            <div class="text-end">
                                                <div class="mb-1">×${item.quantity}</div>
                                                <div class="text-primary fw-bold">
                                                    ¥<fmt:formatNumber value="${item.product.price * item.quantity}" pattern="#,##0.00"/>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                    <div class="d-flex justify-content-between align-items-center mt-3 pt-3 border-top">
                                        <h5>订单总额：</h5>
                                        <h4 class="text-danger">
                                            ¥<fmt:formatNumber value="${totalAmount}" pattern="#,##0.00"/>
                                        </h4>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="item" items="${order.orderItems}">
                                        <div class="d-flex align-items-center py-3 border-bottom">
                                            <div class="flex-shrink-0 me-3">
                                                <c:if test="${not empty item.product.imageUrl}">
                                                    <img src="${item.product.imageUrl}" alt="${item.product.name}" 
                                                         style="width: 80px; height: 80px; object-fit: cover;" class="rounded">
                                                </c:if>
                                            </div>
                                            <div class="flex-grow-1">
                                                <h6 class="mb-1">${item.product.name}</h6>
                                                <small class="text-muted d-block">店铺: ${item.product.merchant.shop.name}</small>
                                                <small class="badge bg-${item.status == 'PENDING' ? 'warning' : item.status == 'SHIPPED' ? 'info' : 'success'}">
                                                    <c:choose>
                                                        <c:when test="${item.status == 'PENDING'}">待发货</c:when>
                                                        <c:when test="${item.status == 'SHIPPED'}">已发货</c:when>
                                                        <c:when test="${item.status == 'DELIVERED'}">已送达</c:when>
                                                    </c:choose>
                                                </small>
                                            </div>
                                            <div class="text-end">
                                                <div class="mb-1">×${item.quantity}</div>
                                                <div class="text-primary fw-bold">
                                                    ¥<fmt:formatNumber value="${item.price * item.quantity}" pattern="#,##0.00"/>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                    <div class="d-flex justify-content-between align-items-center mt-3 pt-3 border-top">
                                        <h5>订单总额：</h5>
                                        <h4 class="text-danger">
                                            ¥<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00"/>
                                        </h4>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        
                        <!-- 收货信息 -->
                        <div class="mb-4">
                            <h5 class="mb-3">收货信息</h5>
                            <c:choose>
                                <c:when test="${mode == 'create'}">
                                    <form action="${pageContext.request.contextPath}/orders/create" method="post">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <label class="form-label">收货人姓名 *</label>
                                                <input type="text" class="form-control" name="receiverName" 
                                                       required value="${currentUser.username}">
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label">联系电话 *</label>
                                                <input type="tel" class="form-control" name="receiverPhone" 
                                                       required value="${currentUser.phone}">
                                            </div>
                                            <div class="col-12">
                                                <label class="form-label">收货地址 *</label>
                                                <textarea class="form-control" name="shippingAddress" 
                                                          rows="3" required placeholder="请填写详细地址"></textarea>
                                            </div>
                                            <div class="col-12">
                                                <label class="form-label">支付方式 *</label>
                                                <div class="d-flex flex-wrap gap-3">
                                                    <div class="form-check">
                                                        <input class="form-check-input" type="radio" 
                                                               name="paymentMethod" value="支付宝" id="alipay" checked>
                                                        <label class="form-check-label" for="alipay">
                                                            支付宝
                                                        </label>
                                                    </div>
                                                    <div class="form-check">
                                                        <input class="form-check-input" type="radio" 
                                                               name="paymentMethod" value="微信支付" id="wechat">
                                                        <label class="form-check-label" for="wechat">
                                                            微信支付
                                                        </label>
                                                    </div>
                                                    <div class="form-check">
                                                        <input class="form-check-input" type="radio" 
                                                               name="paymentMethod" value="银行卡" id="bank">
                                                        <label class="form-check-label" for="bank">
                                                            银行卡
                                                        </label>
                                                    </div>
                                                    <div class="form-check">
                                                        <input class="form-check-input" type="radio" 
                                                               name="paymentMethod" value="货到付款" id="cod">
                                                        <label class="form-check-label" for="cod">
                                                            货到付款
                                                        </label>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="d-flex justify-content-between mt-4">
                                            <a href="${pageContext.request.contextPath}/cart" class="btn btn-outline-secondary">
                                                <i class="fas fa-arrow-left"></i> 返回购物车
                                            </a>
                                            <button type="submit" class="btn btn-primary">
                                                <i class="fas fa-check-circle"></i> 提交订单
                                            </button>
                                        </div>
                                    </form>
                                </c:when>
                                
                                <c:when test="${mode == 'edit'}">
                                    <form action="${pageContext.request.contextPath}/orders/${order.id}/edit" method="post">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <label class="form-label">收货人姓名 *</label>
                                                <input type="text" class="form-control" name="receiverName" 
                                                       required value="${order.receiverName}">
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label">联系电话 *</label>
                                                <input type="tel" class="form-control" name="receiverPhone" 
                                                       required value="${order.receiverPhone}">
                                            </div>
                                            <div class="col-12">
                                                <label class="form-label">收货地址 *</label>
                                                <textarea class="form-control" name="shippingAddress" 
                                                          rows="3" required>${order.shippingAddress}</textarea>
                                            </div>
                                            <div class="col-12">
                                                <label class="form-label">支付方式 *</label>
                                                <div class="d-flex flex-wrap gap-3">
                                                    <div class="form-check">
                                                        <input class="form-check-input" type="radio" 
                                                               name="paymentMethod" value="支付宝" id="editAlipay"
                                                               <c:if test="${order.paymentMethod == '支付宝'}">checked</c:if>>
                                                        <label class="form-check-label" for="editAlipay">
                                                            支付宝
                                                        </label>
                                                    </div>
                                                    <div class="form-check">
                                                        <input class="form-check-input" type="radio" 
                                                               name="paymentMethod" value="微信支付" id="editWechat"
                                                               <c:if test="${order.paymentMethod == '微信支付'}">checked</c:if>>
                                                        <label class="form-check-label" for="editWechat">
                                                            微信支付
                                                        </label>
                                                    </div>
                                                    <div class="form-check">
                                                        <input class="form-check-input" type="radio" 
                                                               name="paymentMethod" value="银行卡" id="editBank"
                                                               <c:if test="${order.paymentMethod == '银行卡'}">checked</c:if>>
                                                        <label class="form-check-label" for="editBank">
                                                            银行卡
                                                        </label>
                                                    </div>
                                                    <div class="form-check">
                                                        <input class="form-check-input" type="radio" 
                                                               name="paymentMethod" value="货到付款" id="editCod"
                                                               <c:if test="${order.paymentMethod == '货到付款'}">checked</c:if>>
                                                        <label class="form-check-label" for="editCod">
                                                            货到付款
                                                        </label>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="d-flex justify-content-end gap-2 mt-4">
                                            <a href="${pageContext.request.contextPath}/orders/${order.id}" class="btn btn-outline-secondary">
                                                取消
                                            </a>
                                            <button type="submit" class="btn btn-primary">
                                                保存更改
                                            </button>
                                        </div>
                                    </form>
                                </c:when>
                                
                                <c:otherwise>
                                    <div class="row g-3">
                                        <div class="col-md-6">
                                            <label class="form-label">收货人姓名</label>
                                            <div class="form-control-plaintext">${order.receiverName}</div>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">联系电话</label>
                                            <div class="form-control-plaintext">${order.receiverPhone}</div>
                                        </div>
                                        <div class="col-12">
                                            <label class="form-label">收货地址</label>
                                            <div class="form-control-plaintext">${order.shippingAddress}</div>
                                        </div>
                                        <div class="col-12">
                                            <label class="form-label">支付方式</label>
                                            <div class="form-control-plaintext">${order.paymentMethod}</div>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        
                        <!-- 操作按钮 -->
                        <c:if test="${mode == 'view'}">
                            <div class="d-flex justify-content-between align-items-center pt-4 border-top">
                                <div>
                                    <c:if test="${order.status == 'PENDING' and order.paidTime == null and currentUser.id == order.user.id}">
                                        <a href="${pageContext.request.contextPath}/orders/${order.id}/pay" class="btn btn-success me-2">
                                            <i class="fas fa-credit-card"></i> 去支付
                                        </a>
                                        <form action="${pageContext.request.contextPath}/orders/${order.id}/cancel" method="post" 
                                              onsubmit="return confirm('确定要取消此订单吗？');" class="d-inline">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                            <button type="submit" class="btn btn-danger">
                                                <i class="fas fa-times"></i> 取消订单
                                            </form>
                                    </c:if>
                                    <c:if test="${order.status == 'PENDING' and order.paidTime != null and currentUser.role == 'MERCHANT'}">
                                        <!-- 商家发货操作 - 针对订单项 -->
                                        <c:forEach var="item" items="${order.orderItems}">
                                            <c:if test="${item.status == 'PENDING'and item.product.merchant.id == currentUser.id}">
                                                <form action="${pageContext.request.contextPath}/orders/${order.id}/items/${item.id}/ship" 
                                                      method="post" class="d-inline me-2"
                                                      onsubmit="return confirm('确定要发货此商品吗？');">
                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                                    <button type="submit" class="btn btn-primary">
                                                        <i class="fas fa-truck"></i> 发货 ${item.product.name}
                                                    </button>
                                                </form>
                                            </c:if>
                                        </c:forEach>
                                    </c:if>
                                    <c:if test="${order.status == 'PENDING' and order.paidTime != null and currentUser.id == order.user.id}">
                                        <!-- 用户确认收货操作 - 针对订单项 -->
                                        <c:forEach var="item" items="${order.orderItems}">
                                            <c:if test="${item.status == 'SHIPPED'}">
                                                <form action="${pageContext.request.contextPath}/orders/${order.id}/items/${item.id}/deliver" 
                                                      method="post" class="d-inline me-2"
                                                      onsubmit="return confirm('确认已收到此商品？');">
                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                                    <button type="submit" class="btn btn-success">
                                                        <i class="fas fa-check"></i> 确认收货 ${item.product.name}
                                                    </button>
                                                </form>
                                            </c:if>
                                        </c:forEach>
                                    </c:if>
                                </div>
                                <div>
                                    <c:if test="${order.status == 'PENDING' and currentUser.id == order.user.id}">
                                        <a href="${pageContext.request.contextPath}/orders/${order.id}/edit" class="btn btn-outline-primary">
                                            <i class="fas fa-edit"></i> 编辑订单
                                        </a>
                                    </c:if>
                                </div>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="../common/footer.jsp" />

    <script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
    <script>
        // 表单验证
        document.addEventListener('DOMContentLoaded', function() {
            const forms = document.querySelectorAll('form');
            forms.forEach(form => {
                form.addEventListener('submit', function(e) {
                    const submitBtn = this.querySelector('button[type="submit"]');
                    if (submitBtn) {
                        submitBtn.disabled = true;
                        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 处理中...';
                    }
                });
            });
        });
    </script>
</body>
</html>