# 1.谈谈Spring IOC的理解，原理与实现

> `IOC(Inversion of Control)控制反转`：是一种理论思想，原来的对象是由我们使用者进行控制，有了Spring之后，整个对象的管理交给Spring
>
> `DI(Dependency Injection)依赖注入`: 把对象的属性的值注入到具体对象中，@Autowried 完成属性的注入
>
> 容器: 存储对象,使用map的数据来存储对象，在Spring中一种有三级缓存，singletonObjects、earlySingletonObjects、singletonFactories，完整的对象创建完成将方法singletonObjects中。，整个bean的生命周期，从Spring的创建、使用、销毁都是由容器来管理
>
> Spring IOC容器刷新12大步 https://processon.com/diagraming/62b4308fe401fd071e11e9ac

# 2. 谈谈Spring IOC的底层实现

> Spring IOC容器刷新12大步 https://processon.com/diagraming/62b4308fe401fd071e11e9ac

# 3. 描述一下bean的生命周期

> https://processon.com/diagraming/62a6096e07912939b228309a

#  4. Spring是如何解决循环依赖的问题

> 循环依赖： A依赖B 、B依赖A
>
> 1. 创建A对象，getSingleton(允许早期引用)，这个时候没有对象，就doCreateBean()
> 2. 在从singletonObjects缓存中获取，发现没有就开始创建，创建了A对象，调用addSingleFactory，将bean对象方法三级缓存singleFactory中
> 3. A进行populateBean赋值AutowiredAnnotationBeanPostProcessor 调用postProcessProperties进行属性装配
> 4. 然后需要getBean(B)重新进入获取对象的流程,然后开始创建B对象流程b的对象创建放在单例池中
>
> https://processon.com/diagraming/62b73402f346fb6dc58161d0

# 5. BeanFactory 与FactoryBean 有什么区别

+ 相同点： 都是创建对象
+ 不同点：
  + 使用BeanFactory创建对象的时候，创建的对象的时候	必须遵循严格的生命周期
  + 简单创建Bean实现FactoryBean接口
    + isSingleton:是否是单例对象
    + getObjectTyle: 对象的类型
    + getObject: 自定义对象的过程

# 6. Spring中用到的设计模式

+ 单例模式: Bean默认都是单例的
+ 工厂模式：beanFactory
+ 模板方法：OnRefresh、initPropertyValue、postProcessBeanFacoty
+ 策略模式:  XmlBeanDefinitionReader、PropertiesBeanDefinitionReader
+ 观察者：listener、event、ApplicationEventMutiCaster
+ 适配器: Adapt
+ 装饰器模式： beanWrapper
+ 责任链模式： 使用aop生成一个拦截器链
+ 代理模式：

# 7. Spring 的Aop的底层实现原理

> 原理图 https://processon.com/diagraming/62b88bcb7d9c0820807e4806
>
> aop是ioc的一个扩展功能 ，先有IOC 再有的aop 这个流程是这个后置处理器AspectJAutoProxyCreator（BeanPostProcessor）
>
> 1. 代理对象的创建过程(1.遍历所有的切面类
>
>    2.反射找到切面的所有方法
>
>    3.判断每一个方法是否通知方法(Pointcut.class, Around.class, Before.class, After.class, AfterReturning.class, AfterThrowing.class)
>
>    4.通知方法被封装为Advisor(增强器)
>
> 2. 通过jdk或者cglib的方式创建代理对象
>
> 3. 在执行方法调用的时候DynamicAdvisedInterceptor的intercept方法
>
> 4. 根据之前的通知生成拦截器链，从拦截器链中获取每一个拦截器进行执行从-1开始执行

# 8.Spring的事务是如何回滚的

> spring的事务是有aop实现的，首先生成具体的代理对象，通过`TransactionInterceptor`实现
>
> 1. 准备工作，解析各个方法上线事务相关的属性，根据具体的属性来判断是否开启新事务
> 2. 当需要开启的时候，获取数据库的连接，关闭自动提交功能，开启事务
> 3. 执行具体的sql操作
> 4. 在操作过程中，如果执行失败，会通过completeTransactionAfterThrowing来完成事务回滚，回滚的具体逻辑是通过doRollBack来实现，先获取连接，通过连接对象进行回滚con.rollback();
> 5. 在操作过程中，如果执行成功，会通过commitTransactionAfterReturning来完成事务提交，回滚的具体逻辑是通过doCommit来实现，先获取连接，通过连接对象进行回滚con.commit();
> 6. 当事务执行完毕，需要调用CleanUpTranscationInfo清楚事务相关信息

# 9. Spring的事务传播

![image-20220701020514934](https://cdn.wuzx.cool/image-20220701020514934.png)

+ Required
+ Requires_new
+ Nested_support
+ Not_support
+ Never
+ Mandatory

某一个事务套另外一个事务怎么办？

**A方法调用B方法，A、B方法都有事务，并且传播特性不同，那么如果A有异常、B怎么办，B如果有异常，A怎么办**

> 1. 先说说事务的不同分类，可以分三类：支持当前事务，不支持当前事务，嵌套事务
> 2. 如果外层是Required ,内层方法是 required,Requires_new,nested
> 3. 如果外层是Requires_new ,内层方法是 required,Requires_new,nested
> 4. 如果外层是nested ,内层方法是 required,Requires_new,nested

![image-20220701021051038](https://cdn.wuzx.cool/image-20220701021051038.png)