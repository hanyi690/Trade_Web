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
                    <th>商品数量</th>
                    <th>销售额</th>
                    <th>状态</th>
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
                            <span class="product-count">${shop.productCount}</span>
                        </td>
                        <td>
                            <span class="sales-amount">
                                ¥<fmt:formatNumber value="${shop.totalSales}" minFractionDigits="2"/>
                            </span>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${shop.status == 'OPEN'}">
                                    <span class="badge badge-success">营业中</span>
                                </c:when>
                                <c:when test="${shop.status == 'CLOSED'}">
                                    <span class="badge badge-danger">已关闭</span>
                                </c:when>
                                <c:when test="${shop.status == 'SUSPENDED'}">
                                    <span class="badge badge-warning">已暂停</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-secondary">${shop.status}</span>
                                </c:otherwise>
                            </c:choose>
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
                                <a href="${pageContext.request.contextPath}/admin/shops/edit/${shop.id}" 
                                   class="btn btn-warning btn-sm" title="编辑店铺">
                                    <i class="fas fa-edit"></i>
                                </a>
                                <c:if test="${shop.status == 'OPEN'}">
                                    <form action="${pageContext.request.contextPath}/admin/shops/suspend/${shop.id}" 
                                          method="post" class="form-inline d-inline">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                        <button type="submit" class="btn btn-danger btn-sm" 
                                               onclick="return confirm('确定要暂停店铺【${shop.name}】吗？')"
                                                title="暂停店铺">
                                            <i class="fas fa-pause"></i>
                                        </button>
                                    </form>
                                </c:if>
                                <c:if test="${shop.status == 'SUSPENDED'}">
                                    <form action="${pageContext.request.contextPath}/admin/shops/activate/${shop.id}" 
                                          method="post" class="form-inline d-inline">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                        <button type="submit" class="btn btn-success btn-sm" 
                                               onclick="return confirm('确定要激活店铺【${shop.name}】吗？')"
                                                title="激活店铺">
                                            <i class="fas fa-play"></i>
                                        </button>
                                    </form>
                                </c:if>
                                <form action="${pageContext.request.contextPath}/admin/shops/delete/${shop.id}" 
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
