package com.ecommerce.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Database connection utility.
 *
 * Credentials are loaded exclusively from environment variables:
 *   DB_URL      - JDBC connection URL
 *   DB_USER     - Database username
 *   DB_PASSWORD - Database password
 *
 * Set these in your local .env file (see .env.example).
 * NEVER hardcode credentials in this file.
 */
public class DBConnection {

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("MySQL JDBC Driver loaded successfully.");
        } catch (ClassNotFoundException e) {
            System.out.println("MySQL JDBC Driver NOT FOUND.");
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        String url = System.getenv("DB_URL");
        String user = System.getenv("DB_USER");
        String password = System.getenv("DB_PASSWORD");

        if (url == null || url.trim().isEmpty()) {
            throw new IllegalStateException(
                "DB_URL environment variable is not set. See .env.example for setup instructions.");
        }
        if (user == null || user.trim().isEmpty()) {
            throw new IllegalStateException(
                "DB_USER environment variable is not set. See .env.example for setup instructions.");
        }
        if (password == null) {
            throw new IllegalStateException(
                "DB_PASSWORD environment variable is not set. See .env.example for setup instructions.");
        }

        return DriverManager.getConnection(url, user, password);
    }
}