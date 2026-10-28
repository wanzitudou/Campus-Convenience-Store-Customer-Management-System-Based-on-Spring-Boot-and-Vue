package com.example.service;

import cn.hutool.core.util.ObjectUtil;
import com.example.entity.Account;
import com.example.entity.Admin;
import com.example.exception.CustomException;
import com.example.mapper.AdminMapper;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 管理员业务处理
 **/
@Service
public class AdminService {

    @Resource
    private AdminMapper adminMapper;

    /**
     * 新增
     */
    public void add(Admin admin) {
        Admin dbAdmin = adminMapper.selectByUsername(admin.getUsername());
        if (ObjectUtil.isNotNull(dbAdmin)) {
            throw new CustomException("该管理员账号已存在");
        }
        if (ObjectUtil.isEmpty(admin.getPassword())) {
            admin.setPassword("admin");
        }
        if (ObjectUtil.isEmpty(admin.getName())) {
            admin.setName(admin.getUsername());
        }
        admin.setRole("管理员");
        adminMapper.insert(admin);
    }

    /**
     * 删除
     */
    public void deleteById(Integer id) {
        adminMapper.deleteById(id);
    }

    /**
     * 修改
     */
    public void updateById(Admin admin) {
        adminMapper.updateById(admin);
    }

    /**
     * 根据ID查询
     */
    public Admin selectById(Integer id) {
        return adminMapper.selectById(id);
    }

    /**
     * 查询所有
     */
    public List<Admin> selectAll(Admin admin) {
        return adminMapper.selectAll(admin);
    }

    /**
     * 分页查询
     */
    public PageInfo<Admin> selectPage(Admin admin, Integer pageNum, Integer pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        List<Admin> list = adminMapper.selectAll(admin);
        return PageInfo.of(list);
    }

    /**
     * 登录
     */
    public Account login(Account account) {
        Account dbAdmin = adminMapper.selectByUsername(account.getUsername());
        if (ObjectUtil.isNull(dbAdmin)) {
            // 提示里带上"角色"，避免把角色选错（选成普通用户）时误以为是密码错了
            throw new CustomException("管理员账号不存在，请确认账号，或检查上方角色是否选成了「普通用户」");
        }
        if (!account.getPassword().equals(dbAdmin.getPassword())) {
            throw new CustomException("密码错误，请检查密码是否带前后空格，或输入法打成了全角字符（管理员默认密码为 admin）");
        }
        return dbAdmin;
    }

    /**
     * 修改密码
     */
    public void updatePassword(Account account) {
        Admin dbAdmin = adminMapper.selectByUsername(account.getUsername());
        if (ObjectUtil.isNull(dbAdmin)) {
            throw new CustomException("用户不存在");
        }
        if (!account.getPassword().equals(dbAdmin.getPassword())) {
            throw new CustomException("原密码错误");
        }
        dbAdmin.setPassword(account.getNewPassword());
        adminMapper.updateById(dbAdmin);
    }

}