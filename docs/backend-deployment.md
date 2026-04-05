# Littlegrid Backend 部署文档

## 环境要求

| 组件 | 版本要求 | 说明 |
|------|----------|------|
| JDK | 17+ | Java 运行环境 |
| Maven | 3.9+ | 构建工具 |
| MySQL | 8.0+ | 主数据库 |
| Redis | 7.x | 缓存、Token 存储 |

---

## 一、数据库部署

### 1.1 MySQL 安装

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install mysql-server
sudo mysql_secure_installation
```

**CentOS/RHEL:**
```bash
sudo yum install mysql-server
sudo systemctl start mysqld
sudo mysql_secure_installation
```

**Docker 方式:**
```bash
docker run -d \
  --name mysql \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=your_password \
  -e MYSQL_DATABASE=littlegrid \
  -v mysql_data:/var/lib/mysql \
  mysql:8.0 \
  --character-set-server=utf8mb4 \
  --collation-server=utf8mb4_general_ci
```

### 1.2 创建数据库

```bash
# 登录 MySQL
mysql -u root -p

# 创建数据库
CREATE DATABASE littlegrid DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

# 创建用户（可选）
CREATE USER 'littlegrid'@'%' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON littlegrid.* TO 'littlegrid'@'%';
FLUSH PRIVILEGES;

exit;
```

### 1.3 导入 SQL 脚本

```bash
cd /path/to/littlegrid/backend

# 先导入 eladmin 系统表
mysql -u root -p littlegrid < sql/eladmin.sql

# 再导入业务表
mysql -u root -p littlegrid < sql/business_tables.sql
```

---

## 二、Redis 部署

### 2.1 Redis 安装

**Ubuntu/Debian:**
```bash
sudo apt install redis-server
sudo systemctl enable redis-server
sudo systemctl start redis-server
```

**CentOS/RHEL:**
```bash
sudo yum install redis
sudo systemctl enable redis
sudo systemctl start redis
```

**Docker 方式:**
```bash
docker run -d \
  --name redis \
  -p 6379:6379 \
  -v redis_data:/data \
  redis:7-alpine \
  redis-server --appendonly yes
```

### 2.2 Redis 配置（可选）

编辑配置文件 `/etc/redis/redis.conf`：

```conf
# 绑定地址（生产环境建议绑定内网IP）
bind 127.0.0.1

# 设置密码
requirepass your_redis_password

# 持久化
appendonly yes
appendfsync everysec
```

重启 Redis：
```bash
sudo systemctl restart redis-server
```

### 2.3 验证 Redis

```bash
redis-cli ping
# 输出: PONG

# 如有密码
redis-cli -a your_redis_password ping
```

---

## 三、应用配置

### 3.1 修改配置文件

编辑 `eladmin-system/src/main/resources/config/application.yml`：

```yaml
# 服务器端口
server:
  port: 8000

spring:
  # 数据源配置
  datasource:
    url: jdbc:mysql://localhost:3306/littlegrid?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai&useSSL=false
    username: root
    password: your_mysql_password
    driver-class-name: com.mysql.cj.jdbc.Driver
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      idle-timeout: 30000
      connection-timeout: 30000

  # Redis 配置
  data:
    redis:
      host: localhost
      port: 6379
      password:        # 如有密码填写
      database: 0
      timeout: 10000

  # JPA 配置
  jpa:
    hibernate:
      ddl-auto: none
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQLDialect

# JWT 配置
jwt:
  header: Authorization
  secret: your_jwt_secret_key_must_be_at_least_256_bits_long
  expiration: 604800  # 7天（秒）

# 日志配置
logging:
  level:
    root: INFO
    me.zhengjie: DEBUG
  file:
    name: logs/eladmin.log
```

### 3.2 环境变量方式（推荐生产环境）

创建 `.env` 文件或设置环境变量：

```bash
export MYSQL_HOST=localhost
export MYSQL_PORT=3306
export MYSQL_DB=littlegrid
export MYSQL_USER=root
export MYSQL_PASSWORD=your_mysql_password
export REDIS_HOST=localhost
export REDIS_PORT=6379
export REDIS_PASSWORD=your_redis_password
```

在配置中使用：
```yaml
spring:
  datasource:
    url: jdbc:mysql://${MYSQL_HOST:localhost}:${MYSQL_PORT:3306}/${MYSQL_DB:littlegrid}
    username: ${MYSQL_USER:root}
    password: ${MYSQL_PASSWORD}
```

---

## 四、Spring Boot 部署

### 4.1 编译项目

```bash
cd /path/to/littlegrid/backend

# 编译（跳过测试）
mvn clean package -DskipTests

# 或安装到本地仓库
mvn clean install -DskipTests
```

### 4.2 开发环境运行

```bash
# 方式一：Maven 运行
mvn spring-boot:run -pl eladmin-system

