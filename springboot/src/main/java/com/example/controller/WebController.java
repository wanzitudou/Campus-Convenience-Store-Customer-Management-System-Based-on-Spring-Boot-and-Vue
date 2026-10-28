package com.example.controller;

import cn.hutool.core.date.DateField;
import cn.hutool.core.date.DateTime;
import cn.hutool.core.date.DateUtil;
import com.example.common.Result;
import com.example.entity.*;
import com.example.mapper.OrderDetailMapper;
import com.example.service.*;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.*;

@RestController
public class WebController {

    @Resource
    private AdminService adminService;
    @Resource
    private UserService userService;
    @Resource
    OrdersService ordersService;
    @Resource
    GoodsService goodsService;
    @Resource
    CategoryService categoryService;
    @Resource
    OrderDetailMapper orderDetailMapper;
    @Resource
    private RecommendService recommendService;

    /**
     * 默认请求接口
     * 前台页面相关接口
     */
    @GetMapping("/")
    public Result hello() {
        return Result.success();
    }
    @GetMapping("/web/recommend")
    public Result getRecommend(@RequestParam(defaultValue = "1") Integer userId) {
        // 首页"智能推荐"区块一行展示 4 个卡片，所以取 4 条；条数不足时 RecommendService 会用热销商品补齐
        List<Goods> list = recommendService.getRecommendationsForUser(userId, 4);
        return Result.success(list);
    }

    /**
     * 登录
     */
    @PostMapping("/login")
    public Result login(@RequestBody Account account) {
        // 去掉账号/密码前后的空白字符。
        // 复制粘贴或手输时很容易带上尾随空格，而密码是精确比较，
        // 多一个空格就会提示"密码错误"，非常难排查。
        if (account.getUsername() != null) {
            account.setUsername(account.getUsername().trim());
        }
        if (account.getPassword() != null) {
            account.setPassword(account.getPassword().trim());
        }

        Account ac = null;
        if ("管理员".equals(account.getRole())) {
            ac = adminService.login(account);
        }
        if ("普通用户".equals(account.getRole())) {
            ac = userService.login(account);
        }
        if (ac == null) {
            return Result.error("登录失败，请检查上方角色是否选对（管理员 / 普通用户）");
        }
        return Result.success(ac);
    }

    /**
     * 注册
     */
    @PostMapping("/register")
    public Result register(@RequestBody User user) {
        if (!user.getPassword().equals(user.getNewPassword())) {
            return Result.error("两次输入密码不一致");
        }
        userService.add(user);
        return Result.success();
    }

    /**
     * 修改密码
     */
    @PutMapping("/updatePassword")
    public Result updatePassword(@RequestBody Account account) {
        if ("管理员".equals(account.getRole())) {
            adminService.updatePassword(account);
        }
        if ("普通用户".equals(account.getRole())) {
            userService.updatePassword(account);
        }
        return Result.success();
    }

    // 数据统计使用的接口
    @GetMapping("/count")
    public Result count() {
        List<Orders> ordersList = ordersService.selectAll(null).stream().filter(orders -> !orders.getStatus().equals("已取消")).toList();
        BigDecimal total = ordersList.stream().map(Orders::getTotal).reduce(BigDecimal::add).orElse(BigDecimal.ZERO);
        String todayDate = DateUtil.today();  // 2025-12-05
        BigDecimal today = ordersList.stream().filter(orders -> orders.getTime().contains(todayDate))
                .map(Orders::getTotal).reduce(BigDecimal::add).orElse(BigDecimal.ZERO);
        Integer goods = goodsService.selectAll(null).size();
        Integer user = userService.selectByAll(null).size();
        Map<String, Object> map = new HashMap<>();
        map.put("total", total);
        map.put("today", today);
        map.put("goods", goods);
        map.put("user", user);
        return Result.success(map);
    }

    @GetMapping("/selectLine")
    public Result selectLine() {
        Date date = new Date();
        DateTime start = DateUtil.offsetDay(date, -6);
        List<DateTime> dateTimes = DateUtil.rangeToList(start, date, DateField.DAY_OF_YEAR);
        List<String> dateStrList = dateTimes.stream().map(dateTime -> DateUtil.format(dateTime, "MM-dd")).sorted().toList();
        List<Orders> ordersList = ordersService.selectAll(null).stream().filter(orders -> !orders.getStatus().equals("已取消")).toList();
        int year = DateUtil.year(date);
        ArrayList<BigDecimal> countList = new ArrayList<>();
        for (String day : dateStrList) {
            // 包含  年月日的  订单
            BigDecimal total = ordersList.stream().filter(o -> o.getTime().contains(String.valueOf(year)) && o.getTime().contains(day))
                    .map(Orders::getTotal).reduce(BigDecimal::add).orElse(BigDecimal.ZERO);
            countList.add(total);
        }
        Map<String, Object> map = new HashMap<>();
        map.put("date", dateStrList);
        map.put("count", countList);
        return Result.success(map);
    }

    @GetMapping("/selectPie")
    public Result selectPie() {
        List<Map<String, Object>> list = new ArrayList<>();
        List<Category> categoryList = categoryService.selectAll(null);
        Map<String, Object> map;
        for (Category category : categoryList) {
            map = new HashMap<>();
            map.put("name", category.getName());
            BigDecimal total = BigDecimal.ZERO;
            List<OrderDetail> orderDetailList = orderDetailMapper.selectAll(null);
            for (OrderDetail orderDetail : orderDetailList) {
                Integer orderId = orderDetail.getOrderId();
                Orders orders = ordersService.selectById(orderId);
                if (!orders.getStatus().equals("已取消")) {
                    Integer goodsId = orderDetail.getGoodsId();
                    Goods goods = goodsService.selectById(goodsId);
                    if (goods.getCategoryId().equals(category.getId())) {
                        total = total.add(orders.getTotal());
                    }
                }
            }

            map.put("value", total);
            if (total.compareTo(BigDecimal.ZERO) > 0) {
                list.add(map);
            }
        }
        return Result.success(list);
    }

}

