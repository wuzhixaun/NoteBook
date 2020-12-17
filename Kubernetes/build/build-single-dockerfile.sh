#!/bin/sh

## 通用脚本，可以直接复制
## 适合单个 dockerfile 工程,差别在 docker build 语句
## 1. 单个dockerfile，适合不同环境打包步骤一致，只是变量不一致的场景
## 2. 多个dockerfile，适合不同环境打包步骤不一样的场景


## 构建docker镜像并推送到阿里云
export PATH=/usr/local/bin/:$PATH
export LANG=zh_CN.UTF-8
export LANGUAGE=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8
export TZ="Asia/Shanghai"


# 执行出错立即退出
set -e

# 根据构建参数得到docker的name
dockerLocalName=${dockerName}-${envType}
dockerRegistryName=registry.cn-hangzhou.aliyuncs.com/wuzhixuan/${dockerLocalName}

# 切换到 docker 组
newgrp docker

# 登录阿里云
docker login --username=吴志旋sy -p wuzhixuan95 registry.cn-hangzhou.aliyuncs.com

# 回显命令
set -x

# profile
if [ -z $1 ]
then
   profileName=${envType}
else
   profileName=$1
   echo "当前profile为 ${profileName}"
fi


# 根据git版本号获的buildNumber
buildNumber=$(git rev-parse HEAD)

# 构建新的镜像
docker build . -t ${dockerLocalName}:${buildNumber} -f Dockerfile --build-arg envType=${profileName}

docker tag  ${dockerLocalName}:${buildNumber} ${dockerRegistryName}:latest
docker push ${dockerRegistryName}:latest

docker tag  ${dockerLocalName}:${buildNumber} ${dockerRegistryName}:${buildNumber}
docker push ${dockerRegistryName}:${buildNumber}

# 回复之前修改的配置
git reset --hard
git clean -df