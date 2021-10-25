# Helm

**Kubernetes 包管理工具**

> Helm 可以帮助我们管理 Kubernetes 应用程序 - Helm Charts 可以定义、安装和升级复杂的 Kubernetes 应用程序，Charts 包很容易创建、版本管理、分享和分布。Helm 对于 Kubernetes 来说就相当于 yum 对于 Centos 来说，如果没有 yum 的话，我们在 Centos 下面要安装一些应用程序是极度麻烦的，同样的，对于越来越复杂的 Kubernetes 应用程序来说，如果单纯依靠我们去手动维护应用程序的 YAML 资源清单文件来说，成本也是巨大的。接下来我们就来了解了 Helm 的使用方法。

## 安装

> 首先当然需要一个可用的 Kubernetes 集群，然后在我们使用 Helm 的节点上已经配置好可以通过 kubectl 访问集群，因为 Helm 其实就是读取的 kubeconfig 文件来访问集群的
>
> [Helm下载链接](https://github.com/helm/helm/releases)
>
> 下载到本地解压后，将 helm 二进制包文件移动到任意的 PATH 路径下即可：

``` shell
$ helm version

version.BuildInfo{Version:"v3.6.1", GitCommit:"61d8e8c4a6f95540c15c6a65f36a6dd0a45e7a2f", GitTreeState:"clean", GoVersion:"go1.16.5"}

```

 Helm 客户端准备好了，我们就可以添加chart 仓库，当然最常用的就是官方的 Helm stable charts 仓库，但是由于官方的 charts 仓库地址需要科学上网，我们可以使用微软的 charts 仓库代替：

``` shell
$ helm repo add stable http://mirror.azure.cn/kubernetes/charts/
$ helm repo list
NAME            URL
stable          http://mirror.azure.cn/kubernetes/charts/
```

安装完成后可以用 search 命令来搜索可以安装的 chart 包：

``` shell
helm search repo stable // 查询
helm repo list  // 列出所有的资源
helm show values xxx 命令来查看一个 chart 包的所有可配置的参数选项：
```



# 升级和回滚

当新版本的 chart 包发布的时候，或者当你要更改 release 的配置的时候，你可以使用 `helm upgrade` 命令来操作。升级需要一个现有的 release，并根据提供的信息对其进行升级。因为 Kubernetes charts 可能很大而且很复杂，Helm 会尝试以最小的侵入性进行升级，它只会更新自上一版本以来发生的变化：

``` shell
$ helm upgrade -f panda.yaml mysql stable/mysql
helm upgrade -f panda.yaml mysql stable/mysql
Release "mysql" has been upgraded. Happy Helming!
NAME: mysql
LAST DEPLOYED: Fri Dec  6 21:06:11 2019
NAMESPACE: default
STATUS: deployed
REVISION: 2
...
```

我们可以使用 `helm get values` 来查看新设置是否生效：

``` shell
helm get values mysql
USER-SUPPLIED VALUES:
mysqlDatabase: user0db
mysqlPassword: user0pwd
mysqlRootPassword: passw0rd
mysqlUser: user0
persistence:
  enabled: false
```

`helm get` 命令是查看集群中 release 的非常有用的命令，正如我们在上面看到的，它显示了 `panda.yaml` 中的新配置值被部署到了集群中，现在如果某个版本在发布期间没有按计划进行，那么可以使用 `helm rollback [RELEASE] [REVISION]` 命令很容易回滚到之前的版本：

``` shell
 helm rollback mysql 1
```

可以看到 values 配置已经回滚到之前的版本了。上面的命令回滚到了 release 的第一个版本，每次进行安装、升级或回滚时，修订号都会加 1，第一个修订号始终为1，我们可以使用 `helm history [RELEASE]` 来查看某个版本的修订号。



> 可以运行 `helm <command> --help` 来查看，这里我们介绍几个有用的参数：
>
> - `--timeout`: 等待 Kubernetes 命令完成的时间，默认是 300（5分钟）
> - `--wait`: 等待直到所有 Pods 都处于就绪状态、PVCs 已经绑定、Deployments 具有处于就绪状态的最小 Pods 数量（期望值减去 maxUnavailable）以及 Service 有一个 IP 地址，然后才标记 release 为成功状态。它将等待与 `--timeout` 值一样长的时间，如果达到超时，则 release 将标记为失败。注意：在 Deployment 将副本设置为 1 并且作为滚动更新策略的一部分，maxUnavailable 未设置为0的情况下，`--wait` 将返回就绪状态，因为它已满足就绪状态下的最小 Pod 数量
> - `--no-hooks`: 将会跳过命令的运行 hooks
> - `--recreate-pods`: 仅适用于 upgrade 和 rollback，这个标志将导致重新创建所有的 Pods。（Helm3 中启用了）