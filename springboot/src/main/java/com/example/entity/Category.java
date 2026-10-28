package com.example.entity;
/**
 * 商品分类实体
 * 对应数据库表 category，用于对商品进行层级分类
 */
public class Category {

    /**主键ID */
    private Integer id;
    /**名称 */
    private String name;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
