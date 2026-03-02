package com.example.cdlforum.servlet;

import com.example.cdlforum.util.FileUploadUtil;
import com.example.cdlforum.dao.ChannelDAO;
import com.example.cdlforum.model.Channel;
import com.example.cdlforum.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "channelSettingsServlet", value = "/channel/settings")
@MultipartConfig(maxFileSize = 5_242_880, maxRequestSize = 12_000_000)
public class ChannelSettingsServlet extends HttpServlet {

    private final ChannelDAO channelDAO = new ChannelDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Channel channel = loadAndAuthorize(req, resp);
        if (channel == null)
            return;

        req.setAttribute("channel", channel);
        req.getRequestDispatcher("/WEB-INF/views/channel_settings.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Channel channel = loadAndAuthorize(req, resp);
        if (channel == null)
            return;

        String name = req.getParameter("name");
        String description = req.getParameter("description");

        if (isBlank(name) || name.trim().length() < 3) {
            req.setAttribute("error", "Channel name must be at least 3 characters.");
            req.setAttribute("channel", channel);
            req.getRequestDispatcher("/WEB-INF/views/channel_settings.jsp").forward(req, resp);
            return;
        }

        String slug = CreateChannelServlet.toSlug(name.trim());

        try {
            if (channelDAO.slugExistsExcluding(slug, channel.getId())) {
                req.setAttribute("error", "A channel with that name already exists.");
                req.setAttribute("channel", channel);
                req.getRequestDispatcher("/WEB-INF/views/channel_settings.jsp").forward(req, resp);
                return;
            }

            String webappRoot = getServletContext().getRealPath("/");
            Part imagePart = req.getPart("image");
            Part bannerPart = req.getPart("banner");

            // Only replace if a new file was uploaded
            String imagePath = (imagePart != null && imagePart.getSize() > 0)
                    ? FileUploadUtil.save(imagePart, "channels", webappRoot)
                    : channel.getImagePath();
            String bannerPath = (bannerPart != null && bannerPart.getSize() > 0)
                    ? FileUploadUtil.save(bannerPart, "channels", webappRoot)
                    : channel.getBannerPath();

            channelDAO.update(channel.getId(), name.trim(), slug, description, imagePath, bannerPath);

            resp.sendRedirect(req.getContextPath() + "/channel/settings?id=" + channel.getId() + "&saved=true");

        } catch (SQLException e) {
            req.setAttribute("error", "Database error: " + e.getMessage());
            req.setAttribute("channel", channel);
            req.getRequestDispatcher("/WEB-INF/views/channel_settings.jsp").forward(req, resp);
        }
    }

    /**
     * Returns the channel if the current user is its owner, otherwise redirects and
     * returns null.
     */
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
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Only the channel owner can access settings.");
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
