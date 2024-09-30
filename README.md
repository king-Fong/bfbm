# bfbm

如何减少Dockerfile中FROM获取基础镜像的时间
答：先通过:docker pull [基础镜像]，这可以减少docker使用from命令重新从仓库拉取基础镜像的时间。

docker note:
一. 常见问题
问题：使用docker build -t goappcontainer .   ，总是构建失败，原因可能有下:
1. 可能是 Dockerfile中的FROM 拉取远程镜像的时候超时 
答：更换镜像源
2.  RUN go build -o /my-go-app报错 
```
=> ERROR [builder 5/5] RUN go build -o /my-go-app                                                                                                      0.3s
------
> [builder 5/5] RUN go build -o /my-go-app:
0.299 main.go:3:8: missing go.sum entry for module providing package github.com/gin-gonic/gin (imported by bfbm-go); to add:
0.299   go get bfbm-go
------
Dockerfile:19
--------------------
17 |
18 |     # 构建 Go 应用
19 | >>> RUN go build -o /my-go-app
20 |
21 |     # 使用 scratch 作为基础镜像
--------------------
ERROR: failed to solve: process "/bin/sh -c go build -o /my-go-app" did not complete successfully: exit code: 1
```
答： go.sum需要加入仓库管理，一并copy到docker镜像中


go mod vendor note:
1. 用于将依赖复制到vendor目录，保证本地依赖的稳定性。
2. 使用 go build -mod=vendor main.go 来指定本地依赖进行构建项目


gin 的一些使用格式
路径格式：user-list/
响应体:{"message": "success", "code": "200", "data": "data.."}