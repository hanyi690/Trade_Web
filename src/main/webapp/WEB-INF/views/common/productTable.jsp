<!-- filepath: f:\project\Trade_Web\src\main\webapp\WEB-INF\views\common\productTable.jsp -->
<%-- 通用商品表格组件 --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" session="false" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 添加对商品表格组件样式的引用 -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modules/product-table.css">

<c:if test="${not empty products}">
    <div class="table-container">
        <table class="product-table" id="productTable">
            <thead>
                <tr>
                    <c:if test="${showIdColumn}">
                        <th>ID</th>
                    </c:if>
                    <th>商品图片</th>
                    <th>商品信息</th>
                    <th>价格</th>
                    <th>库存</th>
                    <th>销量</th>
                    <c:if test="${showCategoryColumn}">
                        <th>分类</th>
                    </c:if>
                    <c:if test="${showMerchantColumn}">
                        <th>商家</th>
                    </c:if>
                    <c:if test="${showStatusColumn}">
                        <th>状态</th>
                    </c:if>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="product" items="${products}">
                    <tr class="product-row" data-id="${product.id}">
                        <c:if test="${showIdColumn}">
                            <td>${product.id}</td>
                        </c:if>
                        <td>
                            <div class="product-image-container">
                                <c:choose>
                                    <c:when test="${not empty product.imageUrl and fn:startsWith(product.imageUrl, 'http')}">
                                        <img src="${product.imageUrl}" 
                                             alt="${product.name}" 
                                             class="product-image lazy-image"
                                             loading="lazy"
                                             onerror='this.onerror=null; this.style.display="none"; this.parentElement.className="placeholder-image"; this.parentElement.innerHTML="<i class=\"fas fa-image\"></i>"'>
                                    </c:when>
                                    <c:when test="${not empty product.imageFilename}">
                                        <img src="${pageContext.request.contextPath}/images/products/${product.imageFilename}" 
                                             alt="${product.name}" 
                                             class="product-image lazy-image"
                                             loading="lazy"
                                             onerror='this.onerror=null; this.style.display="none"; this.parentElement.className="placeholder-image"; this.parentElement.innerHTML="<i class=\"fas fa-image\"></i>"'>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="placeholder-image">
                                            <i class="fas fa-image"></i>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </td>
                        <td>
                            <strong>${product.name}</strong><br>
                            <small class="product-description-small">
                                <c:if test="${not empty product.description}">${fn:substring(product.description, 0, 30)}...</c:if>
                                <c:if test="${empty product.description}">暂无描述</c:if>
                            </small>
                        </td>
                        <td>
                            <span class="price">
                                ¥<fmt:formatNumber value="${product.price}" minFractionDigits="2" maxFractionDigits="2"/>
                            </span>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${empty product.stock}">
                                    <span class="stock-indicator stock-unknown">未知</span>
                                </c:when>
                                <c:when test="${product.stock > 10}">
                                    <span class="stock-indicator stock-high">${product.stock}</span>
                                </c:when>
                                <c:when test="${product.stock > 0}">
                                    <span class="stock-indicator stock-medium">${product.stock}</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="stock-indicator stock-low">缺货</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty product.sales}">
                                    <span class="sales-count">${product.sales}</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="sales-count">0</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <c:if test="${showCategoryColumn}">
                            <td>
                                <c:if test="${not empty product.category}">
                                    <span class="badge">${product.category.name}</span>
                                </c:if>
                            </td>
                        </c:if>
                        <c:if test="${showMerchantColumn}">
                            <td>
                                <c:if test="${not empty product.merchant}">
                                    <small>${product.merchant.username}</small>
                                </c:if>
                            </td>
                        </c:if>
                        <c:if test="${showStatusColumn}">
                            <td>
                                <c:choose>
                                    <c:when test="${product.stock <= 0}">
                                        <span class="badge badge-warning">缺货</span>
                                    </c:when>
                                    <c:when test="${product.stock <= 10}">
                                        <span class="badge badge-warning">库存少</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-success">在售</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </c:if>
                        <td>
                            <%-- 商品操作按钮组件（直接融入） --%>
                            <div class="action-buttons">
                                <a href="${pageContext.request.contextPath}/products/${product.id}" 
                                   class="btn btn-secondary btn-sm" title="查看">
                                    <i class="fas fa-eye"></i>
                                </a>
                                <a href="${pageContext.request.contextPath}/products/edit/${product.id}" 
                                   class="btn btn-warning btn-sm" title="编辑">
                                    <i class="fas fa-edit"></i>
                                </a>
                                <form action="${pageContext.request.contextPath}/products/delete/${product.id}" 
                                      method="post" class="form-inline">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                    <button type="submit" class="btn btn-danger btn-sm" 
                                           onclick="return confirm('确定要删除商品【${product.name}】吗？此操作不可恢复！')"
                                            title="删除">
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

<c:if test="${empty products}">
    <div class="empty-state">
        <i class="fas fa-box-open empty-state-icon"></i>
        <h3 class="empty-state-title">暂无商品</h3>
        <p class="empty-state-message">当前没有商品数据</p>
        <c:if test="${showAddButton}">
            <a href="${pageContext.request.contextPath}/products/create" class="btn btn-success">
                <i class="fas fa-plus"></i> 添加第一个商品
            </a>
        </c:if>
    </div>
</c:if>