package com.ecommerce.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import com.ecommerce.dao.CartDAO;
import com.ecommerce.model.CartItem;
import com.ecommerce.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    private final CartDAO cartDAO = new CartDAO();

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

        BigDecimal total = BigDecimal.ZERO;
        if (cartItems != null) {
            for (CartItem item : cartItems) {
                if (item.getProductPrice() != null) {
                    total = total.add(item.getProductPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
                }
            }
        }

        request.setAttribute("cartItems", cartItems);
        request.setAttribute("total", total);
        request.getRequestDispatcher("/cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        boolean isAjax = "true".equalsIgnoreCase(request.getParameter("ajax"))
                || "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))
                || (request.getHeader("Accept") != null && request.getHeader("Accept").contains("application/json"));

        if (session == null || session.getAttribute("user") == null) {
            if (isAjax) {
                response.setContentType("application/json; charset=UTF-8");
                response.getWriter().write("{\"success\":false,\"requireLogin\":true,\"redirect\":\"" + request.getContextPath() + "/login.jsp?error=Please login first\"}");
            } else {
                response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please login first");
            }
            return;
        }

        User user = (User) session.getAttribute("user");
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            try {
                long productId = Long.parseLong(request.getParameter("productId"));
                String quantityParam = request.getParameter("quantity");
                int quantity = (quantityParam != null && !quantityParam.isBlank()) ? Integer.parseInt(quantityParam) : 1;
                String returnTo = request.getParameter("returnTo");

                if (quantity < 1) {
                    quantity = 1;
                }

                cartDAO.addToCart(user.getUserId(), productId, quantity);

                if (isAjax) {
                    Map<Long, Integer> qtyMap = cartDAO.getCartQuantityMap(user.getUserId());
                    int itemQty = qtyMap.getOrDefault(productId, 0);
                    int cartCount = cartDAO.getCartCount(user.getUserId());
                    BigDecimal cartTotal = calculateTotal(user.getUserId());

                    response.setContentType("application/json; charset=UTF-8");
                    response.getWriter().write(String.format(
                            "{\"success\":true,\"productId\":%d,\"quantity\":%d,\"cartCount\":%d,\"total\":\"%s\"}",
                            productId, itemQty, cartCount, cartTotal.toString()
                    ));
                    return;
                }

                if ("cart".equalsIgnoreCase(returnTo)) {
                    response.sendRedirect(request.getContextPath() + "/cart");
                } else if ("home".equalsIgnoreCase(returnTo)) {
                    response.sendRedirect(request.getContextPath() + "/index.jsp");
                } else if ("products".equalsIgnoreCase(returnTo)) {
                    response.sendRedirect(request.getContextPath() + "/products");
                } else {
                    response.sendRedirect(request.getContextPath() + "/product-details?id=" + productId);
                }
            } catch (Exception e) {
                e.printStackTrace();
                if (isAjax) {
                    response.setContentType("application/json; charset=UTF-8");
                    response.getWriter().write("{\"success\":false,\"message\":\"Invalid product\"}");
                } else {
                    response.sendRedirect(request.getContextPath() + "/products");
                }
            }
            return;
        }

        if ("decrease".equals(action)) {
            try {
                long productId = Long.parseLong(request.getParameter("productId"));
                String returnTo = request.getParameter("returnTo");

                cartDAO.decreaseQuantityByProductId(user.getUserId(), productId);

                if (isAjax) {
                    Map<Long, Integer> qtyMap = cartDAO.getCartQuantityMap(user.getUserId());
                    int itemQty = qtyMap.getOrDefault(productId, 0);
                    int cartCount = cartDAO.getCartCount(user.getUserId());
                    BigDecimal cartTotal = calculateTotal(user.getUserId());

                    response.setContentType("application/json; charset=UTF-8");
                    response.getWriter().write(String.format(
                            "{\"success\":true,\"productId\":%d,\"quantity\":%d,\"cartCount\":%d,\"total\":\"%s\"}",
                            productId, itemQty, cartCount, cartTotal.toString()
                    ));
                    return;
                }

                if ("cart".equalsIgnoreCase(returnTo)) {
                    response.sendRedirect(request.getContextPath() + "/cart");
                } else if ("home".equalsIgnoreCase(returnTo)) {
                    response.sendRedirect(request.getContextPath() + "/index.jsp");
                } else if ("products".equalsIgnoreCase(returnTo)) {
                    response.sendRedirect(request.getContextPath() + "/products");
                } else {
                    response.sendRedirect(request.getContextPath() + "/product-details?id=" + productId);
                }
            } catch (Exception e) {
                e.printStackTrace();
                if (isAjax) {
                    response.setContentType("application/json; charset=UTF-8");
                    response.getWriter().write("{\"success\":false,\"message\":\"Error decreasing quantity\"}");
                } else {
                    response.sendRedirect(request.getContextPath() + "/products");
                }
            }
            return;
        }

        if ("update".equals(action)) {
            try {
                long cartItemId = Long.parseLong(request.getParameter("cartItemId"));
                int quantity = Integer.parseInt(request.getParameter("quantity"));

                if (quantity <= 0) {
                    cartDAO.removeFromCart(user.getUserId(), cartItemId);
                } else {
                    cartDAO.updateQuantity(user.getUserId(), cartItemId, quantity);
                }

                if (isAjax) {
                    List<CartItem> items = cartDAO.getCartItems(user.getUserId());
                    int cartCount = 0;
                    BigDecimal cartTotal = BigDecimal.ZERO;
                    BigDecimal itemSubtotal = BigDecimal.ZERO;

                    for (CartItem itm : items) {
                        BigDecimal sub = itm.getProductPrice().multiply(BigDecimal.valueOf(itm.getQuantity()));
                        cartTotal = cartTotal.add(sub);
                        cartCount += itm.getQuantity();
                        if (itm.getCartItemId().equals(cartItemId)) {
                            itemSubtotal = sub;
                        }
                    }

                    response.setContentType("application/json; charset=UTF-8");
                    response.getWriter().write(String.format(
                            "{\"success\":true,\"cartItemId\":%d,\"quantity\":%d,\"itemSubtotal\":\"%s\",\"cartCount\":%d,\"total\":\"%s\"}",
                            cartItemId, quantity, itemSubtotal.toString(), cartCount, cartTotal.toString()
                    ));
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
                if (isAjax) {
                    response.setContentType("application/json; charset=UTF-8");
                    response.getWriter().write("{\"success\":false,\"message\":\"Error updating cart\"}");
                    return;
                }
            }
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        if ("remove".equals(action)) {
            try {
                long cartItemId = Long.parseLong(request.getParameter("cartItemId"));
                cartDAO.removeFromCart(user.getUserId(), cartItemId);

                if (isAjax) {
                    int cartCount = cartDAO.getCartCount(user.getUserId());
                    BigDecimal cartTotal = calculateTotal(user.getUserId());

                    response.setContentType("application/json; charset=UTF-8");
                    response.getWriter().write(String.format(
                            "{\"success\":true,\"cartItemId\":%d,\"cartCount\":%d,\"total\":\"%s\"}",
                            cartItemId, cartCount, cartTotal.toString()
                    ));
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
                if (isAjax) {
                    response.setContentType("application/json; charset=UTF-8");
                    response.getWriter().write("{\"success\":false,\"message\":\"Error removing item\"}");
                    return;
                }
            }
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        if ("clear".equals(action)) {
            try {
                cartDAO.clearCart(user.getUserId());
            } catch (Exception e) {
                e.printStackTrace();
            }
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/cart");
    }

    private BigDecimal calculateTotal(long userId) {
        List<CartItem> items = cartDAO.getCartItems(userId);
        BigDecimal total = BigDecimal.ZERO;
        if (items != null) {
            for (CartItem itm : items) {
                if (itm.getProductPrice() != null) {
                    total = total.add(itm.getProductPrice().multiply(BigDecimal.valueOf(itm.getQuantity())));
                }
            }
        }
        return total;
    }
}