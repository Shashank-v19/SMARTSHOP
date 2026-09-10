package com.ecommerce.controller;

import com.ecommerce.dao.UserDAO;
import com.ecommerce.model.User;
import com.ecommerce.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();


    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String firstName =
                request.getParameter("firstName");

        String lastName =
                request.getParameter("lastName");

        String email =
                request.getParameter("email");

        String phone =
                request.getParameter("phone");

        String password =
                request.getParameter("password");

        // Basic validation
        if (firstName == null ||
                lastName == null ||
                email == null ||
                phone == null ||
                password == null ||
                firstName.isBlank() ||
                lastName.isBlank() ||
                email.isBlank() ||
                phone.isBlank() ||
                password.isBlank()) {

            response.sendRedirect(
                    "register.jsp?error=Please fill all fields"
            );

            return;
        }


        // Check duplicate email
        if (userDAO.emailExists(email)) {

            response.sendRedirect(
                    "register.jsp?error=Email already registered"
            );

            return;
        }


        // Hash password
        String passwordHash =
                PasswordUtil.hashPassword(password);


        // Create User object
        User user = new User(
                firstName,
                lastName,
                email,
                phone,
                passwordHash
        );


        // Save user
        boolean registered =
                userDAO.registerUser(user);


        if (registered) {

            response.sendRedirect(
                    "login.jsp?success=Registration successful"
            );

        } else {

            response.sendRedirect(
                    "register.jsp?error=Registration failed"
            );
        }
    }
}