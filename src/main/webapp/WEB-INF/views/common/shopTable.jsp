<%@ page contentType="text/html;charset=UTF-8" language="java" session="false" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:if test="${not empty shops}">
    <div class="table-container">
        <table class="shop-table" id="shopTable">
            <thead>
                <tr>
                    <c:if test="${showIdColumn}">
                        <th>ID</th>
                    </c:if>
                    <th>店铺名称</th>
                    <th>店主</th>
                    <th>联系方式</th>
                    <th>地址</th>
                    <th>创建时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="shop" items="${shops}">
                    <tr class="shop-row" data-id="${shop.id}">
                        <c:if test="${showIdColumn}">
                            <td>${shop.id}</td>
                        </c:if>
                        <td>
                            <div class="shop-info">
                                <strong>${shop.name}</strong><br>
                                <c:if test="${not empty shop.description}">
                                    <small class="shop-description">
                                        ${fn:substring(shop.description, 0, 30)}...
                                    </small>
                                </c:if>
                            </div>
                        </td>
                        <td>
                            <span class="merchant-name">${shop.merchant.username}</span>
                        </td>
                        <td>
                            <c:if test="${not empty shop.contactPhone}">
                                <div>电话: ${shop.contactPhone}</div>
                            </c:if>
                            <c:if test="${not empty shop.contactEmail}">
                                <div>邮箱: ${shop.contactEmail}</div>
                            </c:if>
                        </td>
                        <td>
                            <c:if test="${not empty shop.address}">
                                <span class="shop-address">
                                    ${fn:substring(shop.address, 0, 30)}<c:if test="${fn:length(shop.address) > 30}">...</c:if>
                                </span>
                            </c:if>
                        </td>
                        <td>
                            <fmt:parseDate value="${shop.createdTime}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="parsedDate"/>
                            <fmt:formatDate value="${parsedDate}" pattern="yyyy-MM-dd HH:mm"/>
                        </td>
                        <td>
                            <div class="action-buttons">
                                <a href="${pageContext.request.contextPath}/shops/${shop.id}" 
                                   class="btn btn-secondary btn-sm" title="查看店铺">
                                    <i class="fas fa-eye"></i>
                                </a>
                                <a href="${pageContext.request.contextPath}/shops/edit/${shop.id}" 
                                   class="btn btn-warning btn-sm" title="编辑店铺">
                                    <i class="fas fa-edit"></i>
                                </a>
                                <form action="${pageContext.request.contextPath}/shops/delete/${shop.id}" 
                                      method="post" class="form-inline d-inline">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                    <button type="submit" class="btn btn-danger btn-sm" 
                                           onclick="return confirm('确定要永久删除店铺【${shop.name}】吗？此操作不可恢复！')"
                                            title="删除店铺">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</c:if>

<c:if test="${empty shops}">
    <div class="empty-state">
        <i class="fas fa-store empty-state-icon"></i>
        <h3 class="empty-state-title">暂无店铺数据</h3>
        <p class="empty-state-message">当前没有店铺数据</p>
        <c:if test="${showAddButton}">
            <a href="${pageContext.request.contextPath}/admin/shops/create" class="btn btn-success">
                <i class="fas fa-plus"></i> 创建新店铺
            </a>
        </c:if>
    </div>
</c:if>
