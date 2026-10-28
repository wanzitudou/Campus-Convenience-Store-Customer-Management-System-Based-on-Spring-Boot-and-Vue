package com.example.controller;

import com.example.common.Result;
import com.example.entity.Admin;
import com.example.service.AdminService;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 管理员前端操作接口控制器
 * 提供管理员实体的增删改查及分页查询功能
 * 基础路径：/admin
 **/
@RestController
@RequestMapping("/admin")
public class AdminController {

    @Resource
    private AdminService adminService;

    /**
     * 新增管理员
     * @param admin 管理员对象（JSON格式），无需提供id（由数据库自增）
     *  @return 操作成功的统一响应
     */
    @PostMapping("/add")
    public Result add(@RequestBody Admin admin) {
        adminService.add(admin);
        return Result.success();
    }

    /**
     * 根据ID删除管理员
     * @param id 管理员ID（路径变量）
     * @return 操作成功的统一响应
     */
    @DeleteMapping("/delete/{id}")
    public Result deleteById(@PathVariable Integer id) {
        adminService.deleteById(id);
        return Result.success();
    }

    /**
     * 修改管理员信息
     * @param admin 管理员对象（JSON格式），必须包含id以指定要修改的记录
     * @return 操作成功的统一响应
     */
    @PutMapping("/update")
    public Result updateById(@RequestBody Admin admin) {
        adminService.updateById(admin);
        return Result.success();
    }

    /**
     * 根据ID查询单个管理员
     * @param id 管理员ID（路径变量）
     * @return 包含管理员对象的成功响应
     */
    @GetMapping("/selectById/{id}")
    public Result selectById(@PathVariable Integer id) {
        Admin admin = adminService.selectById(id);
        return Result.success(admin);
    }

    /**
     * 查询所有管理员（支持条件筛选）
     * @param admin 可选的查询条件对象，请求参数会自动绑定到该对象的属性
     *              （例如：/admin/selectAll?username=admin 会将username赋值给admin对象的username属性）
     * @return 包含管理员列表的成功响应
     */
    @GetMapping("/selectAll")
    public Result selectAll(Admin admin) {
        List<Admin> list = adminService.selectAll(admin);
        return Result.success(list);
    }

    /**
     * 分页查询管理员
     * @param admin    查询条件对象（可选）
     * @param pageNum  当前页码，默认值为1
     * @param pageSize 每页条数，默认值为10
     * @return 包含分页数据（PageInfo对象）的成功响应
     */
    @GetMapping("/selectPage")
    public Result selectPage(Admin admin,
                             @RequestParam(defaultValue = "1") Integer pageNum,
                             @RequestParam(defaultValue = "10") Integer pageSize) {
        PageInfo<Admin> page = adminService.selectPage(admin, pageNum, pageSize);
        return Result.success(page);
    }

}