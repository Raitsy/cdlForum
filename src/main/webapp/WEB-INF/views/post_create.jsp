<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="com.example.cdlforum.model.User, com.example.cdlforum.model.Channel" %>
        <% User currentUser=(User) session.getAttribute("user"); Channel channel=(Channel)
            request.getAttribute("channel"); String ctx=request.getContextPath(); %>
            <!DOCTYPE html>
            <html lang="fr">

            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>Nouvelle publication – CDL Forum</title>
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
                                            </a> › Nouvelle publication
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
                        <div class="form-card" style="max-width:720px;">
                            <div class="form-card-header">
                                <h1>Nouvelle publication</h1>
                                <% if (channel !=null) { %>
                                    <p>Publication dans <strong>c/<%= channel.getName() %></strong></p>
                                    <% } %>
                            </div>

                            <% if (request.getAttribute("error") !=null) { %>
                                <div class="alert alert-error">${error}</div>
                                <% } %>

                                    <% if (channel !=null) { %>
                                        <form method="post" action="<%= ctx %>/post/create">
                                            <input type="hidden" name="channelId" value="<%= channel.getId() %>" />

                                            <div class="form-group">
                                                <label for="title">Titre <span class="required">*</span></label>
                                                <input id="title" type="text" name="title" maxlength="300" required
                                                    placeholder="Formulez un titre précis et informatif…" />
                                                <div class="form-hint"><span id="titleCount">0</span> / 300 caractères
                                                </div>
                                            </div>

                                            <div class="form-group">
                                                <label for="content">Contenu <span class="form-hint-inline">—
                                                        optionnel</span></label>
                                                <textarea id="content" name="content" rows="12"
                                                    placeholder="Rédigez votre question, analyse ou article…&#10;&#10;Les blocs de code peuvent être encadrés entre backticks."></textarea>
                                            </div>

                                            <div class="post-create-actions">
                                                <a href="<%= ctx %>/channel?id=<%= channel.getId() %>"
                                                    class="btn-outline-sm">Annuler</a>
                                                <button type="submit" class="btn-primary-sm">Publier</button>
                                            </div>
                                        </form>
                                        <% } else { %>
                                            <div class="alert alert-error">Canal introuvable.</div>
                                            <% } %>
                        </div>
                    </div>
                </div>
                <script>
                    const t = document.getElementById('title');
                    const c = document.getElementById('titleCount');
                    if (t) t.addEventListener('input', () => { c.textContent = t.value.length; });
                </script>
            </body>

            </html>