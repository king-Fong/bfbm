# 使用官方 Go 语言基础镜像
FROM golang:latest as builder

# 设置工作目录
WORKDIR /app

# 复制 go.* 文件，用于缓存依赖
COPY go.* ./
RUN go mod download

# 复制源代码
COPY . .

# 构建 Go 应用
RUN go build -o /my-go-app

# 使用 scratch 作为基础镜像
FROM scratch

# 复制构建好的应用
COPY --from=builder /my-go-app /my-go-app

# 暴露端口
EXPOSE 8080

# 运行应用
CMD ["/my-go-app"]