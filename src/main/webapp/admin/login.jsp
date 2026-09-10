<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Portal Login - SmartShop</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body style="background: #0f172a; min-height: 100vh; display: flex; align-items: center; justify-content: center; margin: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;">

<div class="auth-container" style="width: 100%; max-width: 440px; padding: 20px;">
    <div class="auth-card" style="background: #1e293b; color: white; border: 1px solid #334155; box-shadow: 0 10px 30px rgba(0,0,0,0.4); border-radius: 16px; padding: 35px 30px;">
        
        <div style="text-align: center; margin-bottom: 25px;">
            <div style="display: inline-flex; align-items: center; justify-content: center; width: 60px; height: 60px; background: rgba(59, 130, 246, 0.15); border: 1px solid rgba(59, 130, 246, 0.3); border-radius: 14px; margin-bottom: 15px;">
                <span style="font-size: 28px;">⚡</span>
            </div>
            <h1 style="font-size: 1.8rem; font-weight: 700; color: #f8fafc; margin: 0 0 8px 0;">Admin Portal</h1>
            <p style="color: #94a3b8; font-size: 0.95rem; margin: 0;">Sign in to access management dashboard</p>
        </div>

        <% String error = request.getParameter("error"); %>
        <% if (error != null && !error.isBlank()) { %>
            <div style="background: rgba(239, 68, 68, 0.15); border: 1px solid #ef4444; color: #fca5a5; padding: 12px 16px; border-radius: 8px; font-size: 0.9rem; margin-bottom: 20px; text-align: center;">
                <%= error %>
            </div>
        <% } %>

        <% String success = request.getParameter("success"); %>
        <% if (success != null && !success.isBlank()) { %>
            <div style="background: rgba(16, 185, 129, 0.15); border: 1px solid #10b981; color: #6ee7b7; padding: 12px 16px; border-radius: 8px; font-size: 0.9rem; margin-bottom: 20px; text-align: center;">
                <%= success %>
            </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/admin/login" method="post">
            <div class="form-group" style="margin-bottom: 18px; text-align: left;">
                <label style="color: #cbd5e1; font-weight: 500; font-size: 0.9rem; margin-bottom: 6px; display: block;">Admin Email</label>
                <input type="email" name="email" placeholder="admin@ecommerce.com" required 
                       style="background: #0f172a; border: 1px solid #334155; color: white; border-radius: 8px; padding: 12px 14px; width: 100%; font-size: 0.95rem;">
            </div>

            <div class="form-group" style="margin-bottom: 24px; text-align: left;">
                <label style="color: #cbd5e1; font-weight: 500; font-size: 0.9rem; margin-bottom: 6px; display: block;">Password</label>
                <input type="password" name="password" placeholder="••••••••" required 
                       style="background: #0f172a; border: 1px solid #334155; color: white; border-radius: 8px; padding: 12px 14px; width: 100%; font-size: 0.95rem;">
            </div>

            <button type="submit" class="btn-primary" style="width: 100%; padding: 13px; font-size: 1rem; font-weight: 600; border-radius: 8px; background: #3b82f6; border: none; cursor: pointer; transition: background 0.2s;">
                Sign In to Dashboard &rarr;
            </button>
        </form>

        <div style="margin-top: 25px; padding-top: 20px; border-top: 1px solid #334155; text-align: center;">
            <a href="${pageContext.request.contextPath}/index.jsp" style="color: #94a3b8; font-size: 0.9rem; text-decoration: none;">
                &larr; Return to Customer Storefront
            </a>
        </div>
    </div>
</div>

</body>
</html>
