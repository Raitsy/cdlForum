package com.example.cdlforum.dao;

import com.example.cdlforum.DatabaseUtil;
import com.example.cdlforum.model.ChannelRule;

import java.sql.*;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;

public class ChannelRuleDAO {

    public ChannelRule addRule(int channelId, String title, String description) throws SQLException {
        // Find the next position
        int nextPos = 1;
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "SELECT COALESCE(MAX(position),0)+1 FROM channel_rules WHERE channel_id=?")) {
            ps.setInt(1, channelId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    nextPos = rs.getInt(1);
            }
        }

        String sql = """
                INSERT INTO channel_rules (channel_id, position, title, description)
                VALUES (?, ?, ?, ?) RETURNING id, created_at
                """;
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, channelId);
            ps.setInt(2, nextPos);
            ps.setString(3, title.trim());
            ps.setString(4, description != null ? description.trim() : null);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ChannelRule rule = new ChannelRule();
                    rule.setId(rs.getInt("id"));
                    rule.setChannelId(channelId);
                    rule.setPosition(nextPos);
                    rule.setTitle(title.trim());
                    rule.setDescription(description);
                    rule.setCreatedAt(rs.getObject("created_at", OffsetDateTime.class));
                    return rule;
                }
            }
        }
        throw new SQLException("Rule creation failed.");
    }

    public List<ChannelRule> getRules(int channelId) throws SQLException {
        List<ChannelRule> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "SELECT * FROM channel_rules WHERE channel_id=? ORDER BY position ASC")) {
            ps.setInt(1, channelId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ChannelRule r = new ChannelRule();
                    r.setId(rs.getInt("id"));
                    r.setChannelId(rs.getInt("channel_id"));
                    r.setPosition(rs.getInt("position"));
                    r.setTitle(rs.getString("title"));
                    r.setDescription(rs.getString("description"));
                    r.setCreatedAt(rs.getObject("created_at", OffsetDateTime.class));
                    list.add(r);
                }
            }
        }
        return list;
    }

    public void updateRule(int ruleId, int channelId, String title, String description) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "UPDATE channel_rules SET title=?, description=? WHERE id=? AND channel_id=?")) {
            ps.setString(1, title.trim());
            ps.setString(2, description != null ? description.trim() : null);
            ps.setInt(3, ruleId);
            ps.setInt(4, channelId);
            ps.executeUpdate();
        }
    }

    public void deleteRule(int ruleId, int channelId) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM channel_rules WHERE id=? AND channel_id=?")) {
            ps.setInt(1, ruleId);
            ps.setInt(2, channelId);
            ps.executeUpdate();
        }
        // Re-sequence positions
        resequence(channelId);
    }

    private void resequence(int channelId) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "SELECT id FROM channel_rules WHERE channel_id=? ORDER BY position ASC")) {
            ps.setInt(1, channelId);
            List<Integer> ids = new ArrayList<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    ids.add(rs.getInt("id"));
            }
            for (int i = 0; i < ids.size(); i++) {
                try (PreparedStatement up = conn.prepareStatement(
                        "UPDATE channel_rules SET position=? WHERE id=?")) {
                    up.setInt(1, i + 1);
                    up.setInt(2, ids.get(i));
                    up.executeUpdate();
                }
            }
        }
    }
}
