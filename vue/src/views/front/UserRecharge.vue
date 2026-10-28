<template>
  <div class="front-container">
    <div style="font-size: 20px; font-weight: bold; margin-bottom: 20px">我的充值记录（{{ data.total }}）</div>
    <div class="card" style="padding: 20px">
      <div style="margin-bottom: 20px; display: flex; align-items: center">
        <div style="flex: 1">
          <el-date-picker style="width: 300px; margin-right: 10px" v-model="data.time" type="date" placeholder="请输入日期查询" format="YYYY-MM-DD" value-format="YYYY-MM-DD" />
          <el-button type="primary" @click="load">查询</el-button>
          <el-button type="info" style="margin: 0 10px" @click="reset">重置</el-button>
        </div>

        <b style="margin-left: 20px; color: red">当前账户余额：{{ data.user.account }}元</b>
        <el-button @click="handleAdd" type="primary" style="margin-left: 20px">发起充值</el-button>
      </div>
      <div>
        <el-table :data="data.tableData" stripe>
          <el-table-column prop="money" label="充值金额">
            <template #default="scope">
              <b style="color: red">{{ scope.row.money }}元</b>
            </template>
          </el-table-column>
          <el-table-column prop="type" label="支付方式"></el-table-column>
          <el-table-column prop="time" label="充值时间"></el-table-column>
        </el-table>
      </div>

      <div style="margin-top: 20px">
        <el-pagination @current-change="load" layout="total, prev, pager, next" v-model:page-size="data.pageSize" v-model:current-page="data.pageNum" :total="data.total"/>
      </div>
    </div>

    <el-dialog title="用户充值" width="30%" v-model="data.formVisible" :close-on-click-modal="false" destroy-on-close>
      <el-form ref="formRef" :model="data.form" :rules="data.rules" label-width="80px" style="padding-right: 30px; padding-top: 20px">
        <el-form-item label="充值金额" prop="money">
          <el-input-number style="width: 200px" :min="1" v-model="data.form.money" autocomplete="off" />
        </el-form-item>
        <el-form-item label="支付方式" prop="type" style="margin-top: 30px">
          <el-radio-group v-model="data.form.type">
            <el-radio value="微信支付"><img style="width: 100px; height: 40px" src="@/assets/imgs/wx.png" alt=""></el-radio>
            <el-radio value="支付宝"><img style="width: 100px; height: 40px" src="@/assets/imgs/zfb.png" alt=""></el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
      <span class="dialog-footer">
        <el-button @click="data.formVisible = false">取 消</el-button>
        <el-button type="primary" @click="save">保 存</el-button>
      </span>
      </template>
    </el-dialog>

  </div>
</template>

<script setup>
import request from "@/utils/request";
import {reactive, ref} from "vue";
import {ElMessageBox, ElMessage} from "element-plus";

const formRef = ref()
const data = reactive({
  user: JSON.parse(localStorage.getItem('system-user') || '{}'),
  pageNum: 1,
  pageSize: 10,
  total: 0,
  formVisible: false,
  form: {},
  tableData: [],
  time: null,
  rules: {
    money: [
      { required: true, message: '请输入金额', trigger: 'blur' }
    ],
    type: [
      { required: true, message: '请选择支付方式', trigger: 'change' }
    ]
  }
})

const loadAccount = () => {
  request.get('/user/selectById/' + data.user.id).then(res => {
    data.user.account = res.data.account
  })
}
loadAccount()

// 分页查询
const load = () => {
  request.get('/recharge/selectPage', {
    params: {
      pageNum: data.pageNum,
      pageSize: data.pageSize,
      userId: data.user.id,
      time: data.time
    }
  }).then(res => {
    data.tableData = res.data?.list
    data.total = res.data?.total
  })
}
load()

// 新增
const handleAdd = () => {
  data.form = { money: 1, type: '微信支付' }
  data.formVisible = true
}

// 编辑
const handleEdit = (row) => {
  data.form = JSON.parse(JSON.stringify(row))
  data.formVisible = true
}

// 新增保存
const add = () => {
  data.form.userId = data.user.id
  request.post('/recharge/add', data.form).then(res => {
    if (res.code === '200') {
      load()
      loadAccount()
      ElMessage.success('操作成功')
      data.formVisible = false
    } else {
      ElMessage.error(res.msg)
    }
  })
}

// 编辑保存
const update = () => {
  request.put('/recharge/update', data.form).then(res => {
    if (res.code === '200') {
      load()
      ElMessage.success('操作成功')
      data.formVisible = false
    } else {
      ElMessage.error(res.msg)
    }
  })
}

// 弹窗保存
const save = () => {
  formRef.value.validate(valid => {
    if (valid) {
      // data.form有id就是更新，没有就是新增
      data.form.id ? update() : add()
    }
  })
}

// 删除
const handleDelete = (id) => {
  ElMessageBox.confirm('删除后数据无法恢复，您确定删除吗?', '删除确认', { type: 'warning' }).then(res => {
    request.delete('/recharge/delete/' + id).then(res => {
      if (res.code === '200') {
        load()
        ElMessage.success('操作成功')
      } else {
        ElMessage.error(res.msg)
      }
    })
  }).catch(err => {})
}

// 重置
const reset = () => {
  data.userName = null
  load()
}
</script>