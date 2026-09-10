<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="com.ecommerce.model.CartItem" %>
<%@ page import="com.ecommerce.model.User" %>

<%
    List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
    User user = (User) session.getAttribute("user");
    BigDecimal total = BigDecimal.ZERO;
    int cartCount = 0;
    if (cartItems != null) {
        for (CartItem ci : cartItems) cartCount += ci.getQuantity();
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shopping Cart - SmartShop</title>
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
        <a href="cart" style="font-weight:600; color:#3b82f6;">
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

<main class="cart-container">

    <h1>Shopping Cart</h1>

    <% String success = request.getParameter("success"); %>
    <% if (success != null && !success.isBlank()) { %>
        <div class="success-message">
            <%= success %>
        </div>
    <% } %>

    <% String error = request.getParameter("error"); %>
    <% if (error != null && !error.isBlank()) { %>
        <div class="error-message">
            <%= error %>
        </div>
    <% } %>

    <% if (cartItems == null || cartItems.isEmpty()) { %>

        <div class="empty-cart">
            <h2>Your cart is empty</h2>
            <p>Looks like you haven't added anything to your cart yet.</p>
            <br>
            <a href="products" class="product-button" style="display:inline-block; width:auto; text-decoration:none; padding:12px 28px;">
                Explore Products &rarr;
            </a>
        </div>

    <% } else { %>

        <div class="cart-layout">

            <div class="cart-items">
                <% for (CartItem item : cartItems) {
                    BigDecimal itemTotal = item.getProductPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
                    total = total.add(itemTotal);
                %>
                    <div class="cart-item" id="cartItem_<%= item.getCartItemId() %>">
                        <div class="cart-item-image">
                            <% 
                                String itemImg = item.getImageUrl();
                                if (itemImg != null && !itemImg.isBlank()) { 
                                    if (!itemImg.startsWith("http://") && !itemImg.startsWith("https://") && !itemImg.startsWith("//")) {
                                        itemImg = request.getContextPath() + "/" + itemImg;
                                    }
                            %>
                                <img src="<%= itemImg %>" alt="<%= item.getProductName() %>">
                            <% } else { %>
                                <div class="no-image">No Image</div>
                            <% } %>
                        </div>

                        <div class="cart-item-info">
                            <div>
                                <h2><%= item.getProductName() %></h2>
                                <p style="color:#2563eb; font-weight:700; font-size:1.1rem; margin-top:4px;">
                                    &#8377;<%= item.getProductPrice() %>
                                </p>
                            </div>

                            <!-- Automatic quantity change with AJAX (no page refresh) -->
                            <div class="quantity-form" style="margin-top: 10px;">
                                <label style="font-size:0.9rem; color:#475569;">Qty:</label>
                                <div class="cart-quantity">
                                    <button type="button" onclick="updateCartItemQuantity(<%= item.getCartItemId() %>, -1, event)" title="Decrease">−</button>
                                    <input type="number" name="quantity" value="<%= item.getQuantity() %>" min="1" readonly>
                                    <button type="button" onclick="updateCartItemQuantity(<%= item.getCartItemId() %>, 1, event)" title="Increase">+</button>
                                </div>
                            </div>

                            <div style="display:flex; justify-content:space-between; align-items:center; margin-top:12px;">
                                <strong style="font-size:1.05rem; color:#0f172a;">
                                    Subtotal: <span class="item-subtotal-val">&#8377;<%= itemTotal %></span>
                                </strong>

                                <button type="button" class="remove-button" onclick="updateCartItemQuantity(<%= item.getCartItemId() %>, -9999, event)">
                                    Remove
                                </button>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>

            <div class="cart-summary">
                <h2>Order Summary</h2>

                <div class="summary-row">
                    <span>Items Total (<span class="cart-total-count"><%= cartCount %></span> items)</span>
                    <strong class="cart-total-val">&#8377;<%= total %></strong>
                </div>

                <div class="summary-row">
                    <span>Shipping</span>
                    <strong style="color:#10b981;">FREE</strong>
                </div>

                <hr style="border:none; border-top:1px solid var(--border); margin:15px 0;">

                <div class="summary-row total-row">
                    <span>Total Amount</span>
                    <strong class="cart-total-val" style="color:#10b981;">&#8377;<%= total %></strong>
                </div>

                <a href="checkout" class="checkout-button">
                    Proceed to Checkout &rarr;
                </a>

                <a href="products" class="continue-button">
                    Continue Shopping
                </a>
            </div>

        </div>

    <% } %>

</main>

<script src="js/cart.js"></script>

</body>
</html>