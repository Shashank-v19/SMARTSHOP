<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.ecommerce.model.Order" %>
<%@ page import="com.ecommerce.model.OrderItem" %>
<%@ page import="com.ecommerce.model.User" %>

<%
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    Order selectedOrder = (Order) request.getAttribute("selectedOrder");
    List<OrderItem> orderItems = (List<OrderItem>) request.getAttribute("orderItems");
    User customer = (User) request.getAttribute("customer");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Orders - Admin Portal</title>
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
        .status-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
        }
        .badge-pending { background: #fef3c7; color: #92400e; }
        .badge-confirmed { background: #e0e7ff; color: #3730a3; }
        .badge-processing { background: #dbeafe; color: #1e40af; }
        .badge-shipped { background: #fae8ff; color: #86198f; }
        .badge-delivered { background: #dcfce7; color: #166534; }
        .badge-cancelled { background: #fee2e2; color: #991b1b; }
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
    </style>
</head>
<body style="background: #f8fafc; margin: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #1e293b;">

<header class="admin-nav">
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="logo">
        SmartShop <span>Admin</span>
    </a>
    <nav class="admin-nav-links">
        <a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a>
        <a href="${pageContext.request.contextPath}/admin/products">Products</a>
        <a href="${pageContext.request.contextPath}/admin/orders" class="active">Orders</a>
        <a href="${pageContext.request.contextPath}/admin/users">Users</a>
        <a href="${pageContext.request.contextPath}/index.jsp" target="_blank" style="color:#38bdf8;">Storefront &nearr;</a>
        <a href="${pageContext.request.contextPath}/logout" style="color:#ef4444;">Logout</a>
    </nav>
</header>

<main style="max-width: 1200px; margin: 35px auto; padding: 0 24px;">

    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
        <div>
            <h1 style="font-size: 1.8rem; font-weight: 700; margin: 0 0 5px 0;">Customer Order Management</h1>
            <p style="color: #64748b; margin: 0;">Total Orders in System: <strong><%= orders != null ? orders.size() : 0 %></strong></p>
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

    <!-- Selected Order Detail & Status Update Panel -->
    <% if (selectedOrder != null) { %>
        <div style="background: white; border: 2px solid #3b82f6; border-radius: 14px; padding: 25px; margin-bottom: 30px; box-shadow: 0 4px 20px rgba(59, 130, 246, 0.1);">
            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e2e8f0; padding-bottom: 15px; margin-bottom: 20px;">
                <div>
                    <h2 style="margin: 0; font-size: 1.3rem;">Order Details: #<%= selectedOrder.getOrderId() %></h2>
                    <p style="color: #64748b; margin: 4px 0 0 0; font-size: 0.9rem;">Placed on: <%= selectedOrder.getOrderDate() %> by <%= customer != null ? customer.getFirstName() + " " + customer.getLastName() + " (" + customer.getEmail() + ")" : "User #" + selectedOrder.getUserId() %></p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/orders" style="color: #64748b; text-decoration: none; font-size: 1.2rem; font-weight: bold;">&times; Close</a>
            </div>

            <!-- Ordered Items Breakdown -->
            <div style="margin-bottom: 20px;">
                <h3 style="font-size: 1rem; color: #475569; margin-bottom: 10px;">Ordered Items</h3>
                <div style="background: #f8fafc; border-radius: 8px; padding: 12px 16px; border: 1px solid #e2e8f0;">
                    <% if (orderItems != null && !orderItems.isEmpty()) { 
                        for (OrderItem item : orderItems) { %>
                            <div style="display: flex; justify-content: space-between; padding: 6px 0; border-bottom: 1px solid #f1f5f9;">
                                <span><strong><%= item.getProductName() %></strong> &times; <%= item.getQuantity() %> (₹<%= item.getUnitPrice() %> each)</span>
                                <strong>₹<%= item.getSubtotal() %></strong>
                            </div>
                    <%  } 
                       } %>
                    <div style="display: flex; justify-content: space-between; margin-top: 10px; padding-top: 10px; border-top: 2px solid #cbd5e1; font-size: 1.1rem;">
                        <strong>Grand Total</strong>
                        <strong style="color: #10b981;">₹<%= selectedOrder.getTotalAmount() %></strong>
                    </div>
                </div>
            </div>

            <!-- Status Update Form -->
            <form action="${pageContext.request.contextPath}/admin/orders" method="post" style="display: flex; gap: 20px; align-items: flex-end; background: #f1f5f9; padding: 18px; border-radius: 10px;">
                <input type="hidden" name="action" value="updateStatus">
                <input type="hidden" name="orderId" value="<%= selectedOrder.getOrderId() %>">

                <div style="flex: 1;">
                    <label style="display: block; font-weight: 600; font-size: 0.85rem; color: #334155; margin-bottom: 6px;">Update Order Status</label>
                    <select name="orderStatus" style="width: 100%; padding: 8px 12px; border-radius: 6px; border: 1px solid #cbd5e1; background: white;">
                        <option value="PENDING" <%= "PENDING".equalsIgnoreCase(selectedOrder.getOrderStatus()) ? "selected" : "" %>>PENDING</option>
                        <option value="CONFIRMED" <%= "CONFIRMED".equalsIgnoreCase(selectedOrder.getOrderStatus()) ? "selected" : "" %>>CONFIRMED</option>
                        <option value="PROCESSING" <%= "PROCESSING".equalsIgnoreCase(selectedOrder.getOrderStatus()) ? "selected" : "" %>>PROCESSING</option>
                        <option value="SHIPPED" <%= "SHIPPED".equalsIgnoreCase(selectedOrder.getOrderStatus()) ? "selected" : "" %>>SHIPPED</option>
                        <option value="DELIVERED" <%= "DELIVERED".equalsIgnoreCase(selectedOrder.getOrderStatus()) ? "selected" : "" %>>DELIVERED</option>
                        <option value="CANCELLED" <%= "CANCELLED".equalsIgnoreCase(selectedOrder.getOrderStatus()) ? "selected" : "" %>>CANCELLED</option>
                    </select>
                </div>

                <div style="flex: 1;">
                    <label style="display: block; font-weight: 600; font-size: 0.85rem; color: #334155; margin-bottom: 6px;">Update Payment Status</label>
                    <select name="paymentStatus" style="width: 100%; padding: 8px 12px; border-radius: 6px; border: 1px solid #cbd5e1; background: white;">
                        <option value="PENDING" <%= "PENDING".equalsIgnoreCase(selectedOrder.getPaymentStatus()) ? "selected" : "" %>>PENDING</option>
                        <option value="PAID" <%= "PAID".equalsIgnoreCase(selectedOrder.getPaymentStatus()) || "COMPLETED".equalsIgnoreCase(selectedOrder.getPaymentStatus()) ? "selected" : "" %>>PAID</option>
                        <option value="FAILED" <%= "FAILED".equalsIgnoreCase(selectedOrder.getPaymentStatus()) ? "selected" : "" %>>FAILED</option>
                        <option value="REFUNDED" <%= "REFUNDED".equalsIgnoreCase(selectedOrder.getPaymentStatus()) ? "selected" : "" %>>REFUNDED</option>
                    </select>
                </div>

                <button type="submit" class="btn-action btn-action-primary" style="padding: 10px 20px;">
                    Update Status
                </button>
            </form>
        </div>
    <% } %>

    <!-- Orders Master Table -->
    <% if (orders == null || orders.isEmpty()) { %>
        <div style="background: white; padding: 50px; text-align: center; border-radius: 12px; border: 1px solid #e2e8f0; color: #64748b;">
            <h2>No Orders Recorded</h2>
            <p>Customer orders will appear here once placed.</p>
        </div>
    <% } else { %>
        <table class="data-table">
            <thead>
                <tr>
                    <th>Order #</th>
                    <th>User ID</th>
                    <th>Date</th>
                    <th>Total</th>
                    <th>Order Status</th>
                    <th>Payment Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <% for (Order order : orders) { 
                    String statusClass = "badge-" + (order.getOrderStatus() != null ? order.getOrderStatus().toLowerCase() : "pending");
                    boolean isSelected = selectedOrder != null && selectedOrder.getOrderId().equals(order.getOrderId());
                %>
                    <tr style="<%= isSelected ? "background: #eff6ff;" : "" %>">
                        <td><strong>#<%= order.getOrderId() %></strong></td>
                        <td>User #<%= order.getUserId() %></td>
                        <td><%= order.getOrderDate() %></td>
                        <td><strong>₹<%= order.getTotalAmount() %></strong></td>
                        <td>
                            <span class="status-badge <%= statusClass %>">
                                <%= order.getOrderStatus() %>
                            </span>
                        </td>
                        <td>
                            <span style="font-size: 0.85rem; font-weight: 500; color: <%= "PAID".equalsIgnoreCase(order.getPaymentStatus()) || "COMPLETED".equalsIgnoreCase(order.getPaymentStatus()) ? "#166534" : "#b45309" %>;">
                                <%= order.getPaymentStatus() %>
                            </span>
                        </td>
                        <td>
                            <a href="${pageContext.request.contextPath}/admin/orders?id=<%= order.getOrderId() %>" class="btn-action btn-action-primary">
                                View / Update &rarr;
                            </a>
                        </td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    <% } %>

</main>

</body>
</html>
