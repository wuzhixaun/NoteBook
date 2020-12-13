[Toc]

​	数据卷 emptydir,是本地存储，pod重启，数据不存在了，需要对数据进行`持久化存储`

### 一、nfs（网络存储）

+ pod重启，数据还是存在的





## 二、PV和PVC

+ PV：持久化存储，对存储资源进行抽象，对外提供可以进行调用的地方(生产者)
+ PVC：用户调用，不需要关心内部实现细节(消费者)

### 1、 实现流程

![PV和PVC](../images/PV和PVC.png)

### 2、PV

```
apiVerison：v1
kind: PersistentVolum
metadate:
  name: my-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWiteMany
  nfs:
  	path: /data/nfs
  	service: 192.168.44.134
```

### 3、PVC

