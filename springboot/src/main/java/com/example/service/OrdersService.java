package com.example.service;

import cn.hutool.core.date.DateUtil;
import cn.hutool.core.util.RandomUtil;
import com.example.entity.*;
import com.example.exception.CustomException;
import com.example.mapper.*;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * 业务处理
 **/
@Service
public class OrdersService {

    @Resource
    private OrdersMapper ordersMapper;
    @Resource
    GoodsMapper goodsMapper;
    @Resource
    UserMapper userMapper;
    @Resource
    OrderDetailMapper orderDetailMapper;
    @Resource
    CartMapper cartMapper;

    /**
     * 购物车批量和单个商品 通用的下单接口
     */
    @Transactional
    public void add(Orders orders) {
        orders.setStatus("待接单");
        orders.setTime(DateUtil.now());
        // 随机的订单编号  20251202
        String orderNo = DateUtil.format(new Date(), "yyyyMMdd") + System.currentTimeMillis() + RandomUtil.randomNumbers(4);
        orders.setOrderNo(orderNo);
        ordersMapper.insert(orders);
        Integer orderId = orders.getId();
        List<Cart> cartList = orders.getCartList();
        User user = userMapper.selectById(orders.getUserId());
        BigDecimal totalPrice = BigDecimal.ZERO;
        for (Cart cart : cartList) {
            Integer goodsId = cart.getGoodsId();
            Goods goods = goodsMapper.selectById(goodsId);
            if (goods.getStore() < cart.getNum()) {  // 库存不足
                throw new CustomException(goods.getName() + "商品库存不足");
            }
            goods.setStore(goods.getStore() - cart.getNum());  // 扣减库存
            goods.setSaleCount(goods.getSaleCount() + cart.getNum());  // 增加销量
            goodsMapper.updateById(goods);  // 更新商品的库存
            // 新增订单详情
            OrderDetail orderDetail = new OrderDetail();
            orderDetail.setNum(cart.getNum());
            orderDetail.setGoodsId(goodsId);
            orderDetail.setGoodsImg(goods.getImg());
            orderDetail.setGoodsName(goods.getName());
            orderDetail.setGoodsPrice(goods.getPrice());
            orderDetail.setOrderId(orderId);
            orderDetailMapper.insert(orderDetail);

            // 删除下单的商品所对应的购物车记录
            if (cart.getId() != null) {
                cartMapper.deleteById(cart.getId());
            }

            totalPrice = totalPrice.add(goods.getPrice().multiply(BigDecimal.valueOf(cart.getNum())));
        }
        if (user.getAccount().compareTo(totalPrice) < 0) {  // 用户的余额小于订单的总价格
            throw new CustomException("对不起，您的账户余额不足，请充值！");
        }
        user.setAccount(user.getAccount().subtract(totalPrice));
        userMapper.updateById(user);  // 更新余额
        orders.setTotal(totalPrice);
        ordersMapper.updateById(orders);  // 更新订单总额
    }

    /**
     * 删除
     */
    @Transactional
    public void deleteById(Integer id) {
        ordersMapper.deleteById(id);
        orderDetailMapper.deleteByOrderId(id);
    }

    /**
     * 修改
     */
    @Transactional
    public void updateById(Orders orders) {
        if ("已取消".equals(orders.getStatus())) {
            Integer userId = orders.getUserId();
            User user = userMapper.selectById(userId);
            user.setAccount(user.getAccount().add(orders.getTotal()));
            userMapper.updateById(user);
            // 商品库存 加回去   商品的销量 减去
            OrderDetail orderDetail = new OrderDetail();
            orderDetail.setOrderId(orders.getId());
            List<OrderDetail> orderDetailList = orderDetailMapper.selectAll(orderDetail);
            for (OrderDetail detail : orderDetailList) {
                Integer goodsId = detail.getGoodsId();
                Goods goods = goodsMapper.selectById(goodsId);
                if (goods != null) {
                    goods.setStore(goods.getStore() + detail.getNum());
                    goods.setSaleCount(goods.getSaleCount() - detail.getNum());
                    goodsMapper.updateById(goods);
                }
            }
        }
        ordersMapper.updateById(orders);
    }

    /**
     * 根据ID查询
     */
    public Orders selectById(Integer id) {
        return ordersMapper.selectById(id);
    }

    /**
     * 查询所有
     */
    public List<Orders> selectAll(Orders orders) {
        return ordersMapper.selectAll(orders);
    }

    /**
     * 分页查询
     */
    public PageInfo<Orders> selectPage(Orders orders, Integer pageNum, Integer pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        List<Orders> list = ordersMapper.selectAll(orders);
        for (Orders o : list) {
            OrderDetail orderDetail = new OrderDetail();
            orderDetail.setOrderId(o.getId());
            List<OrderDetail> orderDetailList = orderDetailMapper.selectAll(orderDetail);
            o.setOrderDetailList(orderDetailList);
        }
        return PageInfo.of(list);
    }

}