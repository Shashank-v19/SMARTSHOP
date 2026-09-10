<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="com.ecommerce.model.Order" %>
<%@ page import="com.ecommerce.model.User" %>

<%
    BigDecimal totalRevenue = (BigDecimal) request.getAttribute("totalRevenue");
    if (totalRevenue == null) totalRevenue = BigDecimal.ZERO;

    Integer totalOrders = (Integer) request.getAttribute("totalOrders");
    if (totalOrders == null) totalOrders = 0;

    Integer totalProducts = (Integer) request.getAttribute("totalProducts");
    if (totalProducts == null) totalProducts = 0;

    Integer totalUsers = (Integer) request.getAttribute("totalUsers");
    if (totalUsers == null) totalUsers = 0;

    List<Order> recentOrders = (List<Order>) request.getAttribute("recentOrders");
    User adminUser = (User) session.getAttribute("user");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - SmartShop</title>
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
            letter-spacing: 0.5px;
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
            transition: color 0.2s;
        }
        .admin-nav-links a:hover, .admin-nav-links a.active {
            color: #38bdf8;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin: 25px 0;
        }
        .stat-card {
            background: white;
            border-radius: 14px;
            padding: 24px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.04);
            border: 1px solid #e2e8f0;
            position: relative;
            overflow: hidden;
        }
        .stat-card h3 {
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #64748b;
            margin: 0 0 10px 0;
        }
        .stat-card .value {
            font-size: 2rem;
            font-weight: 700;
            color: #0f172a;
            margin: 0;
        }
        .stat-card .indicator {
            position: absolute;
            top: 20px;
            right: 20px;
            font-size: 1.5rem;
            opacity: 0.3;
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
            padding: 14px 18px;
            text-align: left;
            border-bottom: 1px solid #f1f5f9;
        }
        .data-table th {
            background: #f8fafc;
            color: #475569;
            font-size: 0.85rem;
            text-transform: uppercase;
            font-weight: 600;
            letter-spacing: 0.5px;
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
            transition: all 0.2s;
            border: none;
        }
        .btn-action-primary { background: #3b82f6; color: white; }
        .btn-action-primary:hover { background: #2563eb; }
    </style>
</head>
<body style="background: #f8fafc; margin: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #1e293b;">

<!-- Admin Navbar -->
<header class="admin-nav">
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="logo">
        SmartShop <span>Admin</span>
    </a>
    <nav class="admin-nav-links">
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="active">Dashboard</a>
        <a href="${pageContext.request.contextPath}/admin/products">Products</a>
        <a href="${pageContext.request.contextPath}/admin/orders">Orders</a>
        <a href="${pageContext.request.contextPath}/admin/users">Users</a>
        <a href="${pageContext.request.contextPath}/index.jsp" target="_blank" style="color:#38bdf8;">View Storefront &nearr;</a>
        <a href="${pageContext.request.contextPath}/logout" style="color:#ef4444;">Logout</a>
    </nav>
</header>

<main style="max-width: 1200px; margin: 35px auto; padding: 0 24px;">

    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
        <div>
            <h1 style="font-size: 1.8rem; font-weight: 700; margin: 0 0 5px 0;">Overview Dashboard</h1>
            <p style="color: #64748b; margin: 0;">Welcome back, <%= adminUser != null ? adminUser.getFirstName() : "Admin" %>!</p>
        </div>
        <div style="display: flex; gap: 12px;">
            <a href="${pageContext.request.contextPath}/admin/add-product" class="btn-action btn-action-primary" style="padding: 10px 18px; font-size: 0.95rem;">
                + Add New Product
            </a>
        </div>
    </div>

    <!-- Stats Cards -->
    <div class="stats-grid">
        <div class="stat-card">
            <h3>Total Revenue</h3>
            <p class="value" style="color: #10b981;">₹<%= totalRevenue %></p>
            <div class="indicator">💰</div>
        </div>

        <div class="stat-card">
            <h3>Total Orders</h3>
            <p class="value"><%= totalOrders %></p>
            <div class="indicator">📦</div>
        </div>

        <div class="stat-card">
            <h3>Products In Catalog</h3>
            <p class="value"><%= totalProducts %></p>
            <div class="indicator">🏷️</div>
        </div>

        <div class="stat-card">
            <h3>Registered Users</h3>
            <p class="value"><%= totalUsers %></p>
            <div class="indicator">👥</div>
        </div>
    </div>

    <!-- Quick Management Sections -->
    <div style="margin-top: 35px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
            <h2 style="font-size: 1.3rem; font-weight: 600; margin: 0;">Recent Customer Orders</h2>
            <a href="${pageContext.request.contextPath}/admin/orders" style="color: #3b82f6; text-decoration: none; font-weight: 500; font-size: 0.9rem;">
                View All Orders &rarr;
            </a>
        </div>

        <% if (recentOrders == null || recentOrders.isEmpty()) { %>
            <div style="background: white; padding: 40px; text-align: center; border-radius: 12px; border: 1px solid #e2e8f0; color: #64748b;">
                <p style="font-size: 1.1rem; margin: 0;">No orders placed yet.</p>
            </div>
        <% } else { %>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>User ID</th>
                        <th>Date</th>
                        <th>Amount</th>
                        <th>Order Status</th>
                        <th>Payment Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Order order : recentOrders) { 
                        String statusClass = "badge-" + (order.getOrderStatus() != null ? order.getOrderStatus().toLowerCase() : "pending");
                    %>
                        <tr>
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
                                    Manage
                                </a>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } %>
    </div>

</main>

</body>
</html>
