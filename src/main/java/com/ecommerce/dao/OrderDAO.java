package com.ecommerce.dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.ecommerce.model.Address;
import com.ecommerce.model.Order;
import com.ecommerce.model.OrderItem;
import com.ecommerce.util.DBConnection;

public class OrderDAO {

    private Order mapResultSetToOrder(ResultSet resultSet) throws SQLException {
        Order order = new Order();
        order.setOrderId(resultSet.getLong("order_id"));
        order.setUserId(resultSet.getLong("user_id"));
        order.setAddressId(resultSet.getLong("address_id"));
        order.setTotalAmount(resultSet.getBigDecimal("total_amount"));
        order.setOrderStatus(resultSet.getString("order_status"));
        order.setPaymentStatus(resultSet.getString("payment_status"));
        if (resultSet.getTimestamp("order_date") != null) {
            order.setOrderDate(resultSet.getTimestamp("order_date").toLocalDateTime());
        }
        return order;
    }

    public long placeOrder(long userId, Address address, String paymentMethod) {
        String insertAddressSql = """
                INSERT INTO addresses
                (user_id, address_type, full_name, phone, address_line1, address_line2, city, state, postal_code, country, is_default)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;

        String cartItemsSql = """
                SELECT ci.product_id, ci.quantity, p.product_name, p.price, p.discount_price, p.stock_quantity
                FROM cart_items ci
                JOIN cart c ON ci.cart_id = c.cart_id
                JOIN products p ON ci.product_id = p.product_id
                WHERE c.user_id = ?
                FOR UPDATE
                """;

        String insertOrderSql = """
                INSERT INTO orders (user_id, address_id, total_amount, order_status, payment_status)
                VALUES (?, ?, ?, 'PENDING', 'PENDING')
                """;

        String insertOrderItemSql = """
                INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal)
                VALUES (?, ?, ?, ?, ?, ?)
                """;

        String insertPaymentSql = """
                INSERT INTO payments (order_id, payment_method, transaction_id, amount, payment_status)
                VALUES (?, ?, ?, ?, 'PENDING')
                """;

        String updateStockSql = """
                UPDATE products
                SET stock_quantity = stock_quantity - ?
                WHERE product_id = ? AND stock_quantity >= ?
                """;

        String clearCartSql = """
                DELETE ci FROM cart_items ci
                JOIN cart c ON ci.cart_id = c.cart_id
                WHERE c.user_id = ?
                """;

        try (Connection connection = DBConnection.getConnection()) {
            connection.setAutoCommit(false);

            try {
                // 1. GET OR SAVE ADDRESS
                long addressId;
                if (address.getAddressId() != null && address.getAddressId() > 0) {
                    addressId = address.getAddressId();
                } else {
                    try (PreparedStatement statement = connection.prepareStatement(insertAddressSql, Statement.RETURN_GENERATED_KEYS)) {
                        statement.setLong(1, userId);
                        statement.setString(2, address.getAddressType() != null ? address.getAddressType() : "HOME");
                        statement.setString(3, address.getFullName());
                        statement.setString(4, address.getPhone());
                        statement.setString(5, address.getAddressLine1());
                        statement.setString(6, address.getAddressLine2() != null ? address.getAddressLine2() : "");
                        statement.setString(7, address.getCity());
                        statement.setString(8, address.getState());
                        statement.setString(9, address.getPostalCode());
                        statement.setString(10, address.getCountry() != null ? address.getCountry() : "India");
                        statement.setBoolean(11, address.isDefault());
                        statement.executeUpdate();

                        ResultSet keys = statement.getGeneratedKeys();
                        if (!keys.next()) {
                            throw new Exception("Address creation failed");
                        }
                        addressId = keys.getLong(1);
                    }
                }

                // 2. GET CART PRODUCTS
                BigDecimal total = BigDecimal.ZERO;
                List<CartRow> cartRows = new ArrayList<>();

                try (PreparedStatement statement = connection.prepareStatement(cartItemsSql)) {
                    statement.setLong(1, userId);
                    ResultSet resultSet = statement.executeQuery();

                    if (!resultSet.next()) {
                        throw new Exception("Cart is empty");
                    }

                    do {
                        long productId = resultSet.getLong("product_id");
                        int quantity = resultSet.getInt("quantity");
                        String productName = resultSet.getString("product_name");
                        BigDecimal price = resultSet.getBigDecimal("price");
                        BigDecimal discountPrice = resultSet.getBigDecimal("discount_price");
                        int stock = resultSet.getInt("stock_quantity");

                        BigDecimal sellingPrice = discountPrice != null ? discountPrice : price;

                        if (quantity <= 0) {
                            throw new Exception("Invalid cart quantity");
                        }
                        if (stock < quantity) {
                            throw new Exception("Insufficient stock for " + productName);
                        }

                        BigDecimal subtotal = sellingPrice.multiply(BigDecimal.valueOf(quantity));
                        total = total.add(subtotal);
                        cartRows.add(new CartRow(productId, productName, quantity, sellingPrice, subtotal));
                    } while (resultSet.next());
                }

                // 3. CREATE ORDER
                long orderId;
                try (PreparedStatement orderStatement = connection.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS)) {
                    orderStatement.setLong(1, userId);
                    orderStatement.setLong(2, addressId);
                    orderStatement.setBigDecimal(3, total);
                    orderStatement.executeUpdate();

                    ResultSet orderKeys = orderStatement.getGeneratedKeys();
                    if (!orderKeys.next()) {
                        throw new Exception("Order creation failed");
                    }
                    orderId = orderKeys.getLong(1);
                }

                // 4. CREATE ORDER ITEMS
                try (PreparedStatement itemStatement = connection.prepareStatement(insertOrderItemSql)) {
                    for (CartRow row : cartRows) {
                        itemStatement.setLong(1, orderId);
                        itemStatement.setLong(2, row.productId);
                        itemStatement.setString(3, row.productName);
                        itemStatement.setInt(4, row.quantity);
                        itemStatement.setBigDecimal(5, row.unitPrice);
                        itemStatement.setBigDecimal(6, row.subtotal);
                        itemStatement.addBatch();
                    }
                    itemStatement.executeBatch();
                }

                // 5. UPDATE STOCK
                try (PreparedStatement stockStatement = connection.prepareStatement(updateStockSql)) {
                    for (CartRow row : cartRows) {
                        stockStatement.setInt(1, row.quantity);
                        stockStatement.setLong(2, row.productId);
                        stockStatement.setInt(3, row.quantity);
                        if (stockStatement.executeUpdate() == 0) {
                            throw new Exception("Stock update failed");
                        }
                    }
                }

                // 6. CREATE PAYMENT
                try (PreparedStatement paymentStatement = connection.prepareStatement(insertPaymentSql)) {
                    paymentStatement.setLong(1, orderId);
                    paymentStatement.setString(2, paymentMethod);
                    paymentStatement.setString(3, null);
                    paymentStatement.setBigDecimal(4, total);
                    paymentStatement.executeUpdate();
                }

                // 7. CLEAR CART
                try (PreparedStatement clearStatement = connection.prepareStatement(clearCartSql)) {
                    clearStatement.setLong(1, userId);
                    clearStatement.executeUpdate();
                }

                connection.commit();
                return orderId;

            } catch (Exception e) {
                connection.rollback();
                e.printStackTrace();
                return -1;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        }
    }

    private static class CartRow {
        long productId;
        String productName;
        int quantity;
        BigDecimal unitPrice;
        BigDecimal subtotal;

        CartRow(long productId, String productName, int quantity, BigDecimal unitPrice, BigDecimal subtotal) {
            this.productId = productId;
            this.productName = productName;
            this.quantity = quantity;
            this.unitPrice = unitPrice;
            this.subtotal = subtotal;
        }
    }

    public List<Order> getOrdersByUser(long userId) {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT order_id, user_id, address_id, total_amount, order_status, payment_status, order_date FROM orders WHERE user_id = ? ORDER BY order_date DESC";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setLong(1, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    orders.add(mapResultSetToOrder(resultSet));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orders;
    }

    public Order getOrderByIdForUser(long orderId, long userId) {
        String sql = "SELECT order_id, user_id, address_id, total_amount, order_status, payment_status, order_date FROM orders WHERE order_id = ? AND user_id = ?";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setLong(1, orderId);
            statement.setLong(2, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToOrder(resultSet);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Order getOrderById(long orderId) {
        String sql = "SELECT order_id, user_id, address_id, total_amount, order_status, payment_status, order_date FROM orders WHERE order_id = ?";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setLong(1, orderId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToOrder(resultSet);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<OrderItem> getOrderItems(long orderId) {
        List<OrderItem> items = new ArrayList<>();
        String sql = "SELECT order_item_id, order_id, product_id, product_name, quantity, unit_price, subtotal FROM order_items WHERE order_id = ? ORDER BY order_item_id";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setLong(1, orderId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    OrderItem item = new OrderItem();
                    item.setOrderItemId(resultSet.getLong("order_item_id"));
                    item.setOrderId(resultSet.getLong("order_id"));
                    item.setProductId(resultSet.getLong("product_id"));
                    item.setProductName(resultSet.getString("product_name"));
                    item.setQuantity(resultSet.getInt("quantity"));
                    item.setUnitPrice(resultSet.getBigDecimal("unit_price"));
                    item.setSubtotal(resultSet.getBigDecimal("subtotal"));
                    items.add(item);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return items;
    }

    public boolean cancelOrder(long orderId, long userId) {
        String checkOrderSql = "SELECT order_status FROM orders WHERE order_id = ? AND user_id = ? FOR UPDATE";
        String getItemsSql = "SELECT product_id, quantity FROM order_items WHERE order_id = ?";
        String restoreStockSql = "UPDATE products SET stock_quantity = stock_quantity + ? WHERE product_id = ?";
        String cancelOrderSql = "UPDATE orders SET order_status = 'CANCELLED' WHERE order_id = ? AND user_id = ? AND order_status IN ('PENDING', 'CONFIRMED', 'PROCESSING')";

        try (Connection connection = DBConnection.getConnection()) {
            connection.setAutoCommit(false);
            try {
                String currentStatus = null;
                try (PreparedStatement statement = connection.prepareStatement(checkOrderSql)) {
                    statement.setLong(1, orderId);
                    statement.setLong(2, userId);
                    ResultSet resultSet = statement.executeQuery();
                    if (!resultSet.next()) {
                        connection.rollback();
                        return false;
                    }
                    currentStatus = resultSet.getString("order_status");
                }

                if (!"PENDING".equals(currentStatus) && !"CONFIRMED".equals(currentStatus) && !"PROCESSING".equals(currentStatus)) {
                    connection.rollback();
                    return false;
                }

                try (
                        PreparedStatement itemStatement = connection.prepareStatement(getItemsSql);
                        PreparedStatement stockStatement = connection.prepareStatement(restoreStockSql)
                ) {
                    itemStatement.setLong(1, orderId);
                    ResultSet items = itemStatement.executeQuery();
                    while (items.next()) {
                        long productId = items.getLong("product_id");
                        int quantity = items.getInt("quantity");
                        stockStatement.setInt(1, quantity);
                        stockStatement.setLong(2, productId);
                        stockStatement.executeUpdate();
                    }
                }

                try (PreparedStatement statement = connection.prepareStatement(cancelOrderSql)) {
                    statement.setLong(1, orderId);
                    statement.setLong(2, userId);
                    int updated = statement.executeUpdate();
                    if (updated == 0) {
                        connection.rollback();
                        return false;
                    }
                }

                connection.commit();
                return true;
            } catch (Exception e) {
                connection.rollback();
                e.printStackTrace();
                return false;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Admin: Get all orders
    public List<Order> getAllOrders() {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT order_id, user_id, address_id, total_amount, order_status, payment_status, order_date FROM orders ORDER BY order_date DESC";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet resultSet = statement.executeQuery()
        ) {
            while (resultSet.next()) {
                orders.add(mapResultSetToOrder(resultSet));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orders;
    }

    // Admin: Update order status
    public boolean updateOrderStatus(long orderId, String status) {
        String sql = "UPDATE orders SET order_status = ? WHERE order_id = ?";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setString(1, status);
            statement.setLong(2, orderId);
            return statement.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Admin: Update payment status
    public boolean updatePaymentStatus(long orderId, String status) {
        String sql = "UPDATE orders SET payment_status = ? WHERE order_id = ?";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setString(1, status);
            statement.setLong(2, orderId);
            return statement.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Admin Dashboard: Total Revenue
    public BigDecimal getTotalRevenue() {
        String sql = "SELECT SUM(total_amount) FROM orders WHERE order_status != 'CANCELLED'";
        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet resultSet = statement.executeQuery()
        ) {
            if (resultSet.next()) {
                BigDecimal revenue = resultSet.getBigDecimal(1);
                return revenue != null ? revenue : BigDecimal.ZERO;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    // Admin Dashboard: Total orders count
    public int getOrdersCount() {
        String sql = "SELECT COUNT(*) FROM orders";
        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet resultSet = statement.executeQuery()
        ) {
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Admin Dashboard: Recent orders
    public List<Order> getRecentOrders(int limit) {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT order_id, user_id, address_id, total_amount, order_status, payment_status, order_date FROM orders ORDER BY order_date DESC LIMIT ?";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, limit);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    orders.add(mapResultSetToOrder(resultSet));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orders;
    }
}