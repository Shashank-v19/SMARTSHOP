package com.ecommerce.controller;

import java.io.IOException;
import java.util.List;

import com.ecommerce.dao.AddressDAO;
import com.ecommerce.dao.OrderDAO;
import com.ecommerce.model.Address;
import com.ecommerce.model.Order;
import com.ecommerce.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/orders")
public class OrderServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final AddressDAO addressDAO = new AddressDAO();

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

        String selectedAddressIdStr = request.getParameter("selectedAddressId");
        String paymentMethod = request.getParameter("paymentMethod");

        if (paymentMethod == null ||
                !(paymentMethod.equals("COD") || paymentMethod.equals("UPI") || paymentMethod.equals("CARD"))) {
            response.sendRedirect(request.getContextPath() + "/checkout?error=Please select a valid payment method");
            return;
        }

        Address address = null;

        if (selectedAddressIdStr != null && !selectedAddressIdStr.isBlank() && !"new".equalsIgnoreCase(selectedAddressIdStr)) {
            try {
                long addressId = Long.parseLong(selectedAddressIdStr);
                Address savedAddr = addressDAO.getAddressById(addressId);
                if (savedAddr != null && savedAddr.getUserId().equals(user.getUserId())) {
                    address = savedAddr;
                }
            } catch (NumberFormatException ignored) {}
        }

        if (address == null) {
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String addressLine1 = request.getParameter("addressLine1");
            String addressLine2 = request.getParameter("addressLine2");
            String city = request.getParameter("city");
            String state = request.getParameter("state");
            String postalCode = request.getParameter("postalCode");
            String country = request.getParameter("country");
            String addressType = request.getParameter("addressType");

            if (fullName == null || fullName.isBlank() ||
                    phone == null || !phone.matches("\\d{10}") ||
                    addressLine1 == null || addressLine1.isBlank() ||
                    city == null || city.isBlank() ||
                    state == null || state.isBlank() ||
                    postalCode == null || !postalCode.matches("\\d{6}") ||
                    country == null || country.isBlank()) {

                response.sendRedirect(request.getContextPath() + "/checkout?error=Please enter valid delivery address details");
                return;
            }

            address = new Address();
            address.setUserId(user.getUserId());
            address.setAddressType(addressType != null && !addressType.isBlank() ? addressType : "HOME");
            address.setFullName(fullName.trim());
            address.setPhone(phone.trim());
            address.setAddressLine1(addressLine1.trim());
            address.setAddressLine2(addressLine2 != null ? addressLine2.trim() : "");
            address.setCity(city.trim());
            address.setState(state.trim());
            address.setPostalCode(postalCode.trim());
            address.setCountry(country.trim());
            address.setDefault(request.getParameter("isDefault") != null);
        }

        long orderId = orderDAO.placeOrder(user.getUserId(), address, paymentMethod);

        if (orderId > 0) {
            response.sendRedirect(request.getContextPath() + "/order-success?id=" + orderId);
        } else {
            response.sendRedirect(request.getContextPath() + "/checkout?error=Unable to place order. Please check your cart items and stock.");
        }
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please login first");
            return;
        }

        User user = (User) session.getAttribute("user");
        List<Order> orders = orderDAO.getOrdersByUser(user.getUserId());

        request.setAttribute("orders", orders);
        request.getRequestDispatcher("/orders.jsp").forward(request, response);
    }
}