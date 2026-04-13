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
