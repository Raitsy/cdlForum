package com.example.cdlforum.servlet;

import com.example.cdlforum.dao.UserDAO;
import com.example.cdlforum.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "registerServlet", value = "/register")
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // If already logged in, go straight to home
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }
        req.getRequestDispatcher("/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username = req.getParameter("username");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirm = req.getParameter("confirmPassword");

        // --- Basic validation ---
        if (isBlank(username) || isBlank(email) || isBlank(password) || isBlank(confirm)) {
            req.setAttribute("error", "All fields are required.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }
        if (username.length() < 3 || username.length() > 50) {
            req.setAttribute("error", "Username must be between 3 and 50 characters.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }
        if (!password.equals(confirm)) {
            req.setAttribute("error", "Passwords do not match.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }
        if (password.length() < 6) {
            req.setAttribute("error", "Password must be at least 6 characters.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        try {
            if (userDAO.usernameExists(username)) {
                req.setAttribute("error", "Username is already taken. Please choose another.");
                req.getRequestDispatcher("/register.jsp").forward(req, resp);
                return;
            }
            if (userDAO.emailExists(email)) {
                req.setAttribute("error", "An account with that email already exists.");
                req.getRequestDispatcher("/register.jsp").forward(req, resp);
                return;
            }

            String role = req.getParameter("role");
            userDAO.register(username, email, password, role);
            resp.sendRedirect(req.getContextPath() + "/login?registered=true");

        } catch (SQLException e) {
            req.setAttribute("error", "A database error occurred. Please try again later.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
        }
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
