package com.example.common;
/**
 * 统一响应结果封装类
 * 用于规范后端API返回的数据格式，包含状态码、提示信息和业务数据。
 * 所有控制器接口应返回此对象，以便前端统一处理。
 */
public class Result {
    private String code;
    private String msg;
    private Object data;
    /**
     * 私有构造方法，用于创建包含业务数据的Result对象
     * @param data 业务数据
     */
    private Result(Object data) {
        this.data = data;
    }

    public Result() {
    }
    /**
     * 返回成功响应（无业务数据）
     * @return Result对象，code=200，msg="请求成功"
     */

    public static Result success() {
        Result result = new Result();
        result.setCode("200");
        result.setMsg("请求成功");
        return result;
    }
    /**
     * 返回成功响应（包含业务数据）
     * @param data 业务数据
     * @return Result对象，code=200，msg="请求成功"，data为传入的数据
     */
    public static Result success(Object data) {
        Result result = success();
        result.setData(data);
        return result;
    }
    /**
     * 返回错误响应（默认错误信息）
     * @return Result对象，code=500，msg="请求失败"
     */
    public static Result error() {
        Result result = new Result();
        result.setCode("500");
        result.setMsg("请求失败");
        return result;
    }
    /**
     * 返回错误响应（自定义错误信息）
     * @param msg 自定义错误提示信息
     * @return Result对象，code=500，msg为传入的自定义信息
     */
    public static Result error(String msg) {
        Result result = new Result();
        result.setCode("500");
        result.setMsg(msg);
        return result;
    }
    // ---------- Getter 和 Setter 方法 ----------
    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public Object getData() {
        return data;
    }

    public void setData(Object data) {
        this.data = data;
    }
}
