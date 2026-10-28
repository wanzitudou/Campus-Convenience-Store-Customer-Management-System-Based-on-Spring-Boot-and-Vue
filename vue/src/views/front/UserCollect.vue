<template>
  <div class="front-container">
    <div style="font-size: 20px; font-weight: bold; margin-bottom: 20px">我收藏的商品（{{ data.total }}）</div>
    <el-row :gutter="20">
      <el-col :span="6" v-for="item in data.tableData" :key="item.id">
        <div @click="router.push('/front/goodsDetail?id=' + item.goodsId)" class="card"
             style="cursor: pointer; width: 100%; padding: 0; border-radius: 5px; margin-bottom: 20px">
          <img :src="item.goodsImg" alt="" style="width: 100%; height: 260px; border-radius: 5px 5px 0 0">
          <div style="padding: 5px">
            <div class="line1" style="font-size: 18px; margin-bottom: 10px">{{ item.goodsName }}</div>
            <div style="display: flex; align-items: center">
              <div style="flex: 1; color: red">￥<b style="font-size: 20px">{{ item.goodsPrice }}</b></div>
              <el-button type="danger" @click.stop="cancel(item.id)">取消收藏</el-button>
            </div>
          </div>
        </div>
      </el-col>
    </el-row>

    <div v-if="data.total > 0">
      <el-pagination style="background-color: white; width: fit-content; padding: 5px 10px; border-radius: 5px" @current-change="load" layout="total, prev, pager, next" v-model:page-size="data.pageSize" v-model:current-page="data.pageNum" :total="data.total"/>
    </div>
  </div>
</template>

<script setup>
import {reactive} from "vue";
import request from "@/utils/request";
import router from "@/router";
import {ElMessage} from "element-plus";

const data = reactive({
  user: JSON.parse(localStorage.getItem('system-user') || '{}'),
  pageNum: 1,
  pageSize: 10,
  total: 0,
  tableData: [],
})

// 分页查询
const load = () => {
  request.get('/collect/selectPage', {
    params: {
      pageNum: data.pageNum,
      pageSize: data.pageSize,
      userId: data.user.id
    }
  }).then(res => {
    data.tableData = res.data?.list
    data.total = res.data?.total
  })
}
load()

// 取消收藏
const cancel = (collectId) => {
  request.delete('/collect/delete/' + collectId).then(res => {
    if (res.code === '200') {
      ElMessage.success('操作成功')
      load()
    } else {
      ElMessage.error(res.msg)
    }
  })
}
</script>