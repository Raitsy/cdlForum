package com.example.cdlforum.dao;

import com.example.cdlforum.DatabaseUtil;
import com.example.cdlforum.model.Post;

import java.sql.*;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class PostDAO {

    /**
     * Create a new post. Returns the created Post.
     */
    public Post create(int channelId, int authorId, String title, String content) throws SQLException {
        String sql = """
                INSERT INTO posts (channel_id, author_id, title, content)
                VALUES (?, ?, ?, ?) RETURNING id, created_at
                """;
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, channelId);
            ps.setInt(2, authorId);
            ps.setString(3, title.trim());
            ps.setString(4, content != null ? content.trim() : null);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Post p = new Post();
                    p.setId(rs.getInt("id"));
                    p.setChannelId(channelId);
                    p.setAuthorId(authorId);
                    p.setTitle(title.trim());
                    p.setContent(content);
                    p.setCreatedAt(rs.getObject("created_at", OffsetDateTime.class));
                    return p;
                }
            }
        }
        throw new SQLException("Post creation failed.");
    }

    /**
     * Find a single post by id, including author username, comment count, and
     * whether the given userId has already upvoted it.
     */
    public Post findById(int id, int currentUserId) throws SQLException {
        String sql = """
                SELECT p.*,
                       u.username    AS author_username,
                       u.user_role   AS author_role,
                       u.avatar_path AS author_avatar_path,
                       ch.name       AS channel_name,
                       COUNT(DISTINCT c.id) AS comment_count,
                       EXISTS(SELECT 1 FROM post_votes pv
                              WHERE pv.post_id = p.id AND pv.user_id = ?) AS has_voted
                FROM posts p
                JOIN users    u  ON u.id  = p.author_id
                JOIN channels ch ON ch.id = p.channel_id
                LEFT JOIN comments c ON c.post_id = p.id
                WHERE p.id = ?
                GROUP BY p.id, u.username, u.user_role, u.avatar_path, ch.name
                """;
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, currentUserId);
            ps.setInt(2, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return mapRow(rs, true);
            }
        }
        return null;
    }

    /**
     * List posts for a channel, sorted by:
     * "new" – created_at DESC (default)
     * "top" – vote_count DESC
     * "hot" – comment count DESC
     * Pinned posts always float to the top within the sort.
     */
    public List<Post> findByChannel(int channelId, String sort, int currentUserId) throws SQLException {
        String orderBy = switch (sort == null ? "new" : sort.toLowerCase()) {
            case "top" -> "p.pinned DESC, p.vote_count DESC, p.created_at DESC";
            case "hot" -> "p.pinned DESC, comment_count DESC, p.created_at DESC";
            default -> "p.pinned DESC, p.created_at DESC";
        };

        String sql = """
                SELECT p.*,
                       u.username    AS author_username,
                       u.user_role   AS author_role,
                       u.avatar_path AS author_avatar_path,
                       ch.name       AS channel_name,
                       COUNT(DISTINCT c.id) AS comment_count,
                       EXISTS(SELECT 1 FROM post_votes pv
                              WHERE pv.post_id = p.id AND pv.user_id = ?) AS has_voted
                FROM posts p
                JOIN users    u  ON u.id  = p.author_id
                JOIN channels ch ON ch.id = p.channel_id
                LEFT JOIN comments c ON c.post_id = p.id
                WHERE p.channel_id = ?
                GROUP BY p.id, u.username, u.user_role, u.avatar_path, ch.name
                ORDER BY \s""" + orderBy;

        List<Post> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, currentUserId);
            ps.setInt(2, channelId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    list.add(mapRow(rs, true));
            }
        }
        return list;
    }

    /** Increment vote_count by delta (+1 or -1). */
    public void updateVoteCount(int postId, int delta) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "UPDATE posts SET vote_count = vote_count + ? WHERE id = ?")) {
            ps.setInt(1, delta);
            ps.setInt(2, postId);
            ps.executeUpdate();
        }
    }

    /** Toggle pinned status. Only channel owner should call this. */
    public void setPinned(int postId, boolean pinned) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "UPDATE posts SET pinned = ? WHERE id = ?")) {
            ps.setBoolean(1, pinned);
            ps.setInt(2, postId);
            ps.executeUpdate();
        }
    }

    /** Delete a post (and cascade its comments/votes). */
    public void delete(int postId) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM posts WHERE id = ?")) {
            ps.setInt(1, postId);
            ps.executeUpdate();
        }
    }

    /**
     * Home-page feed: return the most recent posts from a set of channels.
     *
     * @param channelIds    list of channel IDs the user belongs to
     * @param limit         max rows to return
     * @param currentUserId used to populate has_voted flag
     */
    public List<Post> findRecentFromChannels(List<Integer> channelIds, int limit, int currentUserId)
            throws SQLException {
        if (channelIds == null || channelIds.isEmpty())
            return new ArrayList<>();

        String placeholders = channelIds.stream().map(id -> "?").collect(Collectors.joining(","));
        String sql = "SELECT p.*, u.username AS author_username, u.user_role AS author_role, u.avatar_path AS author_avatar_path, ch.name AS channel_name, "
                + "COUNT(DISTINCT c.id) AS comment_count, "
                + "EXISTS(SELECT 1 FROM post_votes pv WHERE pv.post_id=p.id AND pv.user_id=?) AS has_voted "
                + "FROM posts p "
                + "JOIN users u ON u.id=p.author_id "
                + "JOIN channels ch ON ch.id=p.channel_id "
                + "LEFT JOIN comments c ON c.post_id=p.id "
                + "WHERE p.channel_id IN (" + placeholders + ") "
                + "GROUP BY p.id, u.username, u.user_role, u.avatar_path, ch.name "
                + "ORDER BY p.pinned DESC, p.created_at DESC "
                + "LIMIT ?";

        List<Post> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            ps.setInt(idx++, currentUserId);
            for (int cid : channelIds)
                ps.setInt(idx++, cid);
            ps.setInt(idx, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    list.add(mapRow(rs, true));
            }
        }
        return list;
    }

    /**
     * Posts by a specific user, newest first – for public user profile pages.
     */
    public List<Post> findByUser(int authorId, int currentUserId) throws SQLException {
        String sql = "SELECT p.*, u.username AS author_username, u.user_role AS author_role, u.avatar_path AS author_avatar_path, ch.name AS channel_name, "
                + "COUNT(DISTINCT c.id) AS comment_count, "
                + "EXISTS(SELECT 1 FROM post_votes pv WHERE pv.post_id=p.id AND pv.user_id=?) AS has_voted "
                + "FROM posts p "
                + "JOIN users u ON u.id=p.author_id "
                + "JOIN channels ch ON ch.id=p.channel_id "
                + "LEFT JOIN comments c ON c.post_id=p.id "
                + "WHERE p.author_id = ? "
                + "GROUP BY p.id, u.username, u.user_role, u.avatar_path, ch.name "
                + "ORDER BY p.created_at DESC";
        List<Post> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, currentUserId);
            ps.setInt(2, authorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    list.add(mapRow(rs, true));
            }
        }
        return list;
    }

    // ── Row mapping ───────────────────────────────────────────
    private Post mapRow(ResultSet rs, boolean includeExtras) throws SQLException {
        Post p = new Post();
        p.setId(rs.getInt("id"));
        p.setChannelId(rs.getInt("channel_id"));
        p.setAuthorId(rs.getInt("author_id"));
        p.setTitle(rs.getString("title"));
        p.setContent(rs.getString("content"));
        p.setVoteCount(rs.getInt("vote_count"));
        p.setPinned(rs.getBoolean("pinned"));
        p.setCreatedAt(rs.getObject("created_at", OffsetDateTime.class));
        if (includeExtras) {
            p.setAuthorUsername(rs.getString("author_username"));
            p.setAuthorRole(rs.getString("author_role"));
            p.setAuthorAvatarPath(rs.getString("author_avatar_path"));
            p.setChannelName(rs.getString("channel_name"));
            p.setCommentCount(rs.getLong("comment_count"));
            p.setHasVoted(rs.getBoolean("has_voted"));
        }
        return p;
    }
}
