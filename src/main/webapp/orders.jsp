<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.ecommerce.model.Order" %>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="com.ecommerce.dao.CartDAO" %>

<%
    List<Order> orders = (List<Order>) request.getAttribute("orders");
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
    <title>My Orders - SmartShop</title>
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
        <a href="orders" style="font-weight:600; color:#3b82f6;">Orders</a>
        <a href="profile">Profile</a>
        <% if (user != null && "ADMIN".equalsIgnoreCase(user.getRole())) { %>
            <a href="admin/dashboard" style="color: #3b82f6; font-weight: 600;">Admin</a>
        <% } %>
        <a href="logout">Logout</a>
    </nav>
</header>

<main class="orders-container">

    <h1>My Orders</h1>

    <% if (orders == null || orders.isEmpty()) { %>
        <div class="empty-orders">
            <h2>No Orders Yet</h2>
            <p>You haven't placed any orders yet.</p>
            <br>
            <a href="products" class="product-button" style="display:inline-block; width:auto; text-decoration:none; padding:12px 28px;">
                Start Shopping &rarr;
            </a>
        </div>
    <% } else { %>
        <div class="orders-list">
            <% for (Order order : orders) { %>
                <div class="order-card">
                    <div class="order-header">
                        <div>
                            <h2>Order #<%= order.getOrderId() %></h2>
                            <p>Date: <%= order.getOrderDate() %></p>
                        </div>
                        <div class="order-amount">
                            &#8377;<%= order.getTotalAmount() %>
                        </div>
                    </div>

                    <div class="order-info">
                        <div>
                            <span>Order Status</span>
                            <strong style="color: #2563eb;"><%= order.getOrderStatus() %></strong>
                        </div>
                        <div>
                            <span>Payment Status</span>
                            <strong style="color: #10b981;"><%= order.getPaymentStatus() %></strong>
                        </div>
                    </div>

                    <div class="order-actions" style="margin-top: 15px;">
                        <a href="order-details?id=<%= order.getOrderId() %>" class="product-button" style="display:inline-block; width:auto; text-decoration:none; padding:8px 20px;">
                            View Details &rarr;
                        </a>
                    </div>
                </div>
            <% } %>
        </div>
    <% } %>

</main>

</body>
</html>