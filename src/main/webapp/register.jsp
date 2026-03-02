<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="fr" data-theme="dark">

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Créer un compte – CDL Forum</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
          rel="stylesheet" />
    <style>
        /* ── Auth Page – Dark Mode ── */
        *,
        *::before,
        *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        :root {
            --auth-bg: #0d1117;
            --auth-surface: #161b22;
            --auth-border: #30363d;
            --auth-primary: #4493f8;
            --auth-primary-h: #3879d4;
            --auth-text: #e6edf3;
            --auth-muted: #8b949e;
            --auth-input-bg: #0d1117;
            --auth-error: #f85149;
            --auth-error-bg: rgba(248, 81, 73, 0.10);
            --auth-role-bg: #1c2128;
            --auth-role-sel: rgba(68, 147, 248, 0.12);
            --radius: 10px;
            --transition: 0.18s ease;
        }

        html,
        body {
            height: 100%;
            font-family: 'Inter', system-ui, sans-serif;
            background: var(--auth-bg);
            color: var(--auth-text);
            -webkit-font-smoothing: antialiased;
        }

        body {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            padding: 1.5rem;
            background-image:
                    radial-gradient(ellipse 80% 50% at 50% -20%, rgba(68, 147, 248, 0.12), transparent),
                    radial-gradient(ellipse 60% 40% at 80% 80%, rgba(68, 147, 248, 0.06), transparent);
        }

        /* ── Card ── */
        .auth-card {
            width: 100%;
            max-width: 440px;
            background: var(--auth-surface);
            border: 1px solid var(--auth-border);
            border-radius: var(--radius);
            padding: 2.5rem 2.25rem;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4), 0 0 0 1px rgba(255, 255, 255, 0.04);
            animation: slideUp 0.35s ease both;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* ── Brand header ── */
        .auth-brand {
            text-align: center;
            margin-bottom: 2rem;
            padding-bottom: 1.75rem;
            border-bottom: 1px solid var(--auth-border);
        }

        .auth-brand-logo {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 48px;
            height: 48px;
            border-radius: 12px;
            background: linear-gradient(135deg, #1b3f7a 0%, #4493f8 100%);
            font-size: 1.5rem;
            margin-bottom: 1rem;
            box-shadow: 0 4px 16px rgba(68, 147, 248, 0.25);
        }

        .auth-brand h1 {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--auth-text);
            letter-spacing: 0.04em;
            text-transform: uppercase;
        }

        .auth-brand p {
            font-size: 0.78rem;
            color: var(--auth-muted);
            margin-top: 0.3rem;
        }

        /* ── Page title ── */
        .auth-title {
            font-size: 1rem;
            font-weight: 600;
            color: var(--auth-text);
            margin-bottom: 1.5rem;
            text-align: center;
        }

        /* ── Alerts ── */
        .alert {
            padding: 0.7rem 0.9rem;
            border-radius: 6px;
            font-size: 0.82rem;
            margin-bottom: 1.1rem;
            border: 1px solid transparent;
        }

        .alert-error {
            background: var(--auth-error-bg);
            border-color: rgba(248, 81, 73, 0.3);
            color: var(--auth-error);
        }

        /* ── Form elements ── */
        .form-group {
            margin-bottom: 1rem;
        }

        .form-label {
            display: block;
            font-size: 0.73rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: var(--auth-muted);
            margin-bottom: 0.4rem;
        }

        .required {
            color: var(--auth-error);
        }

        .form-input {
            width: 100%;
            padding: 0.6rem 0.85rem;
            background: var(--auth-input-bg);
            border: 1px solid var(--auth-border);
            border-radius: 6px;
            color: var(--auth-text);
            font-size: 0.88rem;
            font-family: inherit;
            outline: none;
            transition: border-color var(--transition), box-shadow var(--transition);
        }

        .form-input::placeholder {
            color: var(--auth-muted);
            opacity: 0.7;
        }

        .form-input:focus {
            border-color: var(--auth-primary);
            box-shadow: 0 0 0 3px rgba(68, 147, 248, 0.15);
        }

        /* ── Role selector ── */
        .role-selector {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0.6rem;
        }

        .role-option {
            cursor: pointer;
        }

        .role-option input[type="radio"] {
            display: none;
        }

        .role-option-label {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 0.35rem;
            padding: 0.85rem 0.6rem;
            background: var(--auth-role-bg);
            border: 1.5px solid var(--auth-border);
            border-radius: 8px;
            cursor: pointer;
            transition: all var(--transition);
            text-align: center;
        }

        .role-option-label:hover {
            border-color: var(--auth-primary);
            background: var(--auth-role-sel);
        }

        .role-option input[type="radio"]:checked+.role-option-label {
            border-color: var(--auth-primary);
            background: var(--auth-role-sel);
            box-shadow: 0 0 0 2px rgba(68, 147, 248, 0.2);
        }

        .role-icon {
            font-size: 1.3rem;
        }

        .role-text {
            font-size: 0.8rem;
            font-weight: 500;
            color: var(--auth-text);
        }

        /* ── Password hint ── */
        .form-hint {
            font-size: 0.73rem;
            color: var(--auth-muted);
            margin-top: 0.3rem;
        }

        /* ── Submit button ── */
        .btn-auth {
            width: 100%;
            padding: 0.7rem 1rem;
            margin-top: 0.5rem;
            background: var(--auth-primary);
            color: #fff;
            border: 1px solid var(--auth-primary);
            border-radius: 6px;
            font-size: 0.9rem;
            font-weight: 600;
            font-family: inherit;
            cursor: pointer;
            letter-spacing: 0.01em;
            transition: background var(--transition), box-shadow var(--transition), transform var(--transition);
        }

        .btn-auth:hover {
            background: var(--auth-primary-h);
            box-shadow: 0 4px 14px rgba(68, 147, 248, 0.3);
            transform: translateY(-1px);
        }

        .btn-auth:active {
            transform: translateY(0);
        }

        /* ── Footer link ── */
        .auth-footer {
            text-align: center;
            margin-top: 1.5rem;
            padding-top: 1.25rem;
            border-top: 1px solid var(--auth-border);
            font-size: 0.8rem;
            color: var(--auth-muted);
        }

        .auth-footer a {
            color: var(--auth-primary);
            font-weight: 500;
            text-decoration: none;
        }

        .auth-footer a:hover {
            text-decoration: underline;
        }
    </style>
