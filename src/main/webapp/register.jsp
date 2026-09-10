<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Create Account - SmartShop</title>

    <link rel="stylesheet"
          href="css/style.css">

</head>

<body>

<div class="auth-container">

    <div class="auth-card">

        <h1>Create Account</h1>

        <p class="auth-subtitle">
            Join us and start shopping
        </p>


        <% String error = request.getParameter("error"); %>

        <% if (error != null) { %>

            <div class="error-message">
                <%= error %>
            </div>

        <% } %>


        <form action="register"
              method="post">

            <div class="form-row">

                <div class="form-group">

                    <label>
                        First Name
                    </label>

                    <input
                        type="text"
                        name="firstName"
                        placeholder="Enter first name"
                        required>

                </div>


                <div class="form-group">

                    <label>
                        Last Name
                    </label>

                    <input
                        type="text"
                        name="lastName"
                        placeholder="Enter last name"
                        required>

                </div>

            </div>


            <div class="form-group">

                <label>
                    Email
                </label>

                <input
                    type="email"
                    name="email"
                    placeholder="Enter email"
                    required>

            </div>


            <div class="form-group">

                <label>
                    Phone
                </label>

                <input
                    type="tel"
                    name="phone"
                    placeholder="Enter phone number"
                    required>

            </div>


            <div class="form-group">

                <label>
                    Password
                </label>

                <input
                    type="password"
                    name="password"
                    placeholder="Create password"
                    required>

            </div>


            <button
                type="submit"
                class="btn-primary">

                Create Account

            </button>

        </form>


        <p class="auth-footer">

            Already have an account?

            <a href="login.jsp">
                Login
            </a>

        </p>

    </div>

</div>

</body>

</html>