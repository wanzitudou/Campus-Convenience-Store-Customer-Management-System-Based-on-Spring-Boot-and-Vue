package com.example.service;

import cn.hutool.core.date.DateUtil;
import com.example.entity.Goods;
import com.example.mapper.CartMapper;
import com.example.mapper.GoodsMapper;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Collection;
import java.util.ArrayList;

/**
 * 业务处理
 **/
@Service
public class GoodsService {

    @Resource
    private GoodsMapper goodsMapper;
    @Resource
    CartMapper cartMapper;

    /**
     * 新增
     */
    public void add(Goods goods) {
        goods.setViews(0);
        goods.setSaleCount(0);
        String now = DateUtil.now();
        goods.setTime(now);
        goodsMapper.insert(goods);
    }

    /**
     * 删除
     */
    @Transactional
    public void deleteById(Integer id) {
        goodsMapper.deleteById(id);
        // 删除购物车的对应的商品
        cartMapper.deleteByGoodsId(id);
    }

    /**
     * 修改
     */
    public void updateById(Goods goods) {
        goodsMapper.updateById(goods);
        if ("下架".equals(goods.getStatus())) {
            // 删除购物车的对应的商品
            cartMapper.deleteByGoodsId(goods.getId());
        }
    }

    /**
     * 根据ID查询
     */
    public Goods selectById(Integer id) {
        return goodsMapper.selectById(id);
    }

    /**
     * 查询所有
     */
    public List<Goods> selectAll(Goods goods) {
        return goodsMapper.selectAll(goods);
    }

    /**
     * 分页查询
     */
    public PageInfo<Goods> selectPage(Goods goods, Integer pageNum, Integer pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        List<Goods> list = goodsMapper.selectAll(goods);
        return PageInfo.of(list);
    }


    /**
     * 根据ID列表批量查询商品
     * @param ids 商品ID集合
     * @return 商品列表
     */
    public List<Goods> listByIds(Collection<Integer> ids) {
        if (ids == null || ids.isEmpty()) {
            return new ArrayList<>();
        }
        return goodsMapper.selectByIds(ids);
    }

    /**
     * 获取热门商品（按销量降序）
     * @param limit 获取的数量
     * @return 热门商品列表
     */
    public List<Goods> getHotGoods(int limit) {
        System.out.println("=== getHotGoods 被调用，limit=" + limit);
        try {
            List<Goods> list = goodsMapper.selectHotGoods(limit);
            System.out.println("=== 查询到商品数量：" + list.size());
            return list;
        } catch (Exception e) {
            System.err.println("=== selectHotGoods 调用失败：" + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
}