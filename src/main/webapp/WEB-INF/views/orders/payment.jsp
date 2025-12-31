<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>支付订单 - 电商平台</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/resources/css/site.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="../common/header.jsp" />

    <div class="container py-4">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="card">
                    <div class="card-header bg-white">
                        <h4 class="mb-0">支付订单 #${order.id}</h4>
                    </div>
                    
                    <div class="card-body">
                        <c:if test="${not empty success}">
                            <div class="alert alert-success">${success}</div>
                        </c:if>
                        <c:if test="${not empty error}">
                            <div class="alert alert-danger">${error}</div>
                        </c:if>
                        
                        <!-- 订单摘要 -->
                        <div class="mb-4">
                            <h5 class="mb-3">订单信息</h5>
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label">订单号</label>
                                    <div class="form-control-plaintext">${order.id}</div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">下单时间</label>
                                    <div class="form-control-plaintext">${order.createTime}</div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">收货人</label>
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
                            </div>
                        </div>
                        
                        <!-- 商品清单 -->
                        <div class="mb-4">
                            <h5 class="mb-3">商品清单</h5>
                            <c:forEach var="item" items="${order.orderItems}">
                                <div class="d-flex align-items-center py-2 border-bottom">
                                    <div class="flex-grow-1">
                                        ${item.product.name} × ${item.quantity}
                                    </div>
                                    <div class="text-end">
                                        ¥<fmt:formatNumber value="${item.price * item.quantity}" pattern="#,##0.00"/>
                                    </div>
                                </div>
                            </c:forEach>
                            <div class="d-flex justify-content-between align-items-center mt-3 pt-3 border-top">
                                <h5>订单总额：</h5>
                                <h4 class="text-danger">
                                    ¥<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00"/>
                                </h4>
                            </div>
                        </div>
                        
                        <!-- 支付方式 -->
                        <div class="mb-4">
                            <h5 class="mb-3">选择支付方式</h5>
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <div class="form-check card p-3">
                                        <input class="form-check-input" type="radio" name="paymentMethod" 
                                               id="simulation" value="simulation" checked>
                                        <label class="form-check-label" for="simulation">
                                            <h6 class="mb-1">模拟支付</h6>
                                            <small class="text-muted">课程作业演示</small>
                                        </label>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-check card p-3">
                                        <input class="form-check-input" type="radio" name="paymentMethod" 
                                               id="alipay" value="支付宝">
                                        <label class="form-check-label" for="alipay">
                                            <h6 class="mb-1">支付宝</h6>
                                            <small class="text-muted">推荐使用</small>
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- 支付表单 -->
                        <form action="${pageContext.request.contextPath}/orders/${order.id}/pay" method="post">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                            <input type="hidden" id="selectedPaymentMethod" name="paymentMethod" value="simulation">
                            
                            <div class="form-check mb-4">
                                <input class="form-check-input" type="checkbox" id="agreeTerms" required>
                                <label class="form-check-label" for="agreeTerms">
                                    我同意《用户支付协议》和《退款政策》
                                </label>
                            </div>
                            
                            <div class="d-flex justify-content-between">
                                <a href="${pageContext.request.contextPath}/orders/${order.id}" class="btn btn-outline-secondary">
                                    <i class="fas fa-arrow-left"></i> 返回
                                </a>
                                <button type="submit" class="btn btn-success btn-lg">
                                    <i class="fas fa-credit-card"></i> 确认支付
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
                
                <!-- 支付说明 -->
                <div class="alert alert-info mt-4">
                    <h6><i class="fas fa-info-circle"></i> 支付说明</h6>
                    <ul class="mb-0">
                        <li>本演示为课程作业，使用模拟支付流程</li>
                        <li>支付成功后，订单状态将更新为"已支付"</li>
                        <li>发货时您将收到发货通知邮件</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="../common/footer.jsp" />

    <script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
    <script>
        // 更新支付方式
        document.querySelectorAll('input[name="paymentMethod"]').forEach(input => {
            input.addEventListener('change', function() {
                document.getElementById('selectedPaymentMethod').value = this.value;
            });
        });
        
        // 表单提交处理
        document.querySelector('form').addEventListener('submit', function(e) {
            const submitBtn = this.querySelector('button[type="submit"]');
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 支付处理中...';
            }
        });
    </script>
</body>
</html>
