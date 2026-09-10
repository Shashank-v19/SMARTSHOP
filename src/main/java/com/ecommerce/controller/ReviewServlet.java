package com.ecommerce.controller;

import java.io.IOException;

import com.ecommerce.dao.ReviewDAO;
import com.ecommerce.model.Review;
import com.ecommerce.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/review")
public class ReviewServlet extends HttpServlet {

    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please login to write a review");
            return;
        }

        User user = (User) session.getAttribute("user");
        String productIdStr = request.getParameter("productId");
        String ratingStr = request.getParameter("rating");
        String comment = request.getParameter("comment");

        if (productIdStr == null || ratingStr == null) {
            response.sendRedirect(request.getContextPath() + "/products");
            return;
        }

        try {
            long productId = Long.parseLong(productIdStr);
            int rating = Integer.parseInt(ratingStr);

            if (rating < 1 || rating > 5) {
                rating = 5;
            }

            Review review = new Review();
            review.setProductId(productId);
            review.setUserId(user.getUserId());
            review.setRating(rating);
            review.setComment(comment != null ? comment.trim() : "");

            reviewDAO.addReview(review);

            response.sendRedirect(request.getContextPath() + "/product-details?id=" + productId + "&success=Review submitted successfully");

        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/products");
        }
    }
}
