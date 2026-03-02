package com.example.cdlforum.dao;

import com.example.cdlforum.DatabaseUtil;
import com.example.cdlforum.model.User;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.*;
import java.time.OffsetDateTime;

public class UserDAO {

    private static final String SELECT_COLS = "id, username, email, password, user_role, avatar_path, created_at";

    /**
     * Registers a new user.
     *
     * @param role "student" or "professor"
     */
    public User register(String username, String email, String rawPassword, String role)
            throws SQLException {
        if (role == null || (!role.equals("professor")))
            role = "student";
        String hash = BCrypt.hashpw(rawPassword, BCrypt.gensalt(12));
        String sql = "INSERT INTO users (username, email, password, user_role) VALUES (?,?,?,?) RETURNING id, created_at";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username.trim());
            ps.setString(2, email.trim().toLowerCase());
            ps.setString(3, hash);
            ps.setString(4, role);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("id"));
                    u.setUsername(username.trim());
                    u.setEmail(email.trim().toLowerCase());
                    u.setPasswordHash(hash);
                    u.setUserRole(role);
                    u.setCreatedAt(rs.getObject("created_at", OffsetDateTime.class));
                    return u;
                }
            }
        }
        throw new SQLException("Registration failed — no row returned.");
    }

    /** Authenticate by username+password. Returns User or null. */
    public User findByUsernameAndPassword(String username, String rawPassword) throws SQLException {
        String sql = "SELECT " + SELECT_COLS + " FROM users WHERE username = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && BCrypt.checkpw(rawPassword, rs.getString("password"))) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    /** Find user by ID (for profile page). */
    public User findById(int id) throws SQLException {
        String sql = "SELECT " + SELECT_COLS + " FROM users WHERE id = ?";
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

    /** Find user by username (for public profile). */
    public User findByUsername(String username) throws SQLException {
        String sql = "SELECT " + SELECT_COLS + " FROM users WHERE username = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return mapRow(rs);
            }
        }
        return null;
    }

    /** Update the avatar path for a user. */
    public void updateAvatarPath(int userId, String avatarPath) throws SQLException {
        String sql = "UPDATE users SET avatar_path = ? WHERE id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, avatarPath);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    /** Permanently delete a user account (cascades posts/comments via FK). */
    public void deleteAccount(int userId) throws SQLException {
        String sql = "DELETE FROM users WHERE id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    public boolean usernameExists(String username) throws SQLException {
        return exists("SELECT 1 FROM users WHERE username = ?", username.trim());
    }

    public boolean emailExists(String email) throws SQLException {
        return exists("SELECT 1 FROM users WHERE email = ?", email.trim().toLowerCase());
    }

    // ── Helpers ───────────────────────────────────────────────────
    private boolean exists(String sql, String param) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, param);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setUsername(rs.getString("username"));
        u.setEmail(rs.getString("email"));
        u.setPasswordHash(rs.getString("password"));
        u.setUserRole(rs.getString("user_role"));
        u.setAvatarPath(rs.getString("avatar_path"));
        u.setCreatedAt(rs.getObject("created_at", OffsetDateTime.class));
        return u;
    }
}
