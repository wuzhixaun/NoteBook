![image-20211107103856240](https://cdn.wuzx.cool/image-20211107103856240.png)

# 一、**BeanFactory**与**ApplicationContext**区别

BeanFactory是Spring框架中IoC容器的顶层接口,它只是用来定义一些基础功能,定义一些基础规范,而 ApplicationContext是它的一个子接口，所以ApplicationContext是具备BeanFactory提供的全部功能 的。

通常，我们称BeanFactory为SpringIOC的基础容器，ApplicationContext是容器的高级接口，比 认准一手 微信:meetjava

BeanFactory要拥有更多的功能，比如说国际化支持和资源访问(xml，java配置类)等等

![image-20211107104014912](https://cdn.wuzx.cool/image-20211107104014912.png)

# 二、启动 IoC 容器的方式

## Java环境下启动IoC容器

+ ClassPathXmlApplicationContext:从类的根路径下加载配置文件(推荐使用)
+ FileSystemXmlApplicationContext:从磁盘路径上加载配置文件
+ AnnotationConfigApplicationContext:纯注解模式下启动Spring容器

## Web环境下启动IoC容器

+ 从xml启动容器

``` xml
 <!DOCTYPE web-app PUBLIC
 "-//Sun Microsystems, Inc.//DTD Web Application 2.3//EN"
 "http://java.sun.com/dtd/web-app_2_3.dtd" >
<web-app>
  <display-name>Archetype Created Web Application</display-name>
<!--配置Spring ioc容器的配置文件--> <context-param>
    <param-name>contextConfigLocation</param-name>
<param-value>classpath:applicationContext.xml</param-value> </context-param>
<!--使用监听器启动Spring的IOC容器-->
<listener>
<listener- 认准一手 微信:meetjava class>org.springframework.web.context.ContextLoaderListener</listener- class>
  </listener>
</web-app>
```

+ 从配置类启动容器

  ``` xml
   
  <!DOCTYPE web-app PUBLIC
   "-//Sun Microsystems, Inc.//DTD Web Application 2.3//EN"
   "http://java.sun.com/dtd/web-app_2_3.dtd" >
  <web-app>
    <display-name>Archetype Created Web Application</display-name>
  <!--告诉ContextloaderListener知道我们使用注解的方式启动ioc容器--> <context-param>
      <param-name>contextClass</param-name>
      <param-
  value>org.springframework.web.context.support.AnnotationConfigWebAppli
  cationContext</param-value>
  </context-param>
     
  <!--配置启动类的全限定类名--> <context-param>
      <param-name>contextConfigLocation</param-name>
  <param-value>com.lagou.edu.SpringConfig</param-value> </context-param>
  <!--使用监听器启动Spring的IOC容器-->
  <listener>
      <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
    </listener>
  </web-app>
  ```

  # 三、XML模式

  

## 3.1spring bean xml文件头

``` xml
 <?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://www.springframework.org/schema/beans
https://www.springframework.org/schema/beans/spring-beans.xsd">
```

## 3.2实例化Bean的三种方式

### 3.2.1 方式一:使用无参构造函数

> 在默认情况下，它会通过反射调用无参构造函数来创建对象。如果类中没有无参构造函数，将创建
>   失败。

``` xml
 <!--配置service对象-->
<bean id="userService" class="com.lagou.service.impl.TransferServiceImpl"> </bean>
```

### 3.2.2 使用静态方法创建

> 在实际开发中，我们使用的对象有些时候并不是直接通过构造函数就可以创建出来的，它可能在创 建的过程 中会做很多额外的操作。此时会提供一个创建对象的方法，恰好这个方法是static修饰的 方法，即是此种情 况

``` xml
<!--使用静态方法创建对象的配置方式-->
<bean id="userService" class="com.lagou.factory.BeanFactory" factory-method="getTransferService"></bean>
```

### 3.2.3 方式三:使用实例化方法创建

> 此种方式和上面静态方法创建其实类似，区别是用于获取对象的方法不再是static修饰的了，而是 类中的一 个普通方法。此种方式比静态方法创建的使用几率要高一些

``` xml
<!--使用实例方法创建对象的配置方式-->
<bean id="beanFactory" class="com.lagou.factory.instancemethod.BeanFactory"></bean> <bean id="transferService" factory-bean="beanFactory" factory- method="getTransferService"></bean>
```

## 3.3 	Bean的X及生命周期

### 3.3.1 作用范围的改变

在spring框架管理Bea认n对准象的一创手建时微，B信ean:对象me默e认t都ja是v单a例的，但是它支持配置的方式改 变作用范围。作用范围官方提供的说明如下图:

![image-20211107105106077](https://cdn.wuzx.cool/image-20211107105106077.png)

在上图中提供的这些选项中，我们实际开发中用到最多的作用范围就是singleton(单例模式)和 prototype(原型模式，也叫多例模式)。配置方式参考下面的代码:

``` xml
<!--配置service对象-->
<bean id="transferService" class="com.lagou.service.impl.TransferServiceImpl" scope="singleton"> </bean>
```

+ **singleton** 单例模式,单例模式的bean对象生命周期与容器相同。

  > 对象出生:当创建容器时，对象就被创建了。
  >
  > 对象活着:只要容器在，对象一直活着。
  >
  > 对象死亡:当销毁容器时，对象就被销毁了。
  >
  > 一句话总结:单例模式的bean对象生命周期与容器相同。

+ **prototype** 多例模式,多例模式的bean对象，spring框架只负责创建，不负责销毁

  > 对象出生:当使用对象时，创建新的对象实例。
  >
  >  对象活着:只要对象在使用中，就一直活着。 
  >
  > 对象死亡:当对象⻓时间不用时，被java的垃圾回收器回收了。

### 3.3.2 Bean标签属性

> 在基于xml的IoC配置中，bean标签是最基础的标签。它表示了IoC容器中的一个对象。换句话 说，如果一个对象想让spring管理，在XML的配置中都需要使用此标签配置，Bean标签的属性如 下:

+ **id**属性: 用于给bean提供一个唯一标识。在一个标签内部，标识必须唯一。

+ **class**属性:用于指定创建Bean对象的全限定类名。

+ **name**属性:用于给bean提供一个或多个名称。多个名称用空格分隔。

+ **factory-bean**属性:用于指定创建当前bean对象的工厂bean的唯一标识。当指定了此属性之后，class属性失效+
+ **factory-method**属性:用于指定创建当前bean对象的工厂方法，如配合factory-bean属性使用，则class属性失效。如配合class属性使用，则方法必须是static的。 
+ **scope**属性:用于指定bean对象的作用范围。通常情况下就是singleton。当要用到多例模式时，可以配置为prototype。 
+ **init-method**属性:用于指定bean对象的初始化方法，此方法会在bean对象装配后调用。必须是一个无参方法。
+ **destory-method**属性:用于指定bean对象的销毁方法，此方法会在bean对象销毁前执行。它只能为scope是singleton时起作用

# 四、纯注解模式

将xml中遗留的内容全部以注解的形式迁移出去，最终删除xml，从Java配置类启动 对应注解

+ @Configuration 注解，表名当前类是一个配置类
+  @ComponentScan 注解，替代 context:component-scan

```
<dependency>
    <groupId>javax.annotation</groupId>
  <artifactId>javax.annotation-api</artifactId>
    <version>1.3.2</version>
</dependency>
```

+ @PropertySource，引入外部属性配置文件
+ @Import 引入其他配置类
+  @Value 对变量赋值，可以直接赋值，也可以使用 ${} 读取资源配置文件中的信息
+ @Bean 将方法返回对象加入SpringIOC 容器