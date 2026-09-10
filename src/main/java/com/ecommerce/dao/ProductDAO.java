package com.ecommerce.dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.ecommerce.model.Product;
import com.ecommerce.util.DBConnection;

public class ProductDAO {

    // Helper to map ResultSet to Product
    private Product mapResultSetToProduct(ResultSet resultSet) throws SQLException {
        Product product = new Product();
        product.setProductId(resultSet.getLong("product_id"));
        
        long categoryId = resultSet.getLong("category_id");
        if (!resultSet.wasNull()) {
            product.setCategoryId(categoryId);
        }
        
        product.setProductName(resultSet.getString("product_name"));
        product.setDescription(resultSet.getString("description"));
        product.setPrice(resultSet.getBigDecimal("price"));
        product.setDiscountPrice(resultSet.getBigDecimal("discount_price"));
        product.setStockQuantity(resultSet.getInt("stock_quantity"));
        product.setBrand(resultSet.getString("brand"));
        product.setImageUrl(resultSet.getString("image_url"));
        product.setActive(resultSet.getBoolean("is_active"));
        return product;
    }

    // Get all active products for storefront
    public List<Product> getAllProducts() {
        List<Product> products = new ArrayList<>();
        String sql = """
                SELECT product_id, category_id, product_name, description, price,
                       discount_price, stock_quantity, brand, image_url, is_active
                FROM products
                WHERE is_active = TRUE
                ORDER BY product_id DESC
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet resultSet = statement.executeQuery()
        ) {
            while (resultSet.next()) {
                products.add(mapResultSetToProduct(resultSet));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return products;
    }

    // Get all products (active and inactive) for admin
    public List<Product> getAllProductsAdmin() {
        List<Product> products = new ArrayList<>();
        String sql = """
                SELECT product_id, category_id, product_name, description, price,
                       discount_price, stock_quantity, brand, image_url, is_active
                FROM products
                ORDER BY product_id DESC
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet resultSet = statement.executeQuery()
        ) {
            while (resultSet.next()) {
                products.add(mapResultSetToProduct(resultSet));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return products;
    }

    // Get one product by ID (active or inactive)
    public Product getProductById(Long productId) {
        String sql = """
                SELECT product_id, category_id, product_name, description, price,
                       discount_price, stock_quantity, brand, image_url, is_active
                FROM products
                WHERE product_id = ?
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setLong(1, productId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToProduct(resultSet);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Add new product
    public boolean addProduct(Product product) {
        String sql = """
                INSERT INTO products
                (category_id, product_name, description, price, discount_price, stock_quantity, brand, image_url, is_active)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)
        ) {
            if (product.getCategoryId() != null && product.getCategoryId() > 0) {
                statement.setLong(1, product.getCategoryId());
            } else {
                statement.setNull(1, java.sql.Types.BIGINT);
            }

            statement.setString(2, product.getProductName());
            statement.setString(3, product.getDescription());
            statement.setBigDecimal(4, product.getPrice());
            statement.setBigDecimal(5, product.getDiscountPrice());
            statement.setInt(6, product.getStockQuantity());
            statement.setString(7, product.getBrand());
            statement.setString(8, product.getImageUrl());
            statement.setBoolean(9, product.isActive());

            int rows = statement.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = statement.getGeneratedKeys()) {
                    if (keys.next()) {
                        product.setProductId(keys.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Update existing product
    public boolean updateProduct(Product product) {
        String sql = """
                UPDATE products
                SET category_id = ?,
                    product_name = ?,
                    description = ?,
                    price = ?,
                    discount_price = ?,
                    stock_quantity = ?,
                    brand = ?,
                    image_url = ?,
                    is_active = ?
                WHERE product_id = ?
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            if (product.getCategoryId() != null && product.getCategoryId() > 0) {
                statement.setLong(1, product.getCategoryId());
            } else {
                statement.setNull(1, java.sql.Types.BIGINT);
            }

            statement.setString(2, product.getProductName());
            statement.setString(3, product.getDescription());
            statement.setBigDecimal(4, product.getPrice());
            statement.setBigDecimal(5, product.getDiscountPrice());
            statement.setInt(6, product.getStockQuantity());
            statement.setString(7, product.getBrand());
            statement.setString(8, product.getImageUrl());
            statement.setBoolean(9, product.isActive());
            statement.setLong(10, product.getProductId());

            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Toggle product active/inactive
    public boolean toggleProductStatus(long productId, boolean active) {
        String sql = "UPDATE products SET is_active = ? WHERE product_id = ?";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setBoolean(1, active);
            statement.setLong(2, productId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Delete product (or hard delete)
    public boolean deleteProduct(long productId) {
        String sql = "DELETE FROM products WHERE product_id = ?";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setLong(1, productId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Search and filter active products
    public List<Product> searchAndFilterProducts(Long categoryId, String keyword, BigDecimal minPrice, BigDecimal maxPrice, Boolean inStockOnly, String sortBy) {
        List<Product> products = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
                SELECT product_id, category_id, product_name, description, price,
                       discount_price, stock_quantity, brand, image_url, is_active
                FROM products
                WHERE is_active = TRUE
                """);

        List<Object> params = new ArrayList<>();

        if (categoryId != null && categoryId > 0) {
            sql.append(" AND category_id = ?");
            params.add(categoryId);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (LOWER(product_name) LIKE ? OR LOWER(brand) LIKE ? OR LOWER(description) LIKE ?)");
            String term = "%" + keyword.trim().toLowerCase() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
        }

        if (minPrice != null) {
            sql.append(" AND COALESCE(discount_price, price) >= ?");
            params.add(minPrice);
        }

        if (maxPrice != null) {
            sql.append(" AND COALESCE(discount_price, price) <= ?");
            params.add(maxPrice);
        }

        if (Boolean.TRUE.equals(inStockOnly)) {
            sql.append(" AND stock_quantity > 0");
        }

        if ("price_asc".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY COALESCE(discount_price, price) ASC");
        } else if ("price_desc".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY COALESCE(discount_price, price) DESC");
        } else if ("name_asc".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY product_name ASC");
        } else {
            sql.append(" ORDER BY product_id DESC");
        }

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql.toString())
        ) {
            for (int i = 0; i < params.size(); i++) {
                statement.setObject(i + 1, params.get(i));
            }

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    products.add(mapResultSetToProduct(resultSet));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return products;
    }

    // Count total products
    public int getProductsCount() {
        String sql = "SELECT COUNT(*) FROM products";
        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet resultSet = statement.executeQuery()
        ) {
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}