package com.example.entity;

import java.math.BigDecimal;
/**
 * 购物车项实体
 * 对应数据库表 cart，记录用户添加到购物车的商品
 */

public class Cart {


    /**主键ID */
    private Integer id;
    /**商品ID */
    private Integer goodsId;
    private String goodsName;
    private String goodsImg;
    private BigDecimal goodsPrice;
    /**数量 */
    private Integer num;
    /**用户ID */
    private Integer userId;

    public BigDecimal getGoodsPrice() {
        return goodsPrice;
    }

    public void setGoodsPrice(BigDecimal goodsPrice) {
        this.goodsPrice = goodsPrice;
    }

    public String getGoodsImg() {
        return goodsImg;
    }

    public void setGoodsImg(String goodsImg) {
        this.goodsImg = goodsImg;
    }

    public String getGoodsName() {
        return goodsName;
    }

    public void setGoodsName(String goodsName) {
        this.goodsName = goodsName;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getGoodsId() {
        return goodsId;
    }

    public void setGoodsId(Integer goodsId) {
        this.goodsId = goodsId;
    }

    public Integer getNum() {
        return num;
    }

    public void setNum(Integer num) {
        this.num = num;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }
}
