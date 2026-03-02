package com.example.cdlforum.servlet;

import com.example.cdlforum.dao.*;
import com.example.cdlforum.model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "postViewServlet", value = "/post")
public class PostViewServlet extends HttpServlet {

    private final PostDAO postDAO = new PostDAO();
    private final CommentDAO commentDAO = new CommentDAO();
    private final ChannelDAO channelDAO = new ChannelDAO();
    private final ChannelMemberDAO memberDAO = new ChannelMemberDAO();
    private final ChannelRuleDAO ruleDAO = new ChannelRuleDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String idParam = req.getParameter("id");
        if (idParam == null) {
            resp.sendRedirect(req.getContextPath() + "/channels");
            return;
        }

        try {
            User currentUser = (User) req.getSession().getAttribute("user");
            int postId = Integer.parseInt(idParam);

            Post post = postDAO.findById(postId, currentUser.getId());
            if (post == null) {
                resp.sendError(404, "Post not found.");
                return;
            }

            Channel channel = channelDAO.findById(post.getChannelId());
            List<Comment> comments = commentDAO.getCommentsForPost(postId);
            List<ChannelRule> rules = ruleDAO.getRules(post.getChannelId());
            String role = memberDAO.getRole(post.getChannelId(), currentUser.getId());
            boolean isOwner = channel != null && channel.getOwnerId() == currentUser.getId();

            req.setAttribute("post", post);
            req.setAttribute("channel", channel);
            req.setAttribute("comments", comments);
            req.setAttribute("rules", rules);
            req.setAttribute("userRole", role);
            req.setAttribute("isOwner", isOwner);
            req.setAttribute("isMember", role != null);
            req.setAttribute("canModerate", isOwner || "MODERATOR".equals(role));

            req.getRequestDispatcher("/WEB-INF/views/post_view.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/channels");
        } catch (SQLException e) {
            resp.sendError(500, "Database error.");
        }
    }
}
