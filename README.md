# Campus-Convenience-Store-Customer-Management-System-Based-on-Spring-Boot-and-Vue
面向电商场景的 AI 辅助数据分析师毕业设计项目，含用户行为看板与销量预测模块
# 校园小卖部客户管理系统（Campus Store CRM）

基于 Spring Boot 3 + Vue 3 的前后端分离客户管理系统，以校园小卖部为场景，涵盖商品、订单、用户、智能推荐与 AI 客服。

## 🚀 技术栈

| 后端 | 前端 | 数据库 | 智能服务 |
|------|------|--------|----------|
| Spring Boot 3.3.1 | Vue 3.3.4 | MySQL 8.0.33 | Python + FastAPI |
| MyBatis 3.0.3 | Element Plus 2.4.0 | | implicit (ALS) |
| Spring AI | Pinia / Vue Router | | DeepSeek 大模型 |
| JWT / BCrypt | Axios / SSE | | |

## ✨ 核心功能

- **前台用户端**：注册登录、商品浏览/搜索、商品详情、购物车、订单、收藏、评价、充值、智能推荐、AI 客服。
- **后台管理端**：用户管理、商品分类、商品管理、轮播图、订单查看、评价管理、充值记录。
- **智能推荐**：基于用户行为的 ALS 协同过滤，独立 Python 服务，支持降级为热门商品。
- **AI 客服**：Spring AI + DeepSeek，SSE 流式对话，多轮记忆，Markdown 渲染。


## 🧠 项目亮点

1. **高内聚低耦合**：前后端分离，智能服务独立部署。
2. **推荐降级策略**：推荐服务不可用时自动切换热门商品，保证高可用。
3. **代码生成工具**：CopyUtils 一键生成 CRUD 代码，开发效率提升 30%。
4. **完整测试**：28 个功能测试用例全部通过，兼容 Chrome/Firefox/Edge。

## 🛠 快速运行

### 后端
```bash
cd springboot
mvn spring-boot:run
