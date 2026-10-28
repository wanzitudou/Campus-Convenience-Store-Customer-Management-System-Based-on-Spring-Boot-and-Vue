/*
 Navicat Premium Data Transfer

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 80406
 Source Host           : localhost:3306
 Source Schema         : code2026

 Target Server Type    : MySQL
 Target Server Version : 80406
 File Encoding         : 65001

 Date: 05/12/2025 17:11:21
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for admin
-- ----------------------------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '账号',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '密码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像',
  `role` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '角色',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '管理员信息' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of admin
-- ----------------------------
INSERT INTO `admin` VALUES (1, 'admin', 'admin', '管理员', 'http://localhost:9090/files/download/1763368770367-3.jpeg', '管理员');

-- ----------------------------
-- Table structure for carousel
-- ----------------------------
DROP TABLE IF EXISTS `carousel`;
CREATE TABLE `carousel`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `goods_id` int NULL DEFAULT NULL COMMENT '商品',
  `img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图片',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '轮播图信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of carousel
-- ----------------------------
INSERT INTO `carousel` VALUES (1, 3, 'http://localhost:9090/files/download/1763544923952-l1.png');
INSERT INTO `carousel` VALUES (2, 2, 'http://localhost:9090/files/download/1763545108768-l2.png');

-- ----------------------------
-- Table structure for cart
-- ----------------------------
DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `goods_id` int NULL DEFAULT NULL COMMENT '商品ID',
  `num` int NULL DEFAULT NULL COMMENT '数量',
  `user_id` int NULL DEFAULT NULL COMMENT '用户ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '购物车信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cart
-- ----------------------------

-- ----------------------------
-- Table structure for category
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品分类' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of category
-- ----------------------------
INSERT INTO `category` VALUES (1, '饼干');
INSERT INTO `category` VALUES (2, '果干');
INSERT INTO `category` VALUES (3, '辣条');
INSERT INTO `category` VALUES (4, '文具');
INSERT INTO `category` VALUES (5, '饮料');
INSERT INTO `category` VALUES (6, '巧克力');
INSERT INTO `category` VALUES (7, '咖啡');
INSERT INTO `category` VALUES (8, '奶茶');
INSERT INTO `category` VALUES (9, '生活用品');

-- ----------------------------
-- Table structure for collect
-- ----------------------------
DROP TABLE IF EXISTS `collect`;
CREATE TABLE `collect`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `goods_id` int NULL DEFAULT NULL COMMENT '商品ID',
  `user_id` int NULL DEFAULT NULL COMMENT '用户ID',
  `time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收藏时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户收藏' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of collect
-- ----------------------------
INSERT INTO `collect` VALUES (12, 3, 12, '2025-11-27 15:47:41');
INSERT INTO `collect` VALUES (13, 2, 12, '2025-11-27 15:47:43');
INSERT INTO `collect` VALUES (14, 7, 15, '2025-11-27 15:48:56');
INSERT INTO `collect` VALUES (15, 7, 12, '2025-11-28 16:20:45');

-- ----------------------------
-- Table structure for comment
-- ----------------------------
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `score` double(10, 1) NULL DEFAULT NULL COMMENT '评分',
  `content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '评价内容',
  `user_id` int NULL DEFAULT NULL COMMENT '评价人',
  `time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '时间',
  `order_id` int NULL DEFAULT NULL COMMENT '订单ID',
  `goods_id` int NULL DEFAULT NULL COMMENT '商品ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '订单评价' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of comment
-- ----------------------------
INSERT INTO `comment` VALUES (2, 5.0, '非常满意的一次购物', 12, '2025-12-04 16:45:32', 17, 4);
INSERT INTO `comment` VALUES (3, 3.5, '还可以', 12, '2025-12-04 16:58:13', 23, 4);
INSERT INTO `comment` VALUES (4, 4.0, '经济实惠 ok', 12, '2025-12-04 17:01:27', 12, 7);

-- ----------------------------
-- Table structure for goods
-- ----------------------------
DROP TABLE IF EXISTS `goods`;
CREATE TABLE `goods`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图片',
  `price` decimal(10, 2) NULL DEFAULT NULL COMMENT '价格',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '简介',
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '详情',
  `store` int NULL DEFAULT 0 COMMENT '库存',
  `category_id` int NULL DEFAULT NULL COMMENT '分类ID',
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '上架状态',
  `views` int NULL DEFAULT NULL COMMENT '浏览量',
  `sale_count` int NULL DEFAULT NULL COMMENT '销量',
  `time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建时间',
  `recommend` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '推荐',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of goods
-- ----------------------------
INSERT INTO `goods` VALUES (1, '旺旺 仙贝 原味 家庭装 休闲膨化食品饼干糕点小零食', 'http://localhost:9090/files/download/1763453569231-2.png', 16.80, '🌟这款零食真的超棒！口感酥脆，孩子吃得停不下来😋 📦快递包装很严实，一点都没破损✅ 🚚送货速度飞快，下单第二天就到了⚡ 👏配送员服务态度特别好，还特意提醒我收货📞 🌿原料天然，分量也足，全家都爱吃❤️️\n', '<p><img src=\"http://localhost:9090/files/download/1763453539813-2.png\" alt=\"\" data-href=\"\" style=\"width: 482.25px;height: 449.77px;\"/></p><p><img src=\"http://localhost:9090/files/download/1763453646027-image.png\" alt=\"\" data-href=\"\" style=\"width: 100%;\"/></p>', 997, 1, '上架', 0, 1, '2025-11-18 16:20:00', '否');
INSERT INTO `goods` VALUES (2, '麦酥园 沙琪玛零食面包饼干蛋糕点心无糖精休闲零食品早餐办公室', 'http://localhost:9090/files/download/1763454119340-1.png', 18.88, '这款面包绝了！松软有嚼劲，撕开还能看到细密的组织，麦香超浓郁。甜度把控得刚好，一点不腻口。早餐配牛奶、下午茶当点心都合适。独立小包装干净卫生，方便携带和储存。到手新鲜度拉满，性价比超高，全家都爱吃，已经列入回购清单！', '<p><img src=\"http://localhost:9090/files/download/1763454181850-image.png\" alt=\"\" data-href=\"\" style=\"width: 642.00px;height: 1209.25px;\"/></p>', 500, 1, '上架', 0, 0, '2025-11-18 16:23:12', '否');
INSERT INTO `goods` VALUES (3, '牛奶黑巧克力100%纯可可脂无白砂糖减脂零食 喜糖圣诞节', 'http://localhost:9090/files/download/1763454425510-3.png', 69.90, '这款72%黑巧克力真是让我爱不释手！包装小巧便携，随手一装就放进包里了。虽然看起来热量高，但它的好吃程度绝对让你忍不住多吃几颗。每一块都香浓醇厚，甜中带着微苦，特别适合喜欢浓郁口感的朋友们。特别是户外运动或者外出旅行时，来一颗既解馋又补充能量，太实用啦！价格也不错。', '<p><img src=\"http://localhost:9090/files/download/1763454476520-image.png\" alt=\"\" data-href=\"\" style=\"width: 600.00px;height: 829.30px;\"/></p>', 593, 6, '上架', 0, 9, '2025-11-18 16:28:02', '是');
INSERT INTO `goods` VALUES (4, '得力（deli）S01中性笔签字笔 0.5mm经典办公按动笔水笔 黑色', 'http://localhost:9090/files/download/1763971748290-8.png', 23.00, '办公室的常用笔，书写流畅，握着粗细也合适，还自带替换的笔芯，大品牌值得信赖！', '<p><img src=\"http://localhost:9090/files/download/1763971803791-image.png\" alt=\"\" data-href=\"\" style=\"\"/></p>', 190, 4, '上架', 0, 7, '2025-11-24 16:10:08', '否');
INSERT INTO `goods` VALUES (5, '心相印抽纸 面巾纸茶语丝享 3层150抽', 'http://localhost:9090/files/download/1763971828249-5.png', 3.00, '这款心相印抽纸品质很不错！茶语系列清香淡雅，纸张厚实柔软，擦拭皮肤感觉很舒适，没有屑。3层120抽的规格很耐用，整箱27包家庭装非常实惠。S码虽然略小，但日常使用完全足够', '<p><img src=\"http://localhost:9090/files/download/1763971865330-image.png\" alt=\"\" data-href=\"\" style=\"\"/></p>', 397, 9, '上架', 0, 1, '2025-11-24 16:11:06', '否');
INSERT INTO `goods` VALUES (6, '艾弗五F5 速溶冷萃黑咖啡 美式风味纯享装冻干咖啡粉', 'http://localhost:9090/files/download/1763971887568-4.png', 599.00, '这款咖啡胶囊香气浓郁，冲泡方便快捷，口感醇厚顺滑，包装精致耐用，配送服务贴心周到☕️🌟👍👍 配牛奶很好喝', '<p><img src=\"http://localhost:9090/files/download/1763971931350-image.png\" alt=\"\" data-href=\"\" style=\"\"/></p>', 687, 7, '上架', 0, 6, '2025-11-24 16:12:12', '是');
INSERT INTO `goods` VALUES (7, '可口可乐（Coca-Cola）汽水 碳酸饮料', 'http://localhost:9090/files/download/1763971965315-6.png', 3.00, '整箱包装严实无破损，日期新鲜，经典红白罐颜值在线。开罐气泡冒，气足不呛口，甜度刚好带淡淡焦糖香，清爽解腻超上头。配火锅、炸鸡绝配，冰镇后喝更畅爽。活动价囤货比超市划算，迷你罐不浪费，全家都爱喝', '<p><img src=\"http://localhost:9090/files/download/1763972014440-image.png\" alt=\"\" data-href=\"\" style=\"\"/></p>', 982, 5, '上架', 0, 11, '2025-11-24 16:13:35', '是');
INSERT INTO `goods` VALUES (8, '雪碧 Sprite 柠檬味 汽水 碳酸饮料', 'http://localhost:9090/files/download/1763972027614-7.png', 3.00, '汽水味超正，开瓶满是清新果香，气泡足又不冲，冰过喝超解渴，夏天囤着追剧、待客都合适，性价比很可！', '<p><img src=\"http://localhost:9090/files/download/1763972102303-image.png\" alt=\"\" data-href=\"\" style=\"\"/></p>', 493, 5, '上架', 0, 5, '2025-11-24 16:15:03', '是');

-- ----------------------------
-- Table structure for order_detail
-- ----------------------------
DROP TABLE IF EXISTS `order_detail`;
CREATE TABLE `order_detail`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `goods_id` int NULL DEFAULT NULL COMMENT '商品ID',
  `num` int NULL DEFAULT NULL COMMENT '商品数量',
  `order_id` int NULL DEFAULT NULL COMMENT '订单ID',
  `goods_img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品图片',
  `goods_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品名称',
  `goods_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '商品单价',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 29 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '订单详情' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order_detail
-- ----------------------------
INSERT INTO `order_detail` VALUES (14, 7, 1, 12, 'http://localhost:9090/files/download/1763971965315-6.png', '可口可乐（Coca-Cola）汽水 碳酸饮料', 3.00);
INSERT INTO `order_detail` VALUES (15, 1, 1, 13, 'http://localhost:9090/files/download/1763453569231-2.png', '旺旺 仙贝 原味 家庭装 休闲膨化食品饼干糕点小零食', 16.80);
INSERT INTO `order_detail` VALUES (16, 3, 1, 14, 'http://localhost:9090/files/download/1763454425510-3.png', '牛奶黑巧克力100%纯可可脂无白砂糖减脂零食 喜糖圣诞节', 69.90);
INSERT INTO `order_detail` VALUES (18, 4, 2, 16, 'http://localhost:9090/files/download/1763971748290-8.png', '得力（deli）S01中性笔签字笔 0.5mm经典办公按动笔水笔 黑色', 23.00);
INSERT INTO `order_detail` VALUES (19, 4, 3, 17, 'http://localhost:9090/files/download/1763971748290-8.png', '得力（deli）S01中性笔签字笔 0.5mm经典办公按动笔水笔 黑色', 23.00);
INSERT INTO `order_detail` VALUES (20, 4, 1, 19, 'http://localhost:9090/files/download/1763971748290-8.png', '得力（deli）S01中性笔签字笔 0.5mm经典办公按动笔水笔 黑色', 23.00);
INSERT INTO `order_detail` VALUES (21, 8, 1, 19, 'http://localhost:9090/files/download/1763972027614-7.png', '雪碧 Sprite 柠檬味 汽水 碳酸饮料', 3.00);
INSERT INTO `order_detail` VALUES (22, 3, 1, 19, 'http://localhost:9090/files/download/1763454425510-3.png', '牛奶黑巧克力100%纯可可脂无白砂糖减脂零食 喜糖圣诞节', 69.90);
INSERT INTO `order_detail` VALUES (29, 4, 1, 23, 'http://localhost:9090/files/download/1763971748290-8.png', '得力（deli）S01中性笔签字笔 0.5mm经典办公按动笔水笔 黑色', 23.00);
INSERT INTO `order_detail` VALUES (30, 3, 1, 24, 'http://localhost:9090/files/download/1763454425510-3.png', '牛奶黑巧克力100%纯可可脂无白砂糖减脂零食 喜糖圣诞节', 69.90);
INSERT INTO `order_detail` VALUES (31, 5, 1, 25, 'http://localhost:9090/files/download/1763971828249-5.png', '心相印抽纸 面巾纸茶语丝享 3层150抽', 3.00);

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '订单编号',
  `total` decimal(10, 2) NULL DEFAULT NULL COMMENT '总价格',
  `user_id` int NULL DEFAULT NULL COMMENT '下单人ID',
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '状态',
  `time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '下单时间',
  `deliver_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '配送类型',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收货地址',
  `deliver` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '配送信息',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '订单信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of orders
-- ----------------------------
INSERT INTO `orders` VALUES (12, '2025120317647459464469195', 3.00, 12, '已完成', '2025-12-03 15:12:26', '外送', '联系人：小张\n联系电话：13988997766\n地址：合肥市蜀山区枫叶大道110号', '配送员：小黄\n联系方式：17988997788');
INSERT INTO `orders` VALUES (13, '2025120317647471448740050', 16.80, 12, '已取消', '2025-12-03 15:32:24', '自提', NULL, NULL);
INSERT INTO `orders` VALUES (14, '2025120317647475133620615', 69.90, 12, '已取消', '2025-12-03 15:38:33', '自提', NULL, NULL);
INSERT INTO `orders` VALUES (16, '2025120317647475608899720', 46.00, 12, '待接单', '2025-12-03 15:39:20', '自提', NULL, NULL);
INSERT INTO `orders` VALUES (17, '2025120317647476046570053', 69.00, 12, '已完成', '2025-12-03 15:40:04', '自提', NULL, NULL);
INSERT INTO `orders` VALUES (19, '2025120317647480093758799', 95.90, 12, '待接单', '2025-12-03 15:46:49', NULL, NULL, NULL);
INSERT INTO `orders` VALUES (23, '2025120417648386694764667', 23.00, 12, '已完成', '2025-12-04 16:57:49', '自提', NULL, NULL);
INSERT INTO `orders` VALUES (24, '2025120517649236070926766', 69.90, 12, '待接单', '2025-12-05 16:33:27', '自提', NULL, NULL);
INSERT INTO `orders` VALUES (25, '2025120517649254353894955', 3.00, 12, '待接单', '2025-12-05 17:03:55', '自提', NULL, NULL);

-- ----------------------------
-- Table structure for recharge
-- ----------------------------
DROP TABLE IF EXISTS `recharge`;
CREATE TABLE `recharge`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `money` decimal(10, 2) NULL DEFAULT NULL COMMENT '充值金额',
  `user_id` int NULL DEFAULT NULL COMMENT '充值人',
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付方式',
  `time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '充值时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '充值记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of recharge
-- ----------------------------
INSERT INTO `recharge` VALUES (1, 100.00, 12, '微信支付', '2025-11-28 16:46:35');
INSERT INTO `recharge` VALUES (2, 33.00, 12, '支付宝', '2025-11-28 16:46:44');
INSERT INTO `recharge` VALUES (3, 199.00, 15, '支付宝', '2025-11-28 16:47:36');
INSERT INTO `recharge` VALUES (4, 1000.00, 12, '微信支付', '2025-12-02 16:29:57');
INSERT INTO `recharge` VALUES (5, 999.00, 15, '微信支付', '2025-12-02 16:45:06');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '账号',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '密码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '姓名',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像',
  `role` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '角色',
  `account` decimal(10, 2) NULL DEFAULT NULL COMMENT '账户',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '普通用户' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (12, 'aaa', '123', '小张', 'http://localhost:9090/files/download/1763368558022-2.png', '普通用户', 458.30);
INSERT INTO `user` VALUES (15, 'bbb', '123', '小王', 'http://localhost:9090/files/download/1763023093048-1.png', '普通用户', 599.00);
INSERT INTO `user` VALUES (18, 'ccc', '123', '小美2', 'http://localhost:9090/files/download/1763023084571-2.png', '普通用户', 0.00);
INSERT INTO `user` VALUES (19, 'ddd', '123', '小青1', 'http://localhost:9090/files/download/1763022626626-3.jpeg', '普通用户', 0.00);
INSERT INTO `user` VALUES (20, 'mmm', '123', 'mmm', NULL, '普通用户', 0.00);

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
--  图片占位修复
--
--  原始备份里 goods/carousel/user 的图片都指向 files/ 下的上传文件，
--  但这些文件在磁盘故障中丢失了（24 个引用只剩 2 个）。
--  为了让系统导入后界面不出现破图，这里把缺图商品指向仓库内置的
--  SVG 占位图（files/goods-{id}.svg），并把轮播图指向现存的两张真实商品图。
--  真实商品照片可以在后台「商品管理 → 编辑 → 上传图片」重新补。
-- ============================================================
UPDATE `goods` SET `img` = 'http://localhost:9090/files/download/goods-1.svg' WHERE `id` = 1;
UPDATE `goods` SET `img` = 'http://localhost:9090/files/download/goods-2.svg' WHERE `id` = 2;
UPDATE `goods` SET `img` = 'http://localhost:9090/files/download/goods-3.svg' WHERE `id` = 3;
UPDATE `goods` SET `img` = 'http://localhost:9090/files/download/goods-4.svg' WHERE `id` = 4;
UPDATE `goods` SET `img` = 'http://localhost:9090/files/download/goods-5.svg' WHERE `id` = 5;
UPDATE `goods` SET `img` = 'http://localhost:9090/files/download/goods-6.svg' WHERE `id` = 6;

UPDATE `carousel` SET `goods_id` = 7, `img` = 'http://localhost:9090/files/download/1763971965315-6.png' WHERE `id` = 1;
UPDATE `carousel` SET `goods_id` = 8, `img` = 'http://localhost:9090/files/download/1763972027614-7.png' WHERE `id` = 2;

