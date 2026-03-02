<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="com.example.cdlforum.model.User, com.example.cdlforum.model.Channel" %>
        <% User currentUser=(User) session.getAttribute("user"); Channel channel=(Channel)
            request.getAttribute("channel"); String ctx=request.getContextPath(); %>
            <!DOCTYPE html>
            <html lang="fr">

            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>Paramètres – c/<%= channel !=null ? channel.getName() : "Canal" %> – CDL Forum</title>
                <link rel="stylesheet" href="<%= ctx %>/css/style.css" />
            </head>

            <body>
                <div class="app-wrapper">
                    <nav class="navbar">
                        <a href="<%= ctx %>/home" class="nav-brand">CDL Forum</a>
                        <div class="navbar-center">
                            <% if (channel !=null) { %>
                                <span class="breadcrumb">
                                    <a href="<%= ctx %>/channel?id=<%= channel.getId() %>">c/<%= channel.getName() %>
                                            </a> › Paramètres
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

                    <div class="form-page-wrapper">
                        <% if (channel !=null) { %>
                            <div class="form-card" style="max-width:600px;">
                                <div class="form-card-header">
                                    <h1>Paramètres du canal</h1>
                                    <p>Modifier les informations de <strong>c/<%= channel.getName() %></strong></p>
                                </div>

                                <% if (request.getAttribute("success") !=null) { %>
                                    <div class="alert alert-success">${success}</div>
                                    <% } %>
                                        <% if (request.getAttribute("error") !=null) { %>
                                            <div class="alert alert-error">${error}</div>
                                            <% } %>

                                                <form method="post" action="<%= ctx %>/channel/settings"
                                                    enctype="multipart/form-data">
                                                    <input type="hidden" name="channelId"
                                                        value="<%= channel.getId() %>" />

                                                    <div class="form-group">
                                                        <label>Nom du canal</label>
                                                        <input type="text" value="c/<%= channel.getName() %>" disabled
                                                            style="background:var(--clr-surface-alt);color:var(--clr-muted);" />
                                                        <div class="form-hint">Le nom du canal ne peut pas être modifié
                                                            après création.</div>
                                                    </div>

                                                    <div class="form-group">
                                                        <label for="description">Description <span
                                                                class="required">*</span></label>
                                                        <textarea id="description" name="description" rows="4"
                                                            required><%= channel.getDescription() != null ? channel.getDescription() : "" %></textarea>
                                                    </div>

                                                    <hr class="form-divider" />

                                                    <div class="form-group">
                                                        <label>Nouvelle icône</label>
                                                        <input class="file-input" type="file" name="image"
                                                            accept="image/*" />
                                                    </div>
                                                    <div class="form-group">
                                                        <label>Nouvelle bannière</label>
                                                        <input class="file-input" type="file" name="banner"
                                                            accept="image/*" />
                                                    </div>

                                                    <div class="post-create-actions">
                                                        <a href="<%= ctx %>/channel?id=<%= channel.getId() %>"
                                                            class="btn-outline-sm">Annuler</a>
                                                        <button type="submit"
                                                            class="btn-primary-sm">Enregistrer</button>
                                                    </div>
                                                </form>

                                                <hr class="form-divider" />
                                                <div
                                                    style="display:flex;justify-content:space-between;align-items:center;gap:1rem;font-size:.82rem;">
                                                    <a href="<%= ctx %>/channel/rules?id=<%= channel.getId() %>"
                                                        class="btn-outline-sm">Gérer les règles</a>
                                                    <a href="<%= ctx %>/channel/members?id=<%= channel.getId() %>"
                                                        class="btn-outline-sm">Gérer les membres</a>
                                                </div>
                            </div>
                            <% } %>
                    </div>
                </div>
            </body>

            </html>