<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.cdlforum.model.User,
                 com.example.cdlforum.util.I18nUtil" %>

<%
    User currentUser = (User) session.getAttribute("user");
    String ctx = request.getContextPath();
    String lang = I18nUtil.getLang(request);
    boolean updated = "true".equals(request.getParameter("updated"));

    // Build confirm message safely (your original had broken quotes/newlines)
    String confirmMsg = "fr".equals(lang)
            ? "Êtes-vous sûr ? Cette action est irréversible."
            : "Are you sure? This cannot be undone.";
%>

<!DOCTYPE html>
<html lang="<%= lang %>" data-theme="light">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><%= "fr".equals(lang) ? "Paramètres du profil" : "Profile Settings" %> – CDL Forum</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css" />
    <script src="<%= ctx %>/js/theme-init.js"></script>
</head>

<body>
<div class="app-wrapper">
    <jsp:include page="/WEB-INF/views/_navbar.jsp" />

    <div class="page-container" style="max-width:640px;">

        <div class="page-header">
            <div>
                <div class="page-title">
                    <%= "fr".equals(lang) ? "Paramètres du profil" : "Profile Settings" %>
                </div>
                <div class="page-subtitle">
                    u/<%= (currentUser != null) ? currentUser.getUsername() : "" %>
                </div>
            </div>

            <% if (currentUser != null) { %>
            <a href="<%= ctx %>/user?id=<%= currentUser.getId() %>" class="btn-outline-sm">
                <%= "fr".equals(lang) ? "Voir mon profil" : "View profile" %>
            </a>
            <% } %>
        </div>

        <% if (updated) { %>
        <div class="alert alert-success" style="margin-bottom:1rem;">
            <%= "fr".equals(lang) ? "Profil mis à jour avec succès." : "Profile updated successfully." %>
        </div>
        <% } %>

        <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-error" style="margin-bottom:1rem;">${error}</div>
        <% } %>

        <!-- Avatar section -->
        <div class="card" style="margin-bottom:1rem;">
            <div class="card-title">
                <%= "fr".equals(lang) ? "Photo de profil" : "Profile picture" %>
            </div>

            <div class="avatar-settings-row">
                <div class="avatar-lg">
                    <% if (currentUser != null && currentUser.getAvatarPath() != null) { %>
                    <img src="<%= ctx + currentUser.getAvatarPath() %>" alt="Avatar" />
                    <% } else { %>
                    <span class="avatar-initial-lg">
                            <%= (currentUser != null) ? currentUser.getInitial() : "?" %>
                        </span>
                    <% } %>
                </div>

                <div class="avatar-upload">
                    <form method="post" action="<%= ctx %>/profile" enctype="multipart/form-data">
                        <input type="hidden" name="action" value="avatar" />

                        <label class="avatar-file-label" for="avatarFile">
                            <%= "fr".equals(lang) ? "Choisir une image" : "Choose an image" %>
                        </label>

                        <input id="avatarFile" type="file" name="avatar"
                               accept="image/jpeg,image/png,image/gif,image/webp"
                               style="display:none;" onchange="showFileName(this)" />

                        <div class="avatar-file-name" id="avatarFileName">
                            <%= "fr".equals(lang) ? "Aucun fichier sélectionné" : "No file selected" %>
                        </div>

                        <div class="form-hint">JPEG, PNG, GIF ou WebP. Max 5 Mo.</div>

                        <button type="submit" class="btn-primary-sm" style="margin-top:.5rem;">
                            <%= "fr".equals(lang) ? "Enregistrer" : "Save" %>
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Account info (read-only) -->
        <div class="card" style="margin-bottom:1rem;">
            <div class="card-title">
                <%= "fr".equals(lang) ? "Informations du compte" : "Account information" %>
            </div>

            <div class="profile-info-row">
                <span class="pi-label"><%= "fr".equals(lang) ? "Nom d'utilisateur" : "Username" %></span>
                <span class="pi-value">u/<%= (currentUser != null) ? currentUser.getUsername() : "" %></span>
            </div>

            <div class="profile-info-row">
                <span class="pi-label">E-mail</span>
                <span class="pi-value"><%= (currentUser != null) ? currentUser.getEmail() : "" %></span>
            </div>

            <div class="profile-info-row">
                <span class="pi-label">Rôle</span>
                <span class="role-badge <%= (currentUser != null && currentUser.isProfessor()) ? "role-prof" : "role-student" %>">
                    <%= (currentUser != null && currentUser.isProfessor())
                            ? ("fr".equals(lang) ? "Professeur" : "Professor")
                            : ("fr".equals(lang) ? "Étudiant" : "Student") %>
                </span>
            </div>

            <div class="profile-info-row">
                <span class="pi-label"><%= "fr".equals(lang) ? "Membre depuis" : "Member since" %></span>
                <span class="pi-value">
                    <%= (currentUser != null && currentUser.getCreatedAt() != null)
                            ? currentUser.getCreatedAt().toLocalDate().toString()
                            : "—" %>
                </span>
            </div>
        </div>

        <!-- Danger zone -->
        <div class="card card-danger">
            <div class="card-title" style="color:var(--clr-error);">
                <%= "fr".equals(lang) ? "Zone de danger" : "Danger zone" %>
            </div>

            <p style="font-size:.83rem;color:var(--clr-text-secondary);margin-bottom:.75rem;">
                <%= "fr".equals(lang)
                        ? "La suppression de votre compte est irréversible. Toutes vos publications et commentaires seront définitivement supprimés."
                        : "Account deletion is irreversible. All your posts and comments will be permanently removed." %>
            </p>

            <form method="post" action="<%= ctx %>/profile"
                  onsubmit="return confirm('<%= confirmMsg.replace("'", "\\'") %>')">
                <input type="hidden" name="action" value="delete" />
                <button type="submit" class="btn-danger-sm">
                    <%= "fr".equals(lang) ? "Supprimer mon compte" : "Delete my account" %>
                </button>
            </form>
        </div>

    </div>
</div>

<script>
    function showFileName(input) {
        const el = document.getElementById('avatarFileName');
        const fallback = '<%= "fr".equals(lang) ? "Aucun fichier sélectionné" : "No file selected" %>';
        el.textContent = input.files.length ? input.files[0].name : fallback;
    }
</script>

</body>
</html>