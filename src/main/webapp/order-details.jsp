<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.ecommerce.model.Order" %>
<%@ page import="com.ecommerce.model.OrderItem" %>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="com.ecommerce.dao.CartDAO" %>
<%@ page import="java.util.List" %>

<%
    Order order = (Order) request.getAttribute("order");
    List<OrderItem> orderItems = (List<OrderItem>) request.getAttribute("orderItems");
    User user = (User) session.getAttribute("user");

    if (order == null) {
        response.sendRedirect("orders");
        return;
    }

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
    <title>Order Details #<%= order.getOrderId() %> - SmartShop</title>
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
    <h1>Order Details</h1>

    <%
        String cancelled = request.getParameter("cancelled");
        String error = request.getParameter("error");

        if ("true".equals(cancelled)) {
    %>
        <div class="success-message">
            ✓ Order cancelled successfully. Your product stock has been restored.
        </div>
    <%
        }
        if ("cancel".equals(error)) {
    %>
        <div class="error-message">
            This order cannot be cancelled.
        </div>
    <%
        }
    %>

    <!-- ORDER HEADER -->
    <div class="order-card">
        <div class="order-header">
            <div>
                <h2>Order #<%= order.getOrderId() %></h2>
                <p>Order Date: <%= order.getOrderDate() %></p>
            </div>
            <div class="order-amount">
                &#8377;<%= order.getTotalAmount() %>
            </div>
        </div>

        <!-- ORDER STATUS -->
        <div class="order-info">
            <div>
                <span>Order Status</span>
                <strong style="color: #2563eb;"><%= order.getOrderStatus() %></strong>
            </div>

            <div>
                <span>Payment Status</span>
                <strong style="color: #10b981;"><%= order.getPaymentStatus() %></strong>
            </div>

            <div>
                <span>Order ID</span>
                <strong>#<%= order.getOrderId() %></strong>
            </div>
        </div>
    </div>

    <!-- ORDER ITEMS -->
    <div class="order-card">
        <h2 style="margin-bottom: 15px;">Ordered Products</h2>

        <%
            if (orderItems != null && !orderItems.isEmpty()) {
                for (OrderItem item : orderItems) {
        %>
            <div class="checkout-item">
                <div>
                    <strong><%= item.getProductName() %></strong>
                    <p style="color: #64748b; font-size: 0.85rem;">Quantity: <%= item.getQuantity() %></p>
                    <p style="color: #64748b; font-size: 0.85rem;">Unit Price: &#8377;<%= item.getUnitPrice() %></p>
                </div>
                <strong>&#8377;<%= item.getSubtotal() %></strong>
            </div>
        <%
                }
            } else {
        %>
            <p>No items found for this order.</p>
        <%
            }
        %>

        <div class="checkout-total">
            <span>Total</span>
            <strong style="color: #10b981;">&#8377;<%= order.getTotalAmount() %></strong>
        </div>
    </div>

    <!-- ACTIONS -->
    <div class="success-actions">
        <a href="orders" class="continue-button" style="text-decoration: none;">
            &larr; Back to My Orders
        </a>

        <a href="products" class="continue-button" style="text-decoration: none;">
            Continue Shopping
        </a>

        <%
            String orderStatus = order.getOrderStatus();
            boolean canCancel = "PENDING".equals(orderStatus)
                    || "CONFIRMED".equals(orderStatus)
                    || "PROCESSING".equals(orderStatus);

            if (canCancel) {
        %>
            <form action="order-details" method="post" onsubmit="return confirmCancelOrder();" style="display:inline;">
                <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">
                <button type="submit" class="cancel-order-button">
                    Cancel Order
                </button>
            </form>
        <%
            }
        %>
    </div>
</main>

<script src="js/script.js"></script>
</body>
</html>