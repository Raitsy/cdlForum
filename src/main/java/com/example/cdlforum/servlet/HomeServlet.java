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
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(name = "homeServlet", value = "/home")
public class HomeServlet extends HttpServlet {

    private final ChannelDAO channelDAO = new ChannelDAO();
    private final PostDAO postDAO = new PostDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        try {
            List<Channel> joinedChannels = channelDAO.findByMember(user.getId());
            List<Channel> topChannels = channelDAO.findTopChannels(8);

            // Home feed: latest 20 posts from the joined channels
            List<Integer> channelIds = joinedChannels.stream()
                    .map(Channel::getId)
                    .collect(Collectors.toList());
            List<Post> feedPosts = postDAO.findRecentFromChannels(channelIds, 20, user.getId());

            req.setAttribute("joinedChannels", joinedChannels);
            req.setAttribute("topChannels", topChannels);
            req.setAttribute("feedPosts", feedPosts);

            req.getRequestDispatcher("/home.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("error", "Database error.");
            req.getRequestDispatcher("/home.jsp").forward(req, resp);
        }
    }
}
