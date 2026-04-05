FROM maven:3.9-eclipse-temurin-17-alpine AS builder

WORKDIR /app

# 设置 Maven 使用阿里云镜像
COPY settings.xml /usr/share/maven/ref/settings.xml

# 复制所有 pom.xml 文件
COPY pom.xml .
COPY eladmin-common/pom.xml eladmin-common/
COPY eladmin-logging/pom.xml eladmin-logging/
COPY eladmin-system/pom.xml eladmin-system/
COPY eladmin-tools/pom.xml eladmin-tools/
COPY eladmin-generator/pom.xml eladmin-generator/

# 下载依赖 (如果 pom.xml 没变，这一层会被缓存)
RUN mvn dependency:go-offline -B

# 复制源码
COPY eladmin-common/src eladmin-common/src
COPY eladmin-logging/src eladmin-logging/src
COPY eladmin-system/src eladmin-system/src
COPY eladmin-tools/src eladmin-tools/src
COPY eladmin-generator/src eladmin-generator/src

# 构建项目
RUN mvn clean package -DskipTests

# 运行时镜像
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# 安装时区
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata

# 复制 JAR 文件 - 使用 eladmin-system 作为主应用
COPY --from=builder /app/eladmin-system/target/eladmin-system-2.7.jar app.jar

# 创建日志目录
RUN mkdir -p /app/logs

EXPOSE 8000

# 设置 JVM 参数
ENV JAVA_OPTS="-Xms512m -Xmx1024m"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar app.jar"]
