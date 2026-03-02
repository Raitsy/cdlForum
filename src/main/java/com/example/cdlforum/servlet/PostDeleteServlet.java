package com.example.cdlforum.servlet;

import com.example.cdlforum.dao.*;
import com.example.cdlforum.model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

/**
 * Handles deletion of posts and comments.
 *
 * POST /post/delete?type=post&id=X – deletes post X
 * POST /post/delete?type=comment&id=X – deletes comment X
 *
 * Authorisation:
 * Post: author OR channel owner/moderator
 * Comment: author OR channel owner/moderator
 */
@WebServlet(name = "postDeleteServlet", value = "/post/delete")
public class PostDeleteServlet extends HttpServlet {

    private final PostDAO postDAO = new PostDAO();
    private final CommentDAO commentDAO = new CommentDAO();
    private final ChannelMemberDAO memberDAO = new ChannelMemberDAO();
    private final ChannelDAO channelDAO = new ChannelDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String type = req.getParameter("type");
        String idParam = req.getParameter("id");
        String redirect = req.getHeader("Referer"); // fall back to referer

        if (idParam == null || type == null) {
            resp.sendRedirect(req.getContextPath() + "/channels");
            return;
        }

        User user = (User) req.getSession().getAttribute("user");

        try {
            int id = Integer.parseInt(idParam);

            if ("post".equals(type)) {
                Post post = postDAO.findById(id, user.getId());
                if (post == null) {
                    resp.sendError(404);
                    return;
                }

                if (!canModerate(user, post.getChannelId(), post.getAuthorId())) {
                    resp.sendError(403);
                    return;
                }
                String channelId = String.valueOf(post.getChannelId());
                postDAO.delete(id);
                resp.sendRedirect(req.getContextPath() + "/channel?id=" + channelId);
                return;

            } else if ("comment".equals(type)) {
                Comment comment = commentDAO.findById(id);
                if (comment == null) {
                    resp.sendError(404);
                    return;
                }

                Post post = postDAO.findById(comment.getPostId(), user.getId());
                if (post == null) {
                    resp.sendError(404);
                    return;
                }

                if (!canModerate(user, post.getChannelId(), comment.getAuthorId())) {
                    resp.sendError(403);
                    return;
                }
                commentDAO.delete(id);
                if (redirect != null)
                    resp.sendRedirect(redirect);
                else
                    resp.sendRedirect(req.getContextPath() + "/post?id=" + post.getId());
                return;
            }

            resp.sendRedirect(req.getContextPath() + "/channels");

        } catch (NumberFormatException | SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/channels");
        }
    }

    /** True if the current user is the author OR is a channel owner/moderator. */
    private boolean canModerate(User user, int channelId, int authorId) throws SQLException {
        if (user.getId() == authorId)
            return true;
        Channel ch = channelDAO.findById(channelId);
        if (ch != null && ch.getOwnerId() == user.getId())
            return true;
        String role = memberDAO.getRole(channelId, user.getId());
        return "MODERATOR".equals(role);
    }
}
