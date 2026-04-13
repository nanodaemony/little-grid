# 项目规范结构搭建 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为三个子项目创建完整的规范文档结构，包括 `.rules/` 目录和 Claude memory 文件

**Architecture:** 双结构设计 - `.rules/` 存放详细规范（人读），`.claude/.../memory/` 存放 Claude 速查表（自动加载）

**Tech Stack:** Markdown 文档, Git

---

## 任务清单

### Task 1: 创建 .rules/ 目录结构和总览

**Files:**
- Create: `.rules/README.md`
- Create: `.rules/app/README.md`
- Create: `.rules/backend/README.md`
- Create: `.rules/admin-web/README.md`

- [ ] **Step 1: 创建 .rules 总览 README**

```markdown
# Little Grid 项目规范

本目录包含 little-grid 项目三个子项目的开发规范。

## 项目结构

- [app/](./app/) - Flutter 移动端应用规范
- [backend/](./backend/) - Spring Boot 后端服务规范
- [admin-web/](./admin-web/) - Vue 管理前端规范

## 快速开始

新开发者请从对应项目的 README.md 开始阅读。

## Claude AI 速查表

Claude AI 会自动加载 `.claude/projects/-home-nano-little-grid/memory/quick-reference.md` 中的关键信息。
```

- [ ] **Step 2: 创建三个项目的空 README**

`.rules/app/README.md`:
```markdown
# Flutter 移动端应用规范

TODO - 待完善
```

`.rules/backend/README.md`:
```markdown
# Spring Boot 后端服务规范

TODO - 待完善
```

`.rules/admin-web/README.md`:
```markdown
# Vue 管理前端规范

TODO - 待完善
```

- [ ] **Step 3: 提交**

```bash
git add .rules/README.md .rules/app/README.md .rules/backend/README.md .rules/admin-web/README.md
git commit -m "feat: create .rules directory structure"
```

---

### Task 2: 编写 Flutter (app) 完整规范

**Files:**
- Modify: `.rules/app/README.md`
- Create: `.rules/app/patterns/new_tool.md`
- Create: `.rules/app/patterns/new_service.md`
- Create: `.rules/app/patterns/new_model.md`

- [ ] **Step 1: 编写 app README 完整内容**

```markdown
# Flutter 移动端应用规范

## 技术栈版本

- Flutter SDK: >=3.0.0 <4.0.0
- Dart SDK: >=3.0.0
- 状态管理: provider: ^6.1.1
- 数据库: sqflite: ^2.3.0

## 目录结构

```
app/lib/
├── main.dart                    # 应用入口
├── core/                        # 核心模块
│   ├── constants/               # 常量定义
│   ├── models/                  # 数据模型
│   ├── services/                # 服务层
│   │   ├── tool_registry.dart   # 工具注册中心
│   │   ├── database_service.dart
│   │   └── ...
│   └── ui/                      # UI组件
│       ├── app_colors.dart
│       └── theme.dart
├── pages/                       # 页面
├── providers/                   # 状态管理
└── tools/                       # 工具模块
    ├── coin/
    │   ├── coin_tool.dart       # 工具注册
    │   ├── coin_page.dart       # 主页面
    │   ├── coin_models.dart     # 数据模型
    │   └── coin_service.dart    # 业务逻辑
    └── ...
```

## 命名规范

### 文件命名
- 小写 + 下划线：`xxx_tool.dart`, `xxx_page.dart`
- 组件文件：`xxx_card.dart`, `xxx_dialog.dart`

### 类命名
- 大驼峰：`XxxTool`, `XxxPage`, `XxxItem`
- 私有组件：`_XxxCard`, `_XxxDialog`

### 变量命名
- 小驼峰：`_items`, `_isLoading`, `_selectedItem`
- 常量：`kDefaultValue` 或直接使用 `const`

### 方法命名
- 动词开头：`_loadData()`, `_deleteItem()`, `_showDialog()`
- 构建方法：`_buildBody()`, `_buildEmptyState()`

## 代码规范

### 工具模块实现

每个工具必须实现 `ToolModule` 接口，并在 `main.dart` 中注册。

详见 [patterns/new_tool.md](./patterns/new_tool.md)

### 颜色使用

使用 `AppColors` 中定义的颜色常量，**不要硬编码颜色值**：

```dart
import '../../core/ui/app_colors.dart';

