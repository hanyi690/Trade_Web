<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head>
    <title><c:choose><c:when test="${not empty category.id}">编辑分类</c:when><c:otherwise>新建分类</c:otherwise></c:choose> - E-Shop</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/site.css">
</head>
<body class="category-form-page">
    <!-- 顶部导航栏 -->
   <jsp:include page="../common/header.jsp" />
    
    <div class="container">
        <h1 class="page-title">
            <c:choose><c:when test="${not empty category.id}">编辑分类</c:when><c:otherwise>新建分类</c:otherwise></c:choose>
        </h1>
        
        <div class="form-container">
            <form action="${pageContext.request.contextPath}/categories/save" method="post">
                <input type="hidden" name="id" value="${category.id}" />
                
                <div class="form-group">
                    <label for="name">分类名称</label>
                    <input type="text" id="name" name="name" value="${category.name}" 
                           class="form-input" placeholder="请输入分类名称" required />
                </div>
                
                <div class="form-actions">
                    <a href="${pageContext.request.contextPath}/categories" class="btn btn-secondary">
                        取消
                    </a>
                    <button type="submit" class="btn btn-primary">
                        保存
                    </button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- 页脚 -->
    <jsp:include page="../common/footer.jsp" />
    <script src="${pageContext.request.contextPath}/resources/js/site.js"></script>
</body>
</html>