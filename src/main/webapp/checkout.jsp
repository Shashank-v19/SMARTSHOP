<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="com.ecommerce.model.CartItem" %>
<%@ page import="com.ecommerce.model.Address" %>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="com.ecommerce.dao.CartDAO" %>

<%
    List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
    BigDecimal total = (BigDecimal) request.getAttribute("total");
    List<Address> userAddresses = (List<Address>) request.getAttribute("userAddresses");
    String error = request.getParameter("error");
    User user = (User) session.getAttribute("user");

    if (total == null) {
        total = BigDecimal.ZERO;
    }

    int cartCount = 0;
    if (user != null) {
        CartDAO cartDAO = new CartDAO();
        cartCount = cartDAO.getCartCount(user.getUserId());
    }

    boolean hasSavedAddresses = (userAddresses != null && !userAddresses.isEmpty());
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout - SmartShop</title>
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
        .address-card-option {
            border: 2px solid var(--border);
            border-radius: var(--radius-md);
            padding: 16px;
            margin-bottom: 12px;
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            gap: 12px;
            align-items: flex-start;
        }
        .address-card-option:hover {
            border-color: #93c5fd;
        }
        .address-card-option.selected {
            border-color: var(--primary);
            background: var(--primary-light);
        }
        .address-type-tag {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 4px;
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            background: #e2e8f0;
            color: #334155;
            margin-left: 8px;
        }
        .default-tag {
            background: #dcfce7;
            color: #166534;
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

<main class="checkout-container">

    <h1>Checkout</h1>

    <% if (error != null && !error.isBlank()) { %>
        <div class="error-message">
            <%= error %>
        </div>
    <% } %>

    <% if (cartItems == null || cartItems.isEmpty()) { %>
        <div class="empty-cart">
            <h2>Your cart is empty</h2>
            <p>Please add a product before going to checkout.</p>
            <br>
            <a href="products" class="product-button" style="display:inline-block; width:auto; text-decoration:none; padding:12px 28px;">
                Continue Shopping
            </a>
        </div>
    <% } else { %>

        <form action="orders" method="post" id="checkoutForm">
            <div class="checkout-layout">
                
                <section class="checkout-card">
                    <h2>Delivery Address</h2>

                    <% if (hasSavedAddresses) { %>
                        <div style="margin-bottom: 20px;">
                            <label style="font-weight: 600; color: #475569; display: block; margin-bottom: 10px;">
                                Choose from your Profile Saved Addresses:
                            </label>

                            <% for (int i = 0; i < userAddresses.size(); i++) {
                                Address addr = userAddresses.get(i);
                                boolean isFirst = (i == 0);
                            %>
                                <label class="address-card-option <%= isFirst ? "selected" : "" %>" onclick="toggleAddressSelect('saved', this)">
                                    <input type="radio" name="selectedAddressId" value="<%= addr.getAddressId() %>" <%= isFirst ? "checked" : "" %> style="margin-top: 4px;">
                                    <div style="flex: 1;">
                                        <div style="display: flex; align-items: center; justify-content: space-between;">
                                            <strong><%= addr.getFullName() %> (<%= addr.getPhone() %>)</strong>
                                            <div>
                                                <span class="address-type-tag"><%= addr.getAddressType() %></span>
                                                <% if (addr.isDefault()) { %>
                                                    <span class="address-type-tag default-tag">Default</span>
                                                <% } %>
                                            </div>
                                        </div>
                                        <p style="color: #475569; font-size: 0.9rem; margin-top: 4px;">
                                            <%= addr.getAddressLine1() %><% if (addr.getAddressLine2() != null && !addr.getAddressLine2().isBlank()) { %>, <%= addr.getAddressLine2() %><% } %>,
                                            <%= addr.getCity() %>, <%= addr.getState() %> - <%= addr.getPostalCode() %>, <%= addr.getCountry() %>
                                        </p>
                                    </div>
                                </label>
                            <% } %>

                            <label class="address-card-option" onclick="toggleAddressSelect('new', this)">
                                <input type="radio" name="selectedAddressId" value="new" style="margin-top: 4px;">
                                <div>
                                    <strong>+ Deliver to a Different / New Address</strong>
                                    <p style="color: #64748b; font-size: 0.88rem;">Enter a new shipping address below</p>
                                </div>
                            </label>
                        </div>
                    <% } %>

                    <!-- New Address Form Fields -->
                    <div id="newAddressSection" style="<%= hasSavedAddresses ? "display: none;" : "display: block;" %>">
                        <div class="form-row">
                            <div class="form-group">
                                <label for="fullName">Full Name</label>
                                <input id="fullName" type="text" name="fullName" placeholder="Receiver's name" <%= hasSavedAddresses ? "" : "required" %>>
                            </div>
                            <div class="form-group">
                                <label for="phone">Phone Number</label>
                                <input id="phone" type="tel" name="phone" pattern="[0-9]{10}" maxlength="10" placeholder="10-digit mobile number" <%= hasSavedAddresses ? "" : "required" %>>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="addressLine1">Address Line 1 (Flat, House No, Building, Street)</label>
                            <input id="addressLine1" type="text" name="addressLine1" placeholder="Address line 1" <%= hasSavedAddresses ? "" : "required" %>>
                        </div>

                        <div class="form-group">
                            <label for="addressLine2">Address Line 2 (Area, Landmark - Optional)</label>
                            <input id="addressLine2" type="text" name="addressLine2" placeholder="Address line 2">
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="city">City</label>
                                <input id="city" type="text" name="city" placeholder="City" <%= hasSavedAddresses ? "" : "required" %>>
                            </div>
                            <div class="form-group">
                                <label for="state">State</label>
                                <input id="state" type="text" name="state" placeholder="State" <%= hasSavedAddresses ? "" : "required" %>>
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="postalCode">Postal Code (PIN)</label>
                                <input id="postalCode" type="text" name="postalCode" pattern="[0-9]{6}" maxlength="6" placeholder="6-digit PIN" <%= hasSavedAddresses ? "" : "required" %>>
                            </div>
                            <div class="form-group">
                                <label for="country">Country</label>
                                <input id="country" type="text" name="country" value="India" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="addressType">Address Type</label>
                            <select id="addressType" name="addressType">
                                <option value="HOME">HOME (All Day Delivery)</option>
                                <option value="WORK">WORK (Delivery between 10 AM - 5 PM)</option>
                                <option value="OTHER">OTHER</option>
                            </select>
                        </div>

                        <label class="checkbox-label" style="display: flex; align-items: center; gap: 8px; margin-top: 10px; cursor: pointer;">
                            <input type="checkbox" name="isDefault" checked>
                            Save this address to my profile for future orders
                        </label>
                    </div>
                </section>

                <section class="checkout-card">
                    <h2>Order Summary</h2>

                    <%
                        for (CartItem item : cartItems) {
                            BigDecimal productPrice = item.getProductPrice() != null ? item.getProductPrice() : BigDecimal.ZERO;
                            BigDecimal itemTotal = productPrice.multiply(BigDecimal.valueOf(item.getQuantity()));
                    %>
                        <div class="checkout-item">
                            <div>
                                <strong><%= item.getProductName() %></strong>
                                <p style="color: #64748b; font-size: 0.85rem; margin-top: 2px;">Qty: <%= item.getQuantity() %></p>
                            </div>
                            <strong>&#8377;<%= itemTotal %></strong>
                        </div>
                    <% } %>

                    <hr style="border: none; border-top: 1px solid var(--border); margin: 15px 0;">

                    <div class="checkout-total">
                        <span>Total Payable</span>
                        <strong style="color: #10b981;">&#8377;<%= total %></strong>
                    </div>

                    <h2 class="payment-title">Payment Method</h2>
                    <div class="payment-options">
                        <label>
                            <input type="radio" name="paymentMethod" value="COD" checked>
                            💵 Cash on Delivery
                        </label>
                        <label>
                            <input type="radio" name="paymentMethod" value="UPI">
                            📱 UPI (Google Pay / PhonePe / Paytm)
                        </label>
                        <label>
                            <input type="radio" name="paymentMethod" value="CARD">
                            💳 Credit / Debit Card
                        </label>
                    </div>

                    <button type="submit" class="place-order-button">
                        Place Order &rarr;
                    </button>
                </section>
            </div>
        </form>

    <% } %>

</main>

<script>
function toggleAddressSelect(type, elem) {
    document.querySelectorAll('.address-card-option').forEach(el => el.classList.remove('selected'));
    if (elem) elem.classList.add('selected');

    const newSection = document.getElementById('newAddressSection');
    const newInputs = newSection.querySelectorAll('input[type="text"], input[type="tel"]');

    if (type === 'new') {
        newSection.style.display = 'block';
        newInputs.forEach(inp => {
            if (inp.id !== 'addressLine2') inp.required = true;
        });
    } else {
        newSection.style.display = 'none';
        newInputs.forEach(inp => inp.required = false);
    }
}
</script>

</body>
</html>