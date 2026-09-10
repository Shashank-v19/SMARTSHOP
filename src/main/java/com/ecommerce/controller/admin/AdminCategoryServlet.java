package com.ecommerce.controller.admin;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import com.ecommerce.dao.CategoryDAO;
import com.ecommerce.model.Category;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet({"/admin/categories", "/admin/add-category"})
public class AdminCategoryServlet extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Category> categories = categoryDAO.getAllCategories();

        String format = request.getParameter("format");
        String acceptHeader = request.getHeader("Accept");
        boolean isJson = "json".equalsIgnoreCase(format) || 
                         (acceptHeader != null && acceptHeader.contains("application/json"));

        if (isJson) {
            response.setContentType("application/json;charset=UTF-8");
            PrintWriter out = response.getWriter();
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < categories.size(); i++) {
                Category c = categories.get(i);
                if (i > 0) json.append(",");
                json.append("{")
                    .append("\"categoryId\":").append(c.getCategoryId()).append(",")
                    .append("\"categoryName\":\"").append(escapeJson(c.getCategoryName())).append("\",")
                    .append("\"description\":\"").append(escapeJson(c.getDescription() != null ? c.getDescription() : "")).append("\",")
                    .append("\"active\":").append(c.isActive())
                    .append("}");
            }
            json.append("]");
            out.write(json.toString());
            out.flush();
            return;
        }

        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/admin/products.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        String format = request.getParameter("format");
        String acceptHeader = request.getHeader("Accept");
        String xRequestedWith = request.getHeader("X-Requested-With");
        boolean isAjaxOrJson = "json".equalsIgnoreCase(format) || 
                               "XMLHttpRequest".equalsIgnoreCase(xRequestedWith) ||
                               (acceptHeader != null && acceptHeader.contains("application/json"));

        if ("toggle".equalsIgnoreCase(action)) {
            try {
                long categoryId = Long.parseLong(request.getParameter("categoryId"));
                boolean active = Boolean.parseBoolean(request.getParameter("active"));
                categoryDAO.toggleCategoryStatus(categoryId, active);

                if (isAjaxOrJson) {
                    sendJsonResponse(response, HttpServletResponse.SC_OK, true, "Category status updated", null);
                    return;
                }
                response.sendRedirect(request.getContextPath() + "/admin/products?success=Category status updated");
                return;
            } catch (Exception e) {
                if (isAjaxOrJson) {
                    sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Invalid category ID", null);
                    return;
                }
                response.sendRedirect(request.getContextPath() + "/admin/products?error=Invalid category ID");
                return;
            }
        }

        // Add or Get/Create Category
        String categoryName = request.getParameter("categoryName");
        String description = request.getParameter("description");
        String activeParam = request.getParameter("active");
        boolean active = activeParam == null || "true".equalsIgnoreCase(activeParam) || "on".equalsIgnoreCase(activeParam);

        if (categoryName == null || categoryName.trim().isEmpty()) {
            if (isAjaxOrJson) {
                sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Category name is required", null);
                return;
            }
            response.sendRedirect(request.getContextPath() + "/admin/add-product?error=Category name cannot be empty");
            return;
        }

        categoryName = categoryName.trim();

        // Check if category already exists
        Category existingCategory = categoryDAO.getCategoryByName(categoryName);
        if (existingCategory != null) {
            if (isAjaxOrJson) {
                sendJsonResponse(response, HttpServletResponse.SC_OK, true, "Category already exists and has been selected", existingCategory);
                return;
            }
            response.sendRedirect(request.getContextPath() + "/admin/products?success=Category already exists");
            return;
        }

        Category newCategory = new Category();
        newCategory.setCategoryName(categoryName);
        newCategory.setDescription(description != null ? description.trim() : "");
        newCategory.setActive(active);

        boolean added = categoryDAO.addCategory(newCategory);

        if (added && newCategory.getCategoryId() != null) {
            if (isAjaxOrJson) {
                sendJsonResponse(response, HttpServletResponse.SC_OK, true, "Category added successfully", newCategory);
                return;
            }
            String referer = request.getHeader("Referer");
            if (referer != null && referer.contains("add-product")) {
                response.sendRedirect(request.getContextPath() + "/admin/add-product?success=Category added successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/products?success=Category added successfully");
            }
        } else {
            if (isAjaxOrJson) {
                sendJsonResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "Failed to create category", null);
                return;
            }
            response.sendRedirect(request.getContextPath() + "/admin/add-product?error=Failed to add category");
        }
    }

    private void sendJsonResponse(HttpServletResponse response, int status, boolean success, String message, Category category) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        StringBuilder json = new StringBuilder("{");
        json.append("\"success\":").append(success).append(",");
        json.append("\"message\":\"").append(escapeJson(message)).append("\"");
        if (category != null) {
            json.append(",\"category\":{")
                .append("\"categoryId\":").append(category.getCategoryId()).append(",")
                .append("\"categoryName\":\"").append(escapeJson(category.getCategoryName())).append("\",")
                .append("\"description\":\"").append(escapeJson(category.getDescription() != null ? category.getDescription() : "")).append("\",")
                .append("\"active\":").append(category.isActive())
                .append("}");
        }
        json.append("}");
        out.write(json.toString());
        out.flush();
    }

    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\b", "\\b")
                  .replace("\f", "\\f")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}
