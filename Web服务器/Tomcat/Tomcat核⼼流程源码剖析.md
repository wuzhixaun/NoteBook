Tomcat中的各容器组件都会涉及创建、销毁等，因此设计了⽣命周期接⼝Lifecycle进⾏统⼀规范，各容器组件实现该接⼝

# 一、**Lifecycle**接口

## 1.1 Lifecycle⽣命周期接⼝主要⽅法示意

![image-20211206103359775](https://cdn.wuzx.cool/image-20211206103359775.png)

## 1.2 Lifecycle⽣命周期接⼝继承体系示意

![image-20211206104255371](https://cdn.wuzx.cool/image-20211206104255371.png)

# 二、**核⼼流程源码剖析**

源码追踪部分我们关注两个流程：`Tomcat启动流程`和`Tomcat请求处理流程`

## 2.1 Tomcat启动流程

![image-20211206105932681](https://cdn.wuzx.cool/image-20211206105932681.png)

## 2.2. Tomcat请求处理流程

### 2.2.1 请求处理流程分析 

