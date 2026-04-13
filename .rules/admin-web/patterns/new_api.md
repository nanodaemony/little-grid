# API 模块模板

`src/api/xxx.js`:

```javascript
import request from '@/utils/request'

// 查询列表
export function listXxx(query) {
  return request({
    url: '/api/xxx',
    method: 'get',
    params: query
  })
}

// 查询详情
export function getXxx(id) {
  return request({
    url: '/api/xxx/' + id,
    method: 'get'
  })
}

// 新增
export function addXxx(data) {
  return request({
    url: '/api/xxx',
    method: 'post',
    data: data
  })
}

// 修改
export function updateXxx(data) {
  return request({
    url: '/api/xxx',
    method: 'put',
    data: data
  })
}

// 删除
export function delXxx(ids) {
  return request({
    url: '/api/xxx',
    method: 'delete',
    data: ids
  })
}
```
