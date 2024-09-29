#!/bin/bash
set -e

DATE=$(date +%Y%m%d%H%M)
# 基础路径
BASE_PATH=/cmcf-cp
# 服务名称。同时约定部署服务的 jar 包名字也为它。
SERVER_NAME=cmcf-cp
# 环境变量
PROFILES_ACTIVE=$PROFILE
JAVA_MAX_RAM_PERCENTAGE=$ENV_JAVA_MAX_RAM_PERCENTAGE
JAVA_MIN_RAM_PERCENTAGE=$ENV_JAVA_MIN_RAM_PERCENTAGE
JAVA_INIT_RAM_PERCENTAGE=$ENV_JAVA_INIT_RAM_PERCENTAGE
SW_OFF=$ENV_SW_OFF
SW_OAP_ENDPOINT=$ENV_SW_OAP_ENDPOINT

# 当java版本大于8u191时，可以使用-XX:MinRAMPercentage（默认值50）、-XX:MaxRAMPercentage（默认值25）、-XX:InitialRAMPercentage 参数设置java应用堆内存大小。
# 当内存小于250M时，会使用MinRAMPercentage百分比，当内存大于250M时，会使用MaxRAMPercentage比例
if [ -z "$JAVA_MAX_RAM_PERCENTAGE" ]; then
  echo "[info] 环境变量中无 JAVA_MAX_RAM_PERCENTAGE 值，默认设置为 75.0"
  JAVA_MAX_RAM_PERCENTAGE="75.0"
fi

if [ -z "$JAVA_MIN_RAM_PERCENTAGE" ]; then
  echo "[info] 环境变量中无 JAVA_MIN_RAM_PERCENTAGE 值，默认设置为 80.0"
  JAVA_MIN_RAM_PERCENTAGE="80.0"
fi

if [ -z "$JAVA_INIT_RAM_PERCENTAGE" ]; then
  JAVA_INIT_RAM_PERCENTAGE="50.0"
fi

# heapError 存放路径
HEAP_ERROR_PATH=$BASE_PATH/cmcf/heapErrorLogs/$SERVER_NAME
# JVM 参数
JAVA_OPS="-XX:MaxRAMPercentage=$JAVA_MAX_RAM_PERCENTAGE -XX:MinRAMPercentage=$JAVA_MIN_RAM_PERCENTAGE -XX:InitialRAMPercentage=$JAVA_INIT_RAM_PERCENTAGE -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$HEAP_ERROR_PATH"
if [ -z "$SW_OFF" ]; then
  # 如果没有配置 skywalking 关闭的环境变量，就默认为开启
  JAVA_AGENT="-javaagent:$BASE_PATH/javaagent/skywalking-agent.jar"
else
  # 如果配置了这个环境变量，就认为关闭
  JAVA_AGENT=""
fi

# 停止：优雅关闭之前已经启动的服务
function stop() {
    echo "[stop] 开始停止 $BASE_PATH/$SERVER_NAME"
    PID=$(ps -ef | grep $BASE_PATH/$SERVER_NAME | grep -v "grep" | awk '{print $2}')
    # 如果 Java 服务启动中，则进行关闭
    if [ -n "$PID" ]; then
        # 正常关闭
        echo "[stop] $BASE_PATH/$SERVER_NAME 运行中，开始 kill [$PID]"
        kill -15 $PID
        # 等待最大 120 秒，直到关闭完成。
        for ((i = 0; i < 120; i++))
            do
                sleep 1
                PID=$(ps -ef | grep $BASE_PATH/$SERVER_NAME | grep -v "grep" | awk '{print $2}')
                if [ -n "$PID" ]; then
                    echo -e ".\c"
                else
                    echo '[stop] 停止 $BASE_PATH/$SERVER_NAME 成功'
                    break
                fi
		    done

        # 如果正常关闭失败，那么进行强制 kill -9 进行关闭
        if [ -n "$PID" ]; then
            echo "[stop] $BASE_PATH/$SERVER_NAME 失败，强制 kill -9 $PID"
            kill -9 $PID
        fi
    # 如果 Java 服务未启动，则无需关闭
    else
        echo "[stop] $BASE_PATH/$SERVER_NAME 未启动，无需停止"
    fi
}

# 启动：启动后端项目
function start() {
    # 开启启动前，打印启动参数
    echo "[start] 开始启动 $BASE_PATH/$SERVER_NAME"
    echo "[start] JAVA_OPS: $JAVA_OPS"
    echo "[start] JAVA_AGENT: $JAVA_AGENT"
    echo "[start] PROFILES: $PROFILES_ACTIVE"

    # 直接前台启动，让日志输出到控制台，保证云平台可以采集到
    if [ -z "$SW_OFF" ]; then
      # 如果没有配置 skywalking 关闭的环境变量，就默认为开启
      exec java -server $JAVA_OPS $JAVA_AGENT -Dskywalking.agent.service_name=$SERVER_NAME -Dskywalking.collector.backend_service=$SW_OAP_ENDPOINT -jar -Dspring.profiles.active=$PROFILES_ACTIVE -DHOST_NAME=$HOSTNAME $BASE_PATH/$SERVER_NAME.jar
    else
      # 如果配置了这个环境变量，就认为关闭
      exec java -server $JAVA_OPS $JAVA_AGENT -jar -Dspring.profiles.active=$PROFILES_ACTIVE -DHOST_NAME=$HOSTNAME $BASE_PATH/$SERVER_NAME.jar
    fi
}

# 部署
function deploy() {
    cd $BASE_PATH
    # 第一步：停止 Java 服务
    stop
    # 第二步：启动 Java 服务
    start
}

deploy
