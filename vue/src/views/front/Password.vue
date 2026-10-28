<template>
  <div class="front-container" style="width: 40%">
    <div class="card" style="padding: 20px">
      <div style="font-size: 20px; margin-bottom: 40px; text-align: center">修改密码</div>
      <el-form ref="formRef" :model="data.user" :rules="data.rules" label-width="100px" style="padding-right: 30px">
        <el-form-item prop="password" label="原密码">
          <el-input v-model="data.user.password" autocomplete="off" show-password></el-input>
        </el-form-item>
        <el-form-item prop="newPassword" label="新密码">
          <el-input v-model="data.user.newPassword" autocomplete="off" show-password></el-input>
        </el-form-item>
        <el-form-item prop="confirmPassword" label="确认新密码">
          <el-input v-model="data.user.confirmPassword" autocomplete="off" show-password></el-input>
        </el-form-item>
        <div style="text-align: center">
          <el-button type="primary" size="large" @click="updatePassword">保 存</el-button>
        </div>
      </el-form>
    </div>
  </div>

</template>

<script setup>
import { reactive,ref } from "vue";
import request from "@/utils/request";
import {ElMessage} from "element-plus";
import router from "@/router";

const formRef = ref()
const data = reactive({
  user: JSON.parse(localStorage.getItem('system-user') || '{}'),
  rules: {
    password: [
      { required: true, message: '请输入原密码', trigger: 'blur' },
    ],
    newPassword: [
      { required: true, message: '请输入新密码', trigger: 'blur' },
    ],
    confirmPassword: [
      { required: true, message: '请确认新密码', trigger: 'blur' },
    ]
  }
})

const updatePassword = () => {
  if (data.user.newPassword !== data.user.confirmPassword) {
    ElMessage.warning('两次输入的新密码不同，请确认！')
    return
  }
  request.put('/updatePassword', data.user).then(res => {
    if (res.code === '200') {
      ElMessage.success('更新成功')
      logout()
    } else {
      ElMessage.error(res.msg)
    }
  })
}

const logout = () => {
  router.push('/login')
  localStorage.removeItem('system-user')
}
</script>