<template>
  <div class="front-container">
    <!--  第一行开始 -->
    <div style="display: flex; grid-gap: 20px; margin-bottom: 10px">
      <div style="flex: 1">
        <el-carousel height="450px">
          <el-carousel-item v-for="item in data.carouselList" :key="item.id">
            <img @click="router.push('/front/goodsDetail?id=' + item.goodsId)" :src="item.img" alt="" style="width: 100%; height: 450px; cursor: pointer">
          </el-carousel-item>
        </el-carousel>
      </div>
      <div class="card" style="width: 260px">
        <div style="display: flex; align-items: center; padding-bottom: 5px; border-bottom: 1px solid red">
          <img src="@/assets/imgs/love.png" alt="" style="width: 25px">
          <div style="color: red; font-weight: bold; font-size: 20px; margin-left: 2px">为您推荐</div>
        </div>
        <div style="padding: 20px 0">
          <div class="top-item" @click="router.push('/front/goodsDetail?id=' + item.id)" style="cursor: pointer; display: flex; grid-gap: 10px; margin-bottom: 20px" v-for="item in data.recommendGoods" :key="item.id">
            <img style="width: 65px; height: 65px" :src="item.img" alt="">
            <div>
              <div class="line2" style="margin-bottom: 5px">{{ item.name }}</div>
              <div style="color: red"><span>￥</span><b>{{ item.price }}</b></div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <!--  第一行结束 -->

    <div class="card" style="padding: 20px;">
      <!--  第二行开始 -->
      <div style="display: flex; align-items: flex-end; padding-bottom: 5px; border-bottom: 1px solid red; margin-bottom: 10px">
        <div style="flex: 1; display: flex; align-items: center">
          <div style="color: red; font-weight: bold; font-size: 20px; margin-left: 2px">热销商品</div>
        </div>
        <div @click="router.push('/front/goods')" style="cursor: pointer; font-size: 13px">查看更多</div>
      </div>
      <div style="margin-bottom: 40px">
        <el-row :gutter="20">
          <el-col :span="6" v-for="item in data.hotGoods" :key="item.id">
            <div @click="router.push('/front/goodsDetail?id=' + item.id)" class="item" style="width: 100%; border-radius: 5px; height: 350px">
              <img :src="item.img" alt="" style="width: 100%; height: 260px; border-radius: 5px 5px 0 0">
              <div style="padding: 5px">
                <div class="line1" style="font-size: 16px;">{{ item.name }}</div>
                <div>
                  <span style="color: red">￥</span><b style="color: red; font-size: 20px">{{ item.price }}</b>
                  <span style="margin-left: 10px; color: #666">销量：{{ item.saleCount }}</span>
                </div>
              </div>
            </div>
          </el-col>
        </el-row>
      </div>
      <!--  第二行结束 -->

      <!--  第三行开始 -->
      <div style="display: flex; align-items: flex-end; padding-bottom: 5px; border-bottom: 1px solid red; margin-bottom: 10px">
        <div style="flex: 1; display: flex; align-items: center">
          <img src="@/assets/imgs/new.png" alt="" style="width: 25px">
          <div style="color: red; font-weight: bold; font-size: 20px; margin-left: 2px">最新上架</div>
        </div>
        <div @click="router.push('/front/goods')" style="cursor: pointer; font-size: 13px">查看更多</div>
      </div>
      <div>
        <el-row :gutter="20">
          <el-col :span="6" v-for="item in data.newGoods" :key="item.id">
            <div @click="router.push('/front/goodsDetail?id=' + item.id)" class="item" style="width: 100%; border-radius: 5px; height: 350px">
              <img :src="item.img" alt="" style="width: 100%; height: 260px; border-radius: 5px 5px 0 0">
              <div style="padding: 5px">
                <div class="line1" style="font-size: 16px">{{ item.name }}</div>
                <div>
                  <span style="color: red">￥</span><b style="color: red; font-size: 20px">{{ item.price }}</b>
                  <span style="margin-left: 10px; color: #666">销量：{{ item.saleCount }}</span>
                </div>
              </div>
            </div>
          </el-col>
        </el-row>
      </div>
    </div>
    <!--  第三行结束 -->

    <!-- 底部-根据销量来做智能推荐 -->

    <!-- 为你推荐 -->
    <div class="card" style="margin-top: 30px; padding: 20px;">
      <div style="display: flex; align-items: flex-end; padding-bottom: 5px; border-bottom: 1px solid red; margin-bottom: 10px">
        <div style="flex: 1; display: flex; align-items: center">
          <img src="@/assets/imgs/love.png" alt="" style="width: 25px">
          <div style="color: blue; font-weight: bold; font-size: 20px; margin-left: 2px">智能推荐</div>
        </div>
        <div @click="router.push('/front/goods')" style="cursor: pointer; font-size: 13px">更多</div>
      </div>
      <el-row :gutter="20">
        <el-col :span="6" v-for="item in recommendList" :key="item.id">
          <el-card :body-style="{ padding: '0px' }" @click="router.push('/front/goodsDetail?id=' + item.id)" style="cursor: pointer;">
            <el-image :src="item.img" style="height: 200px; width: 100%; object-fit: cover;" />
            <div style="padding: 14px;">
              <div style="font-size: 16px; font-weight: bold; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">{{ item.name }}</div>
              <div style="color: #f56c6c; font-weight: bold; margin-top: 8px;">¥{{ item.price }}</div>
              <div style="font-size: 12px; color: #999; margin-top: 5px;">
                <span>🔥🔥🔥销量 {{ item.saleCount || 0 }}</span>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <AiChat />

  </div>
</template>

<script setup>
import { reactive, ref } from "vue";
import request from "@/utils/request";
import router from "@/router";
import { getRecommend } from '@/api/recommend'

const data = reactive({
  carouselList: [],
  hotGoods: [],
  newGoods: [],
  recommendGoods: [],
})

request.get('/carousel/selectAll').then(res => {
  data.carouselList = res.data
})

request.get('/goods/selectAll', {
  params: {
    status: '上架'
  }
}).then(res => {
  data.hotGoods = res.data.sort((v1, v2) => v2.saleCount - v1.saleCount).splice(0, 4)
})

request.get('/goods/selectAll', {
  params: {
    status: '上架'
  }
}).then(res => {
  data.newGoods = res.data.splice(0, 4)
})

request.get('/goods/selectAll', {
  params: {
    status: '上架'
  }
}).then(res => {
  data.recommendGoods = res.data.filter(v => v.recommend === '是').splice(0, 5)
})

// 推荐商品列表
const recommendList = ref([])
// 当前登录用户（从本地存储取，避免写死 userId 导致所有用户推荐结果一样）
const currentUser = JSON.parse(localStorage.getItem('system-user') || '{}')

// 加载推荐商品
const loadRecommend = async () => {
  try {
    // 用户没登录时传 0，后端推荐服务会走冷启动（热门榜单）
    const res = await getRecommend(currentUser.id || 0)
    console.log('推荐数据:', res)
    recommendList.value = Array.isArray(res) ? res : res.data || []
  } catch (error) {
    console.error('加载推荐失败', error)
  }
}

// 调用加载函数
loadRecommend()
</script>

<style>
.item {
  cursor: pointer;
}
.item:hover {
  border: 1px solid red
}
.top-item:hover {
  color: red;
}
</style>