# syntax=docker/dockerfile:1.4
FROM node:18-alpine AS builder

WORKDIR /app

# 复制 package.json 和 package-lock.json
COPY package.json package-lock.json* ./

# 安装依赖 - 使用缓存挂载加速
RUN --mount=type=cache,target=/root/.npm \
    npm install --registry=https://registry.npmmirror.com

# 复制源码
COPY . .

# 构建生产版本
RUN npm run build:prod

# 运行时镜像
FROM nginx:alpine

# 复制构建产物
COPY --from=builder /app/dist /usr/share/nginx/html

# 复制 nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8001

CMD ["nginx", "-g", "daemon off;"]