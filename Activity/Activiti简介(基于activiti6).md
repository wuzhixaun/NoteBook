# # 引擎Service接口

## 1.RespositoryService

> 流程仓库Service，用于管理流程仓库，例如：部署，删除，读取流程资源\



## 2.IdentifyService(版本7之后删除)

> 身份Service，可以管理和查询用户，组之间的关系



## 3. RuntimeService

> 运行时Service，可以处理所有正在运行状态的流程实例，任务等



## 4. TaskService

> 任务Service，用于管理，查询任务，例如：签收，办理，指派等



## 5.FormService(版本7之后删除)

> 表单Service，用于读取和流程任务相关的表单数据



## 6.HistoryService

> 历史Sercice，可以查询所有历史数据，例如：流程实例，任务，活动，变量，附件等



## 7.ManagementService

> 引擎管理Service，和具体业务无关，主要是可以查询引擎配置，数据库，作业等



# 流程设计器

- **`Activiti Designer（推荐）`**

> Activiti官方专为Eclipse开发工具提供的一款流程设计器插件，可实现设计.bpmn图，支持效果较好，推荐使用，需安装Eclipse开发工具

- **`actiBPM`**

> IDEA开发工具自带的一款流程设计器插件，可实现设计.bpmn图，支持效果较差，不推荐使用。

- **`Activiti-Modeler（推荐）`**

> Activiti默认的一款在线流程设计器，可在线设计.bpmn流程图文件，需要集成Activiti-Model，然后项目运行后可以在线设计流程图，推荐使用。

- **`camunda-modeler（推荐）`**

> 基于 bpmn.io的面向 BPMN DMN和CMMN的集成建模解决方案，camunda-modeler是一款外部流程设计器，同普通安装软件一样安装完后双击.exe程序即可使用，也可以通过IDEA安装外部Tool使用。

+ **`activiti bpmn visualizer（推荐）`**

> 也是可以使用idea插件，个人感觉还是很方便的

# 应用现状

> 国内使用activiti的比较多



# Activiti组件

+ **`activiti Engine`**

> + 最核心模块
> + 解析，执行，创建，管理（任务流程实例），查询历史记录

+ **`activiti modeler`**

> 模型设计器

+ **`activiti designer`**

> 也是流程设计器

+ **`activiti explorer`**

> 用来管理仓库，用户，组，启动流程，任务管理等，提供REST风格的API

+ **`activiti rest`**

> 提供restful风格的服务，允许客户端以json的方式，语音穷拐的rest api交互，以此跨平台，跨语言



# Api查询

 - asc
  - desc
  - count
  - list
  - single
  - listPage
  - singleResult
  - native
  - 可以自己写sql