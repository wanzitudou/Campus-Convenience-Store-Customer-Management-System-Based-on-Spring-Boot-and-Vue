import request from '@/utils/request'

export function getRecommend(userId) {
    return request({
        url: '/web/recommend',
        method: 'get',
        params: { userId }
    })
}