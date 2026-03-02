<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.cdlforum.model.User,
                 com.example.cdlforum.model.Channel,
                 com.example.cdlforum.model.ChannelRule,
                 com.example.cdlforum.model.Post,
                 com.example.cdlforum.util.I18nUtil,
                 java.util.List" %>

<%
    User currentUser = (User) session.getAttribute("user");
    Channel channel = (Channel) request.getAttribute("channel");

    List<ChannelRule> rules = (List<ChannelRule>) request.getAttribute("rules");
    List<Post> posts = (List<Post>) request.getAttribute("posts");

    boolean isOwner = Boolean.TRUE.equals(request.getAttribute("isOwner"));
    boolean isMember = Boolean.TRUE.equals(request.getAttribute("isMember"));

    String sort = (String) request.getAttribute("sort");
    if (sort == null) sort = "new";

    String ctx = request.getContextPath();
    int channelId = (channel != null) ? channel.getId() : 0;

    String lang = I18nUtil.getLang(request);
    Object userRoleObj = request.getAttribute("userRole");
    String userRole = (userRoleObj != null) ? userRoleObj.toString() : "";
%>

<!DOCTYPE html>
<html lang="<%= lang %>" data-theme="light">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>c/<%= (channel != null) ? channel.getName() : "Canal" %> – CDL Forum</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css" />
    <script src="<%= ctx %>/js/theme-init.js"></script>
</head>

