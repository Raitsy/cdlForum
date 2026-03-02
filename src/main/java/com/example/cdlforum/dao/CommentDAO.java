package com.example.cdlforum.dao;

import com.example.cdlforum.DatabaseUtil;
import com.example.cdlforum.model.Comment;

import java.sql.*;
import java.time.OffsetDateTime;
import java.util.*;

public class CommentDAO {

    /** Add a top-level comment (parentId = null) or a reply (parentId set). */
    public Comment addComment(int postId, int authorId, Integer parentId, String content)
            throws SQLException {
        String sql = """
                INSERT INTO comments (post_id, author_id, parent_id, content)
                VALUES (?, ?, ?, ?) RETURNING id, created_at
                """;
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            ps.setInt(2, authorId);
            if (parentId == null)
                ps.setNull(3, Types.INTEGER);
            else
                ps.setInt(3, parentId);
            ps.setString(4, content.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Comment c = new Comment();
                    c.setId(rs.getInt("id"));
                    c.setPostId(postId);
                    c.setAuthorId(authorId);
                    c.setParentId(parentId);
                    c.setContent(content.trim());
                    c.setCreatedAt(rs.getObject("created_at", OffsetDateTime.class));
                    return c;
                }
            }
        }
        throw new SQLException("Comment insertion failed.");
    }

    /**
     * Returns all comments for a post, organised as a list of top-level comments
     * each with their replies list populated. Supports up to 2 display levels
     * (top-level + 1 level of replies).
     */
    public List<Comment> getCommentsForPost(int postId) throws SQLException {
        String sql = """
                SELECT c.id, c.post_id, c.author_id, u.username AS author_username,
                       c.parent_id, c.content, c.created_at
                FROM comments c
                JOIN users u ON u.id = c.author_id
                WHERE c.post_id = ?
                ORDER BY c.created_at ASC
                """;

        Map<Integer, Comment> byId = new LinkedHashMap<>();
        List<Comment> topLevel = new ArrayList<>();

        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Comment c = new Comment();
                    c.setId(rs.getInt("id"));
                    c.setPostId(rs.getInt("post_id"));
                    c.setAuthorId(rs.getInt("author_id"));
                    c.setAuthorUsername(rs.getString("author_username"));
                    int pid = rs.getInt("parent_id");
                    c.setParentId(rs.wasNull() ? null : pid);
                    c.setContent(rs.getString("content"));
                    c.setCreatedAt(rs.getObject("created_at", OffsetDateTime.class));
                    byId.put(c.getId(), c);
                }
            }
        }

        // Organise into tree
        for (Comment c : byId.values()) {
            if (c.isTopLevel()) {
                topLevel.add(c);
            } else {
                Comment parent = byId.get(c.getParentId());
                if (parent != null)
                    parent.addReply(c);
                else
                    topLevel.add(c); // orphaned reply → promote to top
            }
        }
        return topLevel;
    }

    /** Delete a comment by id. Cascades to child replies via DB constraint. */
    public void delete(int commentId) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement("DELETE FROM comments WHERE id=?")) {
            ps.setInt(1, commentId);
            ps.executeUpdate();
        }
    }

    /** Find a single comment by id. */
    public Comment findById(int commentId) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "SELECT c.*, u.username AS author_username FROM comments c JOIN users u ON u.id=c.author_id WHERE c.id=?")) {
            ps.setInt(1, commentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Comment c = new Comment();
                    c.setId(rs.getInt("id"));
                    c.setPostId(rs.getInt("post_id"));
                    c.setAuthorId(rs.getInt("author_id"));
                    c.setAuthorUsername(rs.getString("author_username"));
                    int pid = rs.getInt("parent_id");
                    c.setParentId(rs.wasNull() ? null : pid);
                    c.setContent(rs.getString("content"));
                    c.setCreatedAt(rs.getObject("created_at", OffsetDateTime.class));
                    return c;
                }
            }
        }
        return null;
    }
}
