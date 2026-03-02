package com.example.cdlforum.servlet;

import com.example.cdlforum.dao.PostDAO;
import com.example.cdlforum.dao.PostVoteDAO;
import com.example.cdlforum.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "postVoteServlet", value = "/post/vote")
public class PostVoteServlet extends HttpServlet {

    private final PostVoteDAO voteDAO = new PostVoteDAO();
    private final PostDAO postDAO = new PostDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String idParam = req.getParameter("postId");
        if (idParam == null) {
            resp.sendRedirect(req.getContextPath() + "/channels");
            return;
        }

        try {
            User currentUser = (User) req.getSession().getAttribute("user");
            int postId = Integer.parseInt(idParam);

            int delta = voteDAO.toggleVote(postId, currentUser.getId());
            postDAO.updateVoteCount(postId, delta);

            // Redirect back to the post or to the referrer
            String ref = req.getHeader("Referer");
            resp.sendRedirect(ref != null ? ref : req.getContextPath() + "/post?id=" + postId);

        } catch (NumberFormatException | SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/channels");
        }
    }
}
