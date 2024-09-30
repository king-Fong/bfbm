# 使用官方 Go 语言基础镜像
FROM golang:latest as builder

ENV GO111MODULE=on \
    GOPROXY=https://goproxy.cn,https://mirrors.aliyun.com/goproxy/,https://goproxy.tuna.tsinghua.edu.cn,direct \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

# 设置工作目录
WORKDIR /app

# 复制源代码
COPY . .

RUN go mod download

# 构建 Go 应用
RUN go build -o /my-go-app

# 使用 scratch 作为基础镜像
FROM alpine:3.14.2

# 复制构建好的应用
COPY --from=builder /my-go-app /usr/local/bin/my-go-app

# 暴露端口
EXPOSE 9080

# 运行应用
CMD ["/my-go-app"]