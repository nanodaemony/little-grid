import axios from 'axios'
import Logger from '@/utils/logger'
import router from '@/router/routers'
import { Notification } from 'element-ui'
import store from '../store'
import { getToken } from '@/utils/auth'
import Config from '@/settings'
import Cookies from 'js-cookie'

// 创建axios实例
const service = axios.create({
  baseURL: process.env.NODE_ENV === 'production' ? process.env.VUE_APP_BASE_API : '/', // api 的 base_url
  timeout: Config.timeout // 请求超时时间
})

// request拦截器
service.interceptors.request.use(
  config => {
    // 生成 TraceId
    const traceId = Logger.generateTraceId()
    config.headers['X-Trace-Id'] = traceId
    Logger.setTraceId(traceId)

    if (getToken()) {
      config.headers['Authorization'] = getToken()
    }
    config.headers['Content-Type'] = 'application/json'

    // 打印请求日志
    const method = config.method && config.method.toUpperCase() || 'GET'
    Logger.info('HTTP', method + ' ' + config.url, {
      params: config.params,
      data: config.data
    })

    return config
  },
  error => {
    Logger.error('HTTP', '请求配置失败', error)
    return Promise.reject(error)
  }
)

// response 拦截器
service.interceptors.response.use(
  response => {
    // 打印响应日志
    const url = response.config && response.config.url || ''
    Logger.info('HTTP', '响应 ' + url, {
      status: response.status,
      data: response.data
    })
    return response.data
  },
  error => {
    // 打印错误日志
    const errorUrl = error.config && error.config.url || ''
    const errorStatus = error.response && error.response.status
    const errorMsg = error.response && error.response.data && error.response.data.message || error.message
    Logger.error('HTTP', '请求失败 ' + errorUrl, {
      status: errorStatus,
      message: errorMsg
    })

    // 兼容blob下载出错json提示
    const errorData = error.response && error.response.data
    const errorDataType = errorData && errorData.type && errorData.type.toLowerCase().indexOf('json') !== -1
    if (errorData instanceof Blob && errorDataType) {
      const reader = new FileReader()
      reader.readAsText(error.response.data, 'utf-8')
      reader.onload = function(e) {
        const errorMsg = JSON.parse(reader.result).message
        Notification.error({
          title: errorMsg,
          duration: 5000
        })
      }
    } else {
      let code = 0
      try {
        code = error.response && error.response.data && error.response.data.status
      } catch (e) {
        if (error.toString().indexOf('Error: timeout') !== -1) {
          Notification.error({
            title: '网络请求超时',
            duration: 5000
          })
          return Promise.reject(error)
        }
      }
      if (code) {
        if (code === 401) {
          store.dispatch('LogOut').then(() => {
            Cookies.set('point', 401)
            location.reload()
          })
        } else if (code === 403) {
          router.push({ path: '/401' })
        } else {
          const errorMsg = error.response && error.response.data && error.response.data.message
          if (errorMsg !== undefined) {
            Notification.error({
              title: errorMsg,
              duration: 5000
            })
          }
        }
      } else {
        Notification.error({
          title: '接口请求失败',
          duration: 5000
        })
      }
    }
    return Promise.reject(error)
  }
)
export default service
