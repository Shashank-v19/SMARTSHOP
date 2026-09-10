package com.ecommerce.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.ecommerce.model.Review;
import com.ecommerce.util.DBConnection;

public class ReviewDAO {

    public boolean addReview(Review review) {
        String sql = """
                INSERT INTO reviews (product_id, user_id, rating, comment)
                VALUES (?, ?, ?, ?)
                ON DUPLICATE KEY UPDATE rating = VALUES(rating), comment = VALUES(comment)
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setLong(1, review.getProductId());
            statement.setLong(2, review.getUserId());
            statement.setInt(3, review.getRating());
            statement.setString(4, review.getComment());

            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Review> getReviewsByProduct(long productId) {
        List<Review> reviews = new ArrayList<>();
        String sql = """
                SELECT r.review_id, r.product_id, r.user_id, r.rating, r.comment, r.created_at,
                       CONCAT(u.first_name, ' ', u.last_name) AS user_name
                FROM reviews r
                JOIN users u ON r.user_id = u.user_id
                WHERE r.product_id = ?
                ORDER BY r.created_at DESC
                """;

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setLong(1, productId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    Review review = new Review();
                    review.setReviewId(resultSet.getLong("review_id"));
                    review.setProductId(resultSet.getLong("product_id"));
                    review.setUserId(resultSet.getLong("user_id"));
                    review.setRating(resultSet.getInt("rating"));
                    review.setComment(resultSet.getString("comment"));
                    if (resultSet.getTimestamp("created_at") != null) {
                        review.setCreatedAt(resultSet.getTimestamp("created_at").toLocalDateTime());
                    }
                    review.setUserName(resultSet.getString("user_name"));
                    reviews.add(review);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reviews;
    }

    public double getAverageRating(long productId) {
        String sql = "SELECT AVG(rating) FROM reviews WHERE product_id = ?";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setLong(1, productId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return resultSet.getDouble(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
}
