<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.ecommerce.model.User" %>

<%
    List<User> users = (List<User>) request.getAttribute("users");
    User loggedInUser = (User) session.getAttribute("user");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users - Admin Portal</title>
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
        .btn-action-toggle { background: #f1f5f9; color: #334155; border: 1px solid #cbd5e1; }
        .btn-action-danger { background: #fee2e2; color: #991b1b; }
        .badge-admin { background: #fae8ff; color: #86198f; padding: 4px 8px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-customer { background: #eff6ff; color: #1d4ed8; padding: 4px 8px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-active { background: #dcfce7; color: #166534; padding: 4px 8px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-inactive { background: #fee2e2; color: #991b1b; padding: 4px 8px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
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
        <a href="${pageContext.request.contextPath}/admin/orders">Orders</a>
        <a href="${pageContext.request.contextPath}/admin/users" class="active">Users</a>
        <a href="${pageContext.request.contextPath}/index.jsp" target="_blank" style="color:#38bdf8;">Storefront &nearr;</a>
        <a href="${pageContext.request.contextPath}/logout" style="color:#ef4444;">Logout</a>
    </nav>
</header>

<main style="max-width: 1200px; margin: 35px auto; padding: 0 24px;">

    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
        <div>
            <h1 style="font-size: 1.8rem; font-weight: 700; margin: 0 0 5px 0;">User Account Management</h1>
            <p style="color: #64748b; margin: 0;">Total Registered Accounts: <strong><%= users != null ? users.size() : 0 %></strong></p>
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

    <% if (users == null || users.isEmpty()) { %>
        <div style="background: white; padding: 50px; text-align: center; border-radius: 12px; border: 1px solid #e2e8f0; color: #64748b;">
            <h2>No Users Found</h2>
        </div>
    <% } else { %>
        <table class="data-table">
            <thead>
                <tr>
                    <th>User ID</th>
                    <th>Full Name</th>
                    <th>Email Address</th>
                    <th>Phone</th>
                    <th>Role</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% for (User u : users) { 
                    boolean isSelf = loggedInUser != null && loggedInUser.getUserId().equals(u.getUserId());
                %>
                    <tr>
                        <td><strong>#<%= u.getUserId() %></strong></td>
                        <td>
                            <strong><%= u.getFirstName() %> <%= u.getLastName() %></strong>
                            <% if (isSelf) { %>
                                <span style="font-size: 0.75rem; background: #e0e7ff; color: #3730a3; padding: 2px 6px; border-radius: 4px; margin-left: 4px;">You</span>
                            <% } %>
                        </td>
                        <td><%= u.getEmail() %></td>
                        <td><%= u.getPhone() != null && !u.getPhone().isBlank() ? u.getPhone() : "N/A" %></td>
                        <td>
                            <span class="<%= "ADMIN".equalsIgnoreCase(u.getRole()) ? "badge-admin" : "badge-customer" %>">
                                <%= u.getRole() %>
                            </span>
                        </td>
                        <td>
                            <span class="<%= u.isActive() ? "badge-active" : "badge-inactive" %>">
                                <%= u.isActive() ? "Active" : "Inactive" %>
                            </span>
                        </td>
                        <td>
                            <div style="display: flex; gap: 8px; align-items: center;">
                                <!-- Role Toggle Form -->
                                <% if (!isSelf) { %>
                                    <form action="${pageContext.request.contextPath}/admin/users" method="post" style="display: inline;">
                                        <input type="hidden" name="action" value="updateRole">
                                        <input type="hidden" name="userId" value="<%= u.getUserId() %>">
                                        <input type="hidden" name="role" value="<%= "ADMIN".equalsIgnoreCase(u.getRole()) ? "CUSTOMER" : "ADMIN" %>">
                                        <button type="submit" class="btn-action btn-action-toggle">
                                            <%= "ADMIN".equalsIgnoreCase(u.getRole()) ? "Make Customer" : "Make Admin" %>
                                        </button>
                                    </form>

                                    <!-- Status Toggle Form -->
                                    <form action="${pageContext.request.contextPath}/admin/users" method="post" style="display: inline;">
                                        <input type="hidden" name="action" value="toggleStatus">
                                        <input type="hidden" name="userId" value="<%= u.getUserId() %>">
                                        <input type="hidden" name="active" value="<%= !u.isActive() %>">
                                        <button type="submit" class="btn-action <%= u.isActive() ? "btn-action-danger" : "btn-action-toggle" %>">
                                            <%= u.isActive() ? "Deactivate" : "Activate" %>
                                        </button>
                                    </form>
                                <% } else { %>
                                    <span style="color: #94a3b8; font-size: 0.85rem; font-style: italic;">Current session</span>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    <% } %>

</main>

</body>
</html>
