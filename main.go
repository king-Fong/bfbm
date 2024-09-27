package main

import "github.com/gin-gonic/gin"

func main() {
	ginServer := gin.Default()
	ginServer.GET("/hello", func(context *gin.Context) {
		context.JSON(200, gin.H{"message": "ok!", "code": "200"})
	})
	if err := ginServer.Run(`:8888`); err != nil {
		panic(err)
	}

}
