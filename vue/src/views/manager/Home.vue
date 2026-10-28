<template>
  <div>

    <div class="card" style="line-height: 30px; margin-bottom: 10px">
      <div style="margin-bottom: 20px; font-size: 24px">校园小卖部管理系统</div>
      <div>欢迎进入</div>
      <div><b>技术栈：SpringBoot3 + Vue3 + MySQL，前后端分离</b></div>
    </div>



  </div>
</template>

<script setup>
import { reactive } from "vue";
import request from "@/utils/request";

const data = reactive({
  user: JSON.parse(localStorage.getItem('system-user') || '{}'),
})
</script>