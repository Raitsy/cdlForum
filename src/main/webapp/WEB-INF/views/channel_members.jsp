<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="
    com.example.cdlforum.model.User,
    com.example.cdlforum.model.Channel,
    com.example.cdlforum.model.ChannelMember,
    java.util.List
" %>
        <% User currentUser=(User) session.getAttribute("user"); Channel channel=(Channel)
            request.getAttribute("channel"); List<ChannelMember> members = (List<ChannelMember>)
                request.getAttribute("members");
                String ctx = request.getContextPath();
                int channelId = channel != null ? channel.getId() : 0;
                %>
                <!DOCTYPE html>
                <html lang="fr">

                <head>
                    <meta charset="UTF-8" />
                    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                    <title>Membres – c/<%= channel !=null ? channel.getName() : "Canal" %> – CDL Forum</title>
                    <link rel="stylesheet" href="<%= ctx %>/css/style.css" />
                </head>

                <body>
                    <div class="app-wrapper">
                        <nav class="navbar">
                            <a href="<%= ctx %>/home" class="nav-brand">CDL Forum</a>
                            <div class="navbar-center">
                                <% if (channel !=null) { %>
                                    <span class="breadcrumb">
                                        <a href="<%= ctx %>/channel?id=<%= channelId %>">c/<%= channel.getName() %></a>
                                        › Membres
                                    </span>
                                    <% } %>
                            </div>
                            <div class="navbar-right">
                                <span class="user-pill">
                                    <%= currentUser.getUsername() %>
                                </span>
                                <form method="get" action="<%= ctx %>/logout" style="margin:0;">
                                    <button type="submit" class="btn-logout">Déconnexion</button>
                                </form>
                            </div>
                        </nav>

                        <div class="page-container">
                            <div class="page-header">
                                <div>
                                    <div class="page-title">Gestion des membres</div>
                                    <% if (channel !=null) { %>
                                        <div class="page-subtitle">c/<%= channel.getName() %>
                                                · <%= members !=null ? members.size() : 0 %> membres</div>
                                        <% } %>
                                </div>
                                <a href="<%= ctx %>/channel?id=<%= channelId %>" class="btn-outline-sm">Retour au
                                    canal</a>
                            </div>

                            <% if (request.getAttribute("success") !=null) { %>
                                <div class="alert alert-success">${success}</div>
                                <% } %>
                                    <% if (request.getAttribute("error") !=null) { %>
                                        <div class="alert alert-error">${error}</div>
                                        <% } %>

                                            <div class="card">
                                                <% if (members==null || members.isEmpty()) { %>
                                                    <p style="font-size:.82rem;color:var(--clr-muted);">Aucun membre
                                                        trouvé.</p>
                                                    <% } else { %>
                                                        <table class="members-table">
                                                            <thead>
                                                                <tr>
                                                                    <th>Utilisateur</th>
                                                                    <th>Rôle</th>
                                                                    <th>Membre depuis</th>
                                                                    <th>Actions</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <% for (ChannelMember m : members) { %>
                                                                    <tr>
                                                                        <td>
                                                                            <div class="member-username">
                                                                                <div class="avatar-sm">
                                                                                    <%= m.getUsername() !=null ?
                                                                                        m.getUsername().substring(0,1).toUpperCase()
                                                                                        : "?" %>
                                                                                </div>
                                                                                <%= m.getUsername() %>
                                                                            </div>
                                                                        </td>
                                                                        <td>
                                                                            <span
                                                                                class="role-badge role-<%= m.getRole().toLowerCase() %>">
                                                                                <%= "OWNER" .equals(m.getRole())
                                                                                    ? "Propriétaire" : "MODERATOR"
                                                                                    .equals(m.getRole()) ? "Modérateur"
                                                                                    : "Membre" %>
                                                                            </span>
                                                                        </td>
                                                                        <td class="member-date">
                                                                            <%= m.getJoinedAt() !=null ?
                                                                                m.getJoinedAt().toLocalDate().toString()
                                                                                : "—" %>
                                                                        </td>
                                                                        <td>
                                                                            <div class="member-actions">
                                                                                <% if (!"OWNER".equals(m.getRole())) {
                                                                                    %>
                                                                                    <% if ("MEMBER".equals(m.getRole()))
                                                                                        { %>
                                                                                        <form method="post"
                                                                                            action="<%= ctx %>/channel/members">
                                                                                            <input type="hidden"
                                                                                                name="action"
                                                                                                value="promote" />
                                                                                            <input type="hidden"
                                                                                                name="channelId"
                                                                                                value="<%= channelId %>" />
                                                                                            <input type="hidden"
                                                                                                name="userId"
                                                                                                value="<%= m.getUserId() %>" />
                                                                                            <button
                                                                                                class="btn-action btn-promote"
                                                                                                type="submit">Promouvoir</button>
                                                                                        </form>
                                                                                        <% } else if
                                                                                            ("MODERATOR".equals(m.getRole()))
                                                                                            { %>
                                                                                            <form method="post"
                                                                                                action="<%= ctx %>/channel/members">
                                                                                                <input type="hidden"
                                                                                                    name="action"
                                                                                                    value="demote" />
                                                                                                <input type="hidden"
                                                                                                    name="channelId"
                                                                                                    value="<%= channelId %>" />
                                                                                                <input type="hidden"
                                                                                                    name="userId"
                                                                                                    value="<%= m.getUserId() %>" />
                                                                                                <button
                                                                                                    class="btn-action btn-demote"
                                                                                                    type="submit">Rétrograder</button>
                                                                                            </form>
                                                                                            <% } %>
                                                                                                <form method="post"
                                                                                                    action="<%= ctx %>/channel/members"
                                                                                                    onsubmit="return confirm('Retirer ce membre ?')">
                                                                                                    <input type="hidden"
                                                                                                        name="action"
                                                                                                        value="remove" />
                                                                                                    <input type="hidden"
                                                                                                        name="channelId"
                                                                                                        value="<%= channelId %>" />
                                                                                                    <input type="hidden"
                                                                                                        name="userId"
                                                                                                        value="<%= m.getUserId() %>" />
                                                                                                    <button
                                                                                                        class="btn-action btn-remove"
                                                                                                        type="submit">Retirer</button>
                                                                                                </form>
                                                                                                <% } %>
                                                                            </div>
                                                                        </td>
                                                                    </tr>
                                                                    <% } %>
                                                            </tbody>
                                                        </table>
                                                        <% } %>
                                            </div>
                        </div>
                    </div>
                </body>

                </html>