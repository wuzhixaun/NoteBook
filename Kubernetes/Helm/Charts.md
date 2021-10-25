# Charts

> Helm 使用一种名为 charts 的包格式，一个 chart 是描述一组相关的 Kubernetes 资源的文件集合，单个 chart 可能用于部署简单的应用，比如 memcached pod，或者复杂的应用，比如一个带有 HTTP 服务、数据库、缓存等等功能的完整 web 应用程序。
>
> Charts 是创建在特定目录下面的文件集合，然后可以将它们打包到一个版本化的存档中来部署。接下来我们就来看看使用 Helm 构建 charts 的一些基本方法

# 文件结构

chart 被组织为一个目录中的文件集合，目录名称就是 chart 的名称（不包含版本信息），下面是一个 WordPress 的 chart，会被存储在 `wordpress/` 目录下面，基本结构如下所示：

``` tex
wordpress/
  Chart.yaml          # 包含当前 chart 信息的 YAML 文件
  LICENSE             # 可选：包含 chart 的 license 的文本文件
  README.md           # 可选：一个可读性高的 README 文件
  values.yaml         # 当前 chart 的默认配置 values
  values.schema.json  # 可选: 一个作用在 values.yaml 文件上的 JSON 模式
  charts/             # 包含该 chart 依赖的所有 chart 的目录
  crds/               # Custom Resource Definitions
  templates/          # 模板目录，与 values 结合使用时，将渲染生成 Kubernetes 资源清单文件
  templates/NOTES.txt # 可选: 包含简短使用使用的文本文件
```

# Chart.yaml 

``` tex
apiVersion: chart API 版本 (必须)
name: chart 名 (必须)
version: SemVer 2版本 (必须)
kubeVersion: 兼容的 Kubernetes 版本 (可选)
description: 一句话描述 (可选)
type: chart 类型 (可选)
keywords:
  - 当前项目关键字集合 (可选)
home: 当前项目的 URL (可选)
sources:
  - 当前项目源码 URL (可选)
dependencies: # chart 依赖列表 (可选)
  - name: chart 名称 (nginx)
    version: chart 版本 ("1.2.3")
    repository: 仓库地址 ("https://example.com/charts")
maintainers: # (可选)
  - name: 维护者名字 (对每个 maintainer 是必须的)
    email: 维护者的 email (可选)
    url: 维护者 URL (可选)
icon: chart 的 SVG 或者 PNG 图标 URL (可选).
appVersion: 包含的应用程序版本 (可选). 不需要 SemVer 版本
deprecated: chart 是否已被弃用 (可选, boolean)
```

## version

> 每个 chart 都必须有一个版本号，版本必须遵循 `SemVer2` 标准，和 Helm Classic 不同，Kubernetes Helm 使用版本号作为 release 的标记，仓库中的软件包通过名称加上版本号来标识的。

ex: 例如，将一个 nginx 的 chart 包 version 字段设置为：1.2.3，则 chart 最终名称为：`nginx-1.2.3.tgz`

## apiVersion

> 对于 Helm 3 以上的版本 `apiVersion` 字段应该是 `v2`，之前版本的 Chart 应该设置为1，并且也可以有 Helm 3 进行安装。



## type

> `type` 字段定义 chart 的类型，可以定义两种类型：应用程序（application）和库（library）。应用程序是默认的类型，它是一个可以完整操作的标准 chart，库或者辅助类 chart 为 chart 提供了一些实用的功能，library 不同于应用程序 chart，因为它没有资源对象，所以无法安装。



# LICENSE, README 和 NOTES

> Chart 还可以包含用于描述 chart 的安装、配置、用法和许可证书的文件。
>
> LICENSE 是一个纯文本文件，其中包含 chart 的许可证书。chart 可以包含一个许可证书，因为它可能在模板中具有编程逻辑，所以不只是配置，如果需要，chart 还可以为应用程序提供单独的 license(s)。
>
> Chart 的 README 文件应该采用 Markdown（README.md）格式，并且通常应该包含如下的一些信息：
>
> - chart 提供的应用程序的描述信息
> - 运行 chart 的任何先决条件或者要求
> - `values.yaml` 和默认值中的一些选项说明
> - 与 chart 的安装或配置有关的任何其他信息

# 依赖

> 在 Helm 中，一个 chart 包可能会依赖许多其他的 chart。这些依赖关系可以使用 `Chart.yaml` 中的依赖关系字段动态链接，也可以引入到 `charts/` 目录手动进行管理。

#### 使用 `dependencies` 字段管理依赖

- `name` 字段是所依赖的 chart 的名称
- `version` 字段是依赖的 chart 版本
- `repository` 字段是 chart 仓库的完整 URL，不过需要注意，必须使用 `helm repo add` 在本地添加该 repo
- `alias `为依赖 chart 添加别名将使用别名作为依赖的名称。在需要访问其他名称的 chart 情况下，就可以使用别名

``` yaml
dependencies:
  - name: apache
    version: 1.2.3
    repository: https://example.com/charts
  - name: mysql
    version: 3.2.1
    repository: https://another.example.com/charts
    alias: new-subchart-2
```

运行 `helm dependency update` 来更新依赖项





# TEMPLATES 和 VALUES

Helm Chart 模板是用 [Go template 语言](https://golang.org/pkg/text/template/) 进行编写的，另外还额外增加了(【Sprig】](https://github.com/Masterminds/sprig)库中的50个左右的附加模板函数和一些其他[专用函数](https://helm.sh/docs/howto/charts_tips_and_tricks/)。

所有模板文件都存储在 chart 的 `templates/` 目录下面，当 Helm 渲染 charts 的时候，它将通过模板引擎传递该目录中的每个文件。模板的 `Values` 可以通过两种方式提供：

- Chart 开发人员可以在 chart 内部提供一个名为 `values.yaml` 的文件，该文件可以包含默认的 values 值内容。
- Chart 用户可以提供包含 values 值的 YAML 文件，可以在命令行中通过 `helm install` 来指定该文件。

当用户提供自定义 values 值的时候，这些值将覆盖 chart 中 `values.yaml` 文件中的相应的值。