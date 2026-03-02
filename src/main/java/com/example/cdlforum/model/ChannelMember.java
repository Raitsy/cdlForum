package com.example.cdlforum.model;

import java.time.OffsetDateTime;

public class ChannelMember {
    private int channelId;
    private int userId;
    private String username; // joined from users table
    private String role; // OWNER | MODERATOR | MEMBER
    private OffsetDateTime joinedAt;

    public ChannelMember() {
    }

    public int getChannelId() {
        return channelId;
    }

    public void setChannelId(int channelId) {
        this.channelId = channelId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public OffsetDateTime getJoinedAt() {
        return joinedAt;
    }

    public void setJoinedAt(OffsetDateTime joinedAt) {
        this.joinedAt = joinedAt;
    }

    /** Convenience helpers used in JSP */
    public boolean isOwner() {
        return "OWNER".equals(role);
    }

    public boolean isModerator() {
        return "MODERATOR".equals(role);
    }
}
