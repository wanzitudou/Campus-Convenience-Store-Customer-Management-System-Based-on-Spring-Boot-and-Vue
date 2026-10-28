"""
api_implicit.py —— 商品推荐服务（FastAPI）

启动：
    uvicorn api_implicit:app --host 0.0.0.0 --port 8000

接口：
    POST /recommend   {"user_id": 12, "top_n": 4}  ->  {"recommended_item_ids": [3, 6, 7, 8], ...}
    GET  /health                                   ->  健康检查（含模型元信息）
    GET  /stats                                    ->  训练报告

设计要点：
    * 冷启动：用户没有行为记录 -> 返回热门榜单，而不是报错
    * 已交互过滤：默认不再推荐用户买过/收藏过的商品（filter_already_liked_items）
    * 降级：模型文件缺失时服务仍能 /health 响应，/recommend 返回 503，
            让 Java 端切到"热销商品"兜底
"""

from __future__ import annotations

import os
from typing import List

import numpy as np
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

MODEL_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "artifacts", "recommender.joblib")

app = FastAPI(title="校园小卖部推荐服务", version="2.0.0")

artifact = None
load_error: str | None = None


@app.on_event("startup")
def load_model():
    global artifact, load_error
    try:
        import joblib
        artifact = joblib.load(MODEL_PATH)
        meta = artifact["meta"]
        print(f"[启动] 模型加载成功：算法={artifact['algo']}, "
              f"用户={meta['n_users']}, 商品={meta['n_items']}, 训练于 {meta['trained_at']}")
    except Exception as e:  # 模型没训练 / 文件损坏，都走降级
        load_error = str(e)
        artifact = None
        print(f"[启动] 模型加载失败，服务降级：{e}")


class RecommendRequest(BaseModel):
    user_id: int
    top_n: int = 4


class RecommendResponse(BaseModel):
    user_id: int
    top_n: int
    source: str                    # als / itemcf / popular / cold_start
    recommended_item_ids: List[int]


# ----------------------------------------------------------------------------
# 核心推荐逻辑
# ----------------------------------------------------------------------------
def popular_ids(top_n: int) -> List[int]:
    """冷启动：热门榜单"""
    pop = artifact["popularity"] if artifact else []
    return pop[:top_n]


def recommend_als(user_idx: int, top_n: int) -> List[int]:
    model = artifact["als_model"]
    matrix = artifact["user_items"]
    # filter_already_liked_items=True：排除用户已经买过/收藏过的商品
    ids, _scores = model.recommend(
        user_idx, matrix[user_idx], N=top_n, filter_already_liked_items=True
    )
    idx_to_item = artifact["idx_to_item"]
    return [idx_to_item[int(i)] for i in ids]


def recommend_itemcf(user_idx: int, top_n: int) -> List[int]:
    """Item-CF：用户向量 × 商品相似度矩阵，取 TopN"""
    item_sim = artifact["item_sim"]
    user_items = artifact["user_items"]
    scores = np.asarray(user_items[user_idx]).reshape(-1) @ item_sim
    # 过滤掉已经交互过的商品
    seen = np.where(np.asarray(user_items[user_idx]).reshape(-1) > 0)[0]
    scores[seen] = -np.inf
    order = np.argsort(-scores)
    idx_to_item = artifact["idx_to_item"]
    out = []
    for i in order:
        if not np.isfinite(scores[i]) or scores[i] <= 0:
            break
        out.append(idx_to_item[int(i)])
        if len(out) >= top_n:
            break
    return out


def recommend(user_id: int, top_n: int) -> tuple[List[int], str]:
    user_to_idx = artifact["user_to_idx"]

    # 冷启动：这个用户从来没产生过行为
    if user_id not in user_to_idx:
        return popular_ids(top_n), "cold_start"

    user_idx = user_to_idx[user_id]
    if artifact["algo"] == "als":
        return recommend_als(user_idx, top_n), "als"
    return recommend_itemcf(user_idx, top_n), "itemcf"


# ----------------------------------------------------------------------------
# 接口
# ----------------------------------------------------------------------------
@app.post("/recommend", response_model=RecommendResponse)
def get_recommendations(request: RecommendRequest):
    if artifact is None:
        raise HTTPException(
            status_code=503,
            detail=f"推荐模型未就绪，请先运行 recommend_implicit.py 训练（原因：{load_error}）",
        )

    top_n = max(1, min(request.top_n, 50))  # 防呆，避免前端传个 99999
    ids, source = recommend(request.user_id, top_n)

    # 推荐结果不足（用户把东西都买完了），用热门榜单补齐
    if len(ids) < top_n:
        for gid in popular_ids(50):
            if gid not in ids:
                ids.append(gid)
            if len(ids) >= top_n:
                break

    return RecommendResponse(
        user_id=request.user_id,
        top_n=top_n,
        source=source,
        recommended_item_ids=ids[:top_n],
    )


@app.get("/health")
def health():
    if artifact is None:
        return {"status": "degraded", "model_loaded": False, "error": load_error}
    return {"status": "ok", "model_loaded": True, "algo": artifact["algo"], "meta": artifact["meta"]}


@app.get("/stats")
def stats():
    if artifact is None:
        raise HTTPException(status_code=503, detail="模型未加载")
    return artifact["meta"]


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
