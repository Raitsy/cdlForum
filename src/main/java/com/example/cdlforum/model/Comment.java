package com.example.cdlforum.model;

import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;

public class Comment {
    private int id;
    private int postId;
    private int authorId;
    private String authorUsername; // joined from users
    private Integer parentId; // null = top-level
    private String content;
    private OffsetDateTime createdAt;

    // Transient – populated in memory after fetching all comments
    private List<Comment> replies = new ArrayList<>();

    public Comment() {
    }

    // ── Getters & Setters ────────────────────────────────────
    public int getId() {
        return id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getPostId() {
        return postId;
    }

    public void setPostId(int v) {
        this.postId = v;
    }

    public int getAuthorId() {
        return authorId;
    }

    public void setAuthorId(int v) {
        this.authorId = v;
    }

    public String getAuthorUsername() {
        return authorUsername;
    }

    public void setAuthorUsername(String v) {
        this.authorUsername = v;
    }

    public Integer getParentId() {
        return parentId;
    }

    public void setParentId(Integer v) {
        this.parentId = v;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String v) {
        this.content = v;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(OffsetDateTime v) {
        this.createdAt = v;
    }

    public List<Comment> getReplies() {
        return replies;
    }

    public void setReplies(List<Comment> v) {
        this.replies = v;
    }

    public void addReply(Comment c) {
        this.replies.add(c);
    }

    public boolean isTopLevel() {
        return parentId == null;
    }
}
