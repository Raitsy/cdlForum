<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="
    com.example.cdlforum.model.User,
    com.example.cdlforum.model.Channel,
    java.util.List,
    com.example.cdlforum.util.I18nUtil
" %>
        <% User currentUser=(User) session.getAttribute("user"); List<Channel> channels = (List<Channel>)
                request.getAttribute("channels");
                String ctx = request.getContextPath();
                %>
                <!DOCTYPE html>
                <html lang="<%= I18nUtil.getLang(request) %>" data-theme="light">

                <head>
                    <meta charset="UTF-8" />
                    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                    <title>
                        <%= I18nUtil.msg(request,"nav.explore") %> – CDL Forum
                    </title>
                    <link rel="stylesheet" href="<%= ctx %>/css/style.css" />
                    <script src="<%= ctx %>/js/theme-init.js"></script>
                </head>

                <body>
                    <div class="app-wrapper">
                        <jsp:include page="/WEB-INF/views/_navbar.jsp" />

                        <div class="page-container">
                            <div class="page-header">
                                <div>
                                    <div class="page-title">
                                        <%= I18nUtil.msg(request,"nav.explore") %>
                                    </div>
                                    <div class="page-subtitle">CDL Forum — <%= I18nUtil.getLang(request).equals("fr")
                                            ? "Découvrez les communautés" : "Discover department communities" %>
                                    </div>
                                </div>
                                <a href="<%= ctx %>/channels/create" class="btn-primary-sm">+ <%=
                                        I18nUtil.getLang(request).equals("fr") ? "Créer un canal" : "Create channel" %>
                                        </a>
                            </div>

                            <% if (channels==null || channels.isEmpty()) { %>
                                <div class="feed-placeholder">
                                    <div class="placeholder-icon">—</div>
                                    <h3>
                                        <%= I18nUtil.getLang(request).equals("fr") ? "Aucun canal disponible"
                                            : "No channels yet" %>
                                    </h3>
                                    <p>
                                        <%= I18nUtil.getLang(request).equals("fr")
                                            ? "Soyez le premier à créer un canal." : "Be the first to create a channel."
                                            %>
                                    </p>
                                    <a href="<%= ctx %>/channels/create" class="btn-primary-sm">
                                        <%= I18nUtil.getLang(request).equals("fr") ? "Créer un canal" : "Create channel"
                                            %>
                                    </a>
                                </div>
                                <% } else { %>
                                    <div class="channels-grid">
                                        <% for (Channel ch : channels) { %>
                                            <a href="<%= ctx %>/channel?id=<%= ch.getId() %>" class="channel-card">
                                                <div class="channel-card-banner" style="<%= ch.getBannerPath() != null
                        ? " background-image:url('" + ctx + ch.getBannerPath() + "');"
                                                    : "background-color:var(--clr-primary);" %>"></div>
                                                <div class="channel-card-body">
                                                    <div class="channel-card-icon">
                                                        <% if (ch.getImagePath() !=null) { %>
                                                            <img src="<%= ctx + ch.getImagePath() %>" alt="" />
                                                            <% } else { %>
                                                                <span class="icon-placeholder" style="font-size:.7rem;">
                                                                    <%= ch.getName().substring(0,1).toUpperCase() %>
                                                                </span>
                                                                <% } %>
                                                    </div>
                                                    <div class="channel-card-info">
                                                        <div class="channel-card-name">c/<%= ch.getName() %>
                                                        </div>
                                                        <div class="channel-card-desc">
                                                            <%= ch.getDescription() !=null &&
                                                                !ch.getDescription().isEmpty() ?
                                                                (ch.getDescription().length()> 80 ?
                                                                ch.getDescription().substring(0,80) + "…" :
                                                                ch.getDescription())
                                                                : "—" %>
                                                        </div>
                                                        <div class="channel-card-count">
                                                            <%= ch.getMemberCount() %>
                                                                <%= I18nUtil.msg(request,"channel.members") %>
                                                        </div>
                                                    </div>
                                                </div>
                                            </a>
                                            <% } %>
                                    </div>
                                    <% } %>
                        </div>
                    </div>
                </body>

                </html>