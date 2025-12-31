<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<html>
<head>
    <title>个人中心 - E-Shop</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- 使用统一样式 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/site.css">
    <!-- 新增：个人中心模块CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modules/profile.css">
</head>
<body>
    <!-- 顶部导航栏 -->
    <jsp:include page="../common/header.jsp" />
    
    <div class="container">
        <h1 class="page-title">个人中心</h1>
        
        <div class="profile-container">
            <div class="user-info">
                <div class="info-item">
                    <div class="info-label">用户名：</div>
                    <div class="info-value">${user.username}</div>
                </div>
                <div class="info-item">
                    <div class="info-label">邮箱：</div>
                    <div class="info-value">${user.email}</div>
                </div>
                <!-- 新增：手机号信息 -->
                <div class="info-item">
                    <div class="info-label">手机号：</div>
                    <div class="info-value">
                        <c:choose>
                            <c:when test="${not empty user.phone}">
                                ${user.phone}
                            </c:when>
                            <c:otherwise>
                                <span style="color: #999;">未设置</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <!-- 新增：用户角色信息 -->
                <div class="info-item">
                    <div class="info-label">角色：</div>
                    <div class="info-value">
                        <c:choose>
                            <c:when test="${user.role == 'ADMIN'}">管理员</c:when>
                            <c:when test="${user.role == 'MERCHANT'}">商家</c:when>
                            <c:when test="${user.role == 'CONSUMER'}">消费者</c:when>
                        </c:choose>
                    </div>
                </div>
                <!-- 新增：店铺信息（仅对商家显示） -->
                <c:if test="${user.role == 'MERCHANT'}">
                    <div class="info-item">
                        <div class="info-label">店铺状态：</div>
                        <div class="info-value">
                            <c:choose>
                                <c:when test="${not empty shop}">
                                    <span style="color: green;">已创建</span>
                                    （<a href="${pageContext.request.contextPath}/shops/${shop.id}">查看店铺</a>）
                                </c:when>
                                <c:otherwise>
                                    <span style="color: #999;">未创建</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:if>
            </div>
            
            <div class="profile-actions">
                <!-- 新增：编辑个人信息按钮 -->
                <button type="button" class="btn btn-primary" onclick="openEditProfileModal()">
                    <i class="fas fa-edit"></i> 编辑个人信息
                </button>
                
                <a href="${pageContext.request.contextPath}/orders" class="btn btn-secondary">我的订单</a>
                <a href="${pageContext.request.contextPath}/user/logout" 
                   class="btn btn-primary" 
                   onclick="return confirm('确定要退出登录吗？')">退出登录</a>
                
                <!-- 新增：普通用户申请成为商家按钮 -->
                <c:if test="${canApplyMerchant}">
                    <a href="${pageContext.request.contextPath}/shops/create" class="btn btn-warning">申请成为商家</a>
                </c:if>
                
                <!-- 商家店铺管理按钮 -->
                <c:if test="${user.role == 'MERCHANT'}">
                    <c:choose>
                        <c:when test="${not empty shop}">
                            <a href="${pageContext.request.contextPath}/shops/${shop.id}/manage" class="btn btn-info">管理店铺</a>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/shops/create" class="btn btn-info">创建店铺</a>
                        </c:otherwise>
                    </c:choose>
                </c:if>
                
                <!-- 注销账户按钮 -->
                <form action="${pageContext.request.contextPath}/user/unregister" method="post" style="display: inline;">
                    <button type="submit" class="btn btn-danger" onclick="return confirm('警告：注销账户将永久删除您的所有数据，包括订单、店铺等。此操作不可恢复。确定要继续吗？')">注销账户</button>
                </form>
            </div>
        </div>
    </div>
    
    <!-- 页脚 -->
    <jsp:include page="../common/footer.jsp" />
    <script src="${pageContext.request.contextPath}/resources/js/site.js"></script>
    <!-- 新增：个人中心编辑功能JS -->
    <script src="${pageContext.request.contextPath}/resources/js/modules/profile-edit.js"></script>
    
    <!-- 新增：编辑个人信息模态框 -->
    <div class="edit-profile-modal" id="editProfileModal">
        <div class="edit-profile-modal-content">
            <div class="modal-header">
                <h3><i class="fas fa-user-edit"></i> 编辑个人信息</h3>
                <button type="button" class="modal-close" onclick="closeEditProfileModal()">&times;</button>
            </div>
            <div class="modal-body">
                <form id="editProfileForm" method="post" action="${pageContext.request.contextPath}/user/update">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    
                    <div class="form-group">
                        <label for="editUsername">用户名</label>
                        <input type="text" id="editUsername" class="form-control" value="${user.username}" readonly disabled>
                        <small class="form-text">用户名不可修改</small>
                    </div>
                    
                    <div class="form-group">
                        <label for="editEmail">邮箱 <span class="required">*</span></label>
                        <input type="email" id="editEmail" name="email" class="form-control" value="${user.email}" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="editPhone">手机号</label>
                        <input type="tel" id="editPhone" name="phone" class="form-control" value="${user.phone}" 
                               pattern="^1[3-9]\d{9}$" title="请输入11位有效手机号">
                        <small class="form-text">11位手机号码，用于订单联系电话（可选）</small>
                    </div>
                    
                    <div class="form-actions">
                        <button type="button" class="btn btn-secondary" onclick="closeEditProfileModal()">取消</button>
                        <button type="submit" class="btn btn-primary">保存更改</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</body>
</html>