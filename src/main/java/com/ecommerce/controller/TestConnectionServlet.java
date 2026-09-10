package com.ecommerce.controller;

import java.io.IOException;
import java.sql.Connection;

import com.ecommerce.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/test-db")
public class TestConnectionServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        try {

            Connection connection =
                    DBConnection.getConnection();

            response.getWriter().println(
                    "<h1 style='color:green'>"
                    + "MySQL Connection Successful!"
                    + "</h1>"
            );

            response.getWriter().println(
                    "<p>Java → JDBC → MySQL is working.</p>"
            );

            connection.close();

        } catch (Exception e) {

            response.setStatus(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR
            );

            response.getWriter().println(
                    "<h1 style='color:red'>"
                    + "MySQL Connection Failed"
                    + "</h1>"
            );

            response.getWriter().println(
                    "<pre>"
                    + e.getMessage()
                    + "</pre>"
            );
        }
    }
}