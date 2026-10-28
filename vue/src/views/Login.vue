<template>
  <div class="login-container">
    <!-- 左侧登录表单 -->
    <div class="login-box">
      <div style="font-weight: bold; font-size: 30px; text-align: center; margin-bottom: 30px; color: #e89e1e">欢 迎 登 录</div>
      <el-form :model="data.form" ref="formRef" :rules="data.rules">
        <el-form-item prop="username">
          <el-input :prefix-icon="User" size="large" v-model="data.form.username" placeholder="请输入账号" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input
              :prefix-icon="Lock"
              size="large"
              v-model="data.form.password"
              placeholder="请输入密码"
              show-password
              @focus="isPasswordFocused = true"
              @blur="isPasswordFocused = false"
          />
        </el-form-item>
        <el-form-item prop="role">
          <el-select size="large" style="width: 100%" v-model="data.form.role">
            <el-option value="普通用户" label="普通用户"></el-option>
            <el-option value="管理员" label="管理员"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button size="large" type="primary" style="width: 100%" @click="login">登 录</el-button>
        </el-form-item>
      </el-form>
      <div style="text-align: right;">
        还没有账号？ <a href="/register">注册</a>
      </div>
    </div>

    <!-- 右侧人物区域 -->
    <div class="character-box">
      <img
          v-if="!isPasswordFocused"
          src="/eye-open.png"
          alt="睁眼"
          class="character-img"
      >
      <img
          v-else
          src="/eye-close.png"
          alt="闭眼"
          class="character-img"
      >
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from "vue";
import { User, Lock } from "@element-plus/icons-vue";
import request from "@/utils/request";
import { ElMessage } from "element-plus";
import router from "@/router";

// 控制人物睁眼/闭眼
const isPasswordFocused = ref(false);

const data = reactive({
  dialogVisible: true,
  form: { role: '管理员' },
  rules: {
    username: [
      { required: true, message: '请输入账号', trigger: 'blur' },
    ],
    password: [
      { required: true, message: '请输入密码', trigger: 'blur' },
    ],
  }
});

const formRef = ref();

const login = () => {
  formRef.value.validate((valid => {
    if (valid) {
      // 去掉前后空格：复制粘贴或手输很容易带上，而后端密码是精确比较
      data.form.username = (data.form.username || '').trim();
      data.form.password = (data.form.password || '').trim();
      request.post('/login', data.form).then(res => {
        if (res.code === '200') {
          ElMessage.success("登录成功");
          localStorage.setItem('system-user', JSON.stringify(res.data));
          if (res.data.role === '管理员') {
            router.push('/manager/home');
          } else {
            router.push('/front/home');
          }
        } else {
          ElMessage.error(res.msg);
        }
      }).catch(error => {
        // 请求本身失败（后端没启动 / 端口不通 / 跨域被拦）时，
        // 原来这里什么都不提示，页面既没跳转也没报错，看起来就是"登录不进去"。
        console.error('登录请求失败：', error);
        ElMessage.error('无法连接后端服务，请确认后端已启动（http://localhost:9090）');
      });
    }
  })).catch(error => {
    console.error(error);
  });
};
</script>

<style scoped>
.login-container {
  height: 100vh;
  overflow: hidden;
  display: flex;
  justify-content: center;     /* 改为居中，让整体居中 */
  align-items: center;
  background: #2e3143;
  padding: 0;                  /* 去掉左右内边距 */
  box-sizing: border-box;
}

.login-box {
  width: 380px;
  padding: 50px 30px;
  border-radius: 5px;
  box-shadow: 0 0 10px rgba(255, 255, 255, 0.3);
  background-color: #fff;
  /* 移除 margin-right */
}

.character-box {
  flex: 0 0 auto;
  max-width: 400px;
  text-align: center;
  /* 如果需要左移，可以加负 margin，但通常不用 */
}

.character-img {
  width: 100%;
  max-width: 300px;
  height: auto;
  border-radius: 10px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
}

/* 如果屏幕过窄，依然保持垂直排列 */
@media (max-width: 800px) {
  .login-container {
    flex-direction: column;
    padding: 20px;
  }
  .login-box {
    margin-bottom: 20px;
  }
}
.login-container {
  background: url('/blackground.png') no-repeat center center fixed;
  background-size: cover;
}
</style>