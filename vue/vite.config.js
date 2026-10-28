import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
// 导入对应包

import AutoImport from 'unplugin-auto-import/vite'
import Components from 'unplugin-vue-components/vite'
import { ElementPlusResolver } from 'unplugin-vue-components/resolvers'

import ElementPlus from 'unplugin-element-plus/vite'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    AutoImport({
      resolvers: [ElementPlusResolver(
          { importStyle: 'sass' }
      )],
    }),
    Components({
      resolvers: [ElementPlusResolver(
          { importStyle: 'sass' }
      )],
    }),

    // 按需定制主题配置
    ElementPlus({
      useSource: true,
    }),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  server: {
    // 监听 IPv4 + IPv6，localhost 和 127.0.0.1 都能打开
    host: true,
    port: 5173,
    watch: {
      /*
       * 重要：不在被监视目录里监听临时文件。
       *
       * 某些编辑器 / 文件同步工具保存文件时，会先在同目录创建形如
       *   .Login.vue.5808.xxxxxxxx.tmpdir/Login.vue.tmp
       * 的临时文件再重命名。chokidar 在 Windows 上尝试 watch 这些临时文件时会抛
       *   EBUSY: resource busy or locked  (errno -4082)
       * 而 chokidar 的 error 事件没有监听者时，会直接让整个 vite 进程退出，
       * 表现为"页面突然打不开 / 点了登录没反应"。
       */
      ignored: [
        '**/.git/**',
        '**/node_modules/**',
        '**/*.tmpdir/**',
        '**/.*.tmp',
        '**/*.swp',
      ],
      // 等文件写完再触发 HMR，避免读到写了一半的内容
      awaitWriteFinish: {
        stabilityThreshold: 300,
        pollInterval: 100,
      },
    },
  },
  css: {
    preprocessorOptions: {
      scss: {
        // 自动导入定制化样式文件进行样式覆盖
        additionalData: `
          @use "@/assets/css/index.scss" as *;
        `,
      }
    }
  }
})
