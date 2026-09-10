package com.ecommerce.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

import com.ecommerce.dao.AddressDAO;
import com.ecommerce.dao.CartDAO;
import com.ecommerce.model.Address;
import com.ecommerce.model.CartItem;
import com.ecommerce.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private final CartDAO cartDAO = new CartDAO();
    private final AddressDAO addressDAO = new AddressDAO();

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
        List<CartItem> cartItems = cartDAO.getCartItems(user.getUserId());

        if (cartItems == null || cartItems.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/cart?error=Your cart is empty");
            return;
        }

        BigDecimal total = BigDecimal.ZERO;
        for (CartItem item : cartItems) {
            if (item.getProductPrice() != null) {
                total = total.add(item.getProductPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
            }
        }

        List<Address> userAddresses = addressDAO.getUserAddresses(user.getUserId());

        request.setAttribute("cartItems", cartItems);
        request.setAttribute("total", total);
        request.setAttribute("userAddresses", userAddresses);

        request.getRequestDispatcher("/checkout.jsp").forward(request, response);
    }
}