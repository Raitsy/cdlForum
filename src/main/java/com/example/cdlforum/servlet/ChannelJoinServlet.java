package com.example.cdlforum.servlet;

import com.example.cdlforum.dao.ChannelDAO;
import com.example.cdlforum.dao.ChannelMemberDAO;
import com.example.cdlforum.model.Channel;
import com.example.cdlforum.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "channelJoinServlet", urlPatterns = { "/channel/join", "/channel/leave" })
public class ChannelJoinServlet extends HttpServlet {

    private final ChannelDAO channelDAO = new ChannelDAO();
    private final ChannelMemberDAO memberDAO = new ChannelMemberDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String idParam = req.getParameter("channelId");
        if (idParam == null) {
            resp.sendRedirect(req.getContextPath() + "/channels");
            return;
        }

        try {
            int channelId = Integer.parseInt(idParam);
            User currentUser = (User) req.getSession().getAttribute("user");
            Channel channel = channelDAO.findById(channelId);

            if (channel == null) {
                resp.sendRedirect(req.getContextPath() + "/channels");
                return;
            }

            String action = req.getServletPath(); // /channel/join or /channel/leave

            if ("/channel/join".equals(action)) {
                memberDAO.join(channelId, currentUser.getId(), "MEMBER");
            } else {
                // Owners cannot leave their own channel
                if (channel.getOwnerId() == currentUser.getId()) {
                    resp.sendRedirect(req.getContextPath() + "/channel?id=" + channelId + "&error=owner_cannot_leave");
                    return;
                }
                memberDAO.leave(channelId, currentUser.getId());
            }

            resp.sendRedirect(req.getContextPath() + "/channel?id=" + channelId);

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/channels");
        } catch (SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/channels");
        }
    }
}
