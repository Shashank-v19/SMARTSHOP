<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="com.ecommerce.model.Order" %>
<%@ page import="com.ecommerce.model.Address" %>
<%@ page import="com.ecommerce.dao.CartDAO" %>

<%
    User profileUser = (User) request.getAttribute("profileUser");
    if (profileUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    List<Address> addresses = (List<Address>) request.getAttribute("addresses");

    int cartCount = 0;
    CartDAO cartDAO = new CartDAO();
    cartCount = cartDAO.getCartCount(profileUser.getUserId());
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - SmartShop</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .profile-container {
            max-width: 1100px;
            margin: 40px auto;
            padding: 0 20px;
        }
        .profile-grid {
            display: grid;
            grid-template-columns: 1fr 1.4fr;
            gap: 30px;
            align-items: start;
        }
        @media (max-width: 850px) {
            .profile-grid {
                grid-template-columns: 1fr;
            }
        }
        .profile-card {
            background: #ffffff;
            border-radius: var(--radius-lg);
            padding: 30px;
            border: 1px solid var(--border);
            box-shadow: var(--shadow-sm);
            margin-bottom: 25px;
        }
        .profile-avatar {
            width: 70px;
            height: 70px;
            border-radius: 50%;
            background: #eff6ff;
            color: #2563eb;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
            font-weight: 800;
            margin-bottom: 15px;
        }
        .cart-badge {
            background: #ef4444;
            color: white;
            font-size: 0.75rem;
            font-weight: 700;
            padding: 2px 7px;
            border-radius: 12px;
            margin-left: 4px;
        }
        .saved-addr-card {
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            padding: 14px 16px;
            margin-bottom: 12px;
            background: #f8fafc;
            transition: all 0.2s;
        }
        .saved-addr-card:hover {
            border-color: #cbd5e1;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.04);
        }
        .btn-delete-addr {
            background: transparent;
            border: 1px solid transparent;
            cursor: pointer;
            font-size: 1.05rem;
            padding: 4px 8px;
            border-radius: 6px;
            transition: all 0.15s ease-in-out;
            color: #64748b;
        }
        .btn-delete-addr:hover {
            background: #fee2e2;
            border-color: #fca5a5;
            color: #ef4444;
            transform: scale(1.05);
        }
        @keyframes modalPop {
            from { opacity: 0; transform: scale(0.95); }
            to { opacity: 1; transform: scale(1); }
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
        <a href="profile" style="font-weight: 600; color: #3b82f6;">Profile</a>
        <% if ("ADMIN".equalsIgnoreCase(profileUser.getRole())) { %>
            <a href="admin/dashboard" style="color: #3b82f6; font-weight: 600;">Admin</a>
        <% } %>
        <a href="logout">Logout</a>
    </nav>
</header>

<main class="profile-container">

    <% String success = request.getParameter("success"); %>
    <% if (success != null && !success.isBlank()) { %>
        <div class="success-message"><%= success %></div>
    <% } %>

    <% String error = request.getParameter("error"); %>
    <% if (error != null && !error.isBlank()) { %>
        <div class="error-message"><%= error %></div>
    <% } %>

    <div class="profile-grid">
        
        <!-- Left Column: Personal Information & Saved Addresses -->
        <div>
            <div class="profile-card">
                <div class="profile-avatar">
                    <%= profileUser.getFirstName() != null ? profileUser.getFirstName().substring(0, 1).toUpperCase() : "U" %>
                </div>
                <h1 style="font-size: 1.6rem; margin-bottom: 4px;"><%= profileUser.getFirstName() %> <%= profileUser.getLastName() %></h1>
                <p style="color: #64748b; font-size: 0.95rem; margin-bottom: 20px;"><%= profileUser.getEmail() %></p>

                <h2 style="font-size: 1.15rem; margin-bottom: 15px; border-top: 1px solid var(--border); padding-top: 15px;">Edit Personal Info</h2>
                
                <form action="profile" method="post">
                    <div class="form-row">
                        <div class="form-group">
                            <label>First Name</label>
                            <input type="text" name="firstName" value="<%= profileUser.getFirstName() %>" required>
                        </div>
                        <div class="form-group">
                            <label>Last Name</label>
                            <input type="text" name="lastName" value="<%= profileUser.getLastName() %>" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Phone Number</label>
                        <input type="tel" name="phone" value="<%= profileUser.getPhone() != null ? profileUser.getPhone() : "" %>" pattern="[0-9]{10}" maxlength="10" required>
                    </div>

                    <div class="form-group">
                        <label>Account Role</label>
                        <input type="text" value="<%= profileUser.getRole() %>" disabled style="background: #f1f5f9; color: #64748b;">
                    </div>

                    <button type="submit" class="product-button" style="width: auto; padding: 10px 24px;">
                        Save Changes
                    </button>
                </form>
            </div>

            <!-- Saved Delivery Addresses Card with Delete Option -->
            <div class="profile-card">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                    <h2 style="font-size: 1.25rem; margin: 0;">Saved Delivery Addresses</h2>
                    <button type="button" onclick="document.getElementById('addAddressForm').style.display = document.getElementById('addAddressForm').style.display === 'none' ? 'block' : 'none'" class="continue-button" style="padding: 6px 14px; font-size: 0.85rem; cursor: pointer;">
                        + Add Address
                    </button>
                </div>

                <!-- Add New Address Form (Hidden by default) -->
                <div id="addAddressForm" style="display: none; background: #f8fafc; padding: 18px; border-radius: var(--radius-sm); border: 1px solid var(--border); margin-bottom: 20px;">
                    <h3 style="font-size: 1rem; margin-bottom: 12px;">Add New Delivery Address</h3>
                    <form action="profile" method="post">
                        <input type="hidden" name="action" value="addAddress">
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label>Recipient Name</label>
                                <input type="text" name="fullName" required>
                            </div>
                            <div class="form-group">
                                <label>Phone Number</label>
                                <input type="tel" name="phone" pattern="[0-9]{10}" maxlength="10" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Address Line 1</label>
                            <input type="text" name="addressLine1" placeholder="House no, Street" required>
                        </div>

                        <div class="form-group">
                            <label>Address Line 2 (Optional)</label>
                            <input type="text" name="addressLine2" placeholder="Area, Landmark">
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label>City</label>
                                <input type="text" name="city" required>
                            </div>
                            <div class="form-group">
                                <label>State</label>
                                <input type="text" name="state" required>
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label>PIN Code</label>
                                <input type="text" name="postalCode" pattern="[0-9]{6}" maxlength="6" required>
                            </div>
                            <div class="form-group">
                                <label>Address Type</label>
                                <select name="addressType">
                                    <option value="HOME">HOME</option>
                                    <option value="WORK">WORK</option>
                                    <option value="OTHER">OTHER</option>
                                </select>
                            </div>
                        </div>

                        <button type="submit" class="product-button" style="width: auto; padding: 8px 20px;">
                            Save Address
                        </button>
                    </form>
                </div>

                <!-- Existing Addresses List with Delete Button -->
                <% if (addresses == null || addresses.isEmpty()) { %>
                    <p style="color: #64748b; font-size: 0.9rem;">No addresses saved yet. Addresses saved during checkout or added above will appear here.</p>
                <% } else { %>
                    <% for (Address addr : addresses) { %>
                        <div class="saved-addr-card">
                            <div style="display: flex; justify-content: space-between; align-items: center;">
                                <div>
                                    <strong><%= addr.getFullName() %> (<%= addr.getPhone() %>)</strong>
                                    <span style="background: #e2e8f0; color: #334155; font-size: 0.72rem; padding: 2px 6px; border-radius: 4px; font-weight: 700; margin-left: 6px;">
                                        <%= addr.getAddressType() %>
                                    </span>
                                </div>

                                <!-- Delete Symbol Button -->
                                <button type="button" class="btn-delete-addr" onclick="confirmDeleteAddress(<%= addr.getAddressId() %>, '<%= addr.getFullName().replace("'", "\\'") %>')" title="Delete this address">
                                    🗑️
                                </button>
                            </div>
                            <p style="color: #475569; font-size: 0.88rem; margin-top: 6px;">
                                <%= addr.getAddressLine1() %><% if (addr.getAddressLine2() != null && !addr.getAddressLine2().isBlank()) { %>, <%= addr.getAddressLine2() %><% } %>,
                                <%= addr.getCity() %>, <%= addr.getState() %> - <%= addr.getPostalCode() %>
                            </p>
                        </div>
                    <% } %>
                <% } %>
            </div>
        </div>

        <!-- Right Column: Order History -->
        <div class="profile-card">
            <h2 style="font-size: 1.35rem; margin-bottom: 20px;">Recent Orders</h2>
            
            <% if (orders == null || orders.isEmpty()) { %>
                <p style="color: #64748b; font-size: 0.95rem;">You haven't placed any orders yet.</p>
                <br>
                <a href="products" class="product-button" style="display: inline-block; width: auto; text-decoration: none; padding: 10px 24px;">
                    Start Shopping &rarr;
                </a>
            <% } else { %>
                <div style="display: flex; flex-direction: column; gap: 15px;">
                    <% for (Order ord : orders) { %>
                        <div style="border: 1px solid var(--border); border-radius: var(--radius-sm); padding: 16px; display: flex; justify-content: space-between; align-items: center;">
                            <div>
                                <strong style="font-size: 1.05rem;">Order #<%= ord.getOrderId() %></strong>
                                <div style="color: #64748b; font-size: 0.85rem; margin-top: 2px;">
                                    Date: <%= ord.getOrderDate() %>
                                </div>
                                <div style="margin-top: 6px;">
                                    <span style="font-size: 0.82rem; font-weight: 700; color: #2563eb;"><%= ord.getOrderStatus() %></span>
                                    <span style="color: #94a3b8; margin: 0 4px;">•</span>
                                    <span style="font-size: 0.82rem; font-weight: 700; color: #10b981;">&#8377;<%= ord.getTotalAmount() %></span>
                                </div>
                            </div>
                            <a href="order-details?id=<%= ord.getOrderId() %>" class="continue-button" style="text-decoration: none; font-size: 0.85rem; padding: 8px 14px;">
                                Details &rarr;
                            </a>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </div>

    </div>

</main>

<!-- Delete Address Confirmation Modal -->
<div id="deleteModal" style="display: none; position: fixed; inset: 0; background: rgba(15, 23, 42, 0.6); z-index: 9999; align-items: center; justify-content: center; backdrop-filter: blur(2px);">
    <div style="background: white; border-radius: var(--radius-lg); padding: 28px; max-width: 440px; width: 90%; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.2); text-align: center; animation: modalPop 0.2s ease-out;">
        <div style="width: 54px; height: 54px; background: #fee2e2; color: #ef4444; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.6rem; margin: 0 auto 16px auto;">
            🗑️
        </div>
        <h3 style="font-size: 1.25rem; font-weight: 700; margin-bottom: 8px; color: #0f172a;">Delete Delivery Address?</h3>
        <p style="color: #64748b; font-size: 0.92rem; margin-bottom: 24px; line-height: 1.4;" id="deleteModalText">
            Are you sure you want to delete this address? This action cannot be undone.
        </p>

        <form action="profile" method="post" id="deleteAddressForm" style="display: flex; gap: 12px; justify-content: center;">
            <input type="hidden" name="action" value="deleteAddress">
            <input type="hidden" name="addressId" id="modalAddressId" value="">
            
            <button type="button" onclick="closeDeleteModal()" style="flex: 1; padding: 11px 18px; border-radius: var(--radius-sm); border: 1px solid var(--border); background: #f8fafc; color: #475569; font-weight: 600; font-size: 0.9rem; cursor: pointer;">
                Cancel / Return Back
            </button>
            <button type="submit" style="flex: 1; padding: 11px 18px; border-radius: var(--radius-sm); border: none; background: #ef4444; color: white; font-weight: 700; font-size: 0.9rem; cursor: pointer;">
                Yes, Delete
            </button>
        </form>
    </div>
</div>

<script>
function confirmDeleteAddress(addressId, recipientName) {
    document.getElementById('modalAddressId').value = addressId;
    document.getElementById('deleteModalText').textContent = 
        'Are you sure you want to delete the delivery address for "' + recipientName + '"? This action cannot be undone.';
    document.getElementById('deleteModal').style.display = 'flex';
}

function closeDeleteModal() {
    document.getElementById('deleteModal').style.display = 'none';
}

// Close modal if clicked outside
document.getElementById('deleteModal').addEventListener('click', function(e) {
    if (e.target === this) {
        closeDeleteModal();
    }
});
</script>

<script src="js/cart.js"></script>

</body>
</html>
