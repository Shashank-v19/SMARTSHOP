<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.ecommerce.model.Product" %>
<%@ page import="com.ecommerce.model.Review" %>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="com.ecommerce.dao.CartDAO" %>

<%
    Product product = (Product) request.getAttribute("product");
    if (product == null) {
        response.sendRedirect("products");
        return;
    }

    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
    Double avgRatingObj = (Double) request.getAttribute("avgRating");
    double avgRating = (avgRatingObj != null) ? avgRatingObj : 0.0;
    User user = (User) session.getAttribute("user");

    int cartCount = 0;
    int productInCartQty = 0;
    if (user != null) {
        CartDAO cartDAO = new CartDAO();
        cartCount = cartDAO.getCartCount(user.getUserId());
        Map<Long, Integer> qtyMap = cartDAO.getCartQuantityMap(user.getUserId());
        if (qtyMap != null && qtyMap.containsKey(product.getProductId())) {
            productInCartQty = qtyMap.get(product.getProductId());
        }
    }

    String imageSrc = product.getImageUrl();
    if (imageSrc != null && !imageSrc.isBlank() && !imageSrc.startsWith("http")) {
        imageSrc = request.getContextPath() + "/" + imageSrc;
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= product.getProductName() %> - SmartShop</title>
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
    </style>
</head>

<body>

<header class="store-header">
    <a href="${pageContext.request.contextPath}/index.jsp" class="store-logo">SmartShop</a>
    <nav>
        <a href="index.jsp">Home</a>
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
                <a href="admin/dashboard" style="color: #3b82f6; font-weight: 600;">Admin</a>
            <% } %>
            <a href="logout">Logout</a>
        <% } %>
    </nav>
</header>

