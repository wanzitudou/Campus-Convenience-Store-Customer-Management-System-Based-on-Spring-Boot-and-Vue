import {createRouter, createWebHistory} from 'vue-router'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { path: '/', redirect: '/login' },
    {
      path: '/manager',
      component: () => import('@/views/Manager.vue'),
      redirect: '/manager/home',
      children: [
        { path: 'home', component: () => import('@/views/manager/Home.vue')},
        { path: 'admin', component: () => import('@/views/manager/Admin.vue')},
        { path: 'user', component: () => import('@/views/manager/User.vue')},
        { path: 'person', component: () => import('@/views/manager/Person.vue')},
        { path: 'password', component: () => import('@/views/manager/Password.vue')},
        { path: 'category', component: () => import('@/views/manager/Category.vue')},
        { path: 'goods', component: () => import('@/views/manager/Goods.vue')},
        { path: 'carousel', component: () => import('@/views/manager/Carousel.vue')},
        { path: 'collect', component: () => import('@/views/manager/Collect.vue')},
        { path: 'recharge', component: () => import('@/views/manager/Recharge.vue')},
        { path: 'orders', component: () => import('@/views/manager/Orders.vue')},
        { path: 'comment', component: () => import('@/views/manager/Comment.vue')},
        { path: 'dataManager', component: () => import('@/views/manager/DataManager.vue')},
      ]
    },
    {
      path: '/front',
      component: () => import('@/views/Front.vue'),
      redirect: '/front/home',
      children: [
        { path: 'home', component: () => import('@/views/front/Home.vue')},
        { path: 'person', component: () => import('@/views/front/Person.vue')},
        { path: 'password', component: () => import('@/views/front/Password.vue')},
        { path: 'goods', component: () => import('@/views/front/Goods.vue')},
        { path: 'goodsDetail', component: () => import('@/views/front/GoodsDetail.vue')},
        { path: 'userCollect', component: () => import('@/views/front/UserCollect.vue')},
        { path: 'userRecharge', component: () => import('@/views/front/UserRecharge.vue')},
        { path: 'cart', component: () => import('@/views/front/Cart.vue')},
        { path: 'userOrders', component: () => import('@/views/front/UserOrders.vue')},
        { path: 'userComment', component: () => import('@/views/front/UserComment.vue')},
      ]
    },
    { path: '/login', component: () => import('@/views/Login.vue') },
    { path: '/register', component: () => import('@/views/Register.vue') }
  ]
})

router.beforeEach(() => {
  window.scroll({ top: 0, behavior: "smooth" })
})

export default router