# 方式二：指定配置文件运行
mvn spring-boot:run -pl eladmin-system -Dspring-boot.run.arguments="--spring.profiles.active=dev"
```

### 4.3 生产环境部署

**方式一：JAR 包运行**

```bash
# 后台运行
nohup java -jar eladmin-system/target/eladmin-system-2.7.jar \
  --spring.profiles.active=prod \
  > logs/app.log 2>&1 &

# 查看日志
tail -f logs/app.log
```

**方式二：Systemd 服务**

创建服务文件 `/etc/systemd/system/littlegrid-backend.service`：

```ini
[Unit]
Description=Littlegrid Backend Service
After=mysql.service redis.service

[Service]
Type=simple
User=app
WorkingDirectory=/opt/littlegrid-backend
ExecStart=/usr/bin/java -jar eladmin-system-2.7.jar --spring.profiles.active=prod
ExecStop=/bin/kill -15 $MAINPID
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

启动服务：
```bash
sudo systemctl daemon-reload
sudo systemctl enable littlegrid-backend
sudo systemctl start littlegrid-backend
sudo systemctl status littlegrid-backend
```

**方式三：Docker 部署**

创建 `Dockerfile`：

```dockerfile
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

COPY eladmin-system/target/eladmin-system-2.7.jar app.jar

ENV TZ=Asia/Shanghai
ENV JAVA_OPTS="-Xms512m -Xmx1024m"

EXPOSE 8000

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

构建并运行：
```bash
# 构建
docker build -t littlegrid-backend:latest .

# 运行
docker run -d \
  --name littlegrid-backend \
  -p 8000:8000 \
  -e SPRING_DATASOURCE_URL=jdbc:mysql://host.docker.internal:3306/littlegrid \
  -e SPRING_DATASOURCE_PASSWORD=your_mysql_password \
  -e SPRING_DATA_REDIS_HOST=host.docker.internal \
  -v logs:/app/logs \
  littlegrid-backend:latest
```

### 4.4 Docker Compose 完整部署

创建 `docker-compose.yml`：

```yaml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: littlegrid-mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: your_mysql_password
      MYSQL_DATABASE: littlegrid
    volumes:
      - mysql_data:/var/lib/mysql
      - ./sql:/docker-entrypoint-initdb.d
    ports:
      - "3306:3306"
    command: --character-set-server=utf8mb4 --collation-server=utf8mb4_general_ci

  redis:
    image: redis:7-alpine
    container_name: littlegrid-redis
    restart: always
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes

  backend:
    image: littlegrid-backend:latest
    container_name: littlegrid-backend
    restart: always
    depends_on:
      - mysql
      - redis
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/littlegrid?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai
      SPRING_DATASOURCE_USERNAME: root
      SPRING_DATASOURCE_PASSWORD: your_mysql_password
      SPRING_DATA_REDIS_HOST: redis
    ports:
      - "8000:8000"
    volumes:
      - logs:/app/logs

volumes:
  mysql_data:
  redis_data:
  logs:
```

启动：
```bash
docker-compose up -d
```

---

## 五、Nginx 反向代理（可选）

### 5.1 Nginx 配置

创建 `/etc/nginx/sites-available/littlegrid`：

```nginx
upstream backend {
    server 127.0.0.1:8000;
    keepalive 32;
}

server {
    listen 80;
    server_name your-domain.com;

    # 强制 HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;

    # SSL 证书
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    # SSL 配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;

    # API 代理
    location /api/ {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 60s;
        proxy_read_timeout 60s;
    }

    # 认证接口
    location /auth/ {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # 健康检查
    location /actuator/health {
        proxy_pass http://backend;
        proxy_set_header Host $host;
    }
}
```

启用配置：
```bash
sudo ln -s /etc/nginx/sites-available/littlegrid /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## 六、验证部署

### 6.1 健康检查

```bash
curl http://localhost:8000/actuator/health
# 期望输出: {"status":"UP"}
```

### 6.2 API 测试

```bash
# 用户登录
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"123456"}'

# 期望输出: JWT Token
```

### 6.3 管理后台

浏览器访问：`http://localhost:8000`

默认账号：
- 用户名：`admin`
- 密码：`123456`

---

## 七、常见问题

| 问题 | 解决方案 |
|------|----------|
| 端口被占用 | `lsof -i:8000` 查看并 kill 进程 |
| MySQL 连接失败 | 检查 MySQL 服务状态、用户名密码、防火墙 |
| Redis 连接失败 | `redis-cli ping` 测试，检查密码配置 |
| 内存不足 | 调整 JVM 参数 `-Xms256m -Xmx512m` |
| 启动超时 | 检查数据库连接池配置，增加超时时间 |

---

## 八、监控与日志

### 8.1 日志位置

- 应用日志：`logs/eladmin.log`
- 错误日志：`logs/error.log`

### 8.2 日志查看

```bash
# 实时查看
tail -f logs/eladmin.log

# 查看错误
grep ERROR logs/eladmin.log
```

### 8.3 监控端点

- 健康检查：`/actuator/health`
- 指标：`/actuator/metrics`
- 环境：`/actuator/env`