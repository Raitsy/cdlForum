package com.example.cdlforum.servlet;

import com.example.cdlforum.dao.ChannelDAO;
import com.example.cdlforum.dao.ChannelMemberDAO;
import com.example.cdlforum.dao.PostDAO;
import com.example.cdlforum.model.Channel;
import com.example.cdlforum.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "postCreateServlet", value = "/post/create")
public class PostCreateServlet extends HttpServlet {

    private final ChannelDAO channelDAO = new ChannelDAO();
    private final ChannelMemberDAO memberDAO = new ChannelMemberDAO();
    private final PostDAO postDAO = new PostDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String channelIdParam = req.getParameter("channelId");
        if (channelIdParam == null) {
            resp.sendRedirect(req.getContextPath() + "/channels");
            return;
        }

        try {
            Channel channel = channelDAO.findById(Integer.parseInt(channelIdParam));
            if (channel == null) {
                resp.sendError(404);
                return;
            }

            req.setAttribute("channel", channel);
            req.getRequestDispatcher("/WEB-INF/views/post_create.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/channels");
        } catch (SQLException e) {
            resp.sendError(500);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String channelIdParam = req.getParameter("channelId");
        String title = req.getParameter("title");
        String content = req.getParameter("content");

        if (channelIdParam == null) {
            resp.sendRedirect(req.getContextPath() + "/channels");
            return;
        }

        if (isBlank(title) || title.trim().length() < 3) {
            forwardWithError(req, resp, channelIdParam, "Title must be at least 3 characters.");
            return;
        }
        if (title.trim().length() > 300) {
            forwardWithError(req, resp, channelIdParam, "Title must be 300 characters or less.");
            return;
        }

        User user = (User) req.getSession().getAttribute("user");
        try {
            int channelId = Integer.parseInt(channelIdParam);
            // Only members can post
            if (!memberDAO.isMember(channelId, user.getId())) {
                forwardWithError(req, resp, channelIdParam, "You must join this channel to post.");
                return;
            }
            var post = postDAO.create(channelId, user.getId(), title, content);
            resp.sendRedirect(req.getContextPath() + "/post?id=" + post.getId());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/channels");
        } catch (SQLException e) {
            forwardWithError(req, resp, channelIdParam, "Database error: " + e.getMessage());
        }
    }

    private void forwardWithError(HttpServletRequest req, HttpServletResponse resp,
            String channelIdParam, String error)
            throws ServletException, IOException {
        try {
            Channel ch = channelDAO.findById(Integer.parseInt(channelIdParam));
            req.setAttribute("channel", ch);
        } catch (Exception ignored) {
        }
        req.setAttribute("error", error);
        req.getRequestDispatcher("/WEB-INF/views/post_create.jsp").forward(req, resp);
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
