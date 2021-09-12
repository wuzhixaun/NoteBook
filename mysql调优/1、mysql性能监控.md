  [TOC]

  # 一、逻辑架构



  ![2021-05-17-20-45-47-866332.png](https://cdn.nlark.com/yuque/0/2021/png/396745/1621255834321-a6b044d9-07f4-4330-8d05-2b654054a052.png?x-oss-process=image%2Fresize%2Cw_752)



  ![MySQL体系架构](https://gitee.com/bliub/phpo/raw/master/img/202109/05/102614-575759.jpeg)

  ![img](https://gitee.com/bliub/phpo/raw/master/img/202106/29/105010-394228.webp)



  ![image-20210909230506493](/Users/wuzhixuan/Library/Application Support/typora-user-images/image-20210909230506493.png)

  # 二、使用show profile查询剖析工具，可以指定具体的type

  type:

  + `all` 显示所有的性能信息 `show profile all for query n`
  + `block io`显示块io操作次数 `show profile block io for query n`

  + `context switches` 显示上下文切换次数，被动和主动 `show profile context switches`
  + `cpu`显示用户cpu时间、系统cpu时间 ` show profile cpu for query n`
  + `IPC`显示发送和接受的消息数量 `show profile ipc for query n`
  + `Memory`暂未实现
  + `page faults`显示页错误数量 `show profile page faults for query n`
  + `source`:显示源码中的函数名称与位置 `show profile source for query n`
  + `swaps`显示swap的次数  `show profile swaps for query n`

  # 三、**performance_schema**

  **MySQL的performance schema 用于监控MySQL server在一个较低级别的运行过程中的资源消耗、资源等待等情况**

  提供了一种在数据库运行时实时检查server的内部执行情况的方法。performance_schema 数据库中的表使用performance_schema存储引擎。该数据库主要关注数据库运行过程中的性能相关的数据，与information_schema不同，information_schema主要关注server运行过程中的元数据信息
  performance_schema通过监视server的事件来实现监视server内部运行情况， “事件”就是server内部活动中所做的任何事情以及对应的时间消耗，利用这些信息来判断server中的相关资源消耗在了哪里？一般来说，事件可以是函数调用、操作系统的等待、SQL语句执行的阶段（如sql语句执行过程中的parsing 或 sorting阶段）或者整个SQL语句与SQL语句集合。事件的采集可以方便的提供server中的相关存储引擎对磁盘文件、表I/O、表锁等资源的同步调用信息。
  performance_schema中的事件与写入二进制日志中的事件（描述数据修改的events）、事件计划调度程序（这是一种存储程序）的事件不同。performance_schema中的事件记录的是server执行某些活动对某些资源的消耗、耗时、这些活动执行的次数等情况。
  performance_schema中的事件只记录在本地server的performance_schema中，其下的这些表中数据发生变化时不会被写入binlog中，也不会通过复制机制被复制到其他server中。
  当前活跃事件、历史事件和事件摘要相关的表中记录的信息。能提供某个事件的执行次数、使用时长。进而可用于分析某个特定线程、特定对象（如mutex或file）相关联的活动。
  PERFORMANCE_SCHEMA存储引擎使用server源代码中的“检测点”来实现事件数据的收集。对于performance_schema实现机制本身的代码没有相关的单独线程来检测，这与其他功能（如复制或事件计划程序）不同
  收集的事件数据存储在performance_schema数据库的表中。这些表可以使用SELECT语句查询，也可以使用SQL语句更新performance_schema数据库中的表记录（如动态修改performance_schema的setup_*开头的几个配置表，但要注意：配置表的更改会立即生效，这会影响数据收集）
  performance_schema的表中的数据不会持久化存储在磁盘中，而是保存在内存中，一旦服务器重启，这些数据会丢失（包括配置表在内的整个performance_schema下的所有数据）
  MySQL支持的所有平台中事件监控功能都可用，但不同平台中用于统计事件时间开销的计时器类型可能会有所差异

  # 四、**使用show processlist查看链接个数，来观察是否有大量的线程处于不正常的状态或者其他不正常的特征**

  ![image-20210911235055825](/Users/wuzhixuan/Library/Application Support/typora-user-images/image-20210911235055825.png)

