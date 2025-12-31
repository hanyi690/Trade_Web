<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<html>
<head>
    <title>用户登录 - E-Shop</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/site.css">
    <!-- 新增：登录页面模块CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modules/login.css">
</head>
<body>
    <!-- 顶部导航栏 -->
    <jsp:include page="/WEB-INF/views/common/header.jsp" />
    
    <div class="container">
        <h1 class="page-title">用户登录</h1>
        
        <div class="login-container">
            <c:if test="${not empty error}">
                <div class="error-message">${error}</div>
            </c:if>
            
            <form action="${pageContext.request.contextPath}/user/auth" method="post">
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
                
                <button type="submit" class="btn btn-primary" style="width: 100%;">登录</button>
            </form>
            
            <div class="login-links">
                <a href="${pageContext.request.contextPath}/user/register">还没有账号？立即注册</a>
                <a href="${pageContext.request.contextPath}/">返回首页</a>
            </div>
        </div>
    </div>
    
    <!-- 页脚 -->
    <jsp:include page="/WEB-INF/views/common/footer.jsp" />
    <script src="${pageContext.request.contextPath}/resources/js/site.js"></script>
</body>
</html>
