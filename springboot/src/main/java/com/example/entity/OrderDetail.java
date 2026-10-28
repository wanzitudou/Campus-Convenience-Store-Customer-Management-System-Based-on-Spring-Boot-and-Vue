package com.example.entity;

import java.math.BigDecimal;
/**
 * 订单详情实体
 * 对应数据库表 order_detail，记录订单中包含的每个商品
 */
public class OrderDetail {

    /**主键ID */
    private Integer id;
    /**商品ID */
    private Integer goodsId;
    /**商品数量 */
    private Integer num;
    /**订单ID */
    private Integer orderId;
    /**商品图片 */
    private String goodsImg;
    /**商品名称 */
    private String goodsName;
    private BigDecimal goodsPrice;

    public BigDecimal getGoodsPrice() {
        return goodsPrice;
    }

    public void setGoodsPrice(BigDecimal goodsPrice) {
        this.goodsPrice = goodsPrice;
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

    public Integer getOrderId() {
        return orderId;
    }

    public void setOrderId(Integer orderId) {
        this.orderId = orderId;
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
}