// 主色调
AppColors.primary          // 主色 #5B9BD5
AppColors.primaryLight     // 浅主色
AppColors.primaryDark      // 深主色

// 文字颜色
AppColors.textPrimary      // 主文字 #333333
AppColors.textSecondary    // 次要文字 #666666
AppColors.textTertiary     // 辅助文字 #999999
```

### 数据库表升级

1. 升级数据库版本（`app_constants.dart`）：
```dart
static const int dbVersion = 2;  // 递增
```

2. 添加建表语句（`database_service.dart` 的 `_onCreate`）

3. 添加升级逻辑（`database_service.dart` 的 `_onUpgrade`）

## 常用命令

```bash
# 安装依赖
flutter pub get

# 运行应用
flutter run

# 分析代码
flutter analyze

# 运行测试
flutter test

# 构建 APK
flutter build apk --release
```

## 检查清单

新增工具时确认：
- [ ] 文件结构符合规范
- [ ] 实现了 `ToolModule` 接口
- [ ] 在 `main.dart` 中注册
- [ ] 使用 `AppColors` 颜色常量
- [ ] 空状态有友好提示
- [ ] 删除操作有确认弹窗
- [ ] 数据库表已正确创建和升级
- [ ] 界面文字使用中文
```

- [ ] **Step 2: 创建 new_tool.md 模板**

```markdown
# 新工具模块模板

## 文件结构

```
app/lib/tools/xxx/
├── xxx_tool.dart      # 必须 - 工具注册
├── xxx_page.dart      # 必须 - 主页面
├── xxx_models.dart    # 可选 - 数据模型
└── xxx_service.dart   # 可选 - 业务逻辑
```

## xxx_tool.dart

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'xxx_page.dart';

class XxxTool implements ToolModule {
  @override
  String get id => 'xxx';

  @override
  String get name => '工具名称';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.extension;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) => const XxxPage();

  @override
  ToolSettings? get settings => null;

  @override
  Future<void> onInit() async {}

  @override
  Future<void> onDispose() async {}

  @override
  void onEnter() {}

  @override
  void onExit() {}
}
```

## 注册到 main.dart

```dart
import 'tools/xxx/xxx_tool.dart';

void main() {
  ToolRegistry.register(XxxTool());
  // ...
}
```
```

- [ ] **Step 3: 创建 new_service.md 模板**

```markdown
# Service 层模板

```dart
import '../../core/services/database_service.dart';
import 'xxx_models.dart';

class XxxService {
  /// 添加
  static Future<int> add(XxxItem item) async {
    final db = await DatabaseService.database;
    return await db.insert('xxx_items', item.toMap());
  }

  /// 查询列表
  static Future<List<XxxItem>> getAll() async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      'xxx_items',
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => XxxItem.fromMap(m)).toList();
  }

  /// 更新
  static Future<void> update(XxxItem item) async {
    final db = await DatabaseService.database;
    await db.update(
      'xxx_items',
      item.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// 删除
  static Future<void> delete(int id) async {
    final db = await DatabaseService.database;
    await db.delete(
      'xxx_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
```
```

- [ ] **Step 4: 创建 new_model.md 模板**

```markdown
# Model 层模板

```dart
class XxxItem {
  final int? id;
  final String field1;
  final DateTime createdAt;
  final DateTime updatedAt;

  XxxItem({
    this.id,
    required this.field1,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'field1': field1,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory XxxItem.fromMap(Map<String, dynamic> map) {
    return XxxItem(
      id: map['id'],
      field1: map['field1'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  XxxItem copyWith({
    int? id,
    String? field1,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return XxxItem(
      id: id ?? this.id,
      field1: field1 ?? this.field1,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```
```

- [ ] **Step 5: 提交**

```bash
git add .rules/app/README.md .rules/app/patterns/new_tool.md .rules/app/patterns/new_service.md .rules/app/patterns/new_model.md
git commit -m "feat: add flutter app development rules"
```

---

### Task 3: 编写 Java Backend 完整规范

**Files:**
- Modify: `.rules/backend/README.md`
- Create: `.rules/backend/patterns/new_entity.md`
- Create: `.rules/backend/patterns/new_controller.md`

- [ ] **Step 1: 编写 backend README 完整内容**

```markdown
# Spring Boot 后端服务规范

