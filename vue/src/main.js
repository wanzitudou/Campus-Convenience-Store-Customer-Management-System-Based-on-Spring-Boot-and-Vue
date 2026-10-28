import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import ElementPlus from 'element-plus'
import zhCn from 'element-plus/dist/locale/zh-cn.mjs'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import AiChat from './components/AiChat.vue'
import '@/assets/css/global.css'   // 只保留一个导入即可

const app = createApp(App)

// 先注册插件和组件
app.use(router)
app.use(ElementPlus, { locale: zhCn })

// 注册所有 Element Plus 图标
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
    app.component(key, component)
}

// 全局注册 AiChat 组件
app.component('AiChat', AiChat)

// 最后挂载应用（只调用一次）
app.mount('#app')