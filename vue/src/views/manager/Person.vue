<template>
  <div>
    <div class="card" style="width: 40%">

      <el-form ref="formRef" :model="data.user" :rules="data.rules" label-width="80px" style="padding-right: 30px">
        <el-form-item prop="avatar" label="头像">
          <el-upload
              class="avatar-uploader"
              :action="baseUrl + '/files/upload'"
              :show-file-list="false"
              :on-success="handleFileUpload"
          >
            <img v-if="data.user.avatar" :src="data.user.avatar" class="avatar" />
            <el-icon v-else class="avatar-uploader-icon"><Plus /></el-icon>
          </el-upload>
        </el-form-item>
        <el-form-item prop="username" label="账号">
          <el-input :disabled="data.user.id !== undefined" v-model="data.user.username" placeholder="请输入账号" autocomplete="off"></el-input>
        </el-form-item>
        <el-form-item prop="name" label="姓名">
          <el-input v-model="data.user.name" placeholder="请输入姓名" autocomplete="off"></el-input>
        </el-form-item>
        <div style="text-align: center">
          <el-button type="primary" size="large" @click="update">保 存</el-button>
        </div>

      </el-form>
    </div>
  </div>
</template>

<script setup>
import { reactive,ref } from "vue";
import request from "@/utils/request";
import {ElMessage} from "element-plus";

const emit = defineEmits(['updateUser'])

const baseUrl = import.meta.env.VITE_BASE_URL
const formRef = ref()
const data = reactive({
  user: JSON.parse(localStorage.getItem('system-user') || '{}'),
  rules: {
    username: [
      { required: true, message: '请输入账号', trigger: 'blur' },
    ]
  }
})

const loadUser = () => {
  request.get('/admin/selectById/' + data.user.id).then(res => {
    data.user = res.data
    // 存储最新的用户信息
    localStorage.setItem('system-user', JSON.stringify(res.data))
    emit('updateUser')
  })
}
loadUser()

const handleFileUpload = (res) => {
  data.user.avatar = res.data
}

const update = () => {
  request.put('/admin/update', data.user).then(res => {
    if (res.code === '200') {
      ElMessage.success('更新成功')
      loadUser()
    } else {
      ElMessage.error(res.msg)
    }
  })
}

</script>

<style scoped>
.avatar-uploader .avatar {
  width: 130px;
  height: 130px;
  display: block;
}
</style>

<style>
.avatar-uploader .el-upload {
  border: 1px dashed var(--el-border-color);
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  transition: var(--el-transition-duration-fast);
}

.avatar-uploader .el-upload:hover {
  border-color: var(--el-color-primary);
}

.el-icon.avatar-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 130px;
  height: 130px;
  text-align: center;
}
</style>