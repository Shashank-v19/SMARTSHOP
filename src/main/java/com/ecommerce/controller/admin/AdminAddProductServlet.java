package com.ecommerce.controller.admin;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

import com.ecommerce.dao.CategoryDAO;
import com.ecommerce.dao.ProductDAO;
import com.ecommerce.model.Category;
import com.ecommerce.model.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/add-product")
public class AdminAddProductServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Category> categories = categoryDAO.getAllCategories();
        request.setAttribute("categories", categories);

        request.getRequestDispatcher("/admin/add-product.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String productName = request.getParameter("productName");
            String brand = request.getParameter("brand");
            String categoryIdStr = request.getParameter("categoryId");
            String priceStr = request.getParameter("price");
            String discountPriceStr = request.getParameter("discountPrice");
            String stockQuantityStr = request.getParameter("stockQuantity");
            String imageUrl = request.getParameter("imageUrl");
            String description = request.getParameter("description");
            boolean active = request.getParameter("active") != null;

            String newCategoryName = request.getParameter("newCategoryName");
            String newCategoryDesc = request.getParameter("newCategoryDesc");

            if (productName == null || productName.isBlank() || priceStr == null || priceStr.isBlank()) {
                response.sendRedirect(request.getContextPath() + "/admin/add-product?error=Product name and Price are required");
                return;
            }

            Long categoryId = null;
            if (newCategoryName != null && !newCategoryName.trim().isEmpty()) {
                Category cat = categoryDAO.getOrCreateCategory(newCategoryName.trim(), newCategoryDesc);
                if (cat != null) {
                    categoryId = cat.getCategoryId();
                }
            } else if (categoryIdStr != null && !categoryIdStr.isBlank() && !categoryIdStr.equalsIgnoreCase("__NEW__") && !categoryIdStr.equalsIgnoreCase("new")) {
                try {
                    categoryId = Long.parseLong(categoryIdStr.trim());
                } catch (NumberFormatException ignored) {}
            }

            BigDecimal price = new BigDecimal(priceStr.trim());
            BigDecimal discountPrice = (discountPriceStr != null && !discountPriceStr.isBlank()) ? new BigDecimal(discountPriceStr.trim()) : null;
            int stockQuantity = (stockQuantityStr != null && !stockQuantityStr.isBlank()) ? Integer.parseInt(stockQuantityStr.trim()) : 0;

            Product product = new Product();
            product.setCategoryId(categoryId);
            product.setProductName(productName.trim());
            product.setBrand(brand != null ? brand.trim() : "");
            product.setDescription(description != null ? description.trim() : "");
            product.setPrice(price);
            product.setDiscountPrice(discountPrice);
            product.setStockQuantity(stockQuantity);
            product.setImageUrl(imageUrl != null ? imageUrl.trim() : "");
            product.setActive(active);

            boolean added = productDAO.addProduct(product);

            if (added) {
                response.sendRedirect(request.getContextPath() + "/admin/products?success=Product added successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/add-product?error=Failed to add product");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/add-product?error=Invalid input values: " + e.getMessage());
        }
    }
}
