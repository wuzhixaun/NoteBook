# 一、架构设计

![image-20211029140627246](https://cdn.wuzx.cool/image-20211029140627246.png)

## Mybatis的功能架构分为三层：

+  API接⼝层：提供给外部使⽤的接⼝ API，开发⼈员通过这些本地API来操纵数据库。接⼝层⼀接收 到 调⽤请求就会调⽤数据处理层来完成具体的数据处理。

    > MyBatis和数据库的交互有两种⽅式：
    >
    > + 使⽤传统的MyBati s提供的API ；
    >
    > + 使⽤Mapper代理的⽅式

+ 数据处理层：负责具体的SQL查找、SQL解析、SQL执⾏和执⾏结果映射处理等。它主要的⽬的是根 据调⽤的请求完成⼀次数据库操作。
+ 基础⽀撑层：负责最基础的功能⽀撑，包括连接管理、事务管理、配置加载和缓存处理，这些都是 共 ⽤的东⻄，将他们抽取出来作为最基础的组件。为上层的数据处理层提供最基础的⽀撑

# 二、主要构件及其相互关系

+ `SqlSession`: MyBatis⼯作的主要顶层API，表示和数据库交互的会话，完成必要数 据库增删改查功能
+ `Executor`:MyBatis执⾏器，是MyBatis调度的核⼼，负责SQL语句的⽣成和查询缓 存的维护
+ `StatementHandler`:封装了JDBC Statement操作，负责对JDBC statement的操作，如设置参 数、将Statement结果集转换成List集合
+ `ParameterHandler`:负责对⽤户传递的参数转换成JDBC Statement所需要的参数
+ `ResultSetHandler`:负责将JDBC返回的ResultSet结果集对象转换成List类型的集合；
+ `TypeHandler`:负责java数据类型和jdbc数据类型之间的映射和转换
+ `MappedStatement`:MappedStatement维护了⼀条＜select | update | delete | insert＞节点 的封 装
+ `SqlSource`:负责根据⽤户传递的parameterObject，动态地⽣成SQL语句，将信息封 装到BoundSql对象中，并返回
+ `BoundSql`:表示动态⽣成的SQL语句以及相应的参数信息

![Mybatis层次结构](https://cdn.wuzx.cool/image-20211029150331909.png)

sqlsession  最后面会有一个baseExecytor key 就是 namespace + id + sql + limit+  参数

commit （执⾏插⼊、更新、删除）会清空缓存

