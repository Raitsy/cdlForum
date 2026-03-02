package com.example.cdlforum.model;

import java.time.OffsetDateTime;

/**
 * Forum post.
 * Author fields (username, role, avatarPath) are populated via JOIN in PostDAO.
 */
public class Post {
    // Stored columns
    private int id;
    private int channelId;
    private int authorId;
    private String title;
    private String content;
    private int voteCount;
    private boolean pinned;
    private OffsetDateTime createdAt;

    // Joined / transient
    private String channelName;
    private String authorUsername;
    private String authorRole; // "student" | "professor" – from JOIN with users
    private String authorAvatarPath; // from JOIN with users
    private long commentCount;
    private boolean hasVoted;

    public Post() {
    }

    // ── Stored ────────────────────────────────────────────────────
    public int getId() {
        return id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getChannelId() {
        return channelId;
    }

    public void setChannelId(int v) {
        this.channelId = v;
    }

    public int getAuthorId() {
        return authorId;
    }

    public void setAuthorId(int v) {
        this.authorId = v;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String v) {
        this.title = v;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String v) {
        this.content = v;
    }

    public int getVoteCount() {
        return voteCount;
    }

    public void setVoteCount(int v) {
        this.voteCount = v;
    }

    public boolean isPinned() {
        return pinned;
    }

    public void setPinned(boolean v) {
        this.pinned = v;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(OffsetDateTime v) {
        this.createdAt = v;
    }

    // ── Joined ────────────────────────────────────────────────────
    public String getChannelName() {
        return channelName;
    }

    public void setChannelName(String v) {
        this.channelName = v;
    }

    public String getAuthorUsername() {
        return authorUsername;
    }

    public void setAuthorUsername(String v) {
        this.authorUsername = v;
    }

    public String getAuthorRole() {
        return authorRole;
    }

    public void setAuthorRole(String v) {
        this.authorRole = v;
    }

    public String getAuthorAvatarPath() {
        return authorAvatarPath;
    }

    public void setAuthorAvatarPath(String v) {
        this.authorAvatarPath = v;
    }

    public long getCommentCount() {
        return commentCount;
    }

    public void setCommentCount(long v) {
        this.commentCount = v;
    }

    public boolean isHasVoted() {
        return hasVoted;
    }

    public void setHasVoted(boolean v) {
        this.hasVoted = v;
    }

    // ── Helpers ───────────────────────────────────────────────────
    /** Returns a ~200-char excerpt of the content for post-card preview. */
    public String getContentPreview(int maxLen) {
        if (content == null || content.isEmpty())
            return null;
        if (content.length() <= maxLen)
            return content;
        return content.substring(0, maxLen).stripTrailing();
    }

    public boolean isProfessor() {
        return "professor".equalsIgnoreCase(authorRole);
    }

    public String getAuthorInitial() {
        return authorUsername != null && !authorUsername.isEmpty()
                ? authorUsername.substring(0, 1).toUpperCase()
                : "?";
    }
}