## 技术栈版本

- Java: 1.8
- Spring Boot: 2.7.18
- 构建工具: Maven
- ORM: Spring Data JPA
- 数据库: MySQL
- 缓存: Redis + Redisson
- 文档: Knife4j (Swagger)
- 工具库: Lombok, MapStruct, fastjson2

## 模块结构

```
backend/
├── grid-common/          # 公共模块
│   ├── annotation/        # 自定义注解
│   ├── aspect/            # AOP 切面
│   ├── base/              # 基类 (BaseEntity)
│   ├── config/            # 配置
│   ├── exception/         # 异常处理
│   └── utils/             # 工具类
├── grid-logging/          # 日志模块
├── grid-system/           # 系统核心模块（启动入口）
│   └── src/main/java/com/naon/grid/modules/
│       ├── system/        # 系统管理（用户、角色、菜单等）
│       ├── security/      # 安全认证
│       └── ...
├── grid-tools/            # 第三方工具模块
├── grid-generator/        # 代码生成模块
└── grid-app/              # APP 接口模块
```

## 分层架构

每个业务模块按以下分层：

```
modules/<module>/
├── domain/            # Entity 实体类
├── repository/        # JPA Repository
├── service/           # 业务逻辑
│   ├── dto/           # DTO 和 QueryCriteria
│   ├── mapstruct/     # MapStruct 映射
│   └── impl/          # Service 实现
└── rest/              # REST Controller
```

## 命名规范

### 类命名
- Entity: 业务名称，如 `User`, `Role`
- DTO: 业务名称 + `Dto`，如 `UserDto`
- QueryCriteria: 业务名称 + `QueryCriteria`
- Service: 业务名称 + `Service`
- Controller: 业务名称 + `Controller`
- Mapper: 业务名称 + `Mapper`

### 包命名
- 全小写，用点分隔: `com.naon.grid.modules.system`

### 变量命名
- 小驼峰: `userId`, `userName`
- 常量: 全大写下划线: `MAX_SIZE`

## 代码规范

### Entity 基类

所有 Entity 继承 `BaseEntity`，自动获得创建人、更新人、创建时间、更新时间字段。

详见 [patterns/new_entity.md](./patterns/new_entity.md)

### 使用 Lombok

使用 `@Getter` `@Setter` 简化代码，不要手写 getter/setter。

### MapStruct 映射

使用 MapStruct 进行 Entity 和 DTO 之间的转换：

```java
@Mapper(componentModel = "spring")
public interface UserMapper extends BaseMapper<UserDto, User> {
}
```

### REST API 返回

统一使用ResponseEntity包装返回值，异常统一处理。

## 常用命令

```bash
# 编译
mvn clean compile

# 打包（跳过测试）
mvn clean package -Dmaven.test.skip=true

# 运行
mvn spring-boot:run -pl grid-system
```

## 检查清单

新增功能时确认：
- [ ] Entity 继承 BaseEntity
- [ ] 使用 Lombok 简化代码
- [ ] DTO 和 QueryCriteria 已创建
- [ ] MapStruct Mapper 已定义
- [ ] Service 接口和实现已分离
- [ ] REST API 路径规范
- [ ] Swagger 注解已添加
```

- [ ] **Step 2: 创建 new_entity.md 模板**

```markdown
# Entity 模板

```java
package com.naon.grid.modules.xxx.domain;

import io.swagger.annotations.ApiModelProperty;
import lombok.Getter;
import lombok.Setter;
import com.naon.grid.base.BaseEntity;
import javax.persistence.*;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.io.Serializable;
import java.util.Objects;

@Entity
@Getter
@Setter
@Table(name = "xxx")
public class Xxx extends BaseEntity implements Serializable {

    @Id
    @Column(name = "id")
    @NotNull(groups = Update.class)
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @ApiModelProperty(value = "ID", hidden = true)
    private Long id;

    @NotBlank
    @Column(name = "name")
    @ApiModelProperty(value = "名称")
    private String name;

    @Column(name = "description")
    @ApiModelProperty(value = "描述")
    private String description;

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        Xxx xxx = (Xxx) o;
        return Objects.equals(id, xxx.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
```
```

- [ ] **Step 3: 创建 new_controller.md 模板**

```markdown
# Controller 模板

