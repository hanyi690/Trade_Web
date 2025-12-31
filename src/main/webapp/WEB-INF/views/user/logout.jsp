<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head>
    <title>退出登录 - E-Shop</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/site.css">
</head>
<body>
    <!-- 顶部导航栏 -->
    <jsp:include page="../common/header.jsp" />

    <div class="container">
        <h1 class="page-title">退出登录</h1>
        
        <div class="logout-container">
            <div class="logout-message">
                您已成功退出登录
            </div>
            
            <div class="logout-actions">
                <a href="${pageContext.request.contextPath}/" class="btn btn-primary">返回首页</a>
                <a href="${pageContext.request.contextPath}/user/login" class="btn btn-secondary">重新登录</a>
            </div>
        </div>
    </div>
    
    <!-- 页脚 -->
    <jsp:include page="../common/footer.jsp" />
    <script src="${pageContext.request.contextPath}/resources/js/site.js"></script>
</body>
</html>