<main class="product-details-container">

    <% String success = request.getParameter("success"); %>
    <% if (success != null && !success.isBlank()) { %>
        <div class="success-message"><%= success %></div>
    <% } %>

    <% String error = request.getParameter("error"); %>
    <% if (error != null && !error.isBlank()) { %>
        <div class="error-message"><%= error %></div>
    <% } %>

    <div class="product-details-card">

        <!-- PRODUCT IMAGE -->
        <div class="product-details-image">
            <% if (imageSrc != null && !imageSrc.isBlank()) { %>
                <img src="<%= imageSrc %>" alt="<%= product.getProductName() %>">
            <% } else { %>
                <div class="no-image">No Image</div>
            <% } %>
        </div>

        <!-- PRODUCT INFORMATION -->
        <div class="product-details-info">

            <% if (product.getBrand() != null && !product.getBrand().isBlank()) { %>
                <span class="product-brand"><%= product.getBrand() %></span>
            <% } %>

            <h1><%= product.getProductName() %></h1>

            <!-- Ratings Summary -->
            <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 12px;">
                <span style="color: #f59e0b; font-size: 1.1rem; font-weight: bold;">
                    <%= String.format("%.1f", avgRating) %> ★
                </span>
                <span style="color: #64748b; font-size: 0.9rem;">
                    (<%= reviews != null ? reviews.size() : 0 %> verified customer reviews)
                </span>
            </div>

            <p class="product-description-large">
                <%= product.getDescription() != null ? product.getDescription() : "No description available." %>
            </p>

            <!-- PRICE -->
            <div class="details-price">
                <% if (product.getDiscountPrice() != null) { %>
                    <span class="details-discount-price">&#8377;<%= product.getDiscountPrice() %></span>
                    <span class="details-original-price">&#8377;<%= product.getPrice() %></span>
                <% } else { %>
                    <span class="details-discount-price">&#8377;<%= product.getPrice() %></span>
                <% } %>
            </div>

            <!-- STOCK -->
            <div class="details-stock">
                <% if (product.getStockQuantity() > 0) { %>
                    <span class="in-stock">✓ In Stock</span>
                    <span>(<%= product.getStockQuantity() %> available)</span>
                <% } else { %>
                    <span class="out-stock">Out of Stock</span>
                <% } %>
            </div>

            <!-- COMPACT ADD / - NUMBER ITEMS + BUTTON & BESIDE GOTO CART BUTTON -->
            <% if (product.getStockQuantity() > 0) { %>
                <div style="display: flex; gap: 12px; align-items: center; margin-bottom: 20px; flex-wrap: wrap;">
                    <!-- Reduced size Add / Stepper container -->
                    <div class="details-action-box" data-product-widget="<%= product.getProductId() %>">
                        <% if (productInCartQty > 0) { %>
                            <div class="cart-stepper-control">
                                <button type="button" class="stepper-btn" onclick="updateCart(<%= product.getProductId() %>, 'decrease', 1, event)" title="Decrease">−</button>
                                <span class="stepper-count"><%= productInCartQty %></span>
                                <button type="button" class="stepper-btn" onclick="updateCart(<%= product.getProductId() %>, 'add', 1, event)" title="Increase">+</button>
                            </div>
                        <% } else { %>
                            <button type="button" class="btn-add-primary" onclick="updateCart(<%= product.getProductId() %>, 'add', 1, event)">
                                Add
                            </button>
                        <% } %>
                    </div>

                    <!-- Go to Cart Button beside it -->
                    <a href="cart" class="btn-goto-cart">
                        🛒 Go to Cart
                    </a>
                </div>
            <% } else { %>
                <button class="add-cart-button disabled" disabled style="max-width: 200px; margin-bottom: 20px;">
                    Out of Stock
                </button>
            <% } %>

            <a href="products" class="back-products">
                &larr; Continue Shopping
            </a>
        </div>
    </div>

    <!-- Customer Reviews Section -->
    <div style="background: white; border-radius: var(--radius-lg); padding: 30px; margin-top: 35px; border: 1px solid var(--border); box-shadow: var(--shadow-sm);">
        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border); padding-bottom: 15px; margin-bottom: 25px;">
            <div>
                <h2 style="font-size: 1.4rem; font-weight: 700; margin: 0;">Customer Reviews</h2>
                <p style="color: #64748b; font-size: 0.9rem; margin: 4px 0 0 0;">Average Rating: <strong><%= String.format("%.1f", avgRating) %>/5</strong></p>
            </div>
        </div>

        <!-- Write Review Form -->
        <% if (user != null) { %>
            <div style="background: #f8fafc; border-radius: var(--radius-md); padding: 20px; border: 1px solid var(--border); margin-bottom: 30px;">
                <h3 style="font-size: 1.1rem; font-weight: 600; margin-bottom: 12px;">Leave a Review</h3>
                <form action="review" method="post">
                    <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                    
                    <div style="display: flex; gap: 20px; align-items: center; margin-bottom: 15px;">
                        <label style="font-weight: 600; font-size: 0.9rem;">Rating:</label>
                        <select name="rating" style="width: auto; padding: 6px 12px; border-radius: 6px; border: 1px solid #cbd5e1; background: white;">
                            <option value="5">★★★★★ (5 - Excellent)</option>
                            <option value="4">★★★★☆ (4 - Good)</option>
                            <option value="3">★★★☆☆ (3 - Average)</option>
                            <option value="2">★★☆☆☆ (2 - Poor)</option>
                            <option value="1">★☆☆☆☆ (1 - Terrible)</option>
                        </select>
                    </div>

                    <div style="margin-bottom: 15px;">
                        <textarea name="comment" rows="3" placeholder="Share your experience with this product..." style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 6px;"></textarea>
                    </div>

                    <button type="submit" class="product-button" style="width: auto; padding: 8px 22px;">
                        Submit Review
                    </button>
                </form>
            </div>
        <% } else { %>
            <div style="background: #f1f5f9; padding: 15px; border-radius: var(--radius-sm); margin-bottom: 25px; text-align: center; color: #475569;">
                <a href="login.jsp" style="color: var(--primary); font-weight: 600;">Sign in</a> to leave your rating and review.
            </div>
        <% } %>

        <!-- Reviews List -->
        <% if (reviews == null || reviews.isEmpty()) { %>
            <p style="color: #64748b; font-style: italic; text-align: center; padding: 20px 0;">No reviews yet. Be the first to review this product!</p>
        <% } else { %>
            <div style="display: flex; flex-direction: column; gap: 18px;">
                <% for (Review rev : reviews) { %>
                    <div style="border-bottom: 1px solid #f1f5f9; padding-bottom: 15px;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                            <strong><%= rev.getUserName() != null ? rev.getUserName() : "Verified Customer" %></strong>
                            <span style="color: #f59e0b; font-weight: bold;"><%= "★".repeat(rev.getRating()) + "☆".repeat(5 - rev.getRating()) %></span>
                        </div>
                        <% if (rev.getComment() != null && !rev.getComment().isBlank()) { %>
                            <p style="color: #475569; font-size: 0.95rem; margin: 0;"><%= rev.getComment() %></p>
                        <% } %>
                        <div style="font-size: 0.8rem; color: #94a3b8; margin-top: 4px;">
                            <%= rev.getCreatedAt() != null ? rev.getCreatedAt().toLocalDate() : "" %>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>
    </div>

</main>

<script src="js/cart.js"></script>

</body>
</html>