```java
package com.naon.grid.modules.xxx.rest;

import com.naon.grid.annotation.Log;
import com.naon.grid.modules.xxx.domain.Xxx;
import com.naon.grid.modules.xxx.service.XxxService;
import com.naon.grid.modules.xxx.service.dto.XxxDto;
import com.naon.grid.modules.xxx.service.dto.XxxQueryCriteria;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@Api(tags = "Xxx管理")
@RequestMapping("/api/xxx")
public class XxxController {

    private final XxxService xxxService;

    @Log("查询Xxx")
    @ApiOperation("查询Xxx")
    @GetMapping
    @PreAuthorize("@el.check('xxx:list')")
    public ResponseEntity<Object> query(XxxQueryCriteria criteria, Pageable pageable) {
        return new ResponseEntity<>(xxxService.queryAll(criteria, pageable), HttpStatus.OK);
    }

    @Log("新增Xxx")
    @ApiOperation("新增Xxx")
    @PostMapping
    @PreAuthorize("@el.check('xxx:add')")
    public ResponseEntity<Object> create(@Validated @RequestBody Xxx resources) {
        xxxService.create(resources);
        return new ResponseEntity<>(HttpStatus.CREATED);
    }

    @Log("修改Xxx")
    @ApiOperation("修改Xxx")
    @PutMapping
    @PreAuthorize("@el.check('xxx:edit')")
    public ResponseEntity<Object> update(@Validated @RequestBody Xxx resources) {
        xxxService.update(resources);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    @Log("删除Xxx")
    @ApiOperation("删除Xxx")
    @DeleteMapping
    @PreAuthorize("@el.check('xxx:del')")
    public ResponseEntity<Object> delete(@RequestBody Long[] ids) {
        xxxService.deleteAll(ids);
        return new ResponseEntity<>(HttpStatus.OK);
    }
}
```
```

- [ ] **Step 4: 提交**

```bash
git add .rules/backend/README.md .rules/backend/patterns/new_entity.md .rules/backend/patterns/new_controller.md
git commit -m "feat: add java backend development rules"
```

---

### Task 4: 编写 Vue Admin-Web 完整规范

**Files:**
- Modify: `.rules/admin-web/README.md`
- Create: `.rules/admin-web/patterns/new_api.md`
- Create: `.rules/admin-web/patterns/new_view.md`

- [ ] **Step 1: 编写 admin-web README 完整内容**

```markdown
# Vue 管理前端规范

## 技术栈版本

- Node.js: >= 12, <= 16
- Vue: 2.7.16
- Vue Router: 3.0.2
- Vuex: 3.1.0
- UI 框架: Element UI 2.15.14
- HTTP 客户端: axios 1.8.2
- 构建工具: Vue CLI 3

## 目录结构

```
admin-web/src/
├── api/                   # API 接口模块
│   ├── login.js
│   ├── system/
│   │   ├── user.js
│   │   ├── role.js
│   │   └── ...
│   └── ...
├── assets/                # 静态资源
├── components/            # 公共组件
│   ├── Crud/
│   ├── Dict/
│   └── ...
├── layout/                # 布局组件
├── router/                # 路由配置
├── store/                 # Vuex 状态管理
│   └── modules/
│       ├── user.js
│       ├── app.js
│       └── ...
├── utils/                 # 工具函数
│   ├── request.js         # axios 拦截器
│   ├── auth.js
│   └── ...
├── views/                 # 页面组件
│   ├── dashboard/
│   ├── system/
│   │   ├── user/
│   │   ├── role/
│   │   └── ...
│   └── ...
├── App.vue
└── main.js
```

## 命名规范

### 文件命名
- 组件: 大驼峰 `User.vue`, `RoleForm.vue`
- 工具/API: 小驼峰 `user.js`, `auth.js`

### 组件命名
- 组件名大驼峰: `export default { name: 'User' }`
- 私有组件: `_UserDetail.vue`

### 变量命名
- 小驼峰: `userName`, `isLoading`
- 常量: 全大写下划线: `MAX_COUNT`

## 代码规范

### API 模块定义

API 统一放在 `src/api/` 目录下，使用 `request.js` 封装的 axios 实例。

详见 [patterns/new_api.md](./patterns/new_api.md)

### HTTP 请求拦截器

