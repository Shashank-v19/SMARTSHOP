<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="com.ecommerce.model.Product" %>
<%@ page import="com.ecommerce.model.Category" %>

<%
    List<Product> products = (List<Product>) request.getAttribute("products");
    List<Category> categories = (List<Category>) request.getAttribute("categories");

    Map<Long, String> categoryMap = new HashMap<>();
    if (categories != null) {
        for (Category cat : categories) {
            categoryMap.put(cat.getCategoryId(), cat.getCategoryName());
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Products - Admin Portal</title>
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
        .data-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.04);
            border: 1px solid #e2e8f0;
        }
        .data-table th, .data-table td {
            padding: 14px 16px;
            text-align: left;
            border-bottom: 1px solid #f1f5f9;
        }
        .data-table th {
            background: #f8fafc;
            color: #475569;
            font-size: 0.85rem;
            text-transform: uppercase;
            font-weight: 600;
        }
        .data-table tr:hover td {
            background: #f8fafc;
        }
        .btn-action {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 0.85rem;
            font-weight: 500;
            text-decoration: none;
            cursor: pointer;
            border: none;
        }
        .btn-action-primary { background: #3b82f6; color: white; }
        .btn-action-edit { background: #f1f5f9; color: #334155; border: 1px solid #cbd5e1; }
        .btn-action-delete { background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; }
        .btn-action-toggle { background: #e0e7ff; color: #3730a3; }
        .badge-active { background: #dcfce7; color: #166534; padding: 4px 8px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-inactive { background: #fee2e2; color: #991b1b; padding: 4px 8px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .prod-thumb {
            width: 48px;
            height: 48px;
            object-fit: cover;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
        }
        .btn-new-category {
            background: #eff6ff;
            color: #2563eb;
            border: 1px solid #bfdbfe;
            padding: 10px 18px;
            border-radius: 8px;
            font-size: 0.95rem;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            text-decoration: none;
            transition: all 0.2s ease;
        }
        .btn-new-category:hover {
            background: #2563eb;
            color: white;
            border-color: #2563eb;
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
        .form-group label {
            display: block;
            font-weight: 600;
            font-size: 0.9rem;
            color: #334155;
            margin-bottom: 6px;
        }
        .form-group input, .form-group textarea {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 0.95rem;
            box-sizing: border-box;
            background: #f8fafc;
        }
        .form-group input:focus, .form-group textarea:focus {
            border-color: #3b82f6;
            outline: none;
            background: white;
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

<main style="max-width: 1200px; margin: 35px auto; padding: 0 24px;">

    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
        <div>
            <h1 style="font-size: 1.8rem; font-weight: 700; margin: 0 0 5px 0;">Product Catalog Management</h1>
            <p style="color: #64748b; margin: 0;">Total Products: <strong><%= products != null ? products.size() : 0 %></strong></p>
        </div>
        <div style="display: flex; gap: 12px;">
            <button type="button" onclick="openCategoryModal()" class="btn-new-category">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                + Add Category
            </button>
            <a href="${pageContext.request.contextPath}/admin/add-product" class="btn-action btn-action-primary" style="padding: 10px 20px; font-size: 0.95rem;">
                + Add New Product
            </a>
        </div>
    </div>

    <% String error = request.getParameter("error"); %>
    <% if (error != null && !error.isBlank()) { %>
        <div style="background: #fee2e2; border: 1px solid #ef4444; color: #991b1b; padding: 12px 18px; border-radius: 8px; margin-bottom: 20px;">
            <%= error %>
        </div>
    <% } %>

    <% String success = request.getParameter("success"); %>
    <% if (success != null && !success.isBlank()) { %>
        <div style="background: #dcfce7; border: 1px solid #10b981; color: #166534; padding: 12px 18px; border-radius: 8px; margin-bottom: 20px;">
            <%= success %>
        </div>
    <% } %>

    <% if (products == null || products.isEmpty()) { %>
        <div style="background: white; padding: 50px; text-align: center; border-radius: 12px; border: 1px solid #e2e8f0;">
            <h2 style="color: #64748b; margin-bottom: 15px;">No Products Found</h2>
            <a href="${pageContext.request.contextPath}/admin/add-product" class="btn-action btn-action-primary">
                Add Your First Product
            </a>
        </div>
    <% } else { %>
        <table class="data-table">
            <thead>
                <tr>
                    <th>Image</th>
                    <th>Product Details</th>
                    <th>Category</th>
                    <th>Price</th>
                    <th>Stock</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% for (Product prod : products) { 
                    String catName = (prod.getCategoryId() != null && categoryMap.containsKey(prod.getCategoryId())) 
                                     ? categoryMap.get(prod.getCategoryId()) : "Uncategorized";
                %>
                    <tr>
                        <td style="width: 60px;">
                            <% 
                                String prodImg = prod.getImageUrl();
                                if (prodImg != null && !prodImg.isBlank()) { 
                                    if (!prodImg.startsWith("http://") && !prodImg.startsWith("https://") && !prodImg.startsWith("//")) {
                                        prodImg = request.getContextPath() + "/" + prodImg;
                                    }
                            %>
                                <img src="<%= prodImg %>" alt="<%= prod.getProductName() %>" class="prod-thumb">
                            <% } else { %>
                                <div style="width:48px;height:48px;background:#f1f5f9;border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:10px;color:#94a3b8;">No img</div>
                            <% } %>
                        </td>
                        <td>
                            <strong style="font-size: 0.95rem; color: #0f172a;"><%= prod.getProductName() %></strong>
                            <div style="font-size: 0.8rem; color: #64748b; margin-top: 2px;">
                                Brand: <%= prod.getBrand() != null && !prod.getBrand().isBlank() ? prod.getBrand() : "N/A" %> &bull; ID: #<%= prod.getProductId() %>
                            </div>
                        </td>
                        <td>
                            <span style="font-size: 0.85rem; background: #f1f5f9; padding: 3px 8px; border-radius: 4px; color: #475569;">
                                <%= catName %>
                            </span>
                        </td>
                        <td>
                            <div><strong>₹<%= prod.getPrice() %></strong></div>
                            <% if (prod.getDiscountPrice() != null) { %>
                                <div style="font-size: 0.8rem; color: #10b981;">Disc: ₹<%= prod.getDiscountPrice() %></div>
                            <% } %>
                        </td>
                        <td>
                            <span style="font-weight: 600; color: <%= prod.getStockQuantity() <= 5 ? "#ef4444" : "#0f172a" %>;">
                                <%= prod.getStockQuantity() %>
                            </span>
                        </td>
                        <td>
                            <span class="<%= prod.isActive() ? "badge-active" : "badge-inactive" %>">
                                <%= prod.isActive() ? "Active" : "Hidden" %>
                            </span>
                        </td>
                        <td>
                            <div style="display: flex; gap: 6px; align-items: center;">
                                <a href="${pageContext.request.contextPath}/admin/edit-product?id=<%= prod.getProductId() %>" class="btn-action btn-action-edit">
                                    Edit
                                </a>

                                <!-- Toggle Active Form -->
                                <form action="${pageContext.request.contextPath}/admin/products" method="post" style="display: inline;">
                                    <input type="hidden" name="action" value="toggle">
                                    <input type="hidden" name="productId" value="<%= prod.getProductId() %>">
                                    <input type="hidden" name="active" value="<%= !prod.isActive() %>">
                                    <button type="submit" class="btn-action btn-action-toggle">
                                        <%= prod.isActive() ? "Hide" : "Show" %>
                                    </button>
                                </form>

                                <!-- Delete Form -->
                                <form action="${pageContext.request.contextPath}/admin/products" method="post" style="display: inline;" onsubmit="return confirm('Are you sure you want to delete this product?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="productId" value="<%= prod.getProductId() %>">
                                    <button type="submit" class="btn-action btn-action-delete">
                                        Delete
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    <% } %>

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
                    <p style="margin: 2px 0 0 0; font-size: 0.82rem; color: #64748b;">Create a new category to organize products</p>
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
                <button type="button" class="btn-action btn-action-edit" onclick="closeCategoryModal()" style="padding: 8px 16px;">Cancel</button>
                <button type="submit" id="btnSubmitModalCat" class="btn-action btn-action-primary" style="padding: 8px 18px; font-size: 0.9rem; border: none; cursor: pointer;">
                    Save Category
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

async function handleModalSubmit(event) {
    event.preventDefault();
    const name = document.getElementById('modalCategoryName').value.trim();
    const desc = document.getElementById('modalCategoryDesc').value.trim();
    const active = document.getElementById('modalCategoryActive').checked;
    const btn = document.getElementById('btnSubmitModalCat');
    const alertBox = document.getElementById('modalAlert');

    if (!name) return;

    btn.disabled = true;
    btn.innerHTML = 'Saving...';

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
        if (result.success) {
            window.location.href = contextPath + '/admin/products?success=' + encodeURIComponent("Category '" + name + "' created successfully!");
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
        btn.innerHTML = 'Save Category';
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
