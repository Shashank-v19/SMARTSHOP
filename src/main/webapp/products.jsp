<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.ecommerce.model.Product" %>
<%@ page import="com.ecommerce.model.Category" %>
<%@ page import="com.ecommerce.model.User" %>

<%
    List<Product> products = (List<Product>) request.getAttribute("products");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    Long selectedCategory = (Long) request.getAttribute("selectedCategory");
    String keyword = (String) request.getAttribute("keyword");
    String minPrice = (String) request.getAttribute("minPrice");
    String maxPrice = (String) request.getAttribute("maxPrice");
    String inStock = (String) request.getAttribute("inStock");
    String sortBy = (String) request.getAttribute("sortBy");

    Map<Long, Integer> cartQtyMap = (Map<Long, Integer>) request.getAttribute("cartQtyMap");
    Integer cartCountObj = (Integer) request.getAttribute("cartCount");
    int cartCount = (cartCountObj != null) ? cartCountObj : 0;

    User user = (User) session.getAttribute("user");
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Products - SmartShop</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .cart-badge {
            background: #ef4444;
            color: white;
            font-size: 0.75rem;
            font-weight: 700;
            padding: 2px 7px;
            border-radius: 12px;
            margin-left: 4px;
        }
        .filter-section {
            background: white;
            border-radius: var(--radius-md);
            padding: 20px 24px;
            border: 1px solid var(--border);
            margin-bottom: 30px;
            box-shadow: var(--shadow-sm);
        }
        .filter-form {
            display: grid;
            grid-template-columns: 2fr 1.5fr 1fr 1fr auto auto;
            gap: 15px;
            align-items: flex-end;
        }
        @media (max-width: 900px) {
            .filter-form {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>

<header class="store-header">
    <a href="${pageContext.request.contextPath}/index.jsp" class="store-logo">SmartShop</a>
    <nav>
        <a href="index.jsp">Home</a>
        <a href="products" style="font-weight:600; color:#3b82f6;">Products</a>
        <% if (user == null) { %>
            <a href="login.jsp">Login</a>
            <a href="register.jsp">Register</a>
        <% } else { %>
            <a href="cart">
                Cart <% if (cartCount > 0) { %><span class="cart-badge"><%= cartCount %></span><% } %>
            </a>
            <a href="orders">Orders</a>
            <a href="profile">Profile</a>
            <% if ("ADMIN".equalsIgnoreCase(user.getRole())) { %>
                <a href="admin/dashboard" style="color: #3b82f6; font-weight: 600;">Admin</a>
            <% } %>
            <a href="logout">Logout</a>
        <% } %>
    </nav>
</header>

<main class="products-container">

    <div class="products-heading">
        <h1>Explore Products</h1>
        <p>Find the best electronics, fashion, footwear, home essentials, and books</p>
    </div>

    <!-- Filter & Search Form -->
    <div class="filter-section">
        <form action="products" method="get" class="filter-form">
            <!-- Search Keyword -->
            <div class="form-group" style="margin: 0;">
                <label>Search Keyword</label>
                <input type="text" name="q" value="<%= keyword != null ? keyword : "" %>" placeholder="Search by name, brand, keyword...">
            </div>

            <!-- Category Filter -->
            <div class="form-group" style="margin: 0;">
                <label>Category</label>
                <select name="category">
                    <option value="">All Categories</option>
                    <% if (categories != null) {
                        for (Category cat : categories) {
                            boolean isSel = selectedCategory != null && selectedCategory.equals(cat.getCategoryId());
                    %>
                        <option value="<%= cat.getCategoryId() %>" <%= isSel ? "selected" : "" %>>
                            <%= cat.getCategoryName() %>
                        </option>
                    <%  } 
                       } %>
                </select>
            </div>

            <!-- Price Range -->
            <div class="form-group" style="margin: 0;">
                <label>Min Price (&#8377;)</label>
                <input type="number" name="minPrice" value="<%= minPrice != null ? minPrice : "" %>" placeholder="0">
            </div>

            <div class="form-group" style="margin: 0;">
                <label>Max Price (&#8377;)</label>
                <input type="number" name="maxPrice" value="<%= maxPrice != null ? maxPrice : "" %>" placeholder="10000">
            </div>

            <!-- Sort By -->
            <div class="form-group" style="margin: 0;">
                <label>Sort By</label>
                <select name="sortBy">
                    <option value="newest" <%= "newest".equalsIgnoreCase(sortBy) ? "selected" : "" %>>Newest First</option>
                    <option value="price_asc" <%= "price_asc".equalsIgnoreCase(sortBy) ? "selected" : "" %>>Price: Low to High</option>
                    <option value="price_desc" <%= "price_desc".equalsIgnoreCase(sortBy) ? "selected" : "" %>>Price: High to Low</option>
                    <option value="name_asc" <%= "name_asc".equalsIgnoreCase(sortBy) ? "selected" : "" %>>Name: A to Z</option>
                </select>
            </div>

            <!-- Action Buttons -->
            <div style="display: flex; gap: 8px;">
                <button type="submit" class="product-button" style="padding: 11px 18px; width: auto;">
                    Filter
                </button>
                <a href="products" class="continue-button" style="padding: 11px 16px; text-decoration: none;">
                    Reset
                </a>
            </div>
        </form>
    </div>

    <!-- Products Grid -->
    <div class="product-grid">
        <%
            if (products != null && !products.isEmpty()) {
                for (Product product : products) {
                    String imageSrc = product.getImageUrl();
                    if (imageSrc != null && !imageSrc.isBlank() && !imageSrc.startsWith("http")) {
                        imageSrc = request.getContextPath() + "/" + imageSrc;
                    }
                    Integer inCartQty = (cartQtyMap != null) ? cartQtyMap.get(product.getProductId()) : null;
                    int itemCartCount = (inCartQty != null) ? inCartQty : 0;
        %>
            <div class="product-card">
                <div class="product-image">
                    <% if (imageSrc != null && !imageSrc.isBlank()) { %>
                        <img src="<%= imageSrc %>" alt="<%= product.getProductName() %>">
                    <% } else { %>
                        <div class="no-image">No Image</div>
                    <% } %>
                </div>

                <div class="product-info">
                    <% if (product.getBrand() != null && !product.getBrand().isBlank()) { %>
                        <span class="product-brand"><%= product.getBrand() %></span>
                    <% } %>

                    <h2><%= product.getProductName() %></h2>

                    <p class="product-description">
                        <%= product.getDescription() != null ? product.getDescription() : "" %>
                    </p>

                    <div class="product-price">
                        <% if (product.getDiscountPrice() != null) { %>
                            <span class="discount-price">&#8377;<%= product.getDiscountPrice() %></span>
                            <span class="original-price">&#8377;<%= product.getPrice() %></span>
                        <% } else { %>
                            <span class="discount-price">&#8377;<%= product.getPrice() %></span>
                        <% } %>
                    </div>

                    <div class="stock">
                        Stock: <%= product.getStockQuantity() %> units
                    </div>

                    <!-- Card Action Buttons -->
                    <div style="display: flex; gap: 8px; align-items: center; margin-top: auto;">
                        <!-- Small View Details Button -->
                        <a href="product-details?id=<%= product.getProductId() %>" class="btn-view-details">
                            View Details
                        </a>

                        <!-- AJAX Auto-Updating Add / - number items + Button -->
                        <% if (product.getStockQuantity() > 0) { %>
                            <div data-product-widget="<%= product.getProductId() %>" style="flex: 1;">
                                <% if (itemCartCount > 0) { %>
                                    <div class="cart-stepper-control">
                                        <button type="button" class="stepper-btn" onclick="updateCart(<%= product.getProductId() %>, 'decrease', 1, event)" title="Decrease">−</button>
                                        <span class="stepper-count"><%= itemCartCount %></span>
                                        <button type="button" class="stepper-btn" onclick="updateCart(<%= product.getProductId() %>, 'add', 1, event)" title="Increase">+</button>
                                    </div>
                                <% } else { %>
                                    <button type="button" class="btn-add-primary" onclick="updateCart(<%= product.getProductId() %>, 'add', 1, event)">
                                        Add
                                    </button>
                                <% } %>
                            </div>
                        <% } else { %>
                            <span style="flex: 1; text-align: center; color: #ef4444; font-size: 0.8rem; font-weight: 700; padding: 7px 0; background: #fee2e2; border-radius: var(--radius-sm);">
                                Out of Stock
                            </span>
                        <% } %>
                    </div>
                </div>
            </div>
        <%
                }
            } else {
        %>
            <div class="empty-products">
                <h2>No matching products found</h2>
                <p>Try adjusting your search query or price filters.</p>
                <br>
                <a href="products" class="product-button" style="display: inline-block; width: auto; text-decoration: none; padding: 10px 24px;">
                    Clear All Filters
                </a>
            </div>
        <%
            }
        %>
    </div>
</main>

<script src="js/cart.js"></script>

</body>
</html>