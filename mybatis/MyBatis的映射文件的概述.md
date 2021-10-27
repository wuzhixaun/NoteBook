# MyBatis的映射文件的概述	![image-20211027231014782](/Users/wuzhixuan/Library/Application Support/typora-user-images/image-20211027231014782.png)



![image-20211027231758003](/Users/wuzhixuan/Library/Application Support/typora-user-images/image-20211027231758003.png)

# **MyBatis**常用配置解析

## 1.**environments**标签

![image-20211027231836941](/Users/wuzhixuan/Library/Application Support/typora-user-images/image-20211027231836941.png)

> + 事务管理器(transactionManager)类型有两种:
>   + JDBC:这个配置就是直接使用了JDBC 的提交和回滚设置，它依赖于从数据源得到的连接来管理事务作用域。
>   + MANAGED:这个配置几乎没做什么。它从来不提交或回滚一个连接，而是让容器来管理事务的整个生 命周期(比如 JEE 应用服务器的上下文)。 默认情况下它会关闭连接，然而一些容器并不希望这样，因 此需要将 closeConnection 属性设置为 false 来阻止它默认的关闭行为。
> + 数据源(dataSource)类型有三种:
>   + UNPOOLED:这个数据源的实现只是每次被请求时打开和关闭连接。 
>   + POOLED:这种数据源的实现利用“池”的概念将 JDBC 连接对象组织起来
>   + JNDI:这个数据源的实现是为了能在如 EJB 或应用服务器这类容器中使用，容器可以集中或在外部配 置数据源，然后放置一个 JNDI 上下文的引用

## 2.**mapper**标签

该标签的作用是加载映射的，加载方式有如下几种:

``` xml-dtd
•使用相对于类路径的资源引用，例如:
<mapper resource="org/mybatis/builder/AuthorMapper.xml"/>
•使用完全限定资源定位符(URL)，例如:
<mapper url="file:///var/mappers/AuthorMapper.xml"/> 
•使用映射器接口实现类的完全限定类名，例如:
<mapper class="org.mybatis.builder.AuthorMapper"/> 
•将包内的映射器接口实现全部注册为映射器，例如:
<package name="org.mybatis.builder"/>
```

## 3.**Properties**标签

实际开发中，习惯将数据源的配置信息单独抽取成一个properties文件，该标签可以加载额外配置的properties文件

![image-20211027234257052](/Users/wuzhixuan/Library/Application Support/typora-user-images/image-20211027234257052.png)

## 4.**typeAliases**标签

类型别名是为Java 类型设置一个短的名字。原来的类型名称配置如下

![image-20211027234702864](/Users/wuzhixuan/Library/Application Support/typora-user-images/image-20211027234702864.png)

配置typeAliases，为com.lagou.domain.User定义别名为user

![image-20211027234720939](/Users/wuzhixuan/Library/Application Support/typora-user-images/image-20211027234720939.png)

```xml-dtd
批量取别名
<!--给实体类的全限定名给别名-->
<typeAliases>
  <!-- 给单个实体类取别名 -->
  <!--  <typeAlias type="com.wuzx.pojo.User" alias="xxuser"></typeAlias>-->
  <!--批量取别名 ,别名就是类型，别名不区分大小写-->
  <package name="com.wuzx.pojo"/>
</typeAliases>
```



上面我们是自定义的别名，mybatis框架已经为我们设置好的一些常用的类型的别名

![image-20211027235006952](/Users/wuzhixuan/Library/Application Support/typora-user-images/image-20211027235006952.png)

# MyBatis复杂映射

