package com.example.cdlforum.servlet;

import com.example.cdlforum.dao.ChannelDAO;
import com.example.cdlforum.dao.ChannelMemberDAO;
import com.example.cdlforum.model.Channel;
import com.example.cdlforum.model.ChannelMember;
import com.example.cdlforum.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "channelMembersServlet", value = "/channel/members")
public class ChannelMembersServlet extends HttpServlet {

    private final ChannelDAO channelDAO = new ChannelDAO();
    private final ChannelMemberDAO memberDAO = new ChannelMemberDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Channel channel = loadAndAuthorize(req, resp);
        if (channel == null)
            return;

        try {
            List<ChannelMember> members = memberDAO.getMembers(channel.getId());
            req.setAttribute("channel", channel);
            req.setAttribute("members", members);
            req.getRequestDispatcher("/WEB-INF/views/channel_members.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("error", "Database error.");
            req.getRequestDispatcher("/WEB-INF/views/channel_members.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Channel channel = loadAndAuthorize(req, resp);
        if (channel == null)
            return;

        String action = req.getParameter("action");
        String userIdParam = req.getParameter("userId");

        try {
            int targetUserId = Integer.parseInt(userIdParam);
            // Don't let owner change their own role
            User owner = (User) req.getSession().getAttribute("user");
            if (targetUserId == owner.getId()) {
                resp.sendRedirect(req.getContextPath() + "/channel/members?id=" + channel.getId());
                return;
            }

            switch (action == null ? "" : action) {
                case "promote" -> memberDAO.setRole(channel.getId(), targetUserId, "MODERATOR");
                case "demote" -> memberDAO.setRole(channel.getId(), targetUserId, "MEMBER");
                case "remove" -> memberDAO.leave(channel.getId(), targetUserId);
            }

            resp.sendRedirect(req.getContextPath() + "/channel/members?id=" + channel.getId());

        } catch (NumberFormatException | SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/channel/members?id=" + channel.getId());
        }
    }

    private Channel loadAndAuthorize(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        String idParam = req.getParameter("id");
        if (idParam == null) {
            resp.sendRedirect(req.getContextPath() + "/channels");
            return null;
        }
        try {
            int channelId = Integer.parseInt(idParam);
            Channel ch = channelDAO.findById(channelId);
            if (ch == null) {
                resp.sendError(404);
                return null;
            }
            User user = (User) req.getSession().getAttribute("user");
            if (ch.getOwnerId() != user.getId()) {
                resp.sendError(403);
                return null;
            }
            return ch;
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/channels");
            return null;
        } catch (SQLException e) {
            resp.sendError(500);
            return null;
        }
    }
}
