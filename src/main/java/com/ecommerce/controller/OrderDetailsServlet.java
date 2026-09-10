package com.ecommerce.controller;

import java.io.IOException;
import java.util.List;

import com.ecommerce.dao.OrderDAO;
import com.ecommerce.model.Order;
import com.ecommerce.model.OrderItem;
import com.ecommerce.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/order-details")
public class OrderDetailsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Check login
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please login first");
            return;
        }

        User user = (User) session.getAttribute("user");
        String idParameter = request.getParameter("id");

        // Check order ID
        if (idParameter == null || idParameter.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/orders");
            return;
        }

        try {
            long orderId = Long.parseLong(idParameter);

            // Get order belonging to logged-in user
            Order order = orderDAO.getOrderByIdForUser(orderId, user.getUserId());

            // Order doesn't exist or doesn't belong to user
            if (order == null) {
                response.sendRedirect(request.getContextPath() + "/orders");
                return;
            }

            // Get order items
            List<OrderItem> orderItems = orderDAO.getOrderItems(orderId);

            request.setAttribute("order", order);
            request.setAttribute("orderItems", orderItems);

            request.getRequestDispatcher("/order-details.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/orders");
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please login first");
            return;
        }

        User user = (User) session.getAttribute("user");
        String orderIdParameter = request.getParameter("orderId");

        if (orderIdParameter == null || orderIdParameter.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/orders");
            return;
        }

        try {
            long orderId = Long.parseLong(orderIdParameter);
            boolean cancelled = orderDAO.cancelOrder(orderId, user.getUserId());

            if (cancelled) {
                response.sendRedirect(request.getContextPath() + "/order-details?id=" + orderId + "&cancelled=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/order-details?id=" + orderId + "&error=cancel");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/orders");
        }
    }
}