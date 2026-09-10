package com.ecommerce.controller;

import java.io.IOException;

import com.ecommerce.dao.UserDAO;
import com.ecommerce.model.User;
import com.ecommerce.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/login", "/admin/login"})
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String uri = request.getRequestURI();
        if (uri.endsWith("/admin/login")) {
            response.sendRedirect(request.getContextPath() + "/admin/login.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String uri = request.getRequestURI();
        boolean isAdminLogin = uri.endsWith("/admin/login");

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String errorRedirect = isAdminLogin ? (request.getContextPath() + "/admin/login.jsp?error=") : (request.getContextPath() + "/login.jsp?error=");

        if (email == null || password == null || email.isBlank() || password.isBlank()) {
            response.sendRedirect(errorRedirect + "Please enter email and password");
            return;
        }

        User user = userDAO.findByEmail(email.trim());

        if (user == null) {
            response.sendRedirect(errorRedirect + "Invalid email or password");
            return;
        }

        if (!user.isActive()) {
            response.sendRedirect(errorRedirect + "Your account is inactive");
            return;
        }

        boolean passwordValid = PasswordUtil.verifyPassword(password, user.getPasswordHash());

        if (!passwordValid) {
            response.sendRedirect(errorRedirect + "Invalid email or password");
            return;
        }

        // If trying to log in via admin portal, must have ADMIN role
        if (isAdminLogin && !"ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(errorRedirect + "Access denied. Only administrators can log in here.");
            return;
        }

        // Create session
        HttpSession session = request.getSession(true);
        session.setAttribute("user", user);
        session.setAttribute("userId", user.getUserId());
        session.setAttribute("role", user.getRole());

        // Prevent session fixation
        request.changeSessionId();

        if ("ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        } else {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
        }
    }
}