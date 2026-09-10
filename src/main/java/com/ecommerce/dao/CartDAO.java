package com.ecommerce.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.ecommerce.model.CartItem;
import com.ecommerce.util.DBConnection;

public class CartDAO {

    // Get or create cart for a user
    public long getOrCreateCart(long userId) {

        String selectSql =
                "SELECT cart_id FROM cart WHERE user_id = ?";

        String insertSql =
                "INSERT INTO cart (user_id) VALUES (?)";

        try (Connection connection =
                     DBConnection.getConnection()) {

            // Check existing cart

            try (PreparedStatement statement =
                         connection.prepareStatement(selectSql)) {

                statement.setLong(1, userId);

                ResultSet resultSet =
                        statement.executeQuery();

                if (resultSet.next()) {

                    return resultSet.getLong("cart_id");
                }
            }

            // Create cart

            try (PreparedStatement statement =
                         connection.prepareStatement(
                                 insertSql,
                                 java.sql.Statement.RETURN_GENERATED_KEYS)) {

                statement.setLong(1, userId);

                statement.executeUpdate();

                ResultSet keys =
                        statement.getGeneratedKeys();

                if (keys.next()) {
                    return keys.getLong(1);
                }
            }

        } catch (Exception e) {

            e.printStackTrace();
        }

        return -1;
    }


