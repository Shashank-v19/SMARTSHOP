<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.ecommerce.model.Product" %>
<%@ page import="com.ecommerce.model.Category" %>

<%
    Product product = (Product) request.getAttribute("product");
    List<Category> categories = (List<Category>) request.getAttribute("categories");

    if (product == null) {
        response.sendRedirect(request.getContextPath() + "/admin/products");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Product #<%= product.getProductId() %> - Admin Portal</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .admin-nav {
            background: #0f172a;
            padding: 16px 32px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        .admin-nav .logo {
            font-size: 1.3rem;
            font-weight: 700;
            color: #f8fafc;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .admin-nav .logo span {
            background: #3b82f6;
            color: white;
            font-size: 0.75rem;
            padding: 3px 8px;
            border-radius: 6px;
            text-transform: uppercase;
        }
        .admin-nav-links {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        .admin-nav-links a {
            color: #94a3b8;
            text-decoration: none;
            font-weight: 500;
            font-size: 0.95rem;
        }
        .admin-nav-links a:hover, .admin-nav-links a.active {
            color: #38bdf8;
        }
        .form-card {
            background: white;
            border-radius: 14px;
            padding: 30px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.04);
            border: 1px solid #e2e8f0;
            max-width: 800px;
            margin: 0 auto;
        }
        .form-grid-2 {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            font-weight: 600;
            font-size: 0.9rem;
            color: #334155;
            margin-bottom: 6px;
        }
        .form-group input, .form-group select, .form-group textarea {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 0.95rem;
            box-sizing: border-box;
            background: #f8fafc;
        }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
            border-color: #3b82f6;
            outline: none;
            background: white;
        }
        .btn-new-category {
            background: #eff6ff;
            color: #2563eb;
            border: 1px solid #bfdbfe;
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 0.78rem;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            transition: all 0.2s ease;
        }
        .btn-new-category:hover {
            background: #2563eb;
            color: white;
            border-color: #2563eb;
        }
        .btn-primary-sm {
            background: #2563eb;
            color: white;
            border: none;
            padding: 6px 14px;
            border-radius: 6px;
            font-size: 0.82rem;
            font-weight: 600;
            cursor: pointer;
        }
        .btn-primary-sm:hover {
            background: #1d4ed8;
        }
        .btn-ghost-sm {
            background: #f1f5f9;
            color: #475569;
            border: 1px solid #cbd5e1;
            padding: 6px 14px;
            border-radius: 6px;
            font-size: 0.82rem;
            font-weight: 500;
            cursor: pointer;
        }
        .btn-ghost-sm:hover {
            background: #e2e8f0;
        }
        .cat-modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 9999;
        }
        .cat-modal-backdrop {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(15, 23, 42, 0.6);
            backdrop-filter: blur(4px);
        }
        .cat-modal-content {
            position: relative;
            background: white;
            width: 90%;
            max-width: 480px;
            border-radius: 12px;
            box-shadow: 0 20px 35px rgba(0, 0, 0, 0.25);
            padding: 24px;
            z-index: 10;
            animation: modalPop 0.2s cubic-bezier(0.16, 1, 0.3, 1);
        }
        @keyframes modalPop {
            from { transform: scale(0.95); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }
        .cat-modal-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 18px;
            border-bottom: 1px solid #f1f5f9;
            padding-bottom: 12px;
        }
        .cat-modal-close {
            background: none;
            border: none;
            font-size: 1.5rem;
            line-height: 1;
            color: #94a3b8;
            cursor: pointer;
            padding: 0 4px;
        }
        .cat-modal-close:hover {
            color: #0f172a;
        }
        .cat-icon-badge {
            width: 36px;
            height: 36px;
            border-radius: 8px;
            background: #eff6ff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.1rem;
        }
    </style>
</head>
<body style="background: #f8fafc; margin: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #1e293b;">

<header class="admin-nav">
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="logo">
        SmartShop <span>Admin</span>
    </a>
    <nav class="admin-nav-links">
        <a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a>
        <a href="${pageContext.request.contextPath}/admin/products" class="active">Products</a>
        <a href="${pageContext.request.contextPath}/admin/orders">Orders</a>
        <a href="${pageContext.request.contextPath}/admin/users">Users</a>
        <a href="${pageContext.request.contextPath}/index.jsp" target="_blank" style="color:#38bdf8;">Storefront &nearr;</a>
        <a href="${pageContext.request.contextPath}/logout" style="color:#ef4444;">Logout</a>
    </nav>
