package com.ecommerce.controller;

import java.io.IOException;
import java.util.List;

import com.ecommerce.dao.AddressDAO;
import com.ecommerce.dao.OrderDAO;
import com.ecommerce.dao.UserDAO;
import com.ecommerce.model.Address;
import com.ecommerce.model.Order;
import com.ecommerce.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final AddressDAO addressDAO = new AddressDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please login first");
            return;
        }

        User sessionUser = (User) session.getAttribute("user");
        User freshUser = userDAO.findById(sessionUser.getUserId());

        if (freshUser == null) {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        session.setAttribute("user", freshUser);
        List<Order> orders = orderDAO.getOrdersByUser(freshUser.getUserId());
        List<Address> addresses = addressDAO.getUserAddresses(freshUser.getUserId());

        request.setAttribute("profileUser", freshUser);
        request.setAttribute("orders", orders);
        request.setAttribute("addresses", addresses);
        request.getRequestDispatcher("/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User sessionUser = (User) session.getAttribute("user");
        String action = request.getParameter("action");

        if ("addAddress".equalsIgnoreCase(action)) {
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String addressLine1 = request.getParameter("addressLine1");
            String addressLine2 = request.getParameter("addressLine2");
            String city = request.getParameter("city");
            String state = request.getParameter("state");
            String postalCode = request.getParameter("postalCode");
            String country = request.getParameter("country");
            String addressType = request.getParameter("addressType");

            if (fullName == null || fullName.isBlank() || phone == null || addressLine1 == null || city == null || postalCode == null) {
                response.sendRedirect(request.getContextPath() + "/profile?error=Please fill all required address fields");
                return;
            }

            Address addr = new Address();
            addr.setUserId(sessionUser.getUserId());
            addr.setFullName(fullName.trim());
            addr.setPhone(phone.trim());
            addr.setAddressLine1(addressLine1.trim());
            addr.setAddressLine2(addressLine2 != null ? addressLine2.trim() : "");
            addr.setCity(city.trim());
            addr.setState(state != null ? state.trim() : "");
            addr.setPostalCode(postalCode.trim());
            addr.setCountry(country != null && !country.isBlank() ? country.trim() : "India");
            addr.setAddressType(addressType != null && !addressType.isBlank() ? addressType : "HOME");
            addr.setDefault(request.getParameter("isDefault") != null);

            addressDAO.saveAddress(addr);
            response.sendRedirect(request.getContextPath() + "/profile?success=Address added to profile");
            return;
        }

        if ("deleteAddress".equalsIgnoreCase(action)) {
            String addressIdStr = request.getParameter("addressId");
            if (addressIdStr != null && !addressIdStr.isBlank()) {
                try {
                    long addressId = Long.parseLong(addressIdStr);
                    boolean deleted = addressDAO.deleteAddress(addressId, sessionUser.getUserId());
                    if (deleted) {
                        response.sendRedirect(request.getContextPath() + "/profile?success=Address deleted successfully");
                        return;
                    }
                } catch (NumberFormatException ignored) {}
            }
            response.sendRedirect(request.getContextPath() + "/profile?error=Could not delete address");
            return;
        }

        // Update profile info
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String phone = request.getParameter("phone");

        if (firstName == null || lastName == null || firstName.isBlank() || lastName.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/profile?error=First name and Last name are required");
            return;
        }

        User userToUpdate = new User();
        userToUpdate.setUserId(sessionUser.getUserId());
        userToUpdate.setFirstName(firstName.trim());
        userToUpdate.setLastName(lastName.trim());
        userToUpdate.setPhone(phone != null ? phone.trim() : "");

        boolean updated = userDAO.updateUserProfile(userToUpdate);

        if (updated) {
            User updatedUser = userDAO.findById(sessionUser.getUserId());
            session.setAttribute("user", updatedUser);
            response.sendRedirect(request.getContextPath() + "/profile?success=Profile updated successfully");
        } else {
            response.sendRedirect(request.getContextPath() + "/profile?error=Failed to update profile");
        }
    }
}
