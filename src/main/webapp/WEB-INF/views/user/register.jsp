<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<html>
<head>
    <title>用户注册 - E-Shop</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- 公共样式 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/site.css">
    <!-- 新增：注册页面模块CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modules/register.css">
</head>
<body>
    <!-- 顶部导航栏 -->
    <jsp:include page="../common/header.jsp" />
    
    <div class="container">
        <h1 class="page-title">用户注册</h1>
        
        <div class="register-container">
            <c:if test="${not empty error}">
                <div class="error-message">${error}</div>
            </c:if>
            
            <form action="${pageContext.request.contextPath}/user/register" method="post">
                <!-- CSRF 隐藏字段（Spring Security） -->
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

                <div class="form-group">
                    <label for="username" class="form-label">用户名:</label>
                    <input type="text" id="username" name="username" class="form-control" 
                           placeholder="请输入用户名" required />
                </div>
                
                <div class="form-group">
                    <label for="password" class="form-label">密码:</label>
                    <input type="password" id="password" name="password" class="form-control" 
                           placeholder="请输入密码" required />
                </div>

                <div class="form-group">
                    <label for="confirmPassword" class="form-label">确认密码:</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" class="form-control"
                           placeholder="请再次输入密码" required />
                </div>
                
                <div class="form-group">
                    <label for="email" class="form-label">邮箱:</label>
                    <input type="email" id="email" name="email" class="form-control" 
                           placeholder="请输入邮箱地址" required />
                </div>
                
                <!-- 新增：手机号字段 -->
                <div class="form-group">
                    <label for="phone" class="form-label">手机号:</label>
                    <input type="tel" id="phone" name="phone" class="form-control" 
                           placeholder="请输入手机号（可选）" 
                           pattern="^1[3-9]\d{9}$" 
                           title="请输入11位有效手机号" />
                    <small class="text-muted">11位手机号码，可用于快速填写订单联系电话（可选）</small>
                </div>
                
                <div class="terms-agreement">
                    <label>
                        <input type="checkbox" name="agreeTerms" required/>
                        我已阅读并同意
                        <a href="${pageContext.request.contextPath}/terms" target="_blank">服务条款</a>
                        和
                        <a href="${pageContext.request.contextPath}/privacy" target="_blank">隐私政策</a>
                    </label>
                </div>
                
                <button type="submit" class="btn btn-primary" style="width: 100%;">立即注册</button>
            </form>
            
            <div class="register-links">
                <a href="${pageContext.request.contextPath}/user/login">已有账号？立即登录</a>
                <a href="${pageContext.request.contextPath}/">返回首页</a>
            </div>
        </div>
    </div>
    
    <!-- 页脚 -->
    <jsp:include page="../common/footer.jsp" />
    <script src="${pageContext.request.contextPath}/resources/js/site.js"></script>
</body>
</html>