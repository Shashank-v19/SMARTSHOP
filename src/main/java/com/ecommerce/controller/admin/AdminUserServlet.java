package com.ecommerce.controller.admin;

import java.io.IOException;
import java.util.List;

import com.ecommerce.dao.UserDAO;
import com.ecommerce.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/users")
public class AdminUserServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<User> users = userDAO.getAllUsers();
        request.setAttribute("users", users);

        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("user");

        if ("toggleStatus".equalsIgnoreCase(action)) {
            try {
                long targetUserId = Long.parseLong(request.getParameter("userId"));
                boolean active = Boolean.parseBoolean(request.getParameter("active"));

                // Prevent self-deactivation
                if (currentUser != null && currentUser.getUserId() == targetUserId && !active) {
                    response.sendRedirect(request.getContextPath() + "/admin/users?error=You cannot deactivate your own admin account");
                    return;
                }

                boolean updated = userDAO.updateUserStatus(targetUserId, active);
                if (updated) {
                    response.sendRedirect(request.getContextPath() + "/admin/users?success=User status updated");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/users?error=Failed to update user status");
                }
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/admin/users?error=Invalid user ID");
            }
            return;
        }

        if ("updateRole".equalsIgnoreCase(action)) {
            try {
                long targetUserId = Long.parseLong(request.getParameter("userId"));
                String role = request.getParameter("role");

                if (role == null || (!role.equalsIgnoreCase("ADMIN") && !role.equalsIgnoreCase("CUSTOMER"))) {
                    response.sendRedirect(request.getContextPath() + "/admin/users?error=Invalid role");
                    return;
                }

                // Prevent self-demotion from ADMIN
                if (currentUser != null && currentUser.getUserId() == targetUserId && "CUSTOMER".equalsIgnoreCase(role)) {
                    response.sendRedirect(request.getContextPath() + "/admin/users?error=You cannot remove your own admin role");
                    return;
                }

                boolean updated = userDAO.updateUserRole(targetUserId, role.toUpperCase());
                if (updated) {
                    response.sendRedirect(request.getContextPath() + "/admin/users?success=User role updated successfully");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/users?error=Failed to update role");
                }
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/admin/users?error=Failed to update role");
            }
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
}
