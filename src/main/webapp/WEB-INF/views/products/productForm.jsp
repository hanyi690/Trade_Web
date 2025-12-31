<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>
        <c:choose>
            <c:when test="${isEdit}">编辑商品 - ${product.name}</c:when>
            <c:otherwise>添加新商品</c:otherwise>
        </c:choose>
        - E-Shop
    </title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/site.css">
    <!-- 新增：商品表单模块CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modules/product-form.css">
</head>
<body class="product-form">
    
   <jsp:include page="../common/header.jsp" />
    
    <div class="container">
        <h1 class="page-title">
            <i class="fas fa-edit"></i> 
            <c:choose>
                <c:when test="${isEdit}">编辑商品：${product.name}</c:when>
                <c:otherwise>添加新商品</c:otherwise>
            </c:choose>
        </h1>
        
        <div class="form-container">
            <form action="${pageContext.request.contextPath}/products/save" 
                  method="post" 
                  enctype="multipart/form-data">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                
                <c:if test="${isEdit}">
                    <input type="hidden" name="id" value="${product.id}"/>
                </c:if>
                
                <!-- 基本信息 -->
                <div class="form-section">
                    <h3>基本信息</h3>
                    
                    <div class="form-group">
                        <label for="name">商品名称 <span class="required">*</span></label>
                        <input type="text" 
                               id="name" 
                               name="name" 
                               value="${product.name}"
                               placeholder="请输入商品名称"
                               required>
                    </div>
                    
                    <div class="form-group">
                        <label for="description">商品描述</label>
                        <textarea id="description" 
                                  name="description" 
                                  placeholder="请输入商品描述">${product.description}</textarea>
                    </div>
                    
                    <div class="form-group">
                        <label for="price">价格 <span class="required">*</span></label>
                        <input type="number" 
                               id="price" 
                               name="price" 
                               value="${product.price}"
                               step="0.01" 
                               min="0" 
                               placeholder="0.00"
                               required>
                    </div>
                    
                    <!-- 新增：分类选择 -->
                    <div class="form-group">
                        <label for="categoryId">商品分类 <span class="required">*</span></label>
                        <select id="categoryId" name="categoryId" required>
                            <option value="">-- 请选择分类 --</option>
                            <c:forEach items="${categories}" var="category">
                                <option value="${category.id}" ${product.category != null && product.category.id eq category.id ? 'selected' : ''}>
                                     ${category.name}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                
                <!-- 库存和状态 -->
                <div class="form-section">
                    <h3>库存和状态</h3>
                    
                    <div class="form-group">
                        <label for="stock">库存数量 <span class="required">*</span></label>
                        <input type="number" 
                               id="stock" 
                               name="stock" 
                               value="${product.stock}"
                               min="0" 
                               placeholder="0"
                               required>
                    </div>
                    
                    <div class="form-group">
                        <label for="sales">初始销量</label>
                        <input type="number" 
                               id="sales" 
                               name="sales" 
                               value="${product.sales}"
                               min="0" 
                               placeholder="0">
                    </div>
                    
                </div>
                
                <!-- 商品图片 -->
                <div class="form-section">
                    <h3>商品图片</h3>
                    
                    <div class="form-group">
                        <label for="imageUrl">图片URL</label>
                        <input type="text" 
                               id="imageUrl" 
                               name="imageUrl" 
                               value="${product.imageUrl}"
                               placeholder="https://example.com/image.jpg">
                    </div>
                    
                    <div class="form-group">
                        <label for="imageFile">上传图片</label>
                        <input type="file" 
                               id="imageFile" 
                               name="imageFile" 
                               accept="image/*">
                    </div>
                    
                    <c:if test="${not empty product.imageUrl or not empty product.imageFilename}">
                        <div class="image-preview">
                            <p>当前图片：</p>
                            <c:choose>
                                <c:when test="${not empty product.imageUrl}">
                                    <img src="${product.imageUrl}" alt="${product.name}">
                                </c:when>
                                <c:when test="${not empty product.imageFilename}">
                                    <img src="${pageContext.request.contextPath}/images/products/${product.imageFilename}" 
                                         alt="${product.name}">
                                </c:when>
                            </c:choose>
                        </div>
                    </c:if>
                </div>
                
                <!-- 商品规格 -->
                <div class="form-section">
                    <h3>商品规格</h3>
                    
                    <div class="form-group">
                        <label for="brand">品牌</label>
                        <input type="text" 
                               id="brand" 
                               name="brand" 
                               value="${product.brand}"
                               placeholder="请输入品牌">
                    </div>
                    
                    <div class="form-group">
                        <label for="model">型号</label>
                        <input type="text" 
                               id="model" 
                               name="model" 
                               value="${product.model}"
                               placeholder="请输入型号">
                    </div>
                    
                    <div class="form-group">
                        <label for="weight">重量（kg）</label>
                        <input type="number" 
                               id="weight" 
                               name="weight" 
                               value="${product.weight}"
                               step="0.01" 
                               min="0" 
                               placeholder="0.00">
                    </div>
                    
                    <div class="form-group">
                        <label for="material">材质</label>
                        <input type="text" 
                               id="material" 
                               name="material" 
                               value="${product.material}"
                               placeholder="请输入材质">
                    </div>
                </div>
                
                <!-- 表单操作 -->
                <div class="form-actions">
                    <a href="${pageContext.request.contextPath}/shops/manage" class="btn btn-secondary">
                        取消
                    </a>
                    <button type="submit" class="btn btn-primary">
                        <c:choose>
                            <c:when test="${isEdit}">
                                <i class="fas fa-save"></i> 保存更改
                            </c:when>
                            <c:otherwise>
                                <i class="fas fa-plus"></i> 创建商品
                            </c:otherwise>
                        </c:choose>
                    </button>
                </div>
            </form>
        </div>
    </div>
    
    <jsp:include page="../common/footer.jsp" />
    
    <script src="${pageContext.request.contextPath}/resources/js/site.js"></script>
    <script>
        // 图片预览功能
        document.getElementById('imageFile')?.addEventListener('change', function(e) {
            const file = e.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    // 创建或更新预览
                    let preview = document.querySelector('.image-preview');
                    if (!preview) {
                        preview = document.createElement('div');
                        preview.className = 'image-preview';
                        document.getElementById('imageFile').parentNode.appendChild(preview);
                    }
                    preview.innerHTML = `<p>预览：</p><img src="\${e.target.result}" alt="预览图片">`;
                }
                reader.readAsDataURL(file);
            }
        });
    </script>
</body>
</html>
