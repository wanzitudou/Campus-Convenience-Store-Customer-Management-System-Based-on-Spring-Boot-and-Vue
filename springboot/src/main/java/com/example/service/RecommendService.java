package com.example.service;

import com.example.entity.Goods;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 智能推荐服务（Java 侧调用方）
 * <p>
 * 整体链路：
 * <pre>
 *   前端 /web/recommend?userId=12
 *      → 本类 getRecommendationsForUser()
 *      → HTTP POST 到 Python 推荐服务（FastAPI + ALS 协同过滤）
 *      → 拿到商品 ID 列表
 *      → 回查 MySQL 拿到完整商品信息
 *      → 返回给前端
 * </pre>
 * <p>
 * 关键设计：<b>柔性降级</b>。
 * 推荐服务是"锦上添花"的功能，不是核心交易链路。所以只要它超时、报错、返回空、
 * 或者返回的 ID 在库里已经被删掉，就统统退回到"热销商品（按销量降序）"，
 * 保证首页的"智能推荐"区块永远有内容，不会因为一个旁路服务挂掉就白屏。
 */
@Service
public class RecommendService {

    private static final Logger log = LoggerFactory.getLogger(RecommendService.class);

    @Autowired
    private RestTemplate restTemplate;

    @Autowired
    private GoodsService goodsService;

    /**
     * Python 推荐服务的地址，配置在 application.yml：
     * recommend.service.url
     */
    @Value("${recommend.service.url:http://localhost:8000/recommend}")
    private String recommendUrl;

    /**
     * 为用户获取推荐商品列表
     *
     * @param userId 用户ID
     * @param topN   推荐数量
     * @return 推荐的商品列表；推荐服务不可用时返回热销商品
     */
    public List<Goods> getRecommendationsForUser(Integer userId, int topN) {
        List<Integer> ids = requestRecommendedIds(userId, topN);

        // 命中推荐服务：按推荐顺序（而不是数据库顺序）返回商品
        if (ids != null && !ids.isEmpty()) {
            List<Goods> ordered = orderByGivenIds(goodsService.listByIds(ids), ids);
            if (!ordered.isEmpty()) {
                return ordered.size() > topN ? new ArrayList<>(ordered.subList(0, topN)) : ordered;
            }
        }

        // 降级：热销商品
        log.debug("推荐服务未返回有效结果，降级为热销商品。userId={}", userId);
        return goodsService.getHotGoods(topN);
    }

    /**
     * 调用 Python 服务，拿商品 ID 列表。
     * 任何异常都在这里被吞掉并返回 null，交给上层降级。
     */
    @SuppressWarnings("unchecked")
    private List<Integer> requestRecommendedIds(Integer userId, int topN) {
        try {
            Map<String, Object> body = new HashMap<>();
            body.put("user_id", userId);
            body.put("top_n", topN);

            ResponseEntity<Map> response = restTemplate.postForEntity(recommendUrl, body, Map.class);
            if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
                return null;
            }

            Object raw = response.getBody().get("recommended_item_ids");
            if (!(raw instanceof List<?> rawList) || rawList.isEmpty()) {
                return null;
            }

            List<Integer> ids = new ArrayList<>();
            for (Object item : rawList) {
                if (item instanceof Number number) {
                    ids.add(number.intValue());
                }
            }
            return ids.isEmpty() ? null : ids;
        } catch (Exception e) {
            // 连不上 / 超时 / 返回格式不对，统一日志降级
            log.warn("调用推荐服务失败，将降级为热销商品：{}", e.getMessage());
            return null;
        }
    }

    /**
     * 把数据库查出来的商品，按推荐服务给的 ID 顺序重新排序。
     * （数据库 selectByIds 用的是 IN 查询，返回顺序是不保证的）
     */
    private List<Goods> orderByGivenIds(List<Goods> goodsList, List<Integer> ids) {
        Map<Integer, Goods> map = new HashMap<>();
        for (Goods goods : goodsList) {
            map.put(goods.getId(), goods);
        }
        List<Goods> ordered = new ArrayList<>();
        for (Integer id : ids) {
            Goods goods = map.get(id);
            // 过滤掉已下架/已删除的商品
            if (goods != null && !"下架".equals(goods.getStatus())) {
                ordered.add(goods);
            }
        }
        return ordered;
    }
}
