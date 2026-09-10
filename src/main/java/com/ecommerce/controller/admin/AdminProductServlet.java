package com.ecommerce.controller.admin;

import java.io.IOException;
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

@WebServlet("/admin/products")
public class AdminProductServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Product> products = productDAO.getAllProductsAdmin();
        List<Category> categories = categoryDAO.getAllCategories();

        request.setAttribute("products", products);
        request.setAttribute("categories", categories);

        request.getRequestDispatcher("/admin/products.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("toggle".equalsIgnoreCase(action)) {
            try {
                long productId = Long.parseLong(request.getParameter("productId"));
                boolean active = Boolean.parseBoolean(request.getParameter("active"));
                boolean updated = productDAO.toggleProductStatus(productId, active);
                if (updated) {
                    response.sendRedirect(request.getContextPath() + "/admin/products?success=Product status updated");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/products?error=Failed to update product status");
                }
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/admin/products?error=Invalid product ID");
            }
            return;
        }

        if ("delete".equalsIgnoreCase(action)) {
            try {
                long productId = Long.parseLong(request.getParameter("productId"));
                boolean deleted = productDAO.deleteProduct(productId);
                if (deleted) {
                    response.sendRedirect(request.getContextPath() + "/admin/products?success=Product deleted successfully");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/products?error=Could not delete product (it may be referenced in existing orders or cart items)");
                }
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/admin/products?error=Could not delete product (it may be referenced in existing orders)");
            }
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/products");
    }
}
