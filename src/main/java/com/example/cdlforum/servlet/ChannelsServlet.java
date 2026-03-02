package com.example.cdlforum.servlet;

import com.example.cdlforum.dao.ChannelDAO;
import com.example.cdlforum.model.Channel;
import com.example.cdlforum.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "channelsServlet", value = "/channels")
public class ChannelsServlet extends HttpServlet {

    private final ChannelDAO channelDAO = new ChannelDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            List<Channel> channels = channelDAO.findAll();
            req.setAttribute("channels", channels);
            req.getRequestDispatcher("/WEB-INF/views/channels.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("error", "Could not load channels.");
            req.getRequestDispatcher("/WEB-INF/views/channels.jsp").forward(req, resp);
        }
    }
}
