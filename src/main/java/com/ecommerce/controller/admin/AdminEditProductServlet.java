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

@WebServlet("/admin/edit-product")
public class AdminEditProductServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/admin/products");
            return;
        }

        try {
            long productId = Long.parseLong(idStr);
            Product product = productDAO.getProductById(productId);
            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/admin/products?error=Product not found");
                return;
            }

            List<Category> categories = categoryDAO.getAllCategories();
            request.setAttribute("product", product);
            request.setAttribute("categories", categories);

            request.getRequestDispatcher("/admin/edit-product.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/products");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            long productId = Long.parseLong(request.getParameter("productId"));
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
                response.sendRedirect(request.getContextPath() + "/admin/edit-product?id=" + productId + "&error=Product name and Price are required");
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
            product.setProductId(productId);
            product.setCategoryId(categoryId);
            product.setProductName(productName.trim());
            product.setBrand(brand != null ? brand.trim() : "");
            product.setDescription(description != null ? description.trim() : "");
            product.setPrice(price);
            product.setDiscountPrice(discountPrice);
            product.setStockQuantity(stockQuantity);
            product.setImageUrl(imageUrl != null ? imageUrl.trim() : "");
            product.setActive(active);

            boolean updated = productDAO.updateProduct(product);

            if (updated) {
                response.sendRedirect(request.getContextPath() + "/admin/products?success=Product updated successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/edit-product?id=" + productId + "&error=Failed to update product");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/products?error=Invalid input values");
        }
    }
}
