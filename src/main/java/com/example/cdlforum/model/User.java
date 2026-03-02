package com.example.cdlforum.model;

import java.time.OffsetDateTime;

/**
 * Represents a registered user.
 * userRole: "student" | "professor"
 * avatarPath: server-relative path to the uploaded avatar image, or null.
 */
public class User {
    private int id;
    private String username;
    private String email;
    private String passwordHash;
    private String userRole; // "student" or "professor"
    private String avatarPath; // e.g. "/uploads/avatars/42.jpg"
    private OffsetDateTime createdAt;

    public User() {
    }

    // ── Getters & Setters ────────────────────────────────────────
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String v) {
        this.username = v;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String v) {
        this.email = v;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String v) {
        this.passwordHash = v;
    }

    public String getUserRole() {
        return userRole;
    }

    public void setUserRole(String v) {
        this.userRole = v;
    }

    public String getAvatarPath() {
        return avatarPath;
    }

    public void setAvatarPath(String v) {
        this.avatarPath = v;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(OffsetDateTime v) {
        this.createdAt = v;
    }

    /** Convenience: true if the user is a professor. */
    public boolean isProfessor() {
        return "professor".equalsIgnoreCase(userRole);
    }

    /** Display-safe initial (first char of username, upper-cased). */
    public String getInitial() {
        return username != null && !username.isEmpty()
                ? username.substring(0, 1).toUpperCase()
                : "?";
    }
}