    // Add product to cart
    public boolean addToCart(
            long userId,
            long productId,
            int quantity) {

        long cartId =
                getOrCreateCart(userId);

        if (cartId == -1) {
            return false;
        }

        String checkSql = """
                SELECT cart_item_id, quantity
                FROM cart_items
                WHERE cart_id = ?
                AND product_id = ?
                """;

        String updateSql = """
                UPDATE cart_items
                SET quantity = quantity + ?
                WHERE cart_item_id = ?
                """;

        String insertSql = """
                INSERT INTO cart_items
                (cart_id, product_id, quantity)
                VALUES (?, ?, ?)
                """;

        try (Connection connection =
                     DBConnection.getConnection()) {

            // Check existing item

            try (PreparedStatement statement =
                         connection.prepareStatement(checkSql)) {

                statement.setLong(1, cartId);
                statement.setLong(2, productId);

                ResultSet resultSet =
                        statement.executeQuery();

                if (resultSet.next()) {

                    long cartItemId =
                            resultSet.getLong("cart_item_id");

                    try (PreparedStatement update =
                                 connection.prepareStatement(updateSql)) {

                        update.setInt(1, quantity);
                        update.setLong(2, cartItemId);

                        return update.executeUpdate() > 0;
                    }
                }
            }

            // New item
            try (PreparedStatement statement = connection.prepareStatement(insertSql)) {
                statement.setLong(1, cartId);
                statement.setLong(2, productId);
                statement.setInt(3, quantity);

                return statement.executeUpdate() > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // Decrease product quantity in cart (removes item if quantity reaches 0)
    public boolean decreaseQuantityByProductId(long userId, long productId) {
        long cartId = getOrCreateCart(userId);
        if (cartId == -1) {
            return false;
        }

        String selectSql = "SELECT cart_item_id, quantity FROM cart_items WHERE cart_id = ? AND product_id = ?";
        String updateSql = "UPDATE cart_items SET quantity = quantity - 1 WHERE cart_item_id = ?";
        String deleteSql = "DELETE FROM cart_items WHERE cart_item_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement selectStmt = connection.prepareStatement(selectSql)) {

            selectStmt.setLong(1, cartId);
            selectStmt.setLong(2, productId);
            try (ResultSet rs = selectStmt.executeQuery()) {
                if (rs.next()) {
                    long cartItemId = rs.getLong("cart_item_id");
                    int currentQty = rs.getInt("quantity");

                    if (currentQty <= 1) {
                        try (PreparedStatement deleteStmt = connection.prepareStatement(deleteSql)) {
                            deleteStmt.setLong(1, cartItemId);
                            return deleteStmt.executeUpdate() > 0;
                        }
                    } else {
                        try (PreparedStatement updateStmt = connection.prepareStatement(updateSql)) {
                            updateStmt.setLong(1, cartItemId);
                            return updateStmt.executeUpdate() > 0;
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }


    // Get cart items
    public List<CartItem> getCartItems(long userId) {

        List<CartItem> items =
                new ArrayList<>();

        String sql = """
                SELECT
                    ci.cart_item_id,
                    ci.cart_id,
                    ci.product_id,
                    ci.quantity,
                    p.product_name,
                    p.price,
                    p.discount_price,
                    p.image_url
                FROM cart_items ci
                JOIN cart c
                    ON ci.cart_id = c.cart_id
                JOIN products p
                    ON ci.product_id = p.product_id
                WHERE c.user_id = ?
                ORDER BY ci.added_at DESC
                """;

        try (
                Connection connection =
                        DBConnection.getConnection();

                PreparedStatement statement =
                        connection.prepareStatement(sql)
        ) {

            statement.setLong(1, userId);

            ResultSet resultSet =
                    statement.executeQuery();

            while (resultSet.next()) {

                CartItem item =
                        new CartItem();

                item.setCartItemId(
                        resultSet.getLong(
                                "cart_item_id"
                        )
                );

                item.setCartId(
                        resultSet.getLong(
                                "cart_id"
                        )
                );

                item.setProductId(
                        resultSet.getLong(
                                "product_id"
                        )
                );

                item.setQuantity(
                        resultSet.getInt(
                                "quantity"
                        )
                );

                item.setProductName(
                        resultSet.getString(
                                "product_name"
                        )
                );

                // Use selling price
                java.math.BigDecimal discountPrice =
                        resultSet.getBigDecimal(
                                "discount_price"
                        );

                java.math.BigDecimal price =
                        resultSet.getBigDecimal(
                                "price"
                        );

                item.setProductPrice(
                        discountPrice != null
                                ? discountPrice
                                : price
                );

                item.setImageUrl(
                        resultSet.getString(
                                "image_url"
                        )
                );

                items.add(item);
            }

        } catch (Exception e) {

            e.printStackTrace();
        }

        return items;
    }


    // Remove item
    public boolean removeFromCart(
            long userId,
            long cartItemId) {

        String sql = """
                DELETE ci
                FROM cart_items ci
                JOIN cart c
                    ON ci.cart_id = c.cart_id
                WHERE ci.cart_item_id = ?
                AND c.user_id = ?
                """;

        try (
                Connection connection =
                        DBConnection.getConnection();

                PreparedStatement statement =
                        connection.prepareStatement(sql)
        ) {

            statement.setLong(1, cartItemId);
            statement.setLong(2, userId);

            return statement.executeUpdate() > 0;

        } catch (Exception e) {

            e.printStackTrace();
        }

        return false;
    }

    public boolean updateQuantity(
            long userId,
            long cartItemId,
            int quantity) {

        if (quantity < 1) {
            return false;
        }

        String sql = """
                UPDATE cart_items ci
                JOIN cart c
                    ON ci.cart_id = c.cart_id
                SET ci.quantity = ?
                WHERE ci.cart_item_id = ?
                AND c.user_id = ?
                """;

        try (
                Connection connection =
                        DBConnection.getConnection();

                PreparedStatement statement =
                        connection.prepareStatement(sql)
        ) {

            statement.setInt(1, quantity);
            statement.setLong(2, cartItemId);
            statement.setLong(3, userId);

            return statement.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean clearCart(long userId) {
        String sql = """
                DELETE ci
                FROM cart_items ci
                JOIN cart c ON ci.cart_id = c.cart_id
                WHERE c.user_id = ?
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setLong(1, userId);
            return statement.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public int getCartCount(long userId) {
        String sql = """
                SELECT COALESCE(SUM(ci.quantity), 0)
                FROM cart_items ci
                JOIN cart c ON ci.cart_id = c.cart_id
                WHERE c.user_id = ?
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setLong(1, userId);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public Map<Long, Integer> getCartQuantityMap(long userId) {
        Map<Long, Integer> map = new HashMap<>();
        String sql = """
                SELECT ci.product_id, ci.quantity
                FROM cart_items ci
                JOIN cart c ON ci.cart_id = c.cart_id
                WHERE c.user_id = ?
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setLong(1, userId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getLong("product_id"), rs.getInt("quantity"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

}