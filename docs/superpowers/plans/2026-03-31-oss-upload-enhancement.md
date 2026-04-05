# 阿里云 OSS 上传功能增强实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 增强 S3 对象存储页面的上传功能，支持多文件上传后展示文件名和链接，并提供复制链接功能。

**Architecture:** 复用现有 S3 上传接口，在 `s3/index.vue` 组件中添加上传结果展示区域和复制功能。

**Tech Stack:** Vue.js, Element UI, Clipboard API

---

## File Structure

```
eladmin-web/src/views/tools/storage/s3/index.vue  [MODIFY]
```

---

### Task 1: 添加 uploadResults 数据属性

**Files:**
- Modify: `eladmin-web/src/views/tools/storage/s3/index.vue:81`

- [ ] **Step 1: 修改 data() 返回对象，添加 uploadResults 属性**

在 `data()` 方法返回的对象中添加 `uploadResults: []` 数组属性，用于存储上传成功的文件信息。

```javascript
data() {
  return {
    permission: {
      del: ['admin', 'storage:del']
    },
    title: '文件', dialog: false,
    icon: 'el-icon-refresh',
    url: '', headers: { 'Authorization': getToken() },
    dialogImageUrl: '', dialogVisible: false, fileList: [], files: [], newWin: null,
    uploadResults: []  // 新增：存储上传结果
  }
}
```

- [ ] **Step 2: 保存修改**

```bash
git add eladmin-web/src/views/tools/storage/s3/index.vue
git commit -m "feat: add uploadResults data property for tracking uploaded files"
```

---

### Task 2: 更新 handleSuccess 方法

**Files:**
- Modify: `eladmin-web/src/views/tools/storage/s3/index.vue:105-109`

- [ ] **Step 1: 修改 handleSuccess 方法，存储上传结果**

更新 `handleSuccess` 方法，不仅存储文件 ID，还存储文件名和链接。

```javascript
handleSuccess(response, file, fileList) {
  const uid = file.uid
  const id = response.id
  const fileName = file.name  // 获取原始文件名
  const fileUrl = response.data && response.data[0] ? response.data[0] : ''  // 获取文件链接

  // 存储文件 ID 用于删除
  this.files.push({ uid, id })

  // 存储上传结果（仅当成功时）
  if (response.errno === 0 && fileUrl) {
    this.uploadResults.push({
      id: id,
      fileName: fileName,
      fileUrl: fileUrl,
      status: 'success',
      error: null
    })
  }
}
```

- [ ] **Step 2: 保存修改**

```bash
git add eladmin-web/src/views/tools/storage/s3/index.vue
git commit -m "feat: update handleSuccess to store upload results with file names and URLs"
```

---

### Task 3: 更新 handleError 方法

**Files:**
- Modify: `eladmin-web/src/views/tools/storage/s3/index.vue:131-134`

- [ ] **Step 1: 修改 handleError 方法，记录失败信息**

更新 `handleError` 方法，将失败的文件也记录到 `uploadResults` 中。

```javascript
handleError(e, file, fileList) {
  let errorMessage = '上传失败'
  try {
    const msg = JSON.parse(e.message)
    errorMessage = msg.message || errorMessage
    this.crud.notify(msg.message, CRUD.NOTIFICATION_TYPE.ERROR)
  } catch (parseError) {
    errorMessage = e.message || errorMessage
  }

  // 记录失败的文件
  this.uploadResults.push({
    id: null,
    fileName: file.name,
    fileUrl: '',
    status: 'error',
    error: errorMessage
  })
}
```

- [ ] **Step 2: 保存修改**

```bash
git add eladmin-web/src/views/tools/storage/s3/index.vue
git commit -m "feat: update handleError to record failed uploads"
```

---

### Task 4: 添加 copyToClipboard 方法

**Files:**
- Modify: `eladmin-web/src/views/tools/storage/s3/index.vue:104`

- [ ] **Step 1: 在 methods 中添加 copyToClipboard 方法**

在 `methods` 对象中添加 `copyToClipboard` 方法，使用 Clipboard API 复制链接到剪贴板。

