<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>出错了</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/site.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pages/error.css">
</head>
<body>
    <div class="container">
        <h1 style="color: #dc3545;">⚠️ 抱歉，发生错误</h1>
        
        <div class="error-info">
            <h3>错误详情：</h3>
            
            <!-- 显示具体的错误信息 -->
            <c:if test="${not empty error}">
                <div class="error-item">
                    <span class="error-label">错误类型：</span> ${error}
                </div>
            </c:if>
            
            <c:if test="${not empty message}">
                <div class="error-item">
                    <span class="error-label">错误消息：</span> ${message}
                </div>
            </c:if>
            
            <c:if test="${not empty exception}">
                <div class="error-item">
                    <span class="error-label">异常信息：</span> ${exception.message}
                </div>
            </c:if>
            
            <c:if test="${not empty status}">
                <div class="error-item">
                    <span class="error-label">状态码：</span> ${status}
                </div>
            </c:if>
            
            <c:if test="${not empty path}">
                <div class="error-item">
                    <span class="error-label">请求路径：</span> ${path}
                </div>
            </c:if>
            
            <c:if test="${not empty timestamp}">
                <div class="error-item">
                    <span class="error-label">发生时间：</span> ${timestamp}
                </div>
            </c:if>
            
            <!-- 如果没有具体的错误信息，显示通用提示 -->
            <c:if test="${empty error and empty message and empty exception}">
                <div class="error-item">
                    <span class="error-label">可能原因：</span> 
                    请求无法处理，可能的原因：资源不存在、权限不足或服务器内部错误。
                </div>
            </c:if>
        </div>
        
        <div style="margin-top: 30px;">
            <p>请尝试以下操作：</p>
            <ol>
                <li>检查您的请求是否正确</li>
                <li>确认您有足够的权限访问该资源</li>
                <li>稍后重试</li>
                <li>联系系统管理员</li>
            </ol>
        </div>
        
        <div class="action-buttons" style="margin-top: 30px;">
            <a href="${pageContext.request.contextPath}/" class="btn btn-secondary" style="margin-right: 15px;">🏠 返回首页</a>
            <a href="javascript:history.back()" class="btn btn-secondary" style="margin-right: 15px;">↩️ 返回上一页</a>
            <a href="javascript:location.reload()" class="btn btn-primary">🔄 刷新页面</a>
        </div>
        
        <!-- 开发/调试模式下的额外信息 -->
        <c:if test="${not empty exception}">
            <div style="margin-top: 20px; font-size: 12px; color: #6c757d;">
                <details>
                    <summary>查看详细堆栈信息（开发调试）</summary>
                    <pre style="background-color: #f8f9fa; padding: 10px; border: 1px solid #dee2e6; 
                               max-height: 300px; overflow: auto; font-size: 11px;">
<c:forEach items="${exception.stackTrace}" var="stackTraceElement">
${stackTraceElement}
</c:forEach>
                    </pre>
                </details>
            </div>
        </c:if>
    </div>
</body>
</html>
