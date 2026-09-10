package com.ecommerce.controller.admin;

import java.io.IOException;
import java.util.List;

import com.ecommerce.dao.OrderDAO;
import com.ecommerce.dao.UserDAO;
import com.ecommerce.model.Order;
import com.ecommerce.model.OrderItem;
import com.ecommerce.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/orders")
public class AdminOrderServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");

        if (idStr != null && !idStr.isBlank()) {
            try {
                long orderId = Long.parseLong(idStr);
                Order order = orderDAO.getOrderById(orderId);
                if (order != null) {
                    List<OrderItem> items = orderDAO.getOrderItems(orderId);
                    User customer = userDAO.findById(order.getUserId());
                    request.setAttribute("selectedOrder", order);
                    request.setAttribute("orderItems", items);
                    request.setAttribute("customer", customer);
                }
            } catch (NumberFormatException e) {
                // Ignore and show all
            }
        }

        List<Order> orders = orderDAO.getAllOrders();
        request.setAttribute("orders", orders);

        request.getRequestDispatcher("/admin/orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("updateStatus".equalsIgnoreCase(action)) {
            try {
                long orderId = Long.parseLong(request.getParameter("orderId"));
                String orderStatus = request.getParameter("orderStatus");
                String paymentStatus = request.getParameter("paymentStatus");

                if (orderStatus != null && !orderStatus.isBlank()) {
                    orderDAO.updateOrderStatus(orderId, orderStatus.trim());
                }

                if (paymentStatus != null && !paymentStatus.isBlank()) {
                    orderDAO.updatePaymentStatus(orderId, paymentStatus.trim());
                }

                response.sendRedirect(request.getContextPath() + "/admin/orders?id=" + orderId + "&success=Order updated successfully");
                return;
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/admin/orders?error=Failed to update order");
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/orders");
    }
}
