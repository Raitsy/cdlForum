package com.example.cdlforum.servlet;

import com.example.cdlforum.dao.ChannelDAO;
import com.example.cdlforum.dao.ChannelRuleDAO;
import com.example.cdlforum.model.Channel;
import com.example.cdlforum.model.ChannelRule;
import com.example.cdlforum.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "channelRulesServlet", value = "/channel/rules")
public class ChannelRulesServlet extends HttpServlet {

    private final ChannelDAO channelDAO = new ChannelDAO();
    private final ChannelRuleDAO ruleDAO = new ChannelRuleDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Channel channel = loadAndAuthorize(req, resp);
        if (channel == null)
            return;

        try {
            List<ChannelRule> rules = ruleDAO.getRules(channel.getId());
            req.setAttribute("channel", channel);
            req.setAttribute("rules", rules);
            req.getRequestDispatcher("/WEB-INF/views/channel_rules.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("error", "Database error.");
            req.getRequestDispatcher("/WEB-INF/views/channel_rules.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Channel channel = loadAndAuthorize(req, resp);
        if (channel == null)
            return;

        String action = req.getParameter("action");

        try {
            switch (action == null ? "" : action) {
                case "add" -> {
                    String title = req.getParameter("title");
                    String desc = req.getParameter("description");
                    if (!isBlank(title))
                        ruleDAO.addRule(channel.getId(), title, desc);
                }
                case "edit" -> {
                    int ruleId = Integer.parseInt(req.getParameter("ruleId"));
                    String title = req.getParameter("title");
                    String desc = req.getParameter("description");
                    if (!isBlank(title))
                        ruleDAO.updateRule(ruleId, channel.getId(), title, desc);
                }
                case "delete" -> {
                    int ruleId = Integer.parseInt(req.getParameter("ruleId"));
                    ruleDAO.deleteRule(ruleId, channel.getId());
                }
            }
            resp.sendRedirect(req.getContextPath() + "/channel/rules?id=" + channel.getId());
        } catch (SQLException | NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/channel/rules?id=" + channel.getId() + "&error=true");
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

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
