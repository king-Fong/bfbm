package main

import (
	"bfbm-go/internal/config"
	"fmt"
	"github.com/gin-gonic/gin"
	"os"
)

func main() {
	//加载配置
	cfg, err := config.LoadConfig()
	if err != nil {
		fmt.Printf("Fail to read file: %v", err)
		os.Exit(1)
	}
	port := cfg.Section("server").Key("http_port").String()
	fmt.Println("port:", cfg.Section("server").Key("http_port").String())

	//启动web服务
	ginServer := gin.Default()
	//测试接口
	ginServer.GET("/hello", func(context *gin.Context) {
		context.JSON(200, gin.H{"message": "ok!", "code": "200"})
	})

	if err = ginServer.Run(fmt.Sprint(`:`, port)); err != nil {
		panic(err)
	}

}
