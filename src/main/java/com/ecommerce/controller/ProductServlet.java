package com.ecommerce.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.ecommerce.dao.CartDAO;
import com.ecommerce.dao.CategoryDAO;
import com.ecommerce.dao.ProductDAO;
import com.ecommerce.model.Category;
import com.ecommerce.model.Product;
import com.ecommerce.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/products")
public class ProductServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final CartDAO cartDAO = new CartDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        String categoryIdStr = request.getParameter("category");
        String keyword = request.getParameter("q");
        String minPriceStr = request.getParameter("minPrice");
        String maxPriceStr = request.getParameter("maxPrice");
        String inStockStr = request.getParameter("inStock");
        String sortBy = request.getParameter("sortBy");

        Long categoryId = null;
        if (categoryIdStr != null && !categoryIdStr.isBlank()) {
            try {
                categoryId = Long.parseLong(categoryIdStr);
            } catch (NumberFormatException ignored) {}
        }

        BigDecimal minPrice = null;
        if (minPriceStr != null && !minPriceStr.isBlank()) {
            try {
                minPrice = new BigDecimal(minPriceStr.trim());
            } catch (Exception ignored) {}
        }

        BigDecimal maxPrice = null;
        if (maxPriceStr != null && !maxPriceStr.isBlank()) {
            try {
                maxPrice = new BigDecimal(maxPriceStr.trim());
            } catch (Exception ignored) {}
        }

        Boolean inStockOnly = (inStockStr != null && "true".equalsIgnoreCase(inStockStr)) ? Boolean.TRUE : null;

        List<Product> products = productDAO.searchAndFilterProducts(categoryId, keyword, minPrice, maxPrice, inStockOnly, sortBy);
        List<Category> categories = categoryDAO.getActiveCategories();

        Map<Long, Integer> cartQtyMap = new HashMap<>();
        int cartCount = 0;
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            cartQtyMap = cartDAO.getCartQuantityMap(user.getUserId());
            cartCount = cartDAO.getCartCount(user.getUserId());
        }

        request.setAttribute("products", products);
        request.setAttribute("categories", categories);
        request.setAttribute("selectedCategory", categoryId);
        request.setAttribute("keyword", keyword);
        request.setAttribute("minPrice", minPriceStr);
        request.setAttribute("maxPrice", maxPriceStr);
        request.setAttribute("inStock", inStockStr);
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("cartQtyMap", cartQtyMap);
        request.setAttribute("cartCount", cartCount);

        request.getRequestDispatcher("/products.jsp").forward(request, response);
    }
}