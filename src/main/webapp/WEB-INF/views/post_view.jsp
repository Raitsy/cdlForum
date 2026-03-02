<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.cdlforum.model.User,
                 com.example.cdlforum.model.Post,
                 com.example.cdlforum.model.Comment,
                 com.example.cdlforum.model.Channel,
                 com.example.cdlforum.model.ChannelRule,
                 java.util.List" %>

<%
    User currentUser = (User) session.getAttribute("user");
    Post post = (Post) request.getAttribute("post");
    Channel channel = (Channel) request.getAttribute("channel");

    List<Comment> comments = (List<Comment>) request.getAttribute("comments");
    List<ChannelRule> rules = (List<ChannelRule>) request.getAttribute("rules");

    boolean isOwner = Boolean.TRUE.equals(request.getAttribute("isOwner"));
    boolean isMember = Boolean.TRUE.equals(request.getAttribute("isMember"));
    boolean canModerate = Boolean.TRUE.equals(request.getAttribute("canModerate"));

    String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><%= (post != null) ? post.getTitle() : "Publication" %> – CDL Forum</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css" />
</head>

<body>
<div class="app-wrapper">

    <nav class="navbar">
        <a href="<%= ctx %>/home" class="nav-brand">CDL Forum</a>

        <div class="navbar-center">
            <% if (channel != null) { %>
            <span class="breadcrumb">
                    <a href="<%= ctx %>/channels">Canaux</a> ›
                    <a href="<%= ctx %>/channel?id=<%= channel.getId() %>">c/<%= channel.getName() %></a> ›
                    Publication
                </span>
            <% } %>
        </div>

        <div class="navbar-right">
            <span class="user-pill"><%= (currentUser != null) ? currentUser.getUsername() : "Invité" %></span>
            <form method="get" action="<%= ctx %>/logout" style="margin:0;">
                <button type="submit" class="btn-logout">Déconnexion</button>
            </form>
        </div>
    </nav>

    <% if (post != null) { %>
    <div class="post-layout">

        <!-- Main column -->
        <main class="post-main">

            <!-- Post card -->
            <div class="post-detail-card">
                <div class="vote-panel">
                    <form method="post" action="<%= ctx %>/post/vote">
                        <input type="hidden" name="postId" value="<%= post.getId() %>" />
                        <button type="submit"
                                class="vote-btn <%= post.isHasVoted() ? "voted" : "" %>"
                                title="<%= post.isHasVoted() ? "Retirer le vote" : "Voter pour cette publication" %>">▲</button>
                    </form>
                    <span class="vote-count"><%= post.getVoteCount() %></span>
                </div>

                <div class="post-detail-body">
                    <div class="post-meta-row">
                        <% if (post.isPinned()) { %>
                        <span class="pin-badge">Épinglé</span>
                        <% } %>

                        <span class="post-author">
                            Publié par <strong>u/<%= post.getAuthorUsername() %></strong>
                        </span>

                        <span class="post-date">
                            <%= (post.getCreatedAt() != null) ? post.getCreatedAt().toLocalDate().toString() : "" %>
                        </span>
                    </div>

                    <h1 class="post-title-lg"><%= post.getTitle() %></h1>

                    <% if (post.getContent() != null && !post.getContent().isEmpty()) { %>
                    <div class="post-content-body">
                        <%= post.getContent().replace("\n", "<br/>") %>
                    </div>
                    <% } %>

                    <div class="post-action-row">
                        <span class="post-stat">
                            <%= post.getCommentCount() %> commentaire<%= (post.getCommentCount() != 1) ? "s" : "" %>
                        </span>

                        <% if (canModerate || (currentUser != null && post.getAuthorId() == currentUser.getId())) { %>
                        <form method="post" action="<%= ctx %>/post/delete"
                              style="display:inline;"
                              onsubmit="return confirm('Supprimer cette publication et ses commentaires ?')">
                            <input type="hidden" name="type" value="post" />
                            <input type="hidden" name="id" value="<%= post.getId() %>" />
                            <button type="submit" class="post-action-link danger">Supprimer</button>
                        </form>
                        <% } %>

                        <% if (isOwner) { %>
                        <form method="post" action="<%= ctx %>/post/pin" style="display:inline;">
                            <input type="hidden" name="postId" value="<%= post.getId() %>" />
                            <input type="hidden" name="pinned" value="<%= post.isPinned() ? "false" : "true" %>" />
                            <button type="submit" class="post-action-link">
                                <%= post.isPinned() ? "Désépingler" : "Épingler" %>
                            </button>
                        </form>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- Comment form -->
            <% if (isMember) { %>
            <div class="comment-form-card">
                <div class="comment-form-label">Laisser un commentaire</div>
                <form method="post" action="<%= ctx %>/post/comment">
                    <input type="hidden" name="postId" value="<%= post.getId() %>" />
                    <textarea name="content" rows="3" required
                              placeholder="Partagez votre analyse ou posez une question…"></textarea>
                    <div style="text-align:right;margin-top:.4rem;">
                        <button type="submit" class="btn-primary-sm">Commenter</button>
                    </div>
                </form>
            </div>
            <% } else { %>
            <div class="comment-form-card comment-join-prompt">
                Rejoignez ce canal pour pouvoir commenter.
                <form method="post" action="<%= ctx %>/channel/join">
                    <input type="hidden" name="channelId" value="<%= (channel != null) ? channel.getId() : "" %>" />
                    <button type="submit" class="btn-primary-sm">Rejoindre</button>
                </form>
            </div>
            <% } %>

            <!-- Comments -->
            <div id="comments" class="comments-section">
                <div class="comments-header">
                    <%= (comments != null) ? comments.size() : 0 %> Commentaire<%= (comments != null && comments.size() != 1) ? "s" : "" %>
                </div>

                <% if (comments == null || comments.isEmpty()) { %>
                <div class="no-comments">
                    <div class="placeholder-icon">—</div>
                    <p>Aucun commentaire. Soyez le premier à contribuer.</p>
                </div>
                <% } else { %>
                <% for (Comment c : comments) { %>
                <div class="comment-card" id="comment-<%= c.getId() %>">
                    <div class="comment-avatar">
                        <%= c.getAuthorUsername().substring(0, 1).toUpperCase() %>
                    </div>

                    <div class="comment-body">
                        <div class="comment-meta">
                            <strong>u/<%= c.getAuthorUsername() %></strong>
                            <span class="comment-date">
                                        <%= (c.getCreatedAt() != null) ? c.getCreatedAt().toLocalDate().toString() : "" %>
                                    </span>
                        </div>

                        <div class="comment-content">
                            <%= c.getContent().replace("\n", "<br/>") %>
                        </div>

                        <div class="comment-actions">
                            <% if (isMember) { %>
                            <button class="comment-action-btn"
                                    onclick="toggleReply(<%= c.getId() %>)">Répondre</button>
                            <% } %>

                            <% if (canModerate || (currentUser != null && c.getAuthorId() == currentUser.getId())) { %>
                            <form method="post" action="<%= ctx %>/post/delete"
                                  style="display:inline;"
                                  onsubmit="return confirm('Supprimer ce commentaire ?')">
                                <input type="hidden" name="type" value="comment" />
                                <input type="hidden" name="id" value="<%= c.getId() %>" />
                                <button type="submit" class="comment-action-btn danger">Supprimer</button>
                            </form>
                            <% } %>
                        </div>

                        <% if (isMember) { %>
                        <div id="replyForm-<%= c.getId() %>" class="reply-form" style="display:none;">
                            <form method="post" action="<%= ctx %>/post/comment">
                                <input type="hidden" name="postId" value="<%= post.getId() %>" />
                                <input type="hidden" name="parentId" value="<%= c.getId() %>" />
                                <textarea name="content" rows="2" required
                                          placeholder="Répondre à u/<%= c.getAuthorUsername() %>…"></textarea>
                                <div class="reply-form-actions">
                                    <button type="submit" class="btn-primary-sm">Répondre</button>
                                    <button type="button" class="btn-outline-sm"
                                            onclick="toggleReply(<%= c.getId() %>)">Annuler</button>
                                </div>
                            </form>
                        </div>
                        <% } %>

                        <!-- Replies -->
                        <% if (c.getReplies() != null && !c.getReplies().isEmpty()) { %>
                        <div class="replies-list">
                            <% for (Comment reply : c.getReplies()) { %>
                            <div class="comment-card reply-card" id="comment-<%= reply.getId() %>">
                                <div class="comment-avatar-sm">
                                    <%= reply.getAuthorUsername().substring(0, 1).toUpperCase() %>
                                </div>

                                <div class="comment-body">
                                    <div class="comment-meta">
                                        <strong>u/<%= reply.getAuthorUsername() %></strong>
                                        <span class="comment-date">
                                                            <%= (reply.getCreatedAt() != null) ? reply.getCreatedAt().toLocalDate().toString() : "" %>
                                                        </span>
                                    </div>

                                    <div class="comment-content">
                                        <%= reply.getContent().replace("\n", "<br/>") %>
                                    </div>

                                    <div class="comment-actions">
                                        <% if (canModerate || (currentUser != null && reply.getAuthorId() == currentUser.getId())) { %>
                                        <form method="post" action="<%= ctx %>/post/delete"
                                              style="display:inline;"
                                              onsubmit="return confirm('Supprimer cette réponse ?')">
                                            <input type="hidden" name="type" value="comment" />
                                            <input type="hidden" name="id" value="<%= reply.getId() %>" />
                                            <button type="submit" class="comment-action-btn danger">Supprimer</button>
                                        </form>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                            <% } %>
                        </div>
                        <% } %>

                    </div>
                </div>
                <% } %>
                <% } %>
            </div>

        </main>

        <!-- Right sidebar -->
        <aside class="post-sidebar">
            <% if (channel != null) { %>
            <div class="card">
                <div class="card-title">À propos de c/<%= channel.getName() %></div>

                <p class="channel-description">
                    <%= (channel.getDescription() != null && !channel.getDescription().isEmpty())
                            ? channel.getDescription()
                            : "Aucune description." %>
                </p>

                <div class="channel-about-meta">
                    <div>
                        <span class="meta-label">Membres</span>
                        <strong><%= channel.getMemberCount() %></strong>
                    </div>
                </div>

                <div style="margin-top:.75rem;">
                    <a href="<%= ctx %>/channel?id=<%= channel.getId() %>"
                       class="btn-outline-sm"
                       style="width:100%;display:block;text-align:center;">Voir le canal</a>
                </div>
            </div>
            <% } %>

            <% if (rules != null && !rules.isEmpty()) { %>
            <div class="card">
                <div class="card-title">Règles de la communauté</div>
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
        </aside>

    </div>
    <% } %>

</div>

<script>
    function toggleReply(id) {
        const el = document.getElementById('replyForm-' + id);
        if (el) el.style.display = (el.style.display === 'none') ? 'block' : 'none';
    }
</script>

</body>
</html>