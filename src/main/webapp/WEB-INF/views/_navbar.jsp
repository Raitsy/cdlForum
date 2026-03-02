<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.cdlforum.model.User,
                 com.example.cdlforum.util.I18nUtil,
                 java.net.URLEncoder,
                 java.nio.charset.StandardCharsets" %>

<%
    User _navUser = (User) session.getAttribute("user");
    String _ctx = request.getContextPath();

    String _lang = I18nUtil.getLang(request);

    // Keep full current URL (path + query) so language switch returns to same page
    String _currentUri = request.getRequestURI();
    String _qs = request.getQueryString();
    if (_qs != null && !_qs.isEmpty()) _currentUri = _currentUri + "?" + _qs;

    String _encodedUri = URLEncoder.encode(_currentUri, StandardCharsets.UTF_8);
%>

<nav class="navbar">
    <a href="<%= _ctx %>/home" class="nav-brand">CDL Forum</a>

    <div class="navbar-actions">

        <!-- Explore button -->
        <a href="<%= _ctx %>/channels" class="btn-nav-explore">
            <%= I18nUtil.msg(request, "nav.explore") %>
        </a>

        <!-- Profile dropdown -->
        <div class="profile-dropdown" id="profileDropdown">
            <button class="profile-btn" id="profileBtn" type="button"
                    onclick="toggleProfileDropdown()"
                    aria-haspopup="true" aria-expanded="false">
                <span class="profile-avatar">
                    <%= (_navUser != null) ? _navUser.getUsername().substring(0, 1).toUpperCase() : "?" %>
                </span>
                <span class="profile-username">
                    <%= (_navUser != null) ? _navUser.getUsername() : "" %>
                </span>
                <span class="dropdown-caret">&#9660;</span>
            </button>

            <div class="profile-dropdown-menu" role="menu">

                <!-- Profile settings -->
                <div class="dropdown-section">
                    <a href="<%= _ctx %>/profile" class="dropdown-item" role="menuitem">
                        <span class="di-icon">&#9675;</span>
                        <%= I18nUtil.msg(request, "nav.profile.settings") %>
                    </a>
                </div>

                <div class="dropdown-divider"></div>

                <!-- Theme selector -->
                <div class="dropdown-section">
                    <div class="dropdown-label"><%= I18nUtil.msg(request, "nav.theme") %></div>
                    <div class="theme-toggle-row">
                        <button class="theme-btn" id="themeLightBtn" type="button" onclick="setTheme('light')">
                            &#9728; <%= I18nUtil.msg(request, "nav.theme.light") %>
                        </button>
                        <button class="theme-btn" id="themeDarkBtn" type="button" onclick="setTheme('dark')">
                            &#9790; <%= I18nUtil.msg(request, "nav.theme.dark") %>
                        </button>
                    </div>
                </div>

                <div class="dropdown-divider"></div>

                <!-- Language selector -->
                <div class="dropdown-section">
                    <div class="dropdown-label"><%= I18nUtil.msg(request, "nav.language") %></div>
                    <div class="lang-picker">
                        <a href="<%= _ctx %>/lang?set=fr&redirect=<%= _encodedUri %>"
                           class="lang-pick-btn <%= "fr".equals(_lang) ? "active" : "" %>">Fran&ccedil;ais</a>
                        <a href="<%= _ctx %>/lang?set=en&redirect=<%= _encodedUri %>"
                           class="lang-pick-btn <%= "en".equals(_lang) ? "active" : "" %>">English</a>
                    </div>
                </div>

                <div class="dropdown-divider"></div>

                <!-- Logout -->
                <div class="dropdown-section">
                    <form method="get" action="<%= _ctx %>/logout">
                        <button type="submit" class="dropdown-item dropdown-item-danger" role="menuitem">
                            <span class="di-icon">&#8594;</span>
                            <%= I18nUtil.msg(request, "nav.logout") %>
                        </button>
                    </form>
                </div>

            </div><!-- /.profile-dropdown-menu -->
        </div><!-- /.profile-dropdown -->

    </div><!-- /.navbar-actions -->
</nav>

<script>
    function toggleProfileDropdown() {
        const dd = document.getElementById('profileDropdown');
        const btn = document.getElementById('profileBtn');
        const isOpen = dd.classList.toggle('open');
        btn.setAttribute('aria-expanded', isOpen);
    }

    // Close dropdown on outside click
    document.addEventListener('click', function (e) {
        const dd = document.getElementById('profileDropdown');
        if (dd && !dd.contains(e.target)) dd.classList.remove('open');
    }, true);

    function setTheme(theme) {
        document.documentElement.setAttribute('data-theme', theme);
        localStorage.setItem('cdl-theme', theme);
        const lb = document.getElementById('themeLightBtn');
        const db = document.getElementById('themeDarkBtn');
        if (lb) lb.classList.toggle('active', theme === 'light');
        if (db) db.classList.toggle('active', theme === 'dark');
    }

    // Sync theme button states with current theme
    (function () {
        const t = localStorage.getItem('cdl-theme') || 'light';
        const lb = document.getElementById('themeLightBtn');
        const db = document.getElementById('themeDarkBtn');
        if (lb) lb.classList.toggle('active', t === 'light');
        if (db) db.classList.toggle('active', t === 'dark');
    })();
</script>