<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<html>
<head>
    <title>
        <c:choose>
            <c:when test="${not empty shop.id}">编辑店铺 - E-Shop</c:when>
            <c:otherwise>创建店铺 - E-Shop</c:otherwise>
        </c:choose>
    </title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/site.css">
    <!-- 新增：店铺表单模块CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modules/shop-form.css">
</head>
<body>
    <!-- 统一顶部导航栏 -->
    <jsp:include page="../common/header.jsp" />
    
    <div class="container">
        <div class="form-container">
            <h1 class="form-title">
                <c:choose>
                    <c:when test="${not empty shop.id}">
                        <i class="fas fa-edit"></i> 编辑店铺信息
                    </c:when>
                    <c:otherwise>
                        <i class="fas fa-plus-circle"></i> 创建新店铺
                    </c:otherwise>
                </c:choose>
            </h1>
            
            <!-- 消息提示 -->
            <c:if test="${not empty success}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> ${success}
                </div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i> ${error}
                </div>
            </c:if>
            
            <!-- 表单 -->
            <form action="${pageContext.request.contextPath}/shops/${not empty shop.id ? 'update/' : 'create'}${not empty shop.id ? shop.id : ''}" 
                  method="post">
                
                <div class="form-group">
                    <label class="form-label" for="name">店铺名称 *</label>
                    <input type="text" id="name" name="name" class="form-control" 
                           value="${shop.name}" required maxlength="200" 
                           placeholder="请输入店铺名称">
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="description">店铺描述</label>
                    <textarea id="description" name="description" class="form-control" 
                              maxlength="1000" placeholder="简要介绍您的店铺特色和经营范围">${shop.description}</textarea>
                    <span class="form-hint">最多1000个字符</span>
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="contactPhone">联系电话 *</label>
                    <input type="tel" id="contactPhone" name="contactPhone" class="form-control" 
                           value="${shop.contactPhone}" required maxlength="50" 
                           placeholder="请输入联系电话">
                    <span class="form-hint">用于客户联系您的电话</span>
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="contactEmail">联系邮箱</label>
                    <input type="email" id="contactEmail" name="contactEmail" class="form-control" 
                           value="${shop.contactEmail}" maxlength="200" 
                           placeholder="请输入联系邮箱">
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="address">店铺地址</label>
                    <input type="text" id="address" name="address" class="form-control" 
                           value="${shop.address}" maxlength="500" 
                           placeholder="请输入店铺地址">
                    <span class="form-hint">您的实体店或办公地址</span>
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="logoUrl">店铺Logo URL</label>
                    <input type="url" id="logoUrl" name="logoUrl" class="form-control" 
                           value="${shop.logoUrl}" maxlength="500" 
                           placeholder="https://example.com/logo.png">
                    <span class="form-hint">店铺Logo图片的在线地址</span>
                </div>
                
                <div class="form-actions">
                    <c:choose>
                        <c:when test="${not empty shop.id}">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save"></i> 更新店铺
                            </button>
                            <a href="${pageContext.request.contextPath}/shops/${shop.id}" class="btn btn-secondary">
                                <i class="fas fa-times"></i> 取消
                            </a>
                            <button type="button" class="btn btn-danger" onclick="confirmDelete()">
                                <i class="fas fa-trash"></i> 删除店铺
                            </button>
                        </c:when>
                        <c:otherwise>
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-check"></i> 创建店铺
                            </button>
                            <a href="${pageContext.request.contextPath}/shops" class="btn btn-secondary">
                                <i class="fas fa-times"></i> 取消
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </form>
        </div>
    </div>
    
    <!-- 统一页脚 -->
    <jsp:include page="../common/footer.jsp" />
    <script src="${pageContext.request.contextPath}/resources/js/site.js"></script>
    <!-- 新增：删除确认模态框 -->
    <div class="delete-confirmation" id="deleteConfirmation">
        <div class="delete-modal">
            <h3><i class="fas fa-exclamation-triangle" style="color: #e74c3c;"></i> 确认删除</h3>
            <p>警告：删除店铺将永久删除店铺的所有信息，包括商品和订单数据。此操作不可恢复。确定要继续吗？</p>
            <div class="delete-modal-actions">
                <form action="${pageContext.request.contextPath}/shops/delete/${shop.id}" method="post" style="display: inline;">
                    <button type="submit" class="btn btn-danger">确认删除</button>
                </form>
                <button type="button" class="btn btn-secondary" onclick="cancelDelete()">取消</button>
            </div>
        </div>
    </div>
    
    <script>
        // 表单验证
        document.querySelector('form').addEventListener('submit', function(event) {
            const name = document.getElementById('name').value.trim();
            const phone = document.getElementById('contactPhone').value.trim();
            
            if (!name) {
                alert('请输入店铺名称');
                event.preventDefault();
                return false;
            }
            
            if (!phone) {
                alert('请输入联系电话');
                event.preventDefault();
                return false;
            }
            
            // 简单的电话格式验证
            const phoneRegex = /^[\d\s\-+()]{6,}$/;
            if (!phoneRegex.test(phone)) {
                alert('请输入有效的联系电话（至少6位数字）');
                event.preventDefault();
                return false;
            }
            
            return true;
        });
        
        // 删除确认功能
        function confirmDelete() {
            const confirmation = document.getElementById('deleteConfirmation');
            confirmation.classList.add('active');
        }
        
        function cancelDelete() {
            const confirmation = document.getElementById('deleteConfirmation');
            confirmation.classList.remove('active');
        }
        
        // 点击模态框外部关闭
        document.getElementById('deleteConfirmation').addEventListener('click', function(e) {
            if (e.target === this) {
                cancelDelete();
            }
        });
    </script>
</body>
</html>
