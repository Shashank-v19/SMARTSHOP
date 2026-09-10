package com.ecommerce.filter;

import java.io.IOException;

import com.ecommerce.model.User;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter(urlPatterns = {"/admin/*"})
public class AdminFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String path = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String relativePath = path.substring(contextPath.length());

        // Allow public admin login resources
        if (relativePath.equals("/admin/login.jsp") ||
            relativePath.equals("/admin/login") ||
            relativePath.startsWith("/css/") ||
            relativePath.startsWith("/js/") ||
            relativePath.startsWith("/images/")) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = httpRequest.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            httpResponse.sendRedirect(contextPath + "/admin/login.jsp?error=Please login as administrator");
            return;
        }

        User user = (User) session.getAttribute("user");

        if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
            httpResponse.sendRedirect(contextPath + "/admin/login.jsp?error=Access denied. Admin privileges required.");
            return;
        }

        // Active admin check
        if (!user.isActive()) {
            session.invalidate();
            httpResponse.sendRedirect(contextPath + "/admin/login.jsp?error=Your administrator account is inactive");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
