<%-- 用户表格组件 --%>
<%-- 参数说明： --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" session="false" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%-- showIdColumn: 是否显示ID列（默认true） --%>
<%-- showStatusColumn: 是否显示状态列（默认true） --%>
<%-- showActions: 是否显示操作列（默认true） --%>
<%-- showAddButton: 是否显示添加按钮（默认false） --%>
<%-- users: 用户列表（必需） --%>

<c:if test="${empty showIdColumn}"><c:set var="showIdColumn" value="true" /></c:if>
<c:if test="${empty showStatusColumn}"><c:set var="showStatusColumn" value="true" /></c:if>
<c:if test="${empty showActions}"><c:set var="showActions" value="true" /></c:if>
<c:if test="${empty showAddButton}"><c:set var="showAddButton" value="false" /></c:if>

<div class="user-management">
    <c:if test="${showAddButton}">
        <div class="user-actions">
            <a href="${pageContext.request.contextPath}/admin/users/create" class="btn btn-success">
                <i class="fas fa-plus"></i> 添加新用户
            </a>
        </div>
    </c:if>
    
    <c:if test="${not empty users}">
        <table class="user-table">
            <thead>
                <tr>
                    <c:if test="${showIdColumn}">
                        <th>ID</th>
                    </c:if>
                    <th>用户名</th>
                    <th>邮箱</th>
                    <th>角色</th>
                    <c:if test="${showStatusColumn}">
                        <th>状态</th>
                    </c:if>
                    <th>注册时间</th>
                    <c:if test="${showActions}">
                        <th>操作</th>
                    </c:if>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="user" items="${users}">
                    <tr>
                        <c:if test="${showIdColumn}">
                            <td>${user.id}</td>
                        </c:if>
                        <td>${user.username}</td>
                        <td>${user.email}</td>
                        <td>
                            <span class="badge badge-primary">${user.role}</span>
                        </td>
                        <c:if test="${showStatusColumn}">
                            <td>
                                <c:choose>
                                    <c:when test="${user.enabled}">
                                        <span class="badge badge-success">激活</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-danger">禁用</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </c:if>
                        <td>
                            <c:if test="${not empty user.createdTime}">
                                <fmt:parseDate value="${user.createdTime}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="parsedDate"/>
                                <fmt:formatDate value="${parsedDate}" pattern="yyyy-MM-dd HH:mm"/>
                            </c:if>
                        </td>
                        <c:if test="${showActions}">
                            <td>
                                <div class="action-buttons">
                                    <a href="${pageContext.request.contextPath}/admin/users/edit/${user.id}" class="btn btn-warning btn-sm">
                                        <i class="fas fa-edit"></i>
                                    </a>
                                    <c:if test="${user.enabled}">
                                        <form action="${pageContext.request.contextPath}/admin/users/disable/${user.id}" method="post" class="d-inline">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                            <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('确定要禁用用户 ${user.username} 吗？')">
                                                <i class="fas fa-ban"></i>
                                            </button>
                                        </form>
                                    </c:if>
                                    <c:if test="${not user.enabled}">
                                        <form action="${pageContext.request.contextPath}/admin/users/enable/${user.id}" method="post" class="d-inline">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                            <button type="submit" class="btn btn-success btn-sm" onclick="return confirm('确定要激活用户 ${user.username} 吗？')">
                                                <i class="fas fa-check"></i>
                                            </button>
                                        </form>
                                    </c:if>
                                </div>
                            </td>
                        </c:if>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </c:if>
    <c:if test="${empty users}">
        <div class="no-data-message">
            <i class="fas fa-users"></i> 暂无用户数据
        </div>
    </c:if>
</div>
