package com.example.cdlforum.servlet;

import com.example.cdlforum.dao.*;
import com.example.cdlforum.model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "channelViewServlet", value = "/channel")
public class ChannelViewServlet extends HttpServlet {

    private final ChannelDAO channelDAO = new ChannelDAO();
    private final ChannelMemberDAO memberDAO = new ChannelMemberDAO();
    private final ChannelRuleDAO ruleDAO = new ChannelRuleDAO();
    private final PostDAO postDAO = new PostDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String idParam = req.getParameter("id");
        if (idParam == null) {
            resp.sendRedirect(req.getContextPath() + "/channels");
            return;
        }

        try {
            int channelId = Integer.parseInt(idParam);
            Channel channel = channelDAO.findById(channelId);
            if (channel == null) {
                resp.sendError(404, "Channel not found.");
                return;
            }

            User currentUser = (User) req.getSession().getAttribute("user");
            String role = memberDAO.getRole(channelId, currentUser.getId());
            List<ChannelRule> rules = ruleDAO.getRules(channelId);

            // Post sorting
            String sort = req.getParameter("sort");
            if (sort == null)
                sort = "new";
            List<Post> posts = postDAO.findByChannel(channelId, sort, currentUser.getId());

            req.setAttribute("channel", channel);
            req.setAttribute("userRole", role);
            req.setAttribute("isOwner", channel.getOwnerId() == currentUser.getId());
            req.setAttribute("isMember", role != null);
            req.setAttribute("rules", rules);
            req.setAttribute("posts", posts);
            req.setAttribute("sort", sort);

            req.getRequestDispatcher("/WEB-INF/views/channel_view.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/channels");
        } catch (SQLException e) {
            req.setAttribute("error", "Database error.");
            req.getRequestDispatcher("/WEB-INF/views/channel_view.jsp").forward(req, resp);
        }
    }
}
