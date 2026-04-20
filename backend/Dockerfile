# syntax=docker/dockerfile:1.4
FROM maven:3.9-eclipse-temurin-17-alpine AS builder

WORKDIR /app

# 设置 Maven 使用阿里云镜像
COPY settings.xml /usr/share/maven/ref/settings.xml

# 复制所有文件
COPY pom.xml .
COPY grid-common grid-common
COPY grid-tools grid-tools
COPY grid-app grid-app

# 从 pom.xml 中移除 grid-admin 模块（临时，直到编译问题解决）
RUN sed -i '/<module>grid-admin<\/module>/d' pom.xml

# 下载依赖 - 使用缓存挂载持久化 Maven 本地仓库
RUN --mount=type=cache,target=/root/.m2 \
    mvn dependency:go-offline -B

# 构建项目 - 使用缓存挂载
RUN --mount=type=cache,target=/root/.m2 \
    mvn clean package -DskipTests

# 运行时镜像
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# 安装时区
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata

# 复制 JAR 文件 - 使用 grid-app 作为主应用（exec classifier）
COPY --from=builder /app/grid-app/target/grid-app-2.7-exec.jar app.jar

# 创建日志目录
RUN mkdir -p /app/logs

EXPOSE 8000

# 设置 JVM 参数
ENV JAVA_OPTS="-Xms512m -Xmx1024m"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar app.jar"]