```javascript
methods: {
  // ... 其他方法 ...

  // 复制链接到剪贴板
  copyToClipboard(url) {
    if (!url) {
      this.$message.error('链接为空，无法复制')
      return
    }

    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(url)
        .then(() => {
          this.$message.success('链接已复制到剪贴板')
        })
        .catch(err => {
          console.error('复制失败:', err)
          this.fallbackCopy(url)
        })
    } else {
      this.fallbackCopy(url)
    }
  },

  // 降级复制方案（用于不支持 Clipboard API 的浏览器）
  fallbackCopy(url) {
    const textArea = document.createElement('textarea')
    textArea.value = url
    textArea.style.position = 'fixed'
    textArea.style.left = '-999999px'
    document.body.appendChild(textArea)
    textArea.select()

    try {
      document.execCommand('copy')
      this.$message.success('链接已复制到剪贴板')
    } catch (err) {
      console.error('复制失败:', err)
      this.$message.error('复制失败，请手动复制')
    }

    document.body.removeChild(textArea)
  },

  // ... 其他方法 ...
}
```

- [ ] **Step 2: 保存修改**

```bash
git add eladmin-web/src/views/tools/storage/s3/index.vue
git commit -m "feat: add copyToClipboard method with fallback support"
```

---

### Task 5: 更新 doSubmit 方法

**Files:**
- Modify: `eladmin-web/src/views/tools/storage/s3/index.vue:123-129`

- [ ] **Step 1: 修改 doSubmit 方法，清空 uploadResults**

更新 `doSubmit` 方法，在关闭对话框时清空上传结果数组。

```javascript
doSubmit() {
  this.fileList = []
  this.files = []
  this.uploadResults = []  // 清空上传结果
  this.dialogVisible = false
  this.dialogImageUrl = ''
  this.dialog = false
  this.crud.toQuery()
}
```

- [ ] **Step 2: 保存修改**

```bash
git add eladmin-web/src/views/tools/storage/s3/index.vue
git commit -m "feat: clear uploadResults in doSubmit method"
```

---

### Task 6: 添加上传结果展示区域 UI

**Files:**
- Modify: `eladmin-web/src/views/tools/storage/s3/index.vue:20-37`

- [ ] **Step 1: 在上传对话框中添加上传结果展示区域**

在 `el-dialog` 的 `el-upload` 和 `dialog-footer` 之间添加上传结果展示区域。

```vue
<el-dialog :visible.sync="dialog" :close-on-click-modal="false" append-to-body width="500px" @close="doSubmit">
  <el-upload
    :before-remove="handleBeforeRemove"
    :on-success="handleSuccess"
    :on-error="handleError"
    :file-list="fileList"
    :headers="headers"
    :action="s3UploadApi"
    class="upload-demo"
    multiple
  >
    <el-button size="small" type="primary">点击上传</el-button>
    <div slot="tip" style="display: block;" class="el-upload__tip">请勿上传违法文件，且文件不超过15M</div>
  </el-upload>

  <!-- 上传结果展示区域 -->
  <div v-if="uploadResults.length > 0" class="upload-results">
    <el-divider content-position="left">上传结果</el-divider>
    <div v-for="(result, index) in uploadResults" :key="index" class="upload-result-item">
      <div class="result-info">
        <span class="file-name" :class="{ 'error': result.status === 'error' }">{{ result.fileName }}</span>
        <el-tag v-if="result.status === 'success'" type="success" size="mini" style="margin-left: 10px;">成功</el-tag>
        <el-tag v-if="result.status === 'error'" type="danger" size="mini" style="margin-left: 10px;">失败</el-tag>
      </div>
      <div v-if="result.status === 'success'" class="result-url">
        <el-link :href="result.fileUrl" target="_blank" :underline="false" class="url-link">{{ result.fileUrl }}</el-link>
        <el-button size="mini" type="text" icon="el-icon-document-copy" @click="copyToClipboard(result.fileUrl)">复制</el-button>
      </div>
      <div v-if="result.status === 'error'" class="result-error">
        <span class="error-message">{{ result.error || '上传失败' }}</span>
      </div>
    </div>
  </div>

  <div slot="footer" class="dialog-footer">
    <el-button type="primary" @click="doSubmit">确认</el-button>
  </div>
</el-dialog>
```

- [ ] **Step 2: 添加样式**

在 `<style scoped>` 标签中添加上传结果区域的样式。

```css
<style scoped>
.upload-results {
  margin-top: 20px;
  max-height: 300px;
  overflow-y: auto;
}

.upload-result-item {
  padding: 10px;
  margin-bottom: 10px;
  border: 1px solid #e4e7ed;
  border-radius: 4px;
  background-color: #f5f7fa;
}

.result-info {
  display: flex;
  align-items: center;
  margin-bottom: 5px;
}

.file-name {
  font-weight: 500;
  color: #303133;
}

.file-name.error {
  color: #f56c6c;
}

.result-url {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.url-link {
  flex: 1;
  font-size: 12px;
  color: #606266;
  word-break: break-all;
}

.result-error {
  color: #f56c6c;
  font-size: 12px;
}

.error-message {
  color: #f56c6c;
}
</style>
```

