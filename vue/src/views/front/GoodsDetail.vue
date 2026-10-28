<template>
  <div class="front-container" style="width: 50%">
    <div class="card" style="padding: 20px; display: flex; grid-gap: 20px; margin-bottom: 10px">
      <img :src="data.goods.img" alt="" style="width: 300px; height: 300px">
      <div style="flex: 1">
        <div style="display: flex; align-items: flex-start; grid-gap: 20px; margin-bottom: 10px">
          <div style="font-size: 22px; font-weight: bold; line-height: 25px; flex: 1">
            <el-tag style="margin-right: 5px; float: left; background-color: red; color: white" type="danger" v-if="data.goods.recommend === '是'">推荐</el-tag>
            {{ data.goods.name }}
          </div>
          <div style="width: 60px; cursor: pointer; color: #666" @click="addCollect" v-if="!data.userCollect?.id">
            <el-icon style="position: relative; top: 3px" size="18"><Star /></el-icon>收藏
          </div>
          <div style="width: 100px; cursor: pointer; color: orange" @click="removeCollect" v-if="data.userCollect?.id">
            <el-icon style="position: relative; top: 3px" size="18"><StarFilled /></el-icon>取消收藏
          </div>
        </div>
        <div style="margin-bottom: 20px">
          <span style="color: red; font-size: 18px">￥</span><b style="color: red; font-size: 30px">{{ data.goods.price }}</b>
          <span style="color: #666; margin-left: 20px">累计销量 {{ data.goods.saleCount }}</span>
          <span style="color: #666; margin-left: 20px">剩余库存 {{ data.goods.store }}</span>
        </div>
        <div style="margin-bottom: 20px; padding: 10px; border-radius: 5px; background-color: #e8e4e4; line-height: 25px; text-align: justify">{{ data.goods.description }}</div>
        <div>
          <el-input-number style="width: 150px; height: 40px" :min="1" v-model="data.num"></el-input-number>
          <el-button @click="addCart" style="height: 40px; margin-left: 5px" type="danger">加入购物车</el-button>
          <el-button @click="handleAddOrder" style="height: 40px; margin-left: 5px" type="danger">立即购买</el-button>
        </div>
        <div style="margin-top: 10px; color: #666">校园小卖部销售并发货的商品，由小卖部提供发票和相应的售后服务。请您放心购买！</div>
      </div>
    </div>

    <div class="card" style="padding: 20px; margin-bottom: 50px">
      <div style="font-size: 20px; padding-bottom: 10px; border-bottom: 1px solid #ddd">
        <span @click="changeTab('商品详情')" style="cursor: pointer" :class="{'current-active': data.current === '商品详情' }">商品详情</span>
        <span @click="changeTab('商品评价')" :class="{'current-active': data.current === '商品评价' }" style="cursor: pointer; margin-left: 20px">商品评价</span>
      </div>
      <div v-if="data.current === '商品详情'" style="padding: 10px" v-html="data.goods.content"></div>
      <div v-if="data.current === '商品评价'" style="min-height: 700px">
        <div v-if="data.commentList.length === 0" style="padding: 50px; text-align: center; color: #666">暂无评价...</div>
        <div v-if="data.commentList.length > 0" style="padding: 20px;">