`request.js` 自动处理：
- 添加 Authorization Token
- 添加 X-Trace-Id 链路追踪
- 请求/响应日志
- 统一错误处理

### Vuex Store 结构

按模块划分，每个模块包含 state, mutations, actions, getters。

### Element UI 使用

使用 Element UI 组件库，保持风格一致。

## 常用命令

```bash
# 安装依赖
npm install

# 开发环境运行 (localhost:8013)
npm run dev

# 生产环境构建
npm run build:prod

# 代码检查
npm run lint
```

## 检查清单

新增功能时确认：
- [ ] API 模块已创建在 `src/api/`
- [ ] 使用 `request.js` 发送请求
- [ ] 页面组件放在 `src/views/`
- [ ] 使用 Element UI 组件
- [ ] 错误处理已完善
```

- [ ] **Step 2: 创建 new_api.md 模板**

```markdown
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
```

- [ ] **Step 3: 创建 new_view.md 模板**

```markdown
# View 页面模板

`src/views/xxx/index.vue`:

```vue
<template>
  <div class="app-container">
    <!-- 搜索表单 -->
    <el-form :model="queryParams" ref="queryForm" :inline="true" v-show="showSearch">
      <el-form-item label="名称" prop="name">
        <el-input
          v-model="queryParams.name"
          placeholder="请输入名称"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 工具栏 -->
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" icon="el-icon-plus" size="mini" @click="handleAdd">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" icon="el-icon-delete" size="mini" @click="handleDelete">删除</el-button>
      </el-col>
    </el-row>

    <!-- 数据表格 -->
    <el-table v-loading="loading" :data="xxxList">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="名称" align="center" prop="name" />
      <el-table-column label="描述" align="center" prop="description" />
      <el-table-column label="操作" align="center">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-edit" @click="handleUpdate(scope.row)">修改</el-button>
          <el-button size="mini" type="text" icon="el-icon-delete" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 分页 -->
    <pagination
      v-show="total>0"
      :total="total"
      :page.sync="queryParams.pageNum"
      :limit.sync="queryParams.pageSize"
      @pagination="getList"
    />

    <!-- 新增/修改对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="500px">
      <el-form ref="form" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入名称" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" placeholder="请输入描述" type="textarea" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listXxx, getXxx, addXxx, updateXxx, delXxx } from '@/api/xxx'

export default {
  name: 'Xxx',
  data() {
    return {
      showSearch: true,
      loading: true,
      ids: [],
      single: true,
      total: 0,
      xxxList: [],
      title: '',
      open: false,
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        name: null
      },
      form: {},
      rules: {
        name: [
          { required: true, message: '名称不能为空', trigger: 'blur' }
        ]
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    getList() {
      this.loading = true
      listXxx(this.queryParams).then(response => {
        this.xxxList = response.data.content
        this.total = response.data.totalElements
        this.loading = false
      })
    },
    cancel() {
      this.open = false
      this.reset()
    },
    reset() {
      this.form = {
        id: null,
        name: null,
        description: null
      }
      this.resetForm('form')
    },
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    resetQuery() {
      this.resetForm('queryForm')
      this.handleQuery()
    },
    handleAdd() {
      this.reset()
      this.open = true
      this.title = '添加Xxx'
    },
    handleUpdate(row) {
      this.reset()
      const id = row.id || this.ids
      getXxx(id).then(response => {
        this.form = response.data
        this.open = true
        this.title = '修改Xxx'
      })
    },
    submitForm() {
      this.$refs['form'].validate(valid => {
        if (valid) {
          if (this.form.id != null) {
            updateXxx(this.form).then(response => {
              this.$message.success('修改成功')
              this.open = false
              this.getList()
            })
          } else {
            addXxx(this.form).then(response => {
              this.$message.success('新增成功')
              this.open = false
              this.getList()
            })
          }
        }
      })
    },
    handleDelete(row) {
      const ids = row.id ? [row.id] : this.ids
      this.$confirm('是否确认删除?').then(() => {
        return delXxx(ids)
      }).then(() => {
        this.getList()
        this.$message.success('删除成功')
      })
    }
  }
}
</script>
```
```

- [ ] **Step 4: 提交**

```bash
git add .rules/admin-web/README.md .rules/admin-web/patterns/new_api.md .rules/admin-web/patterns/new_view.md
git commit -m "feat: add vue admin-web development rules"
```

---

### Task 5: 创建 Claude Memory 速查表

**Files:**
- Create: `.claude/projects/-home-nano-little-grid/memory/quick-reference.md`
- Create/Modify: `.claude/projects/-home-nano-little-grid/memory/MEMORY.md`

- [ ] **Step 1: 创建 memory 目录（如果不存在）**

```bash
mkdir -p /home/nano/little-grid/.claude/projects/-home-nano-little-grid/memory
```

- [ ] **Step 2: 创建 quick-reference.md**

```markdown
---
name: Little Grid 速查表
description: 三个子项目的关键规范，Claude 自动加载
type: reference
---

