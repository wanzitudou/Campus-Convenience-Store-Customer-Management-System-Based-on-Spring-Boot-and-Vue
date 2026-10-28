package com.example.entity;

import java.math.BigDecimal;
/**
 * 普通用户实体
 * 对应数据库表 user，继承自 Account 基类
 * 存储普通用户的特有信息
 */
public class User extends Account {
    private Integer id;
    private String username;
    private String password;
    private String name;
    private String avatar;
    private String role;
    private BigDecimal account;

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public BigDecimal getAccount() {
        return account;
    }

    public void setAccount(BigDecimal account) {
        this.account = account;
    }
}
