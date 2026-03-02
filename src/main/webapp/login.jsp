<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="fr" data-theme="dark">

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Connexion – CDL Forum</title>
    <meta name="description" content="Forum académique du département d'informatique CDL" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <style>
        /* ── Auth Page – Dark Mode ── */
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --auth-bg:        #0d1117;
            --auth-surface:   #161b22;
            --auth-border:    #30363d;
            --auth-primary:   #4493f8;
            --auth-primary-h: #3879d4;
            --auth-text:      #e6edf3;
            --auth-muted:     #8b949e;
            --auth-input-bg:  #0d1117;
            --auth-error:     #f85149;
            --auth-error-bg:  rgba(248,81,73,0.10);
            --auth-success:   #3fb950;
            --auth-success-bg:rgba(63,185,80,0.10);
            --radius:         10px;
            --transition:     0.18s ease;
        }

        html, body {
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
                    radial-gradient(ellipse 80% 50% at 50% -20%, rgba(68,147,248,0.12), transparent),
                    radial-gradient(ellipse 60% 40% at 80% 80%, rgba(68,147,248,0.06), transparent);
        }

        /* ── Card ── */
        .auth-card {
            width: 100%;
            max-width: 420px;
            background: var(--auth-surface);
            border: 1px solid var(--auth-border);
            border-radius: var(--radius);
            padding: 2.5rem 2.25rem;
            box-shadow: 0 8px 32px rgba(0,0,0,0.4), 0 0 0 1px rgba(255,255,255,0.04);
            animation: slideUp 0.35s ease both;
        }

        @keyframes slideUp {
            from { opacity: 0; transform: translateY(20px); }
            to   { opacity: 1; transform: translateY(0); }
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
            box-shadow: 0 4px 16px rgba(68,147,248,0.25);
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
        .alert-error   { background: var(--auth-error-bg);   border-color: rgba(248,81,73,0.3);  color: var(--auth-error);   }
        .alert-success { background: var(--auth-success-bg); border-color: rgba(63,185,80,0.3);  color: var(--auth-success); }

        /* ── Form elements ── */
        .form-group { margin-bottom: 1rem; }

        .form-label {
            display: block;
            font-size: 0.73rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: var(--auth-muted);
            margin-bottom: 0.4rem;
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

        .form-input::placeholder { color: var(--auth-muted); opacity: 0.7; }

        .form-input:focus {
            border-color: var(--auth-primary);
            box-shadow: 0 0 0 3px rgba(68,147,248,0.15);
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
            box-shadow: 0 4px 14px rgba(68,147,248,0.3);
            transform: translateY(-1px);
        }

        .btn-auth:active { transform: translateY(0); }

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

        .auth-footer a:hover { text-decoration: underline; }
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

    <h2 class="auth-title">Connexion</h2>

    <!-- Flash messages -->
    <% String logout   = request.getParameter("logout");
        String regDone  = request.getParameter("registered"); %>
    <% if ("true".equals(logout)) { %>
    <div class="alert alert-success">Vous avez été déconnecté.</div>
    <% } %>
    <% if ("true".equals(regDone)) { %>
    <div class="alert alert-success">Compte créé. Vous pouvez maintenant vous connecter.</div>
    <% } %>
    <% if (request.getAttribute("error") != null) { %>
    <div class="alert alert-error">${error}</div>
    <% } %>

    <form method="post" action="${pageContext.request.contextPath}/login">
        <div class="form-group">
            <label class="form-label" for="username">Nom d'utilisateur</label>
            <input class="form-input" id="username" type="text" name="username"
                   required placeholder="ex. jdupont" />
        </div>
        <div class="form-group">
            <label class="form-label" for="password">Mot de passe</label>
            <input class="form-input" id="password" type="password" name="password"
                   required placeholder="••••••••" />
        </div>
        <button type="submit" class="btn-auth">Se connecter</button>
    </form>

    <div class="auth-footer">
        Pas encore de compte ?
        <a href="${pageContext.request.contextPath}/register">Créer un compte</a>
    </div>
</div>
</body>

</html>