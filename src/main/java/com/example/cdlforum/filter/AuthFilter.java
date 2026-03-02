package com.example.cdlforum.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebFilter(filterName = "authFilter", urlPatterns = {
        "/home",
        "/channels",
        "/channels/create",
        "/channel",
        "/channel/join",
        "/channel/leave",
        "/channel/settings",
        "/channel/rules",
        "/channel/members",
        "/post",
        "/post/create",
        "/post/vote",
        "/post/comment",
        "/post/delete",
        "/post/pin",
        "/profile",
        "/user"
        // Note: /lang and /logout are NOT filtered
})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        boolean loggedIn = session != null && session.getAttribute("user") != null;

        if (loggedIn) {
            chain.doFilter(request, response);
        } else {
            resp.sendRedirect(req.getContextPath() + "/login");
        }
    }
}
