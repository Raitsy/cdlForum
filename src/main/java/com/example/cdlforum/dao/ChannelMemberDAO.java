package com.example.cdlforum.dao;

import com.example.cdlforum.DatabaseUtil;
import com.example.cdlforum.model.ChannelMember;

import java.sql.*;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;

public class ChannelMemberDAO {

    /** Add a user to a channel with given role. */
    public void join(int channelId, int userId, String role) throws SQLException {
        String sql = """
                INSERT INTO channel_members (channel_id, user_id, role)
                VALUES (?, ?, ?)
                ON CONFLICT (channel_id, user_id) DO NOTHING
                """;
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, channelId);
            ps.setInt(2, userId);
            ps.setString(3, role);
            ps.executeUpdate();
        }
    }

    /** Remove a user from a channel. Owners cannot leave (enforced in servlet). */
    public void leave(int channelId, int userId) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM channel_members WHERE channel_id=? AND user_id=?")) {
            ps.setInt(1, channelId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    /** Returns the role string for (channelId, userId), or null if not a member. */
    public String getRole(int channelId, int userId) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "SELECT role FROM channel_members WHERE channel_id=? AND user_id=?")) {
            ps.setInt(1, channelId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("role") : null;
            }
        }
    }

    public boolean isMember(int channelId, int userId) throws SQLException {
        return getRole(channelId, userId) != null;
    }

    /** Change a member's role. */
    public void setRole(int channelId, int userId, String role) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "UPDATE channel_members SET role=? WHERE channel_id=? AND user_id=?")) {
            ps.setString(1, role);
            ps.setInt(2, channelId);
            ps.setInt(3, userId);
            ps.executeUpdate();
        }
    }

    /** All members of a channel, joined with username from users table. */
    public List<ChannelMember> getMembers(int channelId) throws SQLException {
        String sql = """
                SELECT cm.channel_id, cm.user_id, u.username, cm.role, cm.joined_at
                FROM channel_members cm
                JOIN users u ON u.id = cm.user_id
                WHERE cm.channel_id = ?
                ORDER BY CASE cm.role WHEN 'OWNER' THEN 1 WHEN 'MODERATOR' THEN 2 ELSE 3 END, u.username
                """;
        List<ChannelMember> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, channelId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ChannelMember m = new ChannelMember();
                    m.setChannelId(rs.getInt("channel_id"));
                    m.setUserId(rs.getInt("user_id"));
                    m.setUsername(rs.getString("username"));
                    m.setRole(rs.getString("role"));
                    m.setJoinedAt(rs.getObject("joined_at", OffsetDateTime.class));
                    list.add(m);
                }
            }
        }
        return list;
    }
}