</head>

<body>
<div class="auth-card">

    <!-- Brand -->
    <div class="auth-brand">
        <div class="auth-brand-logo">▣</div>
        <h1>CDL Forum</h1>
        <p>Département d'informatique &mdash; Plateforme académique</p>
    </div>

    <h2 class="auth-title">Créer un compte</h2>

    <% if (request.getAttribute("error") !=null) { %>
    <div class="alert alert-error">${error}</div>
    <% } %>

    <form method="post" action="<%= request.getContextPath() %>/register" id="registerForm">

        <!-- Role selector -->
        <div class="form-group">
            <label class="form-label">Je suis <span class="required">*</span></label>
            <div class="role-selector">
                <label class="role-option">
                    <input type="radio" name="role" value="student" checked />
                    <span class="role-option-label">
                                        <span class="role-icon">&#127891;</span>
                                        <span class="role-text">Étudiant</span>
                                    </span>
                </label>
                <label class="role-option">
                    <input type="radio" name="role" value="professor" />
                    <span class="role-option-label">
                                        <span class="role-icon">&#9962;</span>
                                        <span class="role-text">Professeur</span>
                                    </span>
                </label>
            </div>
        </div>

        <div class="form-group">
            <label class="form-label" for="username">Nom d'utilisateur <span
                    class="required">*</span></label>
            <input class="form-input" id="username" type="text" name="username" required minlength="3"
                   maxlength="50" placeholder="ex: alice_martin" />
        </div>

        <div class="form-group">
            <label class="form-label" for="email">Adresse e-mail <span class="required">*</span></label>
            <input class="form-input" id="email" type="email" name="email" required
                   placeholder="votre@email.fr" />
        </div>

        <div class="form-group">
            <label class="form-label" for="password">Mot de passe <span
                    class="required">*</span></label>
            <input class="form-input" id="password" type="password" name="password" required
                   minlength="6" placeholder="Minimum 6 caractères" />
        </div>

        <div class="form-group">
            <label class="form-label" for="confirm">Confirmer le mot de passe <span
                    class="required">*</span></label>
            <input class="form-input" id="confirm" type="password" name="confirmPassword" required
                   placeholder="Répétez le mot de passe" />
            <div class="form-hint" id="pwHint"></div>
        </div>

        <button type="submit" class="btn-auth">Créer mon compte</button>
    </form>

    <div class="auth-footer">
        Déjà un compte ?
        <a href="<%= request.getContextPath() %>/login">Retour à la connexion</a>
    </div>
</div>

<script>
    const pw = document.getElementById('password');
    const cf = document.getElementById('confirm');
    const hint = document.getElementById('pwHint');
    function checkMatch() {
        if (!cf.value) { hint.textContent = ''; return; }
        if (pw.value === cf.value) {
            hint.textContent = '✓ Les mots de passe correspondent';
            hint.style.color = '#3fb950';
        } else {
            hint.textContent = 'Les mots de passe ne correspondent pas';
            hint.style.color = '#f85149';
        }
    }
    pw.addEventListener('input', checkMatch);
    cf.addEventListener('input', checkMatch);
</script>
</body>

</html>