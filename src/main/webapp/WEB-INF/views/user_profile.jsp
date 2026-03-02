<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.cdlforum.model.User,
                 com.example.cdlforum.model.Post,
                 com.example.cdlforum.util.I18nUtil,
                 java.util.List" %>

<%
    User currentUser = (User) session.getAttribute("user");
    User profileUser = (User) request.getAttribute("profileUser");
    List<Post> userPosts = (List<Post>) request.getAttribute("userPosts");

    boolean isOwnProfile = Boolean.TRUE.equals(request.getAttribute("isOwnProfile"));
    String ctx = request.getContextPath();
    String lang = I18nUtil.getLang(request);

    final int PREVIEW_LEN = 220;
%>

<!DOCTYPE html>
<html lang="<%= lang %>" data-theme="light">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><%= (profileUser != null) ? "u/" + profileUser.getUsername() : "Profil" %> – CDL Forum</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css" />
    <script src="<%= ctx %>/js/theme-init.js"></script>
</head>

<body>
<div class="app-wrapper">
    <jsp:include page="/WEB-INF/views/_navbar.jsp" />

    <% if (profileUser == null) { %>
    <div class="page-container">
        <div class="feed-placeholder">
            <p>Utilisateur introuvable.</p>
        </div>
    </div>
    <% } else { %>

    <div class="user-profile-layout">

        <!-- Left: profile card -->
        <aside class="profile-sidebar">
            <div class="card profile-card">
                <div class="profile-avatar-wrap">
                    <% if (profileUser.getAvatarPath() != null) { %>
                    <img src="<%= ctx + profileUser.getAvatarPath() %>" alt="avatar" class="profile-avatar-img" />
                    <% } else { %>
                    <div class="profile-avatar-placeholder"><%= profileUser.getInitial() %></div>
                    <% } %>
                </div>

                <div class="profile-username-lg">u/<%= profileUser.getUsername() %></div>

                <div class="profile-role-badge">
                        <span class="role-badge <%= profileUser.isProfessor() ? "role-prof" : "role-student" %>">
                            <%= profileUser.isProfessor()
                                    ? ("fr".equals(lang) ? "Professeur" : "Professor")
                                    : ("fr".equals(lang) ? "Étudiant" : "Student") %>
                        </span>
                </div>

                <div class="profile-meta">
                    <div class="pi-label"><%= "fr".equals(lang) ? "Membre depuis" : "Member since" %></div>
                    <div class="pi-value">
                        <%= (profileUser.getCreatedAt() != null)
                                ? profileUser.getCreatedAt().toLocalDate().toString()
                                : "—" %>
                    </div>
                </div>

                <div class="profile-meta" style="margin-top:.3rem;">
                    <div class="pi-label"><%= "fr".equals(lang) ? "Publications" : "Posts" %></div>
                    <div class="pi-value">
                        <strong><%= (userPosts != null) ? userPosts.size() : 0 %></strong>
                    </div>
                </div>

                <% if (isOwnProfile) { %>
                <div style="margin-top:1rem;">
                    <a href="<%= ctx %>/profile" class="btn-outline-sm" style="display:block;text-align:center;">
                        <%= "fr".equals(lang) ? "Modifier le profil" : "Edit profile" %>
                    </a>
                </div>
                <% } %>
            </div>
        </aside>

        <!-- Right: post list -->
        <main class="profile-posts">
            <div class="page-title" style="font-size:.95rem;margin-bottom:.75rem;">
                <%= "fr".equals(lang) ? "Publications de " : "Posts by " %><%= profileUser.getUsername() %>
            </div>

            <% if (userPosts == null || userPosts.isEmpty()) { %>
            <div class="feed-placeholder">
                <div class="placeholder-icon">—</div>
                <p><%= "fr".equals(lang) ? "Aucune publication pour le moment." : "No posts yet." %></p>
            </div>
            <% } else { %>

            <% for (Post p : userPosts) {
                String preview = p.getContentPreview(PREVIEW_LEN);
                boolean longContent = (p.getContent() != null && p.getContent().length() > PREVIEW_LEN);
            %>

            <div class="post-card post-card-rich">

                <!-- Vote panel -->
                <div class="post-vote">
                    <form method="post" action="<%= ctx %>/post/vote">
                        <input type="hidden" name="postId" value="<%= p.getId() %>" />
                        <button type="submit"
                                class="vote-btn-sm <%= p.isHasVoted() ? "voted" : "" %>"
                                title="Vote">▲</button>
                    </form>
                    <span class="vote-count-sm"><%= p.getVoteCount() %></span>
                </div>

                <!-- Content -->
                <div class="post-card-body">

                    <div class="post-card-meta-top">
                        <div class="post-author-chip">
                            <div class="post-author-avatar-sm">
                                <% if (p.getAuthorAvatarPath() != null) { %>
                                <img src="<%= ctx + p.getAuthorAvatarPath() %>" alt="" />
                                <% } else { %>
                                <%= p.getAuthorInitial() %>
                                <% } %>
                            </div>

                            <a href="<%= ctx %>/user?id=<%= p.getAuthorId() %>" class="post-author-name">
                                u/<%= p.getAuthorUsername() %>
                            </a>

                            <span class="role-badge-xs <%= p.isProfessor() ? "role-prof" : "role-student" %>">
                                        <%= p.isProfessor()
                                                ? ("fr".equals(lang) ? "Prof." : "Prof.")
                                                : ("fr".equals(lang) ? "Étudiant" : "Student") %>
                                    </span>
                        </div>

                        <div class="post-meta-right">
                            <a href="<%= ctx %>/channel?id=<%= p.getChannelId() %>" class="post-card-channel">
                                c/<%= p.getChannelName() %>
                            </a>
                            <span class="post-date-sm">
                                        <%= (p.getCreatedAt() != null) ? p.getCreatedAt().toLocalDate().toString() : "" %>
                                    </span>
                        </div>
                    </div>

                    <a href="<%= ctx %>/post?id=<%= p.getId() %>" class="post-card-title post-title-md">
                        <% if (p.isPinned()) { %>
                        <span class="pin-badge-sm">&#x25CE;</span>
                        <% } %>
                        <%= p.getTitle() %>
                    </a>

                    <% if (preview != null && !preview.isEmpty()) { %>
                    <p class="post-content-preview">
                        <%= preview %><% if (longContent) { %>…<% } %>
                    </p>
                    <% } %>

                    <div class="post-card-footer">
                                <span class="post-stat-pill">
                                    <%= p.getCommentCount() %>
                                    <%= (p.getCommentCount() == 1)
                                            ? I18nUtil.msg(request, "post.comment")
                                            : I18nUtil.msg(request, "post.comments") %>
                                </span>

                        <% if (longContent) { %>
                        <a href="<%= ctx %>/post?id=<%= p.getId() %>" class="post-read-more">
                            <%= "fr".equals(lang) ? "Lire la suite →" : "Read more →" %>
                        </a>
                        <% } %>
                    </div>

                </div>
            </div>

            <% } %>
            <% } %>

        </main>
    </div>

    <% } %>

</div>
</body>
</html>