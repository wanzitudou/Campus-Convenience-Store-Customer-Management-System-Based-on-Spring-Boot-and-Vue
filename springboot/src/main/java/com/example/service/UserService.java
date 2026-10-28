package com.example.service;

import cn.hutool.core.util.ObjectUtil;
import cn.hutool.core.util.StrUtil;
import com.example.entity.Account;
import com.example.entity.Admin;
import com.example.entity.User;
import com.example.exception.CustomException;
import com.example.mapper.UserMapper;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

@Service
public class UserService {

    @Resource
    private UserMapper userMapper;

    public List<User> selectByAll(String name) {
        return userMapper.selectAll(name);
    }

    /**
     * 分页查询的方法
     */
    public PageInfo<User> selectPage(Integer pageNum, Integer pageSize, String name) {
        PageHelper.startPage(pageNum, pageSize);
        List<User> list = userMapper.selectAll(name);
        return PageInfo.of(list);
    }

    public void deleteById(Integer id) {
        userMapper.deleteById(id);
    }

    public void add(User user) {
        String username = user.getUsername();
        // 校验账户是否重复
        User dbUser = userMapper.selectByUsername(username);
        if (dbUser != null) {
            throw new CustomException("新增失败！账号重复");
        }
        if (StrUtil.isBlank(user.getPassword())) {
            // 默认密码
            user.setPassword("123");
        }
        if (StrUtil.isBlank(user.getName())) {
            // 默认姓名
            user.setName(user.getUsername());
        }
        user.setRole("普通用户"); // 默认用户的角色
        user.setAccount(BigDecimal.ZERO);  // 默认用户的账户余额
        userMapper.insert(user);
    }

    public void update(User user) {
        // user对象里面必须包含ID，否则无法更新数据
        userMapper.updateById(user);
    }

    public Account login(Account account) {
        User dbUser = userMapper.selectByUsername(account.getUsername());
        if (ObjectUtil.isNull(dbUser)) {
            // 提示里带上"角色"，避免把角色选错（选成管理员）时误以为是密码错了
            throw new CustomException("普通用户账号不存在，请确认账号，或检查上方角色是否选成了「管理员」");
        }
        if (!account.getPassword().equals(dbUser.getPassword())) {
            throw new CustomException("密码错误，请检查密码是否带前后空格，或输入法打成了全角字符（普通用户默认密码为 123）");
        }
        return dbUser;
    }

    public User selectById(Integer id) {
        return userMapper.selectById(id);
    }

    /**
     * 修改密码
     */
    public void updatePassword(Account account) {
        User dbUser = userMapper.selectByUsername(account.getUsername());
        if (ObjectUtil.isNull(dbUser)) {
            throw new CustomException("用户不存在");
        }
        if (!account.getPassword().equals(dbUser.getPassword())) {
            throw new CustomException("原密码错误");
        }
        dbUser.setPassword(account.getNewPassword());
        userMapper.updateById(dbUser);
    }

}
