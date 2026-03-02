package com.example.cdlforum.servlet;

import com.example.cdlforum.dao.CommentDAO;
import com.example.cdlforum.dao.PostDAO;
import com.example.cdlforum.dao.ChannelMemberDAO;
import com.example.cdlforum.model.Comment;
import com.example.cdlforum.model.Post;
import com.example.cdlforum.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "commentServlet", value = "/post/comment")
public class CommentServlet extends HttpServlet {

    private final CommentDAO commentDAO = new CommentDAO();
    private final PostDAO postDAO = new PostDAO();
    private final ChannelMemberDAO memberDAO = new ChannelMemberDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String postIdParam = req.getParameter("postId");
        String parentIdParam = req.getParameter("parentId"); // optional
        String content = req.getParameter("content");

        if (postIdParam == null || content == null || content.trim().isEmpty()) {
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

            // Must be a member to comment
            if (!memberDAO.isMember(post.getChannelId(), user.getId())) {
                resp.sendRedirect(req.getContextPath() + "/post?id=" + postId + "&error=notmember");
                return;
            }

            Integer parentId = null;
            if (parentIdParam != null && !parentIdParam.isEmpty()) {
                parentId = Integer.parseInt(parentIdParam);
                // Validate the parent belongs to the same post
                Comment parent = commentDAO.findById(parentId);
                if (parent == null || parent.getPostId() != postId)
                    parentId = null;
            }

            commentDAO.addComment(postId, user.getId(), parentId, content);
            resp.sendRedirect(req.getContextPath() + "/post?id=" + postId + "#comments");

        } catch (NumberFormatException | SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/post?id=" + postIdParam);
        }
    }
}
