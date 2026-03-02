<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="com.example.cdlforum.model.User, com.example.cdlforum.model.Channel" %>
        <% User currentUser=(User) session.getAttribute("user"); Channel channel=(Channel)
            request.getAttribute("channel"); String ctx=request.getContextPath(); %>
            <!DOCTYPE html>
            <html lang="fr">

            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>Créer un canal – CDL Forum</title>
                <link rel="stylesheet" href="<%= ctx %>/css/style.css" />
            </head>

            <body>
                <div class="app-wrapper">
                    <nav class="navbar">
                        <a href="<%= ctx %>/home" class="nav-brand">CDL Forum</a>
                        <div class="navbar-center">
                            <span class="breadcrumb">
                                <a href="<%= ctx %>/channels">Canaux</a> › Créer
                            </span>
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
                        <div class="form-card" style="max-width:600px;">
                            <div class="form-card-header">
                                <h1>Créer un canal académique</h1>
                                <p>Définissez les paramètres de votre nouvelle communauté.</p>
                            </div>

                            <% if (request.getAttribute("error") !=null) { %>
                                <div class="alert alert-error">${error}</div>
                                <% } %>

                                    <form id="createForm" method="post" action="<%= ctx %>/channels/create"
                                        enctype="multipart/form-data">

                                        <div class="form-group">
                                            <label for="name">Nom du canal <span class="required">*</span>
                                                <span class="form-hint-inline">— l'identifiant définitif (non
                                                    modifiable)</span>
                                            </label>
                                            <input id="name" type="text" name="name" required maxlength="50"
                                                placeholder="ex. algorithmes-avances" />
                                            <div class="form-hint">
                                                Identifiant : <strong class="slug-preview" id="slugPreview">—</strong>
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <label for="description">Description <span class="required">*</span></label>
                                            <textarea id="description" name="description" rows="3" required
                                                placeholder="Décrivez l'objet de ce canal…"></textarea>
                                        </div>

                                        <hr class="form-divider" />

                                        <div class="form-group">
                                            <label>Icône du canal</label>
                                            <input class="file-input" type="file" name="image" accept="image/*"
                                                id="imageInput" onchange="previewImage(this,'imgPreview')" />
                                            <img id="imgPreview"
                                                style="display:none;max-height:72px;margin-top:.4rem;border-radius:4px;border:1px solid var(--clr-border);"
                                                alt="" />
                                        </div>

                                        <div class="form-group">
                                            <label>Bannière</label>
                                            <input class="file-input" type="file" name="banner" accept="image/*"
                                                id="bannerInput" onchange="previewImage(this,'bannerPreview')" />
                                            <img id="bannerPreview"
                                                style="display:none;max-height:60px;width:100%;object-fit:cover;margin-top:.4rem;border-radius:4px;border:1px solid var(--clr-border);"
                                                alt="" />
                                        </div>

                                        <div class="post-create-actions">
                                            <a href="<%= ctx %>/channels" class="btn-outline-sm">Annuler</a>
                                            <button type="submit" class="btn-primary-sm">Créer le canal</button>
                                        </div>
                                    </form>
                        </div>
                    </div>
                </div>
                <script>
                    const nameInput = document.getElementById('name');
                    const slugPreview = document.getElementById('slugPreview');
                    nameInput.addEventListener('input', () => {
                        slugPreview.textContent = 'c/' + nameInput.value.toLowerCase()
                            .trim().replace(/\s+/g, '-').replace(/[^a-z0-9\-]/g, '') || '—';
                    });
                    function previewImage(input, previewId) {
                        const img = document.getElementById(previewId);
                        if (input.files && input.files[0]) {
                            const reader = new FileReader();
                            reader.onload = e => { img.src = e.target.result; img.style.display = 'block'; };
                            reader.readAsDataURL(input.files[0]);
                        } else { img.style.display = 'none'; }
                    }
                </script>
            </body>

            </html>