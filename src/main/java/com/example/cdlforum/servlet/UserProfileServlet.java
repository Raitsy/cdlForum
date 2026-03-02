package com.example.cdlforum.servlet;

import com.example.cdlforum.dao.PostDAO;
import com.example.cdlforum.dao.UserDAO;
import com.example.cdlforum.model.Post;
import com.example.cdlforum.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Public user profile page.
 * GET /user?id=123 or /user?username=alice
 * Shows user info + all their posts (newest first).
 */
@WebServlet(name = "userProfileServlet", value = "/user")
public class UserProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final PostDAO postDAO = new PostDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User currentUser = (User) req.getSession().getAttribute("user");
        User profileUser = null;

        try {
            String idParam = req.getParameter("id");
            String usernameParam = req.getParameter("username");

            if (idParam != null) {
                profileUser = userDAO.findById(Integer.parseInt(idParam));
            } else if (usernameParam != null) {
                profileUser = userDAO.findByUsername(usernameParam);
            }

            if (profileUser == null) {
                resp.sendError(404, "User not found");
                return;
            }

            List<Post> posts = postDAO.findByUser(profileUser.getId(), currentUser.getId());
            boolean isOwnProfile = currentUser.getId() == profileUser.getId();

            req.setAttribute("profileUser", profileUser);
            req.setAttribute("userPosts", posts);
            req.setAttribute("isOwnProfile", isOwnProfile);

        } catch (SQLException | NumberFormatException e) {
            req.setAttribute("error", "Profil introuvable.");
        }

        req.getRequestDispatcher("/WEB-INF/views/user_profile.jsp").forward(req, resp);
    }
}
