package com.example.cdlforum.servlet;

import com.example.cdlforum.dao.UserDAO;
import com.example.cdlforum.model.User;
import com.example.cdlforum.util.FileUploadUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

/**
 * Handles the logged-in user's own profile settings:
 * GET /profile – show profile settings page
 * POST /profile – update avatar OR delete account
 * Dispatch via action param: "avatar" | "delete"
 */
@WebServlet(name = "profileServlet", value = "/profile")
@MultipartConfig(maxFileSize = 5_242_880) // 5 MB
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        String action = req.getParameter("action");

        if ("avatar".equals(action)) {
            handleAvatarUpdate(req, resp, user);
        } else if ("delete".equals(action)) {
            handleAccountDelete(req, resp, user);
        } else {
            resp.sendRedirect(req.getContextPath() + "/profile");
        }
    }

    // ── Avatar upload ─────────────────────────────────────────────
    private void handleAvatarUpdate(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        try {
            Part filePart = req.getPart("avatar");
            if (filePart == null || filePart.getSize() == 0) {
                req.setAttribute("error", "Veuillez sélectionner une image.");
                req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);
                return;
            }
            String savedPath = FileUploadUtil.save(
                    filePart,
                    "avatars",
                    getServletContext().getRealPath("/")
            );

            userDAO.updateAvatarPath(user.getId(), savedPath);
            // Refresh session user
            User refreshed = userDAO.findById(user.getId());
            req.getSession().setAttribute("user", refreshed);
            resp.sendRedirect(req.getContextPath() + "/profile?updated=true");

        } catch (SQLException e) {
            req.setAttribute("error", "Erreur lors de la mise à jour de l'avatar.");
            req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);
        }
    }

    // ── Account deletion ──────────────────────────────────────────
    private void handleAccountDelete(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        try {
            userDAO.deleteAccount(user.getId());
            req.getSession().invalidate();
            resp.sendRedirect(req.getContextPath() + "/login?deleted=true");
        } catch (SQLException e) {
            req.setAttribute("error", "Erreur lors de la suppression du compte.");
            req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);
        }
    }
}
