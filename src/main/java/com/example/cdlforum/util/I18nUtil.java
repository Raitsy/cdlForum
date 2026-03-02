package com.example.cdlforum.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.util.Locale;
import java.util.MissingResourceException;
import java.util.ResourceBundle;

/**
 * Jakarta EE classic i18n helper.
 *
 * Reads the "lang" attribute from the HTTP session (set by LanguageServlet).
 * Falls back to French when no preference is stored.
 *
 * Usage in JSP: <%= I18nUtil.msg(request, "nav.explore") %>
 */
public class I18nUtil {

    private static final String BUNDLE_BASE = "messages";
    private static final String DEFAULT_LANG = "fr";

    /** Resolve a message key for the current session locale. */
    public static String msg(HttpServletRequest request, String key) {
        String lang = getLang(request);
        try {
            ResourceBundle bundle = ResourceBundle.getBundle(BUNDLE_BASE, new Locale(lang));
            return bundle.getString(key);
        } catch (MissingResourceException e) {
            try {
                // Fallback to French
                ResourceBundle fallback = ResourceBundle.getBundle(BUNDLE_BASE, new Locale(DEFAULT_LANG));
                return fallback.getString(key);
            } catch (MissingResourceException ex) {
                return key; // Return key as last resort
            }
        }
    }

    /** Return the current language code ("en" or "fr"). */
    public static String getLang(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Object lang = session.getAttribute("lang");
            if (lang instanceof String)
                return (String) lang;
        }
        return DEFAULT_LANG;
    }
}
