# 足迹地图功能设计文档

## 概述

用户可以在地图上标记自己去过的城市，支持点击地图选点和搜索城市两种方式。标记后的城市会在地图上高亮显示，同时提供按时间顺序查看足迹列表的功能。

**注意**：此功能需要用户登录后才能使用，每个用户只能查看和管理自己的足迹数据。

**项目**: littlegrid
**分支**:**: feature-road-map
**设计日期**: 2026-04-01

---

## 1. 数据模型

### 1.1 实体类

```java
@Entity
@Table(name = "footprint")
public class Footprint extends BaseEntity {

    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Schema(description = "用户ID")
    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Schema(description = "城市名称，如'上海市'")
    @Column(name = "city_name", length = 100, nullable = false)
    private String cityName;

    @Schema(description = "省份名称，如'上海'")
    @Column(name = "province_name", length = 50)
    private String provinceName;

    @Schema(description = "纬度")
    @Column(name = "latitude", precision = 10, scale = 7, nullable = false)
    private Double latitude;

    @Schema(description = "经度")
    @Column(name = "longitude", precision = 10, scale = 7, nullable = false)
    private Double longitude;

    @Schema(description = "访问日期")
    @Column(name = "visit_date", nullable = false)
    private LocalDate visitDate;
}
```

### 1.2 数据库表结构

```sql
CREATE TABLE footprint (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  city_name VARCHAR(100) NOT NULL,
  province_name VARCHAR(50),
  latitude DECIMAL(10,7) NOT NULL,
  longitude DECIMAL(10,7) NOT NULL,
  visit_date DATE NOT NULL,
  create_by VARCHAR(50),
  update_by VARCHAR(50),
  create_time TIMESTAMP,
  update_time TIMESTAMP,

  INDEX idx_user_id (user_id)
);
```

---

## 2. 后端 API 设计

**认证要求**：所有 API 调用都需要在请求头中携带有效的 JWT Token，未登录用户无法访问。

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/footprints` | 获取当前用户的所有足迹 |
| GET | `/api/footprints/{id}` | 获取单个足迹详情（仅限当前用户自己的数据） |
| POST | `/api/footprints` | 添加新足迹（仅限当前用户） |
| PUT | `/api/footprints/{id}` | 更新足迹信息（仅限当前用户自己的数据） |
| DELETE | `/api/footprints/{id}` | 删除足迹（仅限当前用户自己的数据） |

**权限说明**：
- 所有操作都通过 JWT Token 中的用户信息进行身份验证
- 用户只能访问自己创建的足迹数据
- 尝试访问其他用户的足迹将返回 403 Forbidden
- 未登录用户访问任何 API 将返回 401 Unauthorized

### 2.1 DTO 类

**FootprintDTO**
```java
public class FootprintDTO {
    private Long id;
    private String cityName;
    private String provinceName;
    private Double latitude;
    private Double longitude;
    private String visitDate;  // ISO 8601 格式
    private String createTime;
}
```

**FootprintCreateDTO**
```java
public class FootprintCreateDTO {
    @NotBlank(message = "城市名称不能为空")
    private String cityName;

    @NotBlank(message = "省份名称不能为空")
    private String provinceName;

    @NotNull(message = "经度不能为空")
    private Double longitude;

    @NotNull(message = "纬度不能为空")
    private Double latitude;

    @NotBlank(message = "访问日期不能为空")
    private String visitDate;
}
```

**FootprintUpdateDTO**
```java
public class FootprintUpdateDTO {
    @NotNull(message = "ID不能为空")
    private Long id;

    private String cityName;
    private String provinceName;
    private Double latitude;
    private Double longitude;
    private String visitDate;
}
```

---

## 3. 前端组件结构

```
FootprintPage                    // 主页面
├── AmapView                    // 高德地图视图
│   └── FootprintMarker         // 足迹标记点（橙色高亮）
├── TimelineListView            // 时间线列表（按日期倒序）
├── AddFootprintDialog          // 添加足迹弹窗
│   └── DatePicker              // 日期选择器
└── CitySearchDialog            // 城市搜索弹窗
    └── SearchResultList        // 搜索结果列表
