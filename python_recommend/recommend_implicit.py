"""
recommend_implicit.py —— 从 MySQL 真实业务数据训练商品推荐模型

数据来源（全部是系统里真实产生的行为，不是假数据）：
    1. 购买   orders ⨝ order_detail        权重 3.0  × 购买件数（封顶 5 件）
    2. 收藏   collect                       权重 2.0
    3. 评价   comment                       权重 1.5
    4. 加购   cart                          权重 1.0

算法：
    首选  implicit.als.AlternatingLeastSquares（隐式反馈 ALS 协同过滤）
    兜底  纯 numpy 实现的 Item-CF（余弦相似度），保证没装 implicit 也能跑出结果

产物：
    artifacts/recommender.joblib   （模型 + 映射表 + 热门榜单，打包成一个文件）
    artifacts/train_report.json    （训练报告，便于写文档/答辩时引用数据）

用法：
    python recommend_implicit.py
    python recommend_implicit.py --host localhost --user root --password 123456 --db code2026
    python recommend_implicit.py --min-user-interactions 1 --factors 32 --iterations 20
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import time
from collections import defaultdict

import numpy as np

# ----------------------------------------------------------------------------
# 权重配置：隐式反馈没有"评分"，用行为强度来近似"置信度"
# ----------------------------------------------------------------------------
W_BUY = 3.0          # 下单（真实交易，信号最强）
W_BUY_UNIT_CAP = 5   # 一次买 10 件不应给 10 倍权重，做个封顶
W_COLLECT = 2.0      # 收藏（明确的偏好表达）
W_COMMENT = 1.5      # 评价（已购买，额外加权）
W_CART = 1.0         # 加购物车（有意向但可能流失）

ARTIFACT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "artifacts")
MODEL_PATH = os.path.join(ARTIFACT_DIR, "recommender.joblib")
REPORT_PATH = os.path.join(ARTIFACT_DIR, "train_report.json")


# ----------------------------------------------------------------------------
# 1. 连接数据库，抽取行为
# ----------------------------------------------------------------------------
def connect(args):
    import pymysql
    return pymysql.connect(
        host=args.host, port=args.port, user=args.user,
        password=args.password, database=args.db,
        charset="utf8mb4", cursorclass=pymysql.cursors.DictCursor,
    )


def query(conn, sql, params=None):
    with conn.cursor() as cur:
        cur.execute(sql, params or ())
        return cur.fetchall()


def on_shelf_goods(conn) -> set[int]:
    """只推荐"上架"状态的商品，下架/删除的不进入候选集"""
    rows = query(conn, "SELECT id FROM goods WHERE status = '上架'")
    return {int(r["id"]) for r in rows}


def fetch_interactions(conn) -> tuple[dict, dict]:
    """返回 interactions[(user_id, goods_id)] = weight，以及各行为原始条数统计"""
    interactions: dict[tuple[int, int], float] = defaultdict(float)
    stats = {}

    # ---- 购买 ----
    rows = query(conn, """
        SELECT o.user_id AS uid, d.goods_id AS gid, SUM(d.num) AS cnt
        FROM orders o
        JOIN order_detail d ON d.order_id = o.id
        WHERE o.status <> '已取消'
        GROUP BY o.user_id, d.goods_id
    """)
    stats["purchase_rows"] = len(rows)
    for r in rows:
        cnt = min(int(r["cnt"] or 1), W_BUY_UNIT_CAP)
        interactions[(int(r["uid"]), int(r["gid"]))] += W_BUY * cnt

    # ---- 收藏 ----
    rows = query(conn, "SELECT user_id AS uid, goods_id AS gid FROM collect")
    stats["collect_rows"] = len(rows)
    for r in rows:
        interactions[(int(r["uid"]), int(r["gid"]))] += W_COLLECT

    # ---- 评价 ----
    rows = query(conn, "SELECT user_id AS uid, goods_id AS gid FROM comment")
    stats["comment_rows"] = len(rows)
    for r in rows:
        interactions[(int(r["uid"]), int(r["gid"]))] += W_COMMENT

    # ---- 加购物车 ----
    rows = query(conn, "SELECT user_id AS uid, goods_id AS gid FROM cart")
    stats["cart_rows"] = len(rows)
    for r in rows:
        interactions[(int(r["uid"]), int(r["gid"]))] += W_CART

    stats["total_pairs"] = len(interactions)
    return dict(interactions), stats


# ----------------------------------------------------------------------------
# 2. 构建 用户 × 商品 稀疏矩阵
# ----------------------------------------------------------------------------
def build_matrix(interactions: dict, keep_items: set[int]):
    """返回 (matrix, user_to_idx, item_to_idx, idx_to_item)

    matrix 用 scipy 的 CSR 稀疏矩阵（implicit 要求）；
    如果环境没装 scipy，则退化成 numpy 稠密矩阵（本项目数据量小，完全够用）。
    """
    pairs = [(u, g, w) for (u, g), w in interactions.items() if g in keep_items]
    if not pairs:
        raise SystemExit(
            "数据库里没有任何可用的用户行为数据，无法训练。\n"
            "请先在系统里下单 / 收藏 / 加购，或先导入 code2026.sql 里的演示数据。"
        )

    user_ids = sorted({u for u, _, _ in pairs})
    item_ids = sorted({g for _, g, _ in pairs})
    user_to_idx = {uid: i for i, uid in enumerate(user_ids)}
    item_to_idx = {gid: j for j, gid in enumerate(item_ids)}
    idx_to_item = {j: gid for gid, j in item_to_idx.items()}

    rows = [user_to_idx[u] for u, _, _ in pairs]
    cols = [item_to_idx[g] for _, g, _ in pairs]
    vals = [w for _, _, w in pairs]

    try:
        from scipy.sparse import csr_matrix
        matrix = csr_matrix((vals, (rows, cols)), shape=(len(user_ids), len(item_ids)), dtype=np.float32)
        matrix.sum_duplicates()
        sparse = True
    except ImportError:
        matrix = np.zeros((len(user_ids), len(item_ids)), dtype=np.float32)
        for r, c, v in zip(rows, cols, vals):
            matrix[r, c] += v
        sparse = False

    print(f"[数据] 用户数 = {len(user_ids)}，商品数 = {len(item_ids)}，行为对 = {len(pairs)}，"
          f"矩阵类型 = {'scipy.sparse.CSR' if sparse else 'numpy.dense'}")
    return matrix, user_to_idx, item_to_idx, idx_to_item


# ----------------------------------------------------------------------------
# 3a. 首选：implicit ALS
# ----------------------------------------------------------------------------
def train_als(matrix, factors: int, iterations: int, regularization: float):
    from implicit.als import AlternatingLeastSquares
    model = AlternatingLeastSquares(
        factors=factors,
        iterations=iterations,
        regularization=regularization,
        random_state=42,
        use_gpu=False,
    )
    # 注意：implicit >= 0.6 的 fit() 接收的是 用户×商品 矩阵（老版本才需要转置）
    model.fit(matrix, show_progress=True)
    return model


# ----------------------------------------------------------------------------
# 3b. 兜底：纯 numpy Item-CF（余弦相似度）
# ----------------------------------------------------------------------------
def train_itemcf(matrix):
    """不依赖 implicit 的协同过滤：商品-商品余弦相似度矩阵"""
    dense = np.asarray(matrix.todense() if hasattr(matrix, "todense") else matrix, dtype=np.float64)
    # 转成"是否交互过"的 0/1 矩阵再算相似度，避免热门商品因为买得多就压过一切
    binary = (dense > 0).astype(np.float64)
    norms = np.linalg.norm(binary, axis=0, keepdims=True)
    norms[norms == 0] = 1.0
    normalized = binary / norms
    item_sim = normalized.T @ normalized          # 商品 × 商品
    np.fill_diagonal(item_sim, 0.0)               # 自己和自己的相似度没意义
    return {"item_sim": item_sim.astype(np.float32), "user_items": dense.astype(np.float32)}


# ----------------------------------------------------------------------------
# 4. 训练入口
# ----------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="从 MySQL 真实数据训练商品推荐模型")
    parser.add_argument("--host", default=os.getenv("DB_HOST", "localhost"))
    parser.add_argument("--port", type=int, default=int(os.getenv("DB_PORT", "3306")))
    parser.add_argument("--user", default=os.getenv("DB_USERNAME", "root"))
    parser.add_argument("--password", default=os.getenv("DB_PASSWORD", "123456"))
    parser.add_argument("--db", default=os.getenv("DB_NAME", "code2026"))
    parser.add_argument("--factors", type=int, default=32, help="ALS 隐因子维度")
    parser.add_argument("--iterations", type=int, default=20, help="ALS 迭代次数")
    parser.add_argument("--regularization", type=float, default=0.05, help="ALS 正则化系数")
    parser.add_argument("--force-itemcf", action="store_true", help="强制使用 numpy Item-CF")
    args = parser.parse_args()

    t0 = time.time()
    print("[1/4] 连接 MySQL ...")
    conn = connect(args)
    try:
        keep_items = on_shelf_goods(conn)
        print(f"[1/4] 上架商品 {len(keep_items)} 个")

        print("[2/4] 抽取用户行为 ...")
        interactions, stats = fetch_interactions(conn)
        for k, v in stats.items():
            print(f"      {k}: {v}")

        matrix, user_to_idx, item_to_idx, idx_to_item = build_matrix(interactions, keep_items)

        # 热门榜单（冷启动兜底用）：直接按销量 + 浏览量算
        pop_rows = query(conn, """
            SELECT id, sale_count, views FROM goods
            WHERE status = '上架'
            ORDER BY sale_count DESC, views DESC, id ASC
        """)
        popularity = [int(r["id"]) for r in pop_rows]
        print(f"[2/4] 热门榜单 {len(popularity)} 条")
    finally:
        conn.close()

    import joblib

    print("[3/4] 开始训练 ...")
    algo = "itemcf"
    artifact = {}
    if not args.force_itemcf:
        try:
            model = train_als(matrix, args.factors, args.iterations, args.regularization)
            artifact["als_model"] = model
            algo = "als"
            print("      使用 implicit ALS 训练完成")
        except ImportError as e:
            print(f"      [跳过 ALS] 未安装 implicit（{e}），改用 numpy Item-CF")
        except MemoryError:
            print("      [跳过 ALS] 内存不足，改用 numpy Item-CF")
    if algo == "itemcf":
        artifact.update(train_itemcf(matrix))
        print("      使用 numpy Item-CF 训练完成")

    artifact.update({
        "algo": algo,
        "user_to_idx": user_to_idx,
        "item_to_idx": item_to_idx,
        "idx_to_item": idx_to_item,
        "user_items": matrix if algo == "als" else artifact["user_items"],
        "popularity": popularity,
        "meta": {
            "trained_at": time.strftime("%Y-%m-%d %H:%M:%S"),
            **stats,
            "n_users": len(user_to_idx),
            "n_items": len(item_to_idx),
            "factors": args.factors if algo == "als" else None,
            "iterations": args.iterations if algo == "als" else None,
            "elapsed_sec": round(time.time() - t0, 2),
        },
    })

    print("[4/4] 保存模型 ...")
    os.makedirs(ARTIFACT_DIR, exist_ok=True)
    joblib.dump(artifact, MODEL_PATH)
    with open(REPORT_PATH, "w", encoding="utf-8") as f:
        json.dump(artifact["meta"], f, ensure_ascii=False, indent=2)

    print(f"      模型 -> {MODEL_PATH}")
    print(f"      报告 -> {REPORT_PATH}")
    print(f"完成，算法 = {algo}，耗时 {artifact['meta']['elapsed_sec']} 秒")


if __name__ == "__main__":
    sys.exit(main())
