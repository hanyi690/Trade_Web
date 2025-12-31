<%-- 用户表格组件 --%>
<%-- 参数说明： --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" session="false" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:if test="${empty showIdColumn}"><c:set var="showIdColumn" value="true" /></c:if>
<c:if test="${empty showStatusColumn}"><c:set var="showStatusColumn" value="true" /></c:if>
<c:if test="${empty showActions}"><c:set var="showActions" value="true" /></c:if>
<c:if test="${empty showAddButton}"><c:set var="showAddButton" value="false" /></c:if>

<c:if test="${not empty users}">
    <div class="table-container">
        <table class="user-table" id="userTable">
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
                    <tr class="user-row" data-id="${user.id}">
                        <c:if test="${showIdColumn}">
                            <td>${user.id}</td>
                        </c:if>
                        <td>
                            <div class="user-info">
                                <strong>${user.username}</strong>
                                <c:if test="${not empty user.phone}">
                                    <br><small class="user-phone">${user.phone}</small>
                                </c:if>
                            </div>
                        </td>
                        <td>${user.email}</td>
                        <td>
                            <!-- 参考profile.jsp中的角色显示 -->
                            <c:choose>
                                <c:when test="${user.role == 'ADMIN'}">
                                    <span class="badge badge-danger">管理员</span>
                                </c:when>
                                <c:when test="${user.role == 'MERCHANT'}">
                                    <span class="badge badge-warning">商家</span>
                                </c:when>
                                <c:when test="${user.role == 'CONSUMER'}">
                                    <span class="badge badge-primary">消费者</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-secondary">${user.role}</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <c:if test="${showStatusColumn}">
                            <td>
                                <!-- 参考profile.jsp中的状态显示 -->
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
                                    <!-- 修改：将查看详情改为管理员编辑用户页面 -->
                                    <a href="${pageContext.request.contextPath}/admin/users/edit/${user.id}" 
                                       class="btn btn-secondary btn-sm" title="编辑用户">
                                        <i class="fas fa-edit"></i> 编辑
                                    </a>
                                    
                                  
                                    
                                    <!-- 角色管理按钮（管理员可以修改用户角色） -->
                                    <div class="dropdown d-inline">
                                        <button class="btn btn-info btn-sm dropdown-toggle" type="button" 
                                                data-toggle="dropdown" title="修改角色">
                                            <i class="fas fa-user-tag"></i>
                                        </button>
                                        <div class="dropdown-menu">
                                            <form action="${pageContext.request.contextPath}/admin/users/setRole" 
                                                  method="post" class="px-2">
                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                                <input type="hidden" name="userId" value="${user.id}"/>
                                                <div class="form-group mb-2">
                                                    <select name="role" class="form-control form-control-sm">
                                                        <option value="CONSUMER" ${user.role == 'CONSUMER' ? 'selected' : ''}>消费者</option>
                                                        <option value="MERCHANT" ${user.role == 'MERCHANT' ? 'selected' : ''}>商家</option>
                                                        <option value="ADMIN" ${user.role == 'ADMIN' ? 'selected' : ''}>管理员</option>
                                                    </select>
                                                </div>
                                                <button type="submit" class="btn btn-primary btn-sm btn-block">
                                                    <i class="fas fa-save"></i> 更新角色
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </td>
                        </c:if>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</c:if>

<c:if test="${empty users}">
    <div class="empty-state">
        <i class="fas fa-users empty-state-icon"></i>
        <h3 class="empty-state-title">暂无用户数据</h3>
        <p class="empty-state-message">当前没有用户数据</p>
        <c:if test="${showAddButton}">
            <a href="${pageContext.request.contextPath}/admin/users/create" class="btn btn-success">
                <i class="fas fa-plus"></i> 添加新用户
            </a>
        </c:if>
    </div>
</c:if>

<style>
    .user-table .badge-danger { background-color: #dc3545; color: white; }
    .user-table .badge-warning { background-color: #ffc107; color: #212529; }
    .user-table .badge-primary { background-color: #007bff; color: white; }
    .user-table .badge-success { background-color: #28a745; color: white; }
    .user-table .badge-secondary { background-color: #6c757d; color: white; }
    
    .user-table .action-buttons {
        display: flex;
        gap: 5px;
        flex-wrap: wrap;
        justify-content: flex-start;
    }
    
    .user-table .action-buttons .btn-sm {
        padding: 4px 8px;
        font-size: 0.8rem;
    }
    
    .user-table .dropdown-menu {
        min-width: 200px;
        padding: 10px;
    }
    
    .user-phone {
        color: #6c757d;
        font-size: 0.8em;
    }
</style>