<!--          显示评论列表-->
          <div v-for="(item, index) in data.commentList" :key="item.id" style="display: flex; grid-gap: 10px; padding: 10px 0;
            border-bottom: 1px solid #ddd" :style="{ 'borderWidth': index === data.commentList.length - 1 ? 0 : '1px' }">
            <img :src="item.userAvatar" alt="" style="width: 50px; height: 50px; border-radius: 50%">
            <div style="flex: 1">
              <div><span>{{ item.userName }}</span>
                <span style="color: #666; font-size: 13px; margin-left: 10px">{{ item.time }}</span>
              </div>
              <div style="margin-bottom: 5px"> <el-rate v-model="item.score" show-score allow-half disabled></el-rate></div>
              <div>{{ item.content }}</div>
            </div>
          </div>
          <div style="margin-top: 20px">
            <el-pagination @current-change="loadComment" layout="total, prev, pager, next" v-model:page-size="data.pageSize" v-model:current-page="data.pageNum" :total="data.total"/>
          </div>
        </div>
      </div>

    </div>

    <el-dialog title="下单信息" width="30%" v-model="data.formVisible" :close-on-click-modal="false" destroy-on-close>
      <el-form ref="formRef" :model="data.form" :rules="data.rules" label-width="100px" style="padding-right: 30px">
        <el-form-item label="配送类型" prop="deliverType">
          <el-radio-group v-model="data.form.deliverType">
            <el-radio-button value="自提" label="自提"></el-radio-button>
            <el-radio-button value="外送" label="外送"></el-radio-button>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="收货地址" prop="address" v-if="data.form.deliverType === '外送'">
          <el-input v-model="data.form.address" type="textarea" :rows="3" placeholder="请输入外送的接收地址，包括联系人、联系电话、地址信息"></el-input>
        </el-form-item>
      </el-form>
      <template #footer>
      <span class="dialog-footer">
        <el-button @click="data.formVisible = false">取 消</el-button>
        <el-button type="primary" @click="addOrder">确 认</el-button>
      </span>
      </template>
    </el-dialog>

  </div>
</template>

<script setup>
import { reactive, ref } from "vue";
import router from "@/router";
import request from "@/utils/request";
import {ElMessage} from "element-plus";

const formRef = ref()
const data = reactive({
  user: JSON.parse(localStorage.getItem('system-user') || '{}'),
  id: router.currentRoute.value.query.id,
  goods: {},
  num: 1,
  current: '商品详情',
  commentList: [],
  pageNum: 1,
  pageSize: 5,
  total: 0,
  userCollect: {},
  form: {},
  formVisible: false,
  rules: {
    deliverType: [
      { required: true, message: '请选择配送类型', trigger: 'change' }
    ],
    address: [
      { required: true, message: '请输入配送地址', trigger: 'blur' }
    ]
  }
})

const loadComment = () => {
  request.get('/comment/selectPage', {
    params: {
      pageNum: data.pageNum,
      pageSize: data.pageSize,
      goodsId: data.id
    }
  }).then(res => {
    data.commentList = res.data?.list
    data.total = res.data?.total
  })
}
loadComment()

const handleAddOrder = () => {
  data.form = {}
  data.formVisible = true
}

const addOrder = () => {
  formRef.value.validate(valid => {
    if (valid) {
      data.form.userId = data.user.id
      data.form.cartList = [ {goodsId: data.id, num: data.num } ]
      request.post('/orders/add', data.form).then(res => {
        if (res.code === '200') {
          ElMessage.success('下单成功')
          load()
          data.formVisible = false
        } else {
          ElMessage.error(res.msg)
        }
      })
    }
  })
}

const addCart = () => {
  request.post('/cart/add', { goodsId: data.id, num: data.num, userId: data.user.id }).then(res => {
    if (res.code === '200') {
      ElMessage.success('加入购物车成功')
    } else {
      ElMessage.error(res.msg)
    }
  })
}

// 当前的商品是否被当前登录的用户收藏过
const loadCollect = () => {
  request.get('/collect/selectAll', {
    params:{
      goodsId: data.id,
      userId: data.user.id
    }
  }).then(res => {
    if (res.data?.length > 0) {  // 查询到数据了 表示用户收藏过了
      data.userCollect = res.data[0]
    } else {
      data.userCollect = {}
    }
  })
}
loadCollect()

// 取消收藏
const removeCollect = () => {
  request.delete('/collect/delete/' + data.userCollect.id).then(res => {
    if (res.code === '200') {
      ElMessage.success('操作成功')
      loadCollect()
    } else {
      ElMessage.error(res.msg)
    }
  })
}

const addCollect = () => {
  request.post('/collect/add', { goodsId: data.id, userId: data.user.id }).then(res => {
    if (res.code === '200') {
      ElMessage.success('操作成功')
      loadCollect()
    } else {
      ElMessage.error(res.msg)
    }
  })
}

const changeTab = (tabName) => {
  data.current = tabName
}

const load = () => {
  request.get('/goods/selectById/' + data.id).then(res => {
    data.goods = res.data
  })
}
load()
</script>

<style>
.current-active {
  color: red;
  border-bottom: 2px solid red;
  padding-bottom: 10px
}
</style>