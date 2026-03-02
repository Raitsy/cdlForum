package com.example.cdlforum.dao;

import com.example.cdlforum.DatabaseUtil;

import java.sql.*;

public class PostVoteDAO {

    /**
     * Toggle an upvote for the given user on the given post.
     * Returns +1 if vote was added, -1 if it was removed (already voted).
     */
    public int toggleVote(int postId, int userId) throws SQLException {
        if (hasVoted(postId, userId)) {
            removeVote(postId, userId);
            return -1;
        } else {
            addVote(postId, userId);
            return +1;
        }
    }

    public boolean hasVoted(int postId, int userId) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "SELECT 1 FROM post_votes WHERE post_id=? AND user_id=?")) {
            ps.setInt(1, postId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private void addVote(int postId, int userId) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO post_votes (post_id, user_id) VALUES (?,?) ON CONFLICT DO NOTHING")) {
            ps.setInt(1, postId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    private void removeVote(int postId, int userId) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM post_votes WHERE post_id=? AND user_id=?")) {
            ps.setInt(1, postId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }
}