<body>
<div class="app-wrapper">

    <jsp:include page="/WEB-INF/views/_navbar.jsp" />

    <% if (channel != null) { %>
    <!-- Channel Banner -->
    <div class="channel-banner"
         style="<%= (channel.getBannerPath() != null)
                        ? "background-image:url('" + ctx + channel.getBannerPath() + "');"
                        : "" %>">
        <div class="channel-banner-overlay">
            <div class="channel-header-content">
                <div class="channel-icon-lg">
                    <% if (channel.getImagePath() != null) { %>
                    <img src="<%= ctx + channel.getImagePath() %>" alt="" />
                    <% } else { %>
                    <span class="icon-placeholder-lg">
                                <%= channel.getName().substring(0, 1).toUpperCase() %>
                            </span>
                    <% } %>
                </div>

                <div class="channel-header-info">
                    <h1 class="channel-title">c/<%= channel.getName() %></h1>

                    <div class="channel-meta-row">
                            <span class="channel-stat">
                                <strong><%= channel.getMemberCount() %></strong>
                                <%= I18nUtil.msg(request, "channel.members") %>
                            </span>

                        <% if (isOwner) { %>
                        <span class="role-badge role-owner">
                                    <%= "fr".equals(lang) ? "Propriétaire" : "Owner" %>
                                </span>
                        <% } else if ("MODERATOR".equals(userRole)) { %>
                        <span class="role-badge role-mod">
                                    <%= "fr".equals(lang) ? "Modérateur" : "Moderator" %>
                                </span>
                        <% } %>
                    </div>
                </div>

                <div class="channel-header-actions">
                    <% if (!isMember) { %>
                    <form method="post" action="<%= ctx %>/channel/join">
                        <input type="hidden" name="channelId" value="<%= channelId %>" />
                        <button type="submit" class="btn btn-join">
                            <%= I18nUtil.msg(request, "channel.join") %>
                        </button>
                    </form>
                    <% } else if (!isOwner) { %>
                    <form method="post" action="<%= ctx %>/channel/leave">
                        <input type="hidden" name="channelId" value="<%= channelId %>" />
                        <button type="submit" class="btn btn-leave">
                            <%= I18nUtil.msg(request, "channel.leave") %>
                        </button>
                    </form>
                    <% } %>

                    <% if (isMember) { %>
                    <a href="<%= ctx %>/post/create?channelId=<%= channelId %>"
                       class="btn btn-manage">
                        <%= I18nUtil.msg(request, "channel.post") %>
                    </a>
                    <% } %>

                    <% if (isOwner) { %>
                    <a href="<%= ctx %>/channel/settings?id=<%= channelId %>"
                       class="btn btn-manage">
                        <%= I18nUtil.msg(request, "channel.settings") %>
                    </a>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <div class="channel-layout">

        <!-- Left sidebar -->
        <aside class="sidebar-left channel-sidebar">
            <div class="card">
                <div class="card-title"><%= I18nUtil.msg(request, "channel.about") %></div>

                <p class="channel-description">
                    <%= (channel.getDescription() != null && !channel.getDescription().isEmpty())
                            ? channel.getDescription()
                            : "—" %>
                </p>

                <div class="channel-about-meta">
                    <div>
                        <span class="meta-label"><%= "fr".equals(lang) ? "Membres" : "Members" %></span>
                        <strong><%= channel.getMemberCount() %></strong>
                    </div>
                    <div>
                        <span class="meta-label"><%= I18nUtil.msg(request, "channel.created") %></span>
                        <strong><%= (channel.getCreatedAt() != null)
                                ? channel.getCreatedAt().toLocalDate().toString()
                                : "—" %></strong>
                    </div>
                </div>

                <% if (isMember) { %>
                <div style="margin-top:.75rem;">
                    <a href="<%= ctx %>/post/create?channelId=<%= channelId %>"
                       class="btn-create-channel" style="font-size:.78rem;">
                        <%= I18nUtil.msg(request, "channel.create.post") %>
                    </a>
                </div>
                <% } %>
            </div>

            <% if (isOwner) { %>
            <div class="card card-manage-links">
                <div class="card-title"><%= I18nUtil.msg(request, "channel.admin") %></div>

                <a href="<%= ctx %>/channel/settings?id=<%= channelId %>" class="manage-link">
                    <%= I18nUtil.msg(request, "channel.settings") %>
                </a>

                <a href="<%= ctx %>/channel/rules?id=<%= channelId %>" class="manage-link">
                    <%= "fr".equals(lang) ? "Gérer les règles" : "Manage rules" %>
                </a>

                <a href="<%= ctx %>/channel/members?id=<%= channelId %>" class="manage-link">
                    <%= "fr".equals(lang) ? "Gérer les membres" : "Manage members" %>
                </a>
            </div>
            <% } %>
        </aside>

        <!-- Main feed -->
        <main class="main-feed">
            <div class="sort-tabs">
                <a href="<%= ctx %>/channel?id=<%= channelId %>&sort=new"
                   class="sort-tab <%= "new".equals(sort) ? "active" : "" %>">
                    <%= I18nUtil.msg(request, "channel.sort.new") %>
                </a>

                <a href="<%= ctx %>/channel?id=<%= channelId %>&sort=top"
                   class="sort-tab <%= "top".equals(sort) ? "active" : "" %>">
                    <%= I18nUtil.msg(request, "channel.sort.top") %>
                </a>

                <a href="<%= ctx %>/channel?id=<%= channelId %>&sort=hot"
                   class="sort-tab <%= "hot".equals(sort) ? "active" : "" %>">
                    <%= I18nUtil.msg(request, "channel.sort.hot") %>
                </a>
            </div>

            <% if (posts == null || posts.isEmpty()) { %>
            <div class="feed-placeholder">
                <div class="placeholder-icon">—</div>
                <h3><%= I18nUtil.msg(request, "channel.empty.title") %></h3>
                <p><%= I18nUtil.msg(request, "channel.empty.sub") %></p>

                <% if (isMember) { %>
                <a href="<%= ctx %>/post/create?channelId=<%= channelId %>"
                   class="btn-primary-sm">
                    <%= I18nUtil.msg(request, "channel.create.post") %>
                </a>
                <% } %>
            </div>
            <% } else { %>
            <% for (Post p : posts) { %>
            <div class="post-card">
                <div class="post-vote">
                    <form method="post" action="<%= ctx %>/post/vote">
                        <input type="hidden" name="postId" value="<%= p.getId() %>" />
                        <button type="submit"
                                class="vote-btn-sm <%= p.isHasVoted() ? "voted" : "" %>">▲</button>
                    </form>
                    <span class="vote-count-sm"><%= p.getVoteCount() %></span>
                </div>

                <div class="post-card-body">
                    <% if (p.isPinned()) { %>
                    <span class="pin-badge-sm">&#x25CE;</span>
                    <% } %>

                    <a href="<%= ctx %>/post?id=<%= p.getId() %>" class="post-card-title">
                        <%= p.getTitle() %>
                    </a>

                    <div class="post-card-meta">
                        <span>u/<%= p.getAuthorUsername() %></span>

                        <span class="post-stat">
                                        <%= p.getCommentCount() %>
                                        <%= (p.getCommentCount() == 1)
                                                ? I18nUtil.msg(request, "post.comment")
                                                : I18nUtil.msg(request, "post.comments") %>
                                    </span>

                        <span>
                                        <%= (p.getCreatedAt() != null)
                                                ? p.getCreatedAt().toLocalDate().toString()
                                                : "" %>
                                    </span>
                    </div>
                </div>
            </div>
            <% } %>
            <% } %>
        </main>

        <!-- Right sidebar -->
        <aside class="sidebar-right">
            <% if (rules != null && !rules.isEmpty()) { %>
            <div class="card">
                <div class="card-title"><%= I18nUtil.msg(request, "channel.rules") %></div>

                <ol class="rules-list">
                    <% for (ChannelRule rule : rules) { %>
                    <li class="rule-item">
                        <div class="rule-title"><%= rule.getTitle() %></div>
                        <% if (rule.getDescription() != null && !rule.getDescription().isEmpty()) { %>
                        <div class="rule-desc"><%= rule.getDescription() %></div>
                        <% } %>
                    </li>
                    <% } %>
                </ol>
            </div>
            <% } %>

            <div class="card">
                <div class="card-title"><%= I18nUtil.msg(request, "channel.info") %></div>

                <div class="channel-about-meta">
                    <div>
                        <span class="meta-label"><%= "fr".equals(lang) ? "Membres" : "Members" %></span>
                        <strong><%= channel.getMemberCount() %></strong>
                    </div>

                    <div>
                        <span class="meta-label"><%= I18nUtil.msg(request, "channel.created") %></span>
                        <strong><%= (channel.getCreatedAt() != null)
                                ? channel.getCreatedAt().toLocalDate().toString()
                                : "—" %></strong>
                    </div>
                </div>
            </div>
        </aside>

    </div>
    <% } %>

</div>
</body>
</html>