# Little Grid 项目速查表

## 项目概览

- **app/** - Flutter 移动端（小方格工具集合）
- **backend/** - Spring Boot 后端服务（基于 ELADMIN）
- **admin-web/** - Vue 2 管理前端（基于 Element UI）

---

## Flutter (app) 关键规范

**工具创建流程：**
1. 在 `app/lib/tools/<tool_name>/` 创建文件
2. 必须有 `<tool_name>_tool.dart` - 实现 ToolModule 接口
3. 必须有 `<tool_name>_page.dart` - 主页面 UI
4. 在 `main.dart` 中注册：`ToolRegistry.register(MyTool())`

**关键文件：**
- `app/lib/core/services/tool_registry.dart` - 工具注册表
- `app/lib/core/ui/app_colors.dart` - 颜色常量（必须使用，不要硬编码）
- `app/lib/core/constants/app_constants.dart` - 数据库版本在此升级

**颜色规范：**
使用 `AppColors.primary` 等，不要用 `Colors.red` 等硬编码

---

## Java (backend) 关键规范

**模块结构：**
- grid-common - 公共模块（BaseEntity, utils, config）
- grid-system - 系统核心（启动入口）
- grid-logging, grid-tools, grid-generator, grid-app

**分层架构：**
```
modules/<module>/
├── domain/       - Entity（继承 BaseEntity）
├── repository/   - JPA Repository
├── service/      - Service 接口 + impl/ 实现
│   ├── dto/      - Dto + QueryCriteria
│   └── mapstruct/- MapStruct Mapper
└── rest/         - REST Controller
```

**Entity 模板：**
- 继承 `BaseEntity`
- 使用 `@Getter @Setter` (Lombok)
- 使用 `@ApiModelProperty` 注解 (Swagger)
- 实现 equals/hashCode

---

## Vue (admin-web) 关键规范

**目录结构：**
- `src/api/` - API 接口模块
- `src/views/` - 页面组件
- `src/components/` - 公共组件
- `src/store/modules/` - Vuex 状态管理
- `src/utils/request.js` - axios 拦截器（必须用这个发请求）

**API 模块模板：**
```javascript
import request from '@/utils/request'
export function listXxx(query) {
  return request({ url: '/api/xxx', method: 'get', params: query })
}
```

**request.js 自动处理：**
- 添加 Authorization Token
- 添加 X-Trace-Id 链路追踪
- 请求/响应日志
- 统一错误处理

---

## 常用命令

**Flutter:**
```bash
flutter pub get    # 安装依赖
flutter run         # 运行
flutter analyze     # 代码检查
```

**Java:**
```bash
mvn clean package -Dmaven.test.skip=true    # 打包
mvn spring-boot:run -pl grid-system          # 运行
```

**Vue:**
```bash
npm install       # 安装依赖
npm run dev       # 开发 (localhost:8013)
npm run build:prod # 生产构建
```
```

- [ ] **Step 3: 创建/更新 MEMORY.md 索引**

如果 MEMORY.md 不存在则创建，添加以下内容：

```markdown
# Little Grid Project Memories

- [quick-reference.md](quick-reference.md) - 三个子项目的关键规范速查表
```

- [ ] **Step 4: 提交**

```bash
git add .claude/projects/-home-nano-little-grid/memory/quick-reference.md .claude/projects/-home-nano-little-grid/memory/MEMORY.md
git commit -m "feat: add claude memory quick reference"
```

---

## 验收

- [ ] `.rules/` 目录结构完整
- [ ] 三个子项目都有 README 和 patterns
- [ ] Claude memory 的 quick-reference.md 已创建
- [ ] 所有文档与现有代码模式一致
