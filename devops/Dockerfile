FROM golang:latest

# 环境变量
ENV GO111MODULE=on \
    GOPROXY=https://goproxy.cn,direct \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

#工作目录
WORKDIR /bfbm-app

# 将代码复制到容器中
COPY ../ .

# 将我们的代码编译成二进制可执行文件app
RUN go build main.go

# 暴露端口
EXPOSE 9080
ENTRYPOINT ["../main"]
