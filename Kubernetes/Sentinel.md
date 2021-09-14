![Sentinel Logo](https://user-images.githubusercontent.com/9434884/43697219-3cb4ef3a-9975-11e8-9a9c-73f4f537442d.png)

# 1、Sentinel: 分布式系统的流量防卫兵

# 2、Sentinel 是什么？

随着微服务的流行，服务和服务之间的稳定性变得越来越重要。Sentinel 以流量为切入点，从流量控制、熔断降级、系统负载保护等多个维度保护服务的稳定性。

Sentinel 具有以下特征:

- **丰富的应用场景**：Sentinel 承接了阿里巴巴近 10 年的双十一大促流量的核心场景，例如秒杀（即突发流量控制在系统容量可以承受的范围）、消息削峰填谷、集群流量控制、实时熔断下游不可用应用等。
- **完备的实时监控**：Sentinel 同时提供实时的监控功能。您可以在控制台中看到接入应用的单台机器秒级数据，甚至 500 台以下规模的集群的汇总运行情况。
- **广泛的开源生态**：Sentinel 提供开箱即用的与其它开源框架/库的整合模块，例如与 Spring Cloud、Apache Dubbo、gRPC、Quarkus 的整合。您只需要引入相应的依赖并进行简单的配置即可快速地接入 Sentinel。同时 Sentinel 提供 Java/Go/C++ 等多语言的原生实现。
- **完善的 SPI 扩展机制**：Sentinel 提供简单易用、完善的 SPI 扩展接口。您可以通过实现扩展接口来快速地定制逻辑。例如定制规则管理、适配动态数据源等。

Sentinel 的主要特性：

![Sentinel-features-overview](https://user-images.githubusercontent.com/9434884/50505538-2c484880-0aaf-11e9-9ffc-cbaaef20be2b.png)

Sentinel 的开源生态：

![Sentinel-opensource-eco](https://user-images.githubusercontent.com/9434884/84338449-a9497e00-abce-11ea-8c6a-473fe477b9a1.png)



Sentinel 分为两个部分:

- 核心库（Java 客户端）不依赖任何框架/库，能够运行于所有 Java 运行时环境，同时对 Dubbo / Spring Cloud 等框架也有较好的支持。
- 控制台（Dashboard）基于 Spring Boot 开发，打包后可以直接运行，不需要额外的 Tomcat 等应用容器。

# 3、Docker部署 Sentinel

可以在GitHub官方网站 [Sentinel](https://github.com/alibaba/Sentinel/sentinel-dashboard) 下载源码包

## 3.1 编写Dockerfile

``` dockerfile
FROM adoptopenjdk/openjdk11
MAINTAINER jackWu <627521884@qq.com>

mvn clean package
COPY ./target/sentinel-dashboard.jar sentinel-dashboard.jar

EXPOSE 8080

CMD java ${JAVA_OPTS} -jar sentinel-dashboard.jar
```

## 3.2 执行Dockerfile 构建docker镜像

```shell
docker build -t  wuzhixuan/sentinel-dashboard:latest .
```

## 3.3测试构建的docke镜像可行

```shell
docker run -d -p 8081:8080 --name sentinel-dashboard -e "JAVA_OPTS= -Dserver.port=8080 -Dcsp.sentinel.dashboard.server=localhost:8080 -Dsentinel.dashboard.auth.username=sentinel -Dsentinel.dashboard.auth.password=sentinel -Dserver.servlet.session.timeout=7200" wuzhixuan/sentinel-dashboard 
```

其实查看源文件可以设置 登录的用户名和密码 默认的用户名和密码都是`sentinel`

![image-20210903172740535](E:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20210903172740535.png)

然后你就可以访问部署好的

![image-20210903172815452](E:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20210903172815452.png)

## # 4. K8s部署 Sentinel

## 4.1流程

+ 我目前是直接使用的是jenkins pieline Jenkinsfile
+ 先将docker镜像push 阿里云 容器镜像服务 仓库 
+ 然后k8s拉取容器镜像自动部署



`Jenkinsfile`

``` yaml
def label = "slave-${UUID.randomUUID().toString()}"

podTemplate(label: label, containers: [
  containerTemplate(name: 'jdk-maven', image: 'appinair/jdk11-maven:latest', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'docker', image: 'docker:latest', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'kubectl', image: 'cnych/kubectl', command: 'cat', ttyEnabled: true)
], serviceAccount: 'jenkins-admin', volumes: [
  hostPathVolume(mountPath: '/home/jenkins/.kube', hostPath: '/root/.kube'),
  hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
]) {
  node(label) {
    def repo = checkout scm
    def gitCommit = repo.GIT_COMMIT
    def gitBranch = repo.GIT_BRANCH
    
    // 获取 git commit id 作为镜像标签
    def imageTag = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
    // 仓库地址
    def registryUrl = "registry-vpc.cn-shenzhen.aliyuncs.com"
    def imageEndpoint = "wuzhixuan/sentinel-dashboard"
    // 镜像
    def image = "${registryUrl}/${imageEndpoint}:latest"
    
    stage('单元测试') {
      echo "测试阶段"
    }
    
    stage('代码编译打包') {
      container('jdk-maven') {
        echo "代码编译打包阶段"
        sh "mvn clean package -Dmaven.test.skip=true"
      }
    }
    
    stage('构建 Docker 镜像') {
      withCredentials([usernamePassword(credentialsId: 'dock-auth-ali', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USER')]) {
          container('docker') {
            echo "3. 构建 Docker 镜像阶段"
            sh """
              docker login ${registryUrl} -u ${DOCKER_USER} -p ${DOCKER_PASSWORD}
              docker build -t ${image} .
              docker push ${image}
              """
          }
      }
    }

        stage('部署到k8s') {
          container('kubectl') {
            echo "部署到k8s集群"
            sh """
              sed -i 's#\$image#${image}#' deployment.yaml
              """
            kubernetesDeploy(enableConfigSubstitution: false, kubeconfigId: 'kubeconfig1', configs: 'deployment.yaml')
          }
        }
  }
}

```

k8s-sentinel.yaml

```yaml
# 外部访问服务
apiVersion: v1
kind: Service
metadata:
  namespace: kube-ops
  name: sentinel
  labels:
    app: sentinel
spec:
  ports:
    - protocol: TCP
      name: http
      port: 8080
      targetPort: 8080
      nodePort: 30007
  type: NodePort
  selector:
    app: sentinel
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: sentinel
  namespace: kube-ops
spec:
  serviceName: sentinel
  replicas: 1
  template:
    metadata:
      labels:
        app: sentinel
      annotations:
        pod.alpha.kubernetes.io/initialized: "true"
    spec:
      containers:
        - name: sentinel
          imagePullPolicy: Always
          image: $image
          resources:
            limits:
              memory: "1Gi"
              cpu: "1"
          ports:
            - containerPort: 8080
              name: client
          env:
            - name: TZ
              value: Asia/Shanghai
            - name: JAVA_OPTS
              value: "-Dserver.port=8080 -Dcsp.sentinel.dashboard.server=localhost:8080 -Dsentinel.dashboard.auth.username=sentinel -Dsentinel.dashboard.auth.password=sentinel -Dserver.servlet.session.timeout=7200"
  selector:
    matchLabels:
      app: sentinel
```



## 5.配置jenkins 

![image-20210903173751204](E:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20210903173751204.png)

这样就可以直接自动部署服务到k8s 

![image-20210903173837615](E:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20210903173837615.png)

