<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<html>
<head>
    <title>分类管理 - E-Shop</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/site.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pages/categories.css">
</head>
<body>
    <!-- 顶部导航栏 -->
    <jsp:include page="../common/header.jsp" />
    
    <div class="container">
        <h1 class="page-title">分类</h1>
        
        <c:if test="${not empty success}">
            <div style="color:green; text-align:center; margin-bottom:20px;">✅ ${success}</div>
        </c:if>
        <c:if test="${not empty error}">
            <div style="color:red; text-align:center; margin-bottom:20px;">❌ ${error}</div>
        </c:if>

        <div style="text-align:center; margin-bottom:30px;">
            <sec:authorize access="hasRole('ADMIN')">
                <a href="${pageContext.request.contextPath}/categories/new" class="btn btn-primary">➕ 新建分类</a>
            </sec:authorize>
            <sec:authorize access="!hasRole('ADMIN')">
                <p class="text-muted">普通用户无法修改分类信息</p>
            </sec:authorize>
        </div>

        <c:choose>
            <c:when test="${not empty categories && categories.size() > 0}">
                <div class="data-table">
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>分类名称</th>
                                <th>操作</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="c" items="${categories}" varStatus="status">
                                <tr>
                                    <!-- 使用从1开始的计数，而不是数据库ID -->
                                    <td><strong>#${status.index + 1}</strong></td>
                                    <td>
                                        <div style="display: flex; align-items: center; gap: 10px;">
                                            <span style="width: 12px; height: 12px; background: #667eea; border-radius: 50%;"></span>
                                            ${c.name}
                                        </div>
                                    </td>
                                    <td>
                                        <div class="table-actions">
                                            <a href="${pageContext.request.contextPath}/categories/${c.id}/products" 
                                               class="btn btn-warning">🛍️ 查看商品</a>

                                            <!-- 仅 ADMIN 可见编辑与删除 -->
                                            <sec:authorize access="hasRole('ADMIN')">
                                                <a href="${pageContext.request.contextPath}/categories/edit/${c.id}" 
                                                   class="btn btn-warning">✏️ 编辑</a>
                                                <form action="${pageContext.request.contextPath}/categories/delete/${c.id}" 
                                                      method="post" 
                                                      style="display:inline;"
                                                      onsubmit="return confirm('确定要删除分类【${fn:escapeXml(c.name)}】吗？此操作不可逆！')">
                                                    <!-- CSRF 隐藏字段（当启用 Spring Security 时需要） -->
                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                                    <button type="submit" class="btn btn-danger">🗑️ 删除</button>
                                                </form>
                                            </sec:authorize>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <h3>暂无分类数据</h3>
                    <p>还没有创建任何商品分类，点击"新建分类"开始添加</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    
    <!-- 页脚 -->
    <jsp:include page="../common/footer.jsp" />
    <script src="${pageContext.request.contextPath}/resources/js/site.js"></script>
</body>
</html>