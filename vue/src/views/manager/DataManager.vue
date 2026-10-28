<template>
  <div>
    <div style="display: flex; grid-gap: 10px">
      <div class="card" style="padding: 20px; flex: 1; display: flex">
        <div style="flex: 1; font-size: 20px;">销售总额</div>
        <div style="flex: 1; font-size: 20px; font-weight: bold; color: red">￥{{ data.count.total }}</div>
      </div>
      <div class="card" style="padding: 20px; flex: 1; display: flex">
        <div style="flex: 1; font-size: 20px;">今日销售额</div>
        <div style="flex: 1; font-size: 20px; font-weight: bold; color: #ff8200">￥{{ data.count.today }}</div>
      </div>
      <div class="card" style="padding: 20px; flex: 1; display: flex">
        <div style="flex: 1; font-size: 20px;">商品总数</div>
        <div style="flex: 1; font-size: 20px; font-weight: bold; color: #00b0ef">{{ data.count.goods }}</div>
      </div>
      <div class="card" style="padding: 20px; flex: 1; display: flex">
        <div style="flex: 1; font-size: 20px;">注册用户</div>
        <div style="flex: 1; font-size: 20px; font-weight: bold; color: #9b3cfd">{{ data.count.user }}</div>
      </div>
    </div>

    <div style="margin-top: 10px; display: flex; grid-gap: 10px">
      <div id="line" style="flex: 1; padding: 20px; height: 500px" class="card"></div>
      <div id="pie" style="flex: 1; padding: 20px; height: 500px" class="card"></div>
    </div>

  </div>
</template>

<script setup>
import { reactive, onMounted } from "vue";
import request from "@/utils/request";
import * as echarts from 'echarts'

const data = reactive({
  count: {}
})

const lineOption = {
  title: {
    text: '近一周订单销售的趋势图',
    left: 'center'
  },
  tooltip: {
    trigger: 'axis'
  },
  legend: {
    left: 'left'
  },
  xAxis: {
    name: '日期',
    type: 'category',
    data: []
  },
  yAxis: {
    name: '销售额（元）',
    type: 'value'
  },
  grid: {
    top: '20%',
    bottom:'10%'
  },
  series: [
    {
      data: [],
      type: 'line',
      smooth: true,
      areaStyle: {
        opacity: 0.8, // 阴影的透明度
        color: 'rgb(185,190,255)' // 阴影的颜色和透明度
      },
      markPoint: {
        data: [
          { type: 'max', name: 'Max' },
          { type: 'min', name: 'Min' }
        ]
      },
      markLine: {
        data: [{ type: 'average', name: 'Avg' }]
      }
    },
  ]
}

const pieOption = {
  title: {
    text: '分类商品销售额统计',
    subtext: '比例图',
    left: 'center'
  },
  tooltip: {
    trigger: 'item',
    formatter: '{a} <br/>{b} : {c}元 ({d}%)'
  },
  legend: {
    top: 0,
    orient: 'vertical',
    left: 'left'
  },
  series: [
    {
      name: '销售额',
      type: 'pie',
      center: ['50%', '60%'],
      radius: '50%',
      data: [],
      label: {
        show: true,
        formatter(param) {
          return param.name + ' (' + param.percent + '%)';
        }
      },
      emphasis: {
        itemStyle: {
          shadowBlur: 10,
          shadowOffsetX: 0,
          shadowColor: 'rgba(0, 0, 0, 0.5)'
        }
      }
    }
  ]
}

request.get('/count').then(res => {
  data.count = res.data
})

// 等页面所有元素加载完成后再设置 echarts图表
onMounted(() => {
  // 折线图
  let lineDom = document.getElementById('line')
  let lineChart = echarts.init(lineDom)
  // 请求数据  初始化图表
  request.get('/selectLine').then(res => {
    lineOption.xAxis.data = res.data.date
    lineOption.series[0].data = res.data.count
    lineChart.setOption(lineOption)
  })

  // 饼图
  let pieDom = document.getElementById('pie')
  let pieChart = echarts.init(pieDom)
  // 请求数据  初始化图表
  request.get('/selectPie').then(res => {
    pieOption.series[0].data = res.data
    pieChart.setOption(pieOption)
  })
})
</script>