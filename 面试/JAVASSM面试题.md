# 一、Spring bean作用域的之间的区别

	+ Singleton 在spring IOC容器中仅存在一个bean实例，bean以单例的方式存在
	+ prototype：每次调用getBean()时都会返回一个新的实例
 + request: 每次HTTP 请求都会创建一个新的bean，该作用域适用于WebApplicationContext环境
 + session 同一个HTTP Session 共享一个Bean，不同的Http Session使用不同的Bean。该作用域适用于

WebApplicationContext环境



# 二、Spring 支持的常用数据库事物传播属性和事物隔离级别

## 事务的属性

+ propagation：用来设置事务的传播行为
+ ISo

# 三、SpringMVC中如何解决POST请求中文乱码问题，GET又是如何处理

+ POST请求

  + 配置CharacterEncodingFilter--  encoding utf-8 -- forceencoding true

+ GET 请求

  + URIEncoding - utf-8

  





