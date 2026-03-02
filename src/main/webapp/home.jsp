<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="
    com.example.cdlforum.model.User,
    com.example.cdlforum.model.Channel,
    com.example.cdlforum.model.Post,
    com.example.cdlforum.util.I18nUtil,
    java.util.List
" %>
        <% User currentUser=(User) session.getAttribute("user"); List<Channel> joinedChannels = (List<Channel>)
                request.getAttribute("joinedChannels");
                List<Channel> topChannels = (List<Channel>) request.getAttribute("topChannels");
                        List<Post> feedPosts = (List<Post>) request.getAttribute("feedPosts");
                                String ctx = request.getContextPath();
                                %>
                                <!DOCTYPE html>
                                <html lang="<%= I18nUtil.getLang(request) %>" data-theme="light">

                                <head>
                                    <meta charset="UTF-8" />
                                    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                                    <title>
                                        <%= I18nUtil.msg(request,"nav.brand") %> – <%=
                                                I18nUtil.msg(request,"home.feed.title") %>
                                    </title>
                                    <link rel="stylesheet" href="<%= ctx %>/css/style.css" />
                                    <!-- Prevent theme flash -->
                                    <script src="<%= ctx %>/js/theme-init.js"></script>
                                </head>

                                <body>
                                    <div class="app-wrapper">

                                        <jsp:include page="/WEB-INF/views/_navbar.jsp" />

                                        <div class="home-layout">

                                            <!-- LEFT SIDEBAR -->
                                            <aside class="sidebar-left">
                                                <a href="<%= ctx %>/channels/create" class="btn-create-channel">
                                                    <%= I18nUtil.msg(request,"home.create.channel") %>
                                                </a>
                                                <div class="sidebar-section-title">
                                                    <%= I18nUtil.msg(request,"home.sidebar.mycommunities") %>
                                                </div>
                                                <div class="sidebar-section">
                                                    <% if (joinedChannels==null || joinedChannels.isEmpty()) { %>
                                                        <span class="sidebar-empty">
                                                            <%= I18nUtil.msg(request,"home.sidebar.none") %>
                                                        </span>
                                                        <% } else { for (Channel ch : joinedChannels) { %>
                                                            <a href="<%= ctx %>/channel?id=<%= ch.getId() %>"
                                                                class="sidebar-channel-link">
                                                                <div class="sidebar-channel-icon">
                                                                    <% if (ch.getImagePath() !=null) { %>
                                                                        <img src="<%= ctx + ch.getImagePath() %>"
                                                                            alt="" />
                                                                        <% } else { %>
                                                                            <%= ch.getName().substring(0,1).toUpperCase()
                                                                                %>
                                                                                <% } %>
                                                                </div>
                                                                <span class="sidebar-channel-name">c/<%= ch.getName() %>
                                                                        </span>
                                                            </a>
                                                            <% } } %>
                                                                <a href="<%= ctx %>/channels"
                                                                    class="sidebar-discover-link">
                                                                    <%= I18nUtil.msg(request,"home.sidebar.discover") %>
                                                                </a>
                                                </div>
                                            </aside>

                                            <!-- MAIN FEED -->
                                            <main class="main-feed">
                                                <!-- Welcome card -->
                                                <div class="welcome-card">
                                                    <div class="welcome-badge">CDL &middot; <%=
                                                            I18nUtil.msg(request,"home.welcome.subtitle") %>
                                                    </div>
                                                    <h1>
                                                        <% String lang=I18nUtil.getLang(request);
                                                            out.print("fr".equals(lang) ? "Bonjour, " +
                                                            currentUser.getUsername() : "Welcome, " +
                                                            currentUser.getUsername()); %>
                                                    </h1>
                                                </div>

                                                <!-- Feed header -->
                                                <div
                                                    style="display:flex;align-items:center;justify-content:space-between;gap:.5rem;">
                                                    <span
                                                        style="font-size:.72rem;font-weight:700;text-transform:uppercase;letter-spacing:.07em;color:var(--clr-muted);">
                                                        <%= I18nUtil.msg(request,"home.feed.title") %>
                                                    </span>
                                                </div>

                                                <% if (feedPosts==null || feedPosts.isEmpty()) { %>
                                                    <div class="feed-placeholder">
                                                        <div class="placeholder-icon">—</div>
                                                        <h3>
                                                            <%= I18nUtil.msg(request,"home.feed.empty") %>
                                                        </h3>
                                                        <p>
                                                            <%= I18nUtil.msg(request,"home.feed.join") %>
                                                        </p>
                                                        <a href="<%= ctx %>/channels" class="btn-primary-sm">
                                                            <%= I18nUtil.msg(request,"nav.explore") %>
                                                        </a>
                                                    </div>
                                                    <% } else { for (Post p : feedPosts) { %>
                                                        <div class="post-card">
                                                            <div class="post-vote">
                                                                <form method="post" action="<%= ctx %>/post/vote">
                                                                    <input type="hidden" name="postId"
                                                                        value="<%= p.getId() %>" />
                                                                    <button type="submit"
                                                                        class="vote-btn-sm <%= p.isHasVoted() ? " voted"
                                                                        : "" %>"
                                                                        title="Vote">▲</button>
                                                                </form>
                                                                <span class="vote-count-sm">
                                                                    <%= p.getVoteCount() %>
                                                                </span>
                                                            </div>
                                                            <div class="post-card-body">
                                                                <% if (p.isPinned()) { %><span
                                                                        class="pin-badge-sm">&#x25CE;</span>
                                                                    <% } %>
                                                                        <a href="<%= ctx %>/post?id=<%= p.getId() %>"
                                                                            class="post-card-title">
                                                                            <%= p.getTitle() %>
                                                                        </a>
                                                                        <div class="post-card-meta">
                                                                            <a href="<%= ctx %>/channel?id=<%= p.getChannelId() %>"
                                                                                class="post-card-channel">c/<%=
                                                                                    p.getChannelName() %></a>
                                                                            <span>u/<%= p.getAuthorUsername() %></span>
                                                                            <span class="post-stat">
                                                                                <%= p.getCommentCount() %>
                                                                                    <%= p.getCommentCount()==1 ?
                                                                                        I18nUtil.msg(request,"post.comment")
                                                                                        :
                                                                                        I18nUtil.msg(request,"post.comments")
                                                                                        %>
                                                                            </span>
                                                                            <span>
                                                                                <%= p.getCreatedAt() !=null ?
                                                                                    p.getCreatedAt().toLocalDate().toString()
                                                                                    : "" %>
                                                                            </span>
                                                                        </div>
                                                            </div>
                                                        </div>
                                                        <% } } %>
                                            </main>

                                            <!-- RIGHT SIDEBAR -->
                                            <aside class="sidebar-right">
                                                <div class="card">
                                                    <div class="card-title">
                                                        <%= I18nUtil.msg(request,"home.sidebar.popular") %>
                                                    </div>
                                                    <% if (topChannels !=null && !topChannels.isEmpty()) { int rank=1;
                                                        for (Channel ch : topChannels) { %>
                                                        <a href="<%= ctx %>/channel?id=<%= ch.getId() %>"
                                                            class="trending-channel">
                                                            <span class="trending-rank">#<%= rank++ %></span>
                                                            <div class="sidebar-channel-icon"
                                                                style="width:24px;height:24px;border-radius:3px;font-size:.65rem;flex-shrink:0;">
                                                                <% if (ch.getImagePath() !=null) { %>
                                                                    <img src="<%= ctx + ch.getImagePath() %>" alt="" />
                                                                    <% } else { %>
                                                                        <%= ch.getName().substring(0,1).toUpperCase() %>
                                                                            <% } %>
                                                            </div>
                                                            <div class="trending-info">
                                                                <span class="trending-name">c/<%= ch.getName() %></span>
                                                                <span class="trending-count">
                                                                    <%= ch.getMemberCount() %>
                                                                        <%= I18nUtil.msg(request,"home.sidebar.members")
                                                                            %>
                                                                </span>
                                                            </div>
                                                        </a>
                                                        <% } } else { %>
                                                            <p style="font-size:.8rem;color:var(--clr-muted);">—</p>
                                                            <% } %>
                                                </div>
                                            </aside>

                                        </div>
                                    </div>
                                </body>

                                </html>