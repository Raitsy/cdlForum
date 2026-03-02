package com.example.cdlforum.dao;

import com.example.cdlforum.DatabaseUtil;
import com.example.cdlforum.model.Channel;

import java.sql.*;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;

public class ChannelDAO {

    // ── Create ───────────────────────────────────────────────
    public Channel create(String name, String slug, String description,
            String imagePath, String bannerPath, int ownerId) throws SQLException {

        String sql = """
                INSERT INTO channels (name, slug, description, image_path, banner_path, owner_id)
                VALUES (?, ?, ?, ?, ?, ?) RETURNING id, created_at
                """;
        try (Connection c = DatabaseUtil.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, name.trim());
            ps.setString(2, slug.trim().toLowerCase());
            ps.setString(3, description != null ? description.trim() : null);
            ps.setString(4, imagePath);
            ps.setString(5, bannerPath);
            ps.setInt(6, ownerId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Channel ch = new Channel();
                    ch.setId(rs.getInt("id"));
                    ch.setName(name.trim());
                    ch.setSlug(slug.trim().toLowerCase());
                    ch.setDescription(description);
                    ch.setImagePath(imagePath);
                    ch.setBannerPath(bannerPath);
                    ch.setOwnerId(ownerId);
                    ch.setCreatedAt(rs.getObject("created_at", OffsetDateTime.class));
                    return ch;
                }
            }
        }
        throw new SQLException("Channel creation failed — no row returned.");
    }

    // ── Find by ID ───────────────────────────────────────────
    public Channel findById(int id) throws SQLException {
        String sql = """
                SELECT c.*, COUNT(cm.user_id) AS member_count
                FROM channels c
                LEFT JOIN channel_members cm ON cm.channel_id = c.id
                WHERE c.id = ?
                GROUP BY c.id
                """;
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return mapRow(rs);
            }
        }
        return null;
    }

    // ── Find by Slug ─────────────────────────────────────────
    public Channel findBySlug(String slug) throws SQLException {
        String sql = """
                SELECT c.*, COUNT(cm.user_id) AS member_count
                FROM channels c
                LEFT JOIN channel_members cm ON cm.channel_id = c.id
                WHERE c.slug = ?
                GROUP BY c.id
                """;
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, slug.toLowerCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return mapRow(rs);
            }
        }
        return null;
    }

    // ── Find all (ordered by member count desc) ───────────────
    public List<Channel> findAll() throws SQLException {
        String sql = """
                SELECT c.*, COUNT(cm.user_id) AS member_count
                FROM channels c
                LEFT JOIN channel_members cm ON cm.channel_id = c.id
                GROUP BY c.id
                ORDER BY member_count DESC, c.created_at DESC
                """;
        List<Channel> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next())
                list.add(mapRow(rs));
        }
        return list;
    }

    // ── Channels the user has joined ─────────────────────────
    public List<Channel> findByMember(int userId) throws SQLException {
        String sql = """
                SELECT c.*, COUNT(cm2.user_id) AS member_count
                FROM channels c
                JOIN channel_members cm ON cm.channel_id = c.id AND cm.user_id = ?
                LEFT JOIN channel_members cm2 ON cm2.channel_id = c.id
                GROUP BY c.id
                ORDER BY c.name ASC
                """;
        List<Channel> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    list.add(mapRow(rs));
            }
        }
        return list;
    }

    // ── Top N channels by member count (for home sidebar) ─────
    public List<Channel> findTopChannels(int limit) throws SQLException {
        String sql = """
                SELECT c.*, COUNT(cm.user_id) AS member_count
                FROM channels c
                LEFT JOIN channel_members cm ON cm.channel_id = c.id
                GROUP BY c.id
                ORDER BY member_count DESC
                LIMIT ?
                """;
        List<Channel> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    list.add(mapRow(rs));
            }
        }
        return list;
    }

    // ── Update ───────────────────────────────────────────────
    public void update(int id, String name, String slug, String description,
            String imagePath, String bannerPath) throws SQLException {
        String sql = """
                UPDATE channels SET name=?, slug=?, description=?, image_path=?, banner_path=?
                WHERE id=?
                """;
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name.trim());
            ps.setString(2, slug.trim().toLowerCase());
            ps.setString(3, description);
            ps.setString(4, imagePath);
            ps.setString(5, bannerPath);
            ps.setInt(6, id);
            ps.executeUpdate();
        }
    }

    // ── Slug exists? ──────────────────────────────────────────
    public boolean slugExists(String slug) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM channels WHERE slug=?")) {
            ps.setString(1, slug.toLowerCase());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean slugExistsExcluding(String slug, int excludeId) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "SELECT 1 FROM channels WHERE slug=? AND id<>?")) {
            ps.setString(1, slug.toLowerCase());
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // ── Map ResultSet row ─────────────────────────────────────
    private Channel mapRow(ResultSet rs) throws SQLException {
        Channel ch = new Channel();
        ch.setId(rs.getInt("id"));
        ch.setName(rs.getString("name"));
        ch.setSlug(rs.getString("slug"));
        ch.setDescription(rs.getString("description"));
        ch.setImagePath(rs.getString("image_path"));
        ch.setBannerPath(rs.getString("banner_path"));
        ch.setOwnerId(rs.getInt("owner_id"));
        ch.setCreatedAt(rs.getObject("created_at", OffsetDateTime.class));
        ch.setMemberCount(rs.getLong("member_count"));
        return ch;
    }
}