- [ ] **Step 3: 保存修改**

```bash
git add eladmin-web/src/views/tools/storage/s3/index.vue
git commit -m "feat: add upload results display UI with copy functionality"
```

---

### Task 7: 添加上传状态指示

**Files:**
- Modify: `eladmin-web/src/views/tools/storage/s3/index.vue:81`

- [ ] **Step 1: 添加 uploading 状态属性**

在 `data()` 方法中添加 `uploading: false` 属性，用于跟踪上传状态。

```javascript
data() {
  return {
    permission: {
      del: ['admin', 'storage:del']
    },
    title: '文件', dialog: false,
    icon: 'el-icon-refresh',
    url: '', headers: { 'Authorization': getToken() },
    dialogImageUrl: '', dialogVisible: false, fileList: [], files: [], newWin: null,
    uploadResults: [],
    uploading: false  // 新增：上传状态
  }
}
```

- [ ] **Step 2: 添加上传状态监听方法**

在 `methods` 中添加上传相关的方法来管理上传状态。

```javascript
methods: {
  // ... 其他方法 ...

  // 上传前回调
  beforeUpload(file) {
    this.uploading = true
    return true
  },

  // 上传完成回调（成功或失败都会调用）
  uploadFinish() {
    this.uploading = false
  },

  // ... 其他方法 ...
}
```

- [ ] **Step 3: 更新 el-upload 组件，添加上传状态监听**

在模板中的 `el-upload` 组件上添加 `:before-upload` 和 `:on-finish` 属性。

```vue
<el-upload
  :before-remove="handleBeforeRemove"
  :before-upload="beforeUpload"
  :on-success="handleSuccess"
  :on-error="handleError"
  :on-finish="uploadFinish"
  :file-list="fileList"
  :headers="headers"
  :action="s3UploadApi"
  class="upload-demo"
  multiple
>
```

- [ ] **Step 4: 保存修改**

```bash
git add eladmin-web/src/views/tools/storage/s3/index.vue
git commit -m "feat: add upload status tracking"
```

---

### Task 8: 更新 doSubmit 方法处理上传状态

**Files:**
- Modify: `eladmin-web/src/views/tools/storage/s3/index.vue:123-129`

- [ ] **Step 1: 在 doSubmit 中检查上传状态**

更新 `doSubmit` 方法，添加上传中状态的检查。

```javascript
doSubmit() {
  if (this.uploading) {
    this.$message.warning('文件正在上传中，请稍候...')
    return
  }
  this.fileList = []
  this.files = []
  this.uploadResults = []
  this.dialogVisible = false
  this.dialogImageUrl = ''
  this.dialog = false
  this.crud.toQuery()
}
```

- [ ] **Step 2: 保存修改**

```bash
git add eladmin-web/src/views/tools/storage/s3/index.vue
git commit -m "feat: prevent dialog close during upload"
```

---

## Testing

### Test 1: 单文件上传测试

1. 打开浏览器，导航到工具 → 存储 → 对象存储页面
2. 点击"上传"按钮
3. 选择一个图片文件（如 test.jpg）
4. 观察上传结果区域
5. 验证显示：文件名、链接、成功状态图标
6. 点击"复制"按钮
7. 验证显示"链接已复制到剪贴板"提示
8. 验证剪贴板中包含正确的链接
9. 点击"文件名"链接
10. 验证在新标签页打开链接，图片正常显示

### Test 2: 多文件上传测试

1. 点击"上传"按钮
2. 选择多个图片文件（如 test1.jpg, test2.png, test3.jpg）
3. 观察上传过程
4. 验证每个文件上传成功后显示在结果区域
5. 验证每个文件都有对应的链接和复制按钮
6. 分别复制每个文件的链接
7. 验证所有链接都能正常访问

### Test 3: 上传失败测试

1. 模拟网络断开或上传超大文件（超过15MB）
2. 观察错误处理
3. 验证显示失败状态和错误信息
4. 验证不影响其他文件的上传

### Test 4: 对话框操作测试

1. 上传文件后不关闭对话框
2. 点击"确认"按钮
3. 验证对话框关闭
4. 验证文件列表刷新
5. 重新打开上传对话框
6. 验证上传结果已清空

### Test 5: 浏览器兼容性测试

1. 在不同浏览器（Chrome, Firefox, Safari, Edge）中测试
2. 验证复制功能在所有浏览器中正常工作
3. 验证降级复制方案在旧浏览器中正常工作