```

---

## 4. 核心功能流程

### 4.1 查看足迹

1. 页面加载 → 调用 `GET /api/footprints` 获取所有足迹
2. 地图显示中国地图
3. 有足迹的城市用**橙色标记**高亮显示
4. 没有足迹的城市显示灰色（或仅突出显示有足迹的区域）
5. 侧边显示时间线列表，按访问日期倒序排列

### 4.2 添加足迹（点击地图）

1. 用户点击地图上的某个位置
2. 获取点击位置的经纬度坐标
3. 调用高德逆地理编码API，获取该位置对应的城市信息
4. 弹出确认对话框，显示：
   - 城市名称（如：上海市）
   - 省份（如：上海）
   - 经纬度坐标
5. 用户选择访问日期
6. 用户确认后，调用 `POST /api/footprints` 提交数据
7. 成功后刷新地图和列表
8. 失败则显示错误提示

### 4.3 添加足迹（搜索城市）

1. 用户点击搜索按钮
2. 打开搜索对话框
3. 输入城市名称，调用高德POI搜索API
4. 显示搜索结果列表（城市名称+省份）
5. 用户选择一个城市
6. 弹出日期选择器，选择访问日期
7. 调用 `POST /api/footprints` 提交数据
8. 成功后刷新地图和列表

### 4.4 编辑足迹

1. 用户在地图上点击已存在的足迹标记，或在时间线列表中点击某条记录
2. 弹出编辑对话框，显示当前信息
3. 用户修改后，调用 `PUT /api/footprints/{id}`
3. 成功后刷新地图和列表

### 4.5 删除足迹

1. 用户在足迹卡片上点击删除按钮
2. 弹出确认对话框："确定删除这条足迹吗？"
3. 用户确认后，调用 `DELETE /api/footprints/{id}`
4. 成功后刷新地图和列表

---

## 5. 技术实现细节

### 5.1 后端实现

**模块结构**
```
backend/
└── eladmin-system/
    └── src/main/java/me/zhengjie/modules/footprint/
        ├── domain/Footprint.java              // 实体类
        ├── repository/FootprintRepository.java // 数据访问层
        ├── service/FootprintService.java      // 服务接口
        ├── service/impl/FootprintServiceImpl.java
        ├── service/dto/FootprintDTO.java
        ├── service/dto/FootprintCreateDTO.java
        ├── service/dto/FootprintUpdateDTO.java
        ├── rest/FootprintController.java      // REST控制器
        └── service/mapstruct/FootprintMapper.java
```

**关键技术**
- Spring Data JPA：数据持久化
- MapStruct：DTO与实体转换
- Validation：参数校验
- Swagger/OpenAPI：API文档

### 5.2 前端实现

**依赖包**
```yaml
dependencies:
  amap_flutter_map: ^3.0.0    # 高德地图 Flutter 插件
  amap_flutter_base: ^3.0.0    # 高德地图基础库
  http: ^1.1.0                 # HTTP 请求
  intl: ^0.18.0                # 日期格式化
```

**高德地图配置**
- 使用 Web端 API Key
- 通过项目配置文件或环境变量管理

---

## 6. 错误处理

| 场景 | 处理方式 |
|------|----------|
| 未登录（401） | 跳转到登录页面，提示"请先登录" |
| 无权限访问（403） | 显示"无权访问此数据" |
| API 请求失败 | 显示友好提示，提供重试按钮 |
| 地理编码失败 | 提示用户手动输入城市名称 |
| 重复添加同一城市（同日期） | 提示"该城市在同一天已标记" |
| 网络超时 | 显示"网络连接失败，请检查网络" |
| 日期格式错误 | 前端校验，确保格式正确 |
| 参数缺失 | 后端返回 400 错误，前端显示具体字段提示 |

### 6.1 认证流程

1. 用户访问足迹地图页面
2. 前端检查本地存储的 Token 是否存在且有效
3. 如果未登录，跳转到登录页面
4. 登录成功后，保存 Token 并跳转回足迹地图页面
5. 所有 API 请求都在 Header 中携带：`Authorization: Bearer {token}`

---

## 7. 后续扩展点

1. **足迹分组**：支持按"旅行"分组，一次旅行包含多个足迹
2. **照片和备注**：用户可以为足迹添加照片和文字备注
3. **数据导出**：支持导出为 KML/GPX 格式，可在其他地图应用中查看
4. **统计功能**：显示已覆盖省份数量、城市数量、旅行时间跨度等
5. **足迹分享**：用户可以将自己的足迹生成分享链接，让他人查看
