package com.ecommerce.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/order-success")
public class OrderSuccessServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String orderId = request.getParameter("id");

        if (orderId == null || orderId.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/products");
            return;
        }

        request.setAttribute("orderId", orderId);
        request.getRequestDispatcher("/order-success.jsp").forward(request, response);
    }
}