package com.example.cdlforum.servlet;

import com.example.cdlforum.util.FileUploadUtil;
import com.example.cdlforum.dao.ChannelDAO;
import com.example.cdlforum.dao.ChannelMemberDAO;
import com.example.cdlforum.model.Channel;
import com.example.cdlforum.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.text.Normalizer;
import java.util.regex.Pattern;

@WebServlet(name = "createChannelServlet", value = "/channels/create")
@MultipartConfig(maxFileSize = 5_242_880, maxRequestSize = 12_000_000)
public class CreateChannelServlet extends HttpServlet {

    private final ChannelDAO channelDAO = new ChannelDAO();
    private final ChannelMemberDAO memberDAO = new ChannelMemberDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/channel_create.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User currentUser = (User) req.getSession().getAttribute("user");
        String name = req.getParameter("name");
        String description = req.getParameter("description");

        if (isBlank(name) || name.trim().length() < 3) {
            req.setAttribute("error", "Channel name must be at least 3 characters.");
            req.getRequestDispatcher("/WEB-INF/views/channel_create.jsp").forward(req, resp);
            return;
        }
        if (name.trim().length() > 100) {
            req.setAttribute("error", "Channel name must be 100 characters or less.");
            req.getRequestDispatcher("/WEB-INF/views/channel_create.jsp").forward(req, resp);
            return;
        }

        String slug = toSlug(name.trim());

        try {
            if (channelDAO.slugExists(slug)) {
                req.setAttribute("error", "A channel with that name already exists.");
                req.getRequestDispatcher("/WEB-INF/views/channel_create.jsp").forward(req, resp);
                return;
            }

            String webappRoot = getServletContext().getRealPath("/");
            String imagePath = FileUploadUtil.save(req.getPart("image"), "channels", webappRoot);
            String bannerPath = FileUploadUtil.save(req.getPart("banner"), "channels", webappRoot);

            Channel ch = channelDAO.create(name.trim(), slug, description, imagePath, bannerPath,
                    currentUser.getId());

            // Owner automatically joins with OWNER role
            memberDAO.join(ch.getId(), currentUser.getId(), "OWNER");

            resp.sendRedirect(req.getContextPath() + "/channel?id=" + ch.getId());

        } catch (SQLException e) {
            req.setAttribute("error", "Database error: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/channel_create.jsp").forward(req, resp);
        }
    }

    /** Converts a display name to a URL-safe slug. */
    public static String toSlug(String name) {
        String normalized = Normalizer.normalize(name, Normalizer.Form.NFD);
        normalized = Pattern.compile("[^\\p{ASCII}]").matcher(normalized).replaceAll("");
        return normalized.toLowerCase()
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("^-|-$", "");
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
