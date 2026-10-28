package com.example.entity;
/**
 * 首页轮播图配置实体
 * 对应数据库表 carousel，用于管理首页展示的轮播图片
 */
public class Carousel {

    /**主键ID */
    private Integer id;
    /**商品 */
    private Integer goodsId;
    private String goodsName;
    /**图片 */
    private String img;

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

    public String getGoodsName() {
        return goodsName;
    }

    public void setGoodsName(String goodsName) {
        this.goodsName = goodsName;
    }

    public String getImg() {
        return img;
    }

    public void setImg(String img) {
        this.img = img;
    }
}
