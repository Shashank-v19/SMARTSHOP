package com.ecommerce.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.ecommerce.model.Address;
import com.ecommerce.util.DBConnection;

public class AddressDAO {

    public long saveAddress(Address address) {
        String sql = """
                INSERT INTO addresses (
                    user_id, address_type, full_name, phone, address_line1,
                    address_line2, city, state, postal_code, country, is_default
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)
        ) {
            statement.setLong(1, address.getUserId());
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
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getLong(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public List<Address> getUserAddresses(long userId) {
        List<Address> addresses = new ArrayList<>();
        String sql = """
                SELECT address_id, user_id, address_type, full_name, phone,
                       address_line1, address_line2, city, state, postal_code, country, is_default
                FROM addresses
                WHERE user_id = ?
                ORDER BY is_default DESC, address_id DESC
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setLong(1, userId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    addresses.add(mapResultSetToAddress(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return addresses;
    }

    public Address getAddressById(long addressId) {
        String sql = """
                SELECT address_id, user_id, address_type, full_name, phone,
                       address_line1, address_line2, city, state, postal_code, country, is_default
                FROM addresses
                WHERE address_id = ?
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setLong(1, addressId);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToAddress(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Address getDefaultAddress(long userId) {
        String sql = """
                SELECT address_id, user_id, address_type, full_name, phone,
                       address_line1, address_line2, city, state, postal_code, country, is_default
                FROM addresses
                WHERE user_id = ?
                ORDER BY is_default DESC, address_id DESC
                LIMIT 1
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setLong(1, userId);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToAddress(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private Address mapResultSetToAddress(ResultSet rs) throws SQLException {
        Address address = new Address();
        address.setAddressId(rs.getLong("address_id"));
        address.setUserId(rs.getLong("user_id"));
        address.setAddressType(rs.getString("address_type"));
        address.setFullName(rs.getString("full_name"));
        address.setPhone(rs.getString("phone"));
        address.setAddressLine1(rs.getString("address_line1"));
        address.setAddressLine2(rs.getString("address_line2"));
        address.setCity(rs.getString("city"));
        address.setState(rs.getString("state"));
        address.setPostalCode(rs.getString("postal_code"));
        address.setCountry(rs.getString("country"));
        address.setDefault(rs.getBoolean("is_default"));
        return address;
    }

    public boolean deleteAddress(long addressId, long userId) {
        String sql = "DELETE FROM addresses WHERE address_id = ? AND user_id = ?";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setLong(1, addressId);
            statement.setLong(2, userId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}