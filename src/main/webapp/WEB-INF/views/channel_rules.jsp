<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="
    com.example.cdlforum.model.User,
    com.example.cdlforum.model.Channel,
    com.example.cdlforum.model.ChannelRule,
    java.util.List
" %>
        <% User currentUser=(User) session.getAttribute("user"); Channel channel=(Channel)
            request.getAttribute("channel"); List<ChannelRule> rules = (List<ChannelRule>)
                request.getAttribute("rules");
                String ctx = request.getContextPath();
                int channelId = channel != null ? channel.getId() : 0;
                %>
                <!DOCTYPE html>
                <html lang="fr">

                <head>
                    <meta charset="UTF-8" />
                    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                    <title>Règles – c/<%= channel !=null ? channel.getName() : "Canal" %> – CDL Forum</title>
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
                                        › Règles
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

                        <div class="page-container" style="max-width:680px;">
                            <div class="page-header">
                                <div>
                                    <div class="page-title">Règles de la communauté</div>
                                    <% if (channel !=null) { %>
                                        <div class="page-subtitle">c/<%= channel.getName() %>
                                        </div>
                                        <% } %>
                                </div>
                            </div>

                            <% if (request.getAttribute("success") !=null) { %>
                                <div class="alert alert-success">${success}</div>
                                <% } %>
                                    <% if (request.getAttribute("error") !=null) { %>
                                        <div class="alert alert-error">${error}</div>
                                        <% } %>

                                            <!-- Existing rules -->
                                            <div class="card" style="margin-bottom:1.25rem;">
                                                <div class="card-title">Règles actuelles</div>
                                                <% if (rules==null || rules.isEmpty()) { %>
                                                    <p style="font-size:.82rem;color:var(--clr-muted);">Aucune règle
                                                        définie pour le moment.</p>
                                                    <% } else { %>
                                                        <div class="rules-manage-list">
                                                            <% for (ChannelRule rule : rules) { %>
                                                                <div class="rule-manage-item">
                                                                    <span class="rule-manage-pos">
                                                                        <%= rule.getPosition() %>.
                                                                    </span>
                                                                    <div class="rule-manage-content">
                                                                        <strong>
                                                                            <%= rule.getTitle() %>
                                                                        </strong>
                                                                        <% if (rule.getDescription() !=null &&
                                                                            !rule.getDescription().isEmpty()) { %>
                                                                            <div class="rule-desc">
                                                                                <%= rule.getDescription() %>
                                                                            </div>
                                                                            <% } %>
                                                                    </div>
                                                                    <div class="rule-manage-actions">
                                                                        <button class="btn-icon" title="Modifier"
                                                                            onclick="toggleEdit(<%= rule.getId() %>)">✎</button>
                                                                        <form method="post"
                                                                            action="<%= ctx %>/channel/rules"
                                                                            style="display:inline;"
                                                                            onsubmit="return confirm('Supprimer cette règle ?')">
                                                                            <input type="hidden" name="action"
                                                                                value="delete" />
                                                                            <input type="hidden" name="channelId"
                                                                                value="<%= channelId %>" />
                                                                            <input type="hidden" name="ruleId"
                                                                                value="<%= rule.getId() %>" />
                                                                            <button class="btn-icon" title="Supprimer"
                                                                                style="color:var(--clr-error);">✕</button>
                                                                        </form>
                                                                    </div>
                                                                    <!-- Inline edit form -->
                                                                    <div id="editForm-<%= rule.getId() %>"
                                                                        class="rule-edit-form" style="display:none;">
                                                                        <form method="post"
                                                                            action="<%= ctx %>/channel/rules">
                                                                            <input type="hidden" name="action"
                                                                                value="edit" />
                                                                            <input type="hidden" name="channelId"
                                                                                value="<%= channelId %>" />
                                                                            <input type="hidden" name="ruleId"
                                                                                value="<%= rule.getId() %>" />
                                                                            <input type="text" name="title"
                                                                                value="<%= rule.getTitle() %>"
                                                                                placeholder="Titre de la règle"
                                                                                required />
                                                                            <textarea name="description" rows="2"
                                                                                placeholder="Description (facultatif)"><%= rule.getDescription() != null ? rule.getDescription() : "" %></textarea>
                                                                            <div class="rule-edit-btns">
                                                                                <button type="submit"
                                                                                    class="btn-primary-sm">Enregistrer</button>
                                                                                <button type="button"
                                                                                    class="btn-outline-sm"
                                                                                    onclick="toggleEdit(<%= rule.getId() %>)">Annuler</button>
                                                                            </div>
                                                                        </form>
                                                                    </div>
                                                                </div>
                                                                <% } %>
                                                        </div>
                                                        <% } %>
                                            </div>

                                            <!-- Add rule form -->
                                            <div class="card">
                                                <div class="card-title">Ajouter une règle</div>
                                                <form method="post" action="<%= ctx %>/channel/rules">
                                                    <input type="hidden" name="action" value="add" />
                                                    <input type="hidden" name="channelId" value="<%= channelId %>" />
                                                    <div class="form-group">
                                                        <label for="ruleTitle">Titre <span
                                                                class="required">*</span></label>
                                                        <input id="ruleTitle" type="text" name="title" required
                                                            placeholder="ex. Respecter la charte académique" />
                                                    </div>
                                                    <div class="form-group">
                                                        <label for="ruleDesc">Description</label>
                                                        <textarea id="ruleDesc" name="description" rows="2"
                                                            placeholder="Explication détaillée de la règle (facultatif)"></textarea>
                                                    </div>
                                                    <div class="post-create-actions">
                                                        <a href="<%= ctx %>/channel?id=<%= channelId %>"
                                                            class="btn-outline-sm">Retour</a>
                                                        <button type="submit" class="btn-primary-sm">Ajouter la
                                                            règle</button>
                                                    </div>
                                                </form>
                                            </div>
                        </div>
                    </div>
                    <script>
                        function toggleEdit(id) {
                            const el = document.getElementById('editForm-' + id);
                            if (el) el.style.display = el.style.display === 'none' ? 'grid' : 'none';
                        }
                    </script>
                </body>

                </html>