</header>

<main style="max-width: 900px; margin: 35px auto; padding: 0 24px;">

    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
        <div>
            <h1 style="font-size: 1.8rem; font-weight: 700; margin: 0 0 5px 0;">Edit Product #<%= product.getProductId() %></h1>
            <p style="color: #64748b; margin: 0;">Update product attributes, pricing and stock levels</p>
        </div>
        <a href="${pageContext.request.contextPath}/admin/products" class="continue-button" style="text-decoration: none; padding: 8px 16px; font-size: 0.9rem;">
            &larr; Back to Products
        </a>
    </div>

    <% String error = request.getParameter("error"); %>
    <% if (error != null && !error.isBlank()) { %>
        <div style="background: #fee2e2; border: 1px solid #ef4444; color: #991b1b; padding: 12px 18px; border-radius: 8px; margin-bottom: 20px;">
            <%= error %>
        </div>
    <% } %>

    <div class="form-card">
        <form action="${pageContext.request.contextPath}/admin/edit-product" method="post">
            <input type="hidden" name="productId" value="<%= product.getProductId() %>">
            
            <div class="form-grid-2">
                <div class="form-group">
                    <label>Product Name *</label>
                    <input type="text" name="productName" value="<%= product.getProductName() %>" required>
                </div>
                
                <div class="form-group">
                    <label>Brand / Manufacturer</label>
                    <input type="text" name="brand" value="<%= product.getBrand() != null ? product.getBrand() : "" %>">
                </div>
            </div>

            <div class="form-grid-2">
                <div class="form-group">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                        <label style="margin: 0;">Category</label>
                        <button type="button" class="btn-new-category" onclick="openCategoryModal()">
                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                            + New Category
                        </button>
                    </div>
                    <select name="categoryId" id="categorySelect" onchange="handleCategorySelectChange(this)">
                        <option value="">-- Select Category --</option>
                        <option value="__NEW__" style="color: #2563eb; font-weight: 600;">➕ + Add New Category...</option>
                        <% if (categories != null) { 
                            for (Category cat : categories) { 
                                boolean selected = product.getCategoryId() != null && product.getCategoryId().equals(cat.getCategoryId());
                        %>
                                <option value="<%= cat.getCategoryId() %>" <%= selected ? "selected" : "" %>><%= cat.getCategoryName() %></option>
                        <%  } 
                           } %>
                    </select>

                    <!-- Inline Quick Category box -->
                    <div id="inlineCategoryBox" style="display: none; margin-top: 10px; padding: 14px; background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 8px;">
                        <div style="font-weight: 600; font-size: 0.85rem; color: #166534; margin-bottom: 8px; display: flex; justify-content: space-between; align-items: center;">
                            <span>Create New Category</span>
                            <button type="button" onclick="closeInlineCategoryBox()" style="background: none; border: none; color: #166534; cursor: pointer; font-size: 1.1rem; line-height: 1;">&times;</button>
                        </div>
                        <div style="margin-bottom: 8px;">
                            <input type="text" id="inlineCategoryName" name="newCategoryName" placeholder="Enter category name (e.g. Smart Wearables)" style="background: white; margin-bottom: 6px;">
                            <input type="text" id="inlineCategoryDesc" name="newCategoryDesc" placeholder="Description (optional)" style="background: white; font-size: 0.85rem;">
                        </div>
                        <div style="display: flex; gap: 8px;">
                            <button type="button" class="btn-primary-sm" onclick="submitInlineCategory()">Save & Select</button>
                            <button type="button" class="btn-ghost-sm" onclick="closeInlineCategoryBox()">Cancel</button>
                        </div>
                    </div>

                    <div id="categorySuccessToast" style="display: none; margin-top: 8px; font-size: 0.85rem; color: #166534; background: #dcfce7; padding: 6px 12px; border-radius: 6px; border: 1px solid #86efac;">
                    </div>
                </div>

                <div class="form-group">
                    <label>Stock Quantity *</label>
                    <input type="number" name="stockQuantity" value="<%= product.getStockQuantity() %>" min="0" required>
                </div>
            </div>

            <div class="form-grid-2">
                <div class="form-group">
                    <label>Regular Price (₹) *</label>
                    <input type="number" step="0.01" name="price" value="<%= product.getPrice() %>" required>
                </div>

                <div class="form-group">
                    <label>Discounted Price (₹)</label>
                    <input type="number" step="0.01" name="discountPrice" value="<%= product.getDiscountPrice() != null ? product.getDiscountPrice() : "" %>" placeholder="Optional">
                </div>
            </div>

            <div class="form-group">
                <label>Image URL</label>
                <input type="url" name="imageUrl" value="<%= product.getImageUrl() != null ? product.getImageUrl() : "" %>">
            </div>

            <div class="form-group">
                <label>Product Description</label>
                <textarea name="description" rows="4"><%= product.getDescription() != null ? product.getDescription() : "" %></textarea>
            </div>

            <div class="form-group" style="display: flex; align-items: center; gap: 10px; margin-top: 10px;">
                <input type="checkbox" name="active" id="activeCheck" value="true" <%= product.isActive() ? "checked" : "" %> style="width: auto; margin: 0;">
                <label for="activeCheck" style="margin: 0; cursor: pointer; font-weight: 500;">
                    Product is active and visible in storefront
                </label>
            </div>

            <div style="margin-top: 30px; display: flex; justify-content: flex-end; gap: 15px;">
                <a href="${pageContext.request.contextPath}/admin/products" class="continue-button" style="text-decoration: none; padding: 10px 20px;">
                    Cancel
                </a>
                <button type="submit" class="product-button" style="padding: 10px 25px; border: none; cursor: pointer;">
                    Update Changes
                </button>
            </div>
        </form>
    </div>

</main>

<!-- Category Quick-Add Modal -->
<div id="categoryModal" class="cat-modal" style="display: none;">
    <div class="cat-modal-backdrop" onclick="closeCategoryModal()"></div>
    <div class="cat-modal-content">
        <div class="cat-modal-header">
            <div style="display: flex; align-items: center; gap: 10px;">
                <div class="cat-icon-badge">📁</div>
                <div>
                    <h3 style="margin: 0; font-size: 1.15rem; font-weight: 700; color: #0f172a;">Add New Category</h3>
                    <p style="margin: 2px 0 0 0; font-size: 0.82rem; color: #64748b;">Create a new category for products in the store</p>
                </div>
            </div>
            <button type="button" class="cat-modal-close" onclick="closeCategoryModal()">&times;</button>
        </div>
        
        <div id="modalAlert" style="display: none; padding: 10px 14px; border-radius: 6px; font-size: 0.88rem; margin-bottom: 15px;"></div>

        <form id="quickCategoryForm" onsubmit="handleModalSubmit(event)">
            <div class="form-group" style="margin-bottom: 14px;">
                <label for="modalCategoryName" style="font-weight: 600; font-size: 0.88rem; color: #334155; margin-bottom: 4px; display: block;">Category Name *</label>
                <input type="text" id="modalCategoryName" placeholder="e.g. Gaming Accessories, Smart Watches..." required style="width: 100%; padding: 9px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.92rem; box-sizing: border-box;">
            </div>

            <div class="form-group" style="margin-bottom: 14px;">
                <label for="modalCategoryDesc" style="font-weight: 600; font-size: 0.88rem; color: #334155; margin-bottom: 4px; display: block;">Description (Optional)</label>
                <textarea id="modalCategoryDesc" rows="3" placeholder="Short description of products in this category..." style="width: 100%; padding: 9px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.92rem; box-sizing: border-box; resize: vertical;"></textarea>
            </div>

            <div class="form-group" style="display: flex; align-items: center; gap: 8px; margin-bottom: 20px;">
                <input type="checkbox" id="modalCategoryActive" checked style="width: auto; margin: 0; cursor: pointer;">
                <label for="modalCategoryActive" style="margin: 0; font-size: 0.88rem; color: #475569; cursor: pointer;">Active and visible in store navigation</label>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px;">
                <button type="button" class="btn-ghost-sm" onclick="closeCategoryModal()" style="padding: 8px 16px;">Cancel</button>
                <button type="submit" id="btnSubmitModalCat" class="product-button" style="padding: 8px 18px; font-size: 0.9rem; border: none; cursor: pointer; display: flex; align-items: center; gap: 6px;">
                    <span>Save & Select Category</span>
                </button>
            </div>
        </form>
    </div>
</div>

<script>
function openCategoryModal() {
    document.getElementById('categoryModal').style.display = 'flex';
    document.getElementById('modalAlert').style.display = 'none';
    const nameInput = document.getElementById('modalCategoryName');
    nameInput.value = '';
    document.getElementById('modalCategoryDesc').value = '';
    document.getElementById('modalCategoryActive').checked = true;
    setTimeout(() => nameInput.focus(), 50);
}

function closeCategoryModal() {
    document.getElementById('categoryModal').style.display = 'none';
}

function handleCategorySelectChange(selectElem) {
    if (selectElem.value === '__NEW__') {
        openCategoryModal();
        selectElem.value = '<%= product.getCategoryId() != null ? product.getCategoryId() : "" %>';
    }
}

function openInlineCategoryBox() {
    document.getElementById('inlineCategoryBox').style.display = 'block';
    document.getElementById('inlineCategoryName').focus();
}

function closeInlineCategoryBox() {
    document.getElementById('inlineCategoryBox').style.display = 'none';
    document.getElementById('inlineCategoryName').value = '';
    document.getElementById('inlineCategoryDesc').value = '';
}

async function handleModalSubmit(event) {
    event.preventDefault();
    const name = document.getElementById('modalCategoryName').value.trim();
    const desc = document.getElementById('modalCategoryDesc').value.trim();
    const active = document.getElementById('modalCategoryActive').checked;
    const btn = document.getElementById('btnSubmitModalCat');
    const alertBox = document.getElementById('modalAlert');

    if (!name) return;

    btn.disabled = true;
    btn.innerHTML = '<span>Saving...</span>';

    try {
        const formData = new URLSearchParams();
        formData.append('categoryName', name);
        formData.append('description', desc);
        formData.append('active', active);
        formData.append('format', 'json');

        const contextPath = '${pageContext.request.contextPath}';
        const response = await fetch(contextPath + '/admin/categories', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: formData.toString()
        });

        const result = await response.json();
        if (result.success && result.category) {
            addNewCategoryToSelect(result.category.categoryId, result.category.categoryName);
            closeCategoryModal();
            showCategorySuccessToast("✓ Category '" + result.category.categoryName + "' added and selected!");
        } else {
            alertBox.style.display = 'block';
            alertBox.style.background = '#fee2e2';
            alertBox.style.border = '1px solid #ef4444';
            alertBox.style.color = '#991b1b';
            alertBox.innerText = result.message || 'Failed to create category';
        }
    } catch (err) {
        alertBox.style.display = 'block';
        alertBox.style.background = '#fee2e2';
        alertBox.style.border = '1px solid #ef4444';
        alertBox.style.color = '#991b1b';
        alertBox.innerText = 'Network error or server unavailable';
    } finally {
        btn.disabled = false;
        btn.innerHTML = '<span>Save & Select Category</span>';
    }
}

async function submitInlineCategory() {
    const nameInput = document.getElementById('inlineCategoryName');
    const descInput = document.getElementById('inlineCategoryDesc');
    const name = nameInput.value.trim();
    const desc = descInput.value.trim();

    if (!name) {
        alert('Please enter a category name.');
        nameInput.focus();
        return;
    }

    try {
        const formData = new URLSearchParams();
        formData.append('categoryName', name);
        formData.append('description', desc);
        formData.append('active', 'true');
        formData.append('format', 'json');

        const contextPath = '${pageContext.request.contextPath}';
        const response = await fetch(contextPath + '/admin/categories', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: formData.toString()
        });

        const result = await response.json();
        if (result.success && result.category) {
            addNewCategoryToSelect(result.category.categoryId, result.category.categoryName);
            closeInlineCategoryBox();
            showCategorySuccessToast("✓ Category '" + result.category.categoryName + "' added and selected!");
        } else {
            alert(result.message || 'Failed to create category');
        }
    } catch (err) {
        alert('Error creating category: ' + err.message);
    }
}

function addNewCategoryToSelect(id, name) {
    const select = document.getElementById('categorySelect');
    let existingOpt = select.querySelector('option[value="' + id + '"]');
    if (!existingOpt) {
        const opt = document.createElement('option');
        opt.value = id;
        opt.textContent = name;
        select.appendChild(opt);
        select.value = id;
    } else {
        select.value = id;
    }
}

function showCategorySuccessToast(msg) {
    const toast = document.getElementById('categorySuccessToast');
    if (toast) {
        toast.textContent = msg;
        toast.style.display = 'block';
        setTimeout(() => {
            toast.style.display = 'none';
        }, 5000);
    }
}

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        closeCategoryModal();
    }
});
</script>

</body>
</html>
