package com.ecommerce.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.ecommerce.model.Category;
import com.ecommerce.util.DBConnection;

public class CategoryDAO {

    public List<Category> getAllCategories() {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT category_id, category_name, description, is_active FROM categories ORDER BY category_name ASC";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet resultSet = statement.executeQuery()
        ) {
            while (resultSet.next()) {
                Category category = new Category();
                category.setCategoryId(resultSet.getLong("category_id"));
                category.setCategoryName(resultSet.getString("category_name"));
                category.setDescription(resultSet.getString("description"));
                category.setActive(resultSet.getBoolean("is_active"));
                categories.add(category);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return categories;
    }

    public List<Category> getActiveCategories() {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT category_id, category_name, description, is_active FROM categories WHERE is_active = TRUE ORDER BY category_name ASC";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet resultSet = statement.executeQuery()
        ) {
            while (resultSet.next()) {
                Category category = new Category();
                category.setCategoryId(resultSet.getLong("category_id"));
                category.setCategoryName(resultSet.getString("category_name"));
                category.setDescription(resultSet.getString("description"));
                category.setActive(resultSet.getBoolean("is_active"));
                categories.add(category);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return categories;
    }

    public Category getCategoryById(long categoryId) {
        String sql = "SELECT category_id, category_name, description, is_active FROM categories WHERE category_id = ?";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setLong(1, categoryId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    Category category = new Category();
                    category.setCategoryId(resultSet.getLong("category_id"));
                    category.setCategoryName(resultSet.getString("category_name"));
                    category.setDescription(resultSet.getString("description"));
                    category.setActive(resultSet.getBoolean("is_active"));
                    return category;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean addCategory(Category category) {
        String sql = "INSERT INTO categories (category_name, description, is_active) VALUES (?, ?, ?)";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)
        ) {
            statement.setString(1, category.getCategoryName());
            statement.setString(2, category.getDescription());
            statement.setBoolean(3, category.isActive());

            int rows = statement.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = statement.getGeneratedKeys()) {
                    if (keys.next()) {
                        category.setCategoryId(keys.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateCategory(Category category) {
        String sql = "UPDATE categories SET category_name = ?, description = ?, is_active = ? WHERE category_id = ?";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setString(1, category.getCategoryName());
            statement.setString(2, category.getDescription());
            statement.setBoolean(3, category.isActive());
            statement.setLong(4, category.getCategoryId());

            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean toggleCategoryStatus(long categoryId, boolean active) {
        String sql = "UPDATE categories SET is_active = ? WHERE category_id = ?";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setBoolean(1, active);
            statement.setLong(2, categoryId);

            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public Category getCategoryByName(String categoryName) {
        if (categoryName == null || categoryName.trim().isEmpty()) {
            return null;
        }
        String sql = "SELECT category_id, category_name, description, is_active FROM categories WHERE LOWER(TRIM(category_name)) = LOWER(TRIM(?))";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setString(1, categoryName.trim());
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    Category category = new Category();
                    category.setCategoryId(resultSet.getLong("category_id"));
                    category.setCategoryName(resultSet.getString("category_name"));
                    category.setDescription(resultSet.getString("description"));
                    category.setActive(resultSet.getBoolean("is_active"));
                    return category;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public synchronized Category getOrCreateCategory(String categoryName, String description) {
        if (categoryName == null || categoryName.trim().isEmpty()) {
            return null;
        }

        Category existing = getCategoryByName(categoryName);
        if (existing != null) {
            return existing;
        }

        Category newCategory = new Category();
        newCategory.setCategoryName(categoryName.trim());
        newCategory.setDescription(description != null ? description.trim() : "");
        newCategory.setActive(true);

        boolean added = addCategory(newCategory);
        if (added && newCategory.getCategoryId() != null) {
            return newCategory;
        }

        // If insert failed due to concurrent insert, try fetching again
        return getCategoryByName(categoryName);
    }
}

