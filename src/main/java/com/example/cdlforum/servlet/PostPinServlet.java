package com.example.cdlforum.servlet;

import com.example.cdlforum.dao.ChannelDAO;
import com.example.cdlforum.dao.PostDAO;
import com.example.cdlforum.model.Channel;
import com.example.cdlforum.model.Post;
import com.example.cdlforum.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

/** Allows channel owners to pin/unpin a post. */
@WebServlet(name = "postPinServlet", value = "/post/pin")
public class PostPinServlet extends HttpServlet {

    private final PostDAO postDAO = new PostDAO();
    private final ChannelDAO channelDAO = new ChannelDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String postIdParam = req.getParameter("postId");
        String pinnedParam = req.getParameter("pinned");

        if (postIdParam == null) {
            resp.sendRedirect(req.getContextPath() + "/channels");
            return;
        }

        try {
            User user = (User) req.getSession().getAttribute("user");
            int postId = Integer.parseInt(postIdParam);
            Post post = postDAO.findById(postId, user.getId());
            if (post == null) {
                resp.sendError(404);
                return;
            }

            Channel ch = channelDAO.findById(post.getChannelId());
            if (ch == null || ch.getOwnerId() != user.getId()) {
                resp.sendError(403);
                return;
            }

            boolean pinned = "true".equalsIgnoreCase(pinnedParam);
            postDAO.setPinned(postId, pinned);

            resp.sendRedirect(req.getContextPath() + "/post?id=" + postId);

        } catch (NumberFormatException | SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/channels");
        }
    }
}
