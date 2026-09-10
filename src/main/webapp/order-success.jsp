<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="com.ecommerce.dao.CartDAO" %>

<%
    String orderId = (String) request.getAttribute("orderId");
    if (orderId == null) {
        orderId = request.getParameter("id");
    }
    User user = (User) session.getAttribute("user");
    int cartCount = 0;
    if (user != null) {
        CartDAO cartDAO = new CartDAO();
        cartCount = cartDAO.getCartCount(user.getUserId());
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Successful - SmartShop</title>
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
        <a href="cart">
            Cart <% if (cartCount > 0) { %><span class="cart-badge"><%= cartCount %></span><% } %>
        </a>
        <a href="orders">Orders</a>
        <a href="profile">Profile</a>
        <% if (user != null && "ADMIN".equalsIgnoreCase(user.getRole())) { %>
            <a href="admin/dashboard" style="color: #3b82f6; font-weight: 600;">Admin</a>
        <% } %>
        <a href="logout">Logout</a>
    </nav>
</header>

<main class="order-success-container">
    <div class="success-card">
        <div class="success-icon">✓</div>

        <h1>Order Placed Successfully!</h1>
        <p>Thank you for shopping with us.</p>

        <div class="order-number">
            Order ID: <strong>#<%= orderId != null ? orderId : "" %></strong>
        </div>

        <p style="color: #64748b; font-size: 0.95rem; margin-bottom: 25px;">
            Your order has been confirmed and is being processed.
        </p>

        <div class="success-actions">
            <a href="orders" class="product-button" style="width: auto; text-decoration: none; padding: 12px 24px;">
                View My Orders &rarr;
            </a>

            <a href="products" class="continue-button" style="text-decoration: none; padding: 12px 24px;">
                Continue Shopping
            </a>
        </div>
    </div>
</main>

</body>
</html>