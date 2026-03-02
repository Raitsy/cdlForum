package com.example.cdlforum.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * Sets the user's preferred language in the session and redirects back.
 *
 * Classical Jakarta EE i18n – language is persisted in the HTTP session.
 *
 * Usage: GET /lang?set=en or GET /lang?set=fr
 * Optional redirect param: ?redirect=/channel?id=3
 */
@WebServlet(name = "languageServlet", value = "/lang")
public class LanguageServlet extends HttpServlet {

    private static final String[] SUPPORTED = { "en", "fr" };

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doPost(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String lang = req.getParameter("set");
        if (lang != null) {
            lang = lang.toLowerCase().trim();
            for (String supported : SUPPORTED) {
                if (supported.equals(lang)) {
                    req.getSession(true).setAttribute("lang", lang);
                    break;
                }
            }
        }

        // Redirect back. Use Referer if available, otherwise home.
        String redirect = req.getParameter("redirect");
        if (redirect == null || redirect.isEmpty()) {
            redirect = req.getHeader("Referer");
        }
        if (redirect == null || redirect.isEmpty()) {
            redirect = req.getContextPath() + "/home";
        }
        resp.sendRedirect(redirect);
    }
}
