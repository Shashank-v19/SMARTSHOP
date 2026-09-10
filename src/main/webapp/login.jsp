<%@ page import="com.ecommerce.model.User" %>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Login - SmartShop</title>

    <link rel="stylesheet"
          href="css/style.css">

</head>

<body>

<div class="auth-container">

    <div class="auth-card">

        <h1>Welcome Back</h1>

        <p class="auth-subtitle">
            Login to continue shopping
        </p>


        <% String error = request.getParameter("error"); %>

        <% if (error != null) { %>

            <div class="error-message">
                <%= error %>
            </div>

        <% } %>


        <% String success = request.getParameter("success"); %>

        <% if (success != null) { %>

            <div class="success-message">
                <%= success %>
            </div>

        <% } %>


        <form action="login" method="post">

            <div class="form-group">

                <label>Email</label>

                <input
                    type="email"
                    name="email"
                    placeholder="Enter your email"
                    required>

            </div>


            <div class="form-group">

                <label>Password</label>

                <input
                    type="password"
                    name="password"
                    placeholder="Enter your password"
                    required>

            </div>


            <button
                type="submit"
                class="btn-primary">

                Login

            </button>

        </form>


        <p class="auth-footer">

            Don't have an account?

            <a href="register.jsp">
                Create Account
            </a>

        </p>

    </div>

</div>

</body>

</html>