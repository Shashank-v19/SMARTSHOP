<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="com.ecommerce.model.Product" %>
<%@ page import="com.ecommerce.model.Category" %>
<%@ page import="com.ecommerce.dao.ProductDAO" %>
<%@ page import="com.ecommerce.dao.CategoryDAO" %>
<%@ page import="com.ecommerce.dao.CartDAO" %>

<%
    User user = (User) session.getAttribute("user");
    ProductDAO productDAO = new ProductDAO();
    CategoryDAO categoryDAO = new CategoryDAO();
    CartDAO cartDAO = new CartDAO();

    List<Product> products = productDAO.getAllProducts();
    List<Category> categories = categoryDAO.getActiveCategories();

    int cartCount = 0;
    Map<Long, Integer> cartQtyMap = new HashMap<>();
    if (user != null) {
        cartCount = cartDAO.getCartCount(user.getUserId());
        cartQtyMap = cartDAO.getCartQuantityMap(user.getUserId());
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SmartShop - Online Shopping for Electronics, Fashion & More</title>
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
        .hero-banner {
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
            color: white;
            border-radius: var(--radius-lg);
            padding: 50px 40px;
            margin: 30px auto;
            max-width: 1200px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 10px 25px rgba(15, 23, 42, 0.15);
        }
        .hero-content {
            max-width: 600px;
        }
        .hero-content h1 {
            font-size: 2.5rem;
            font-weight: 800;
            line-height: 1.2;
            margin-bottom: 15px;
            color: #f8fafc;
        }
        .hero-content p {
            font-size: 1.1rem;
            color: #94a3b8;
            margin-bottom: 25px;
        }
        .cat-pill {
            display: inline-block;
            padding: 8px 18px;
            background: white;
            border-radius: 25px;
            font-weight: 600;
            font-size: 0.9rem;
            color: #334155;
            border: 1px solid var(--border);
            box-shadow: var(--shadow-sm);
            transition: all 0.2s;
            text-decoration: none;
        }
        .cat-pill:hover {
            background: #2563eb;
            color: white;
            border-color: #2563eb;
        }
    </style>
</head>

<body>

<header class="store-header">
    <a href="${pageContext.request.contextPath}/index.jsp" class="store-logo">SmartShop</a>
    <nav>
        <a href="index.jsp" style="font-weight:600; color:#3b82f6;">Home</a>
        <a href="products">Products</a>
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
                <a href="admin/dashboard" style="color: #3b82f6; font-weight: 600;">Admin Panel</a>
            <% } %>
            <a href="logout">Logout</a>
        <% } %>
    </nav>
</header>

<main style="padding: 0 20px;">

    <!-- Hero Banner -->
    <div class="hero-banner">
        <div class="hero-content">
            <span style="background: rgba(59, 130, 246, 0.2); color: #38bdf8; font-weight: 700; padding: 4px 12px; border-radius: 20px; font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.5px;">
                Mega Store Deals
            </span>
            <h1>Discover Top Quality Products at Best Prices</h1>
            <p>Explore electronics, trendy fashion, footwear, home essentials, and books with instant delivery.</p>
            <div style="display: flex; gap: 15px;">
                <a href="#products-section" class="product-button" style="width: auto; padding: 12px 28px; text-decoration: none;">
                    Explore Products &darr;
                </a>
                <a href="products" class="continue-button" style="text-decoration: none; padding: 12px 24px; background: rgba(255,255,255,0.1); color: white;">
                    Filter & Search
                </a>
            </div>
        </div>
        <div style="font-size: 5rem; opacity: 0.8;">
            🛍️
        </div>
    </div>

    <!-- Category Filter Pills Bar -->
    <% if (categories != null && !categories.isEmpty()) { %>
        <div style="max-width: 1200px; margin: 25px auto; display: flex; gap: 12px; flex-wrap: wrap; justify-content: center;">
            <a href="products" class="cat-pill" style="background:#2563eb; color:white; border-color:#2563eb;">All Categories</a>
            <% for (Category cat : categories) { %>
                <a href="products?category=<%= cat.getCategoryId() %>" class="cat-pill"><%= cat.getCategoryName() %></a>
            <% } %>
        </div>
    <% } %>

    <!-- Featured Products Showcase -->
    <div id="products-section" class="products-container" style="margin-top: 30px;">
        <div class="products-heading">
            <h1>Featured Products</h1>
            <p>Handpicked selections with special discounts for you</p>
        </div>

        <div class="product-grid">
            <%
                if (products != null && !products.isEmpty()) {
                    for (Product product : products) {
                        String imageSrc = product.getImageUrl();
                        if (imageSrc != null && !imageSrc.isBlank() && !imageSrc.startsWith("http")) {
                            imageSrc = request.getContextPath() + "/" + imageSrc;
                        }
                        Integer inCartQty = cartQtyMap.get(product.getProductId());
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
                    <h2>No products found in catalog</h2>
                    <p>Please check back soon.</p>
                </div>
            <%
                }
            %>
        </div>
    </div>

</main>

<footer style="margin-top: 60px; padding: 30px; text-align: center; background: white; border-top: 1px solid var(--border); color: #64748b;">
    <p>&copy; <%= java.time.Year.now() %> SmartShop. All rights reserved.</p>
</footer>

<script src="js/cart.js"></script>

</body>
</html>