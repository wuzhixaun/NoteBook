# 一、**Spring** 简介

Spring 是分层的 full-stack(全栈) 轻量级开源框架，以 IoC 和 AOP 为内核，提供了展现层 Spring MVC 和业务层事务管理等众多的企业级应用技术，还能整合开源世界众多著名的第三方框架和类库，已 经成为使用最多的 Java EE 企业应用开源框架。

Spring 官方网址:http://spring.io/
 我们经常说的 Spring 其实指的是Spring Framework(spring 框架)。

# 二、**Spring** 发展历程

+  1997年 IBM 提出了EJB的思想; 1998年，SUN 制定开发标准规范EJB1.0; 1999年，EJB 1.1发

  布; 2001年，EJB 2.0发布; 2003年，EJB 2.1发布; 2006年，EJB 3.0发布;

+ Rod Johnson(spring之父)

  + Expert One-to-One J2EE Design and Development(2002) 阐述了J2EE使用EJB开发设计的优 点及解决方案
  + Expert One-to-One J2EE Development without EJB(2004) 阐述了J2EE开发不使用EJB的解决 方式(Spring雏形)

# 三、**Spring** 的优势

整个 Spring 优势，传达出一个信号，Spring 是一个综合性，且有很强的思想性框架，每学习一 天，就能体会到它的一些优势。

## 方便解耦，简化开发

> 通过Spring提供的IoC容器，可以将对象间的依赖关系交由Spring进行控制，避免硬编码所造成的 过度程序耦合。用户也不必再为单例模式类、属性文件解析等这些很底层的需求编写代码，可以更 专注于上层的应用。

## **AOP**编程的支持

> 通过Spring的AOP功能，方便进行面向切面的编程，许多不容易用传统OOP实现的功能可以通过
>
> AOP轻松应付。

## 声明式事务的支持

> @Transactional
>
> 可以将我们从单调烦闷的事务管理代码中解脱出来，通过声明式方式灵活的进行事务的管理，提高
>
> 开发效率和质量。

## 方便程序的测试

> 可以用非容器依赖的编程方式进行几乎所有的测试工作，测试不再是昂贵的操作，而是随手可做的
>   事情。

## 方便集成各种优秀框架

> Spring可以降低各种框架的使用难度，提供了对各种优秀框架(Struts、Hibernate、Hessian、 Quartz等)的直接支持。

## 降低**JavaEE API**的使用难度

> Spring对JavaEE API(如JDBC、JavaMail、远程调用等)进行了薄薄的封装层，使这些API的使用
>
> 难度大为降低。

## 源码是经典的 **Java** 学习范例

> Spring的源代码设计精妙、结构清晰、匠心独用，处处体现着大师对Java设计模式灵活运用以及对
>
> Java技术的高深造诣。它的源代码无意是Java技术的最佳实践的范例。

# 四、**Spring** 的核心结构

![image-20211103001913984](https://cdn.wuzx.cool/image-20211103001913984.png)

+ Spring核心容器(Core Container) 容器是Spring框架最核心的部分，它管理着Spring应用中 bean的创建、配置和管理。在该模块中，包括了Spring bean工厂，它为Spring提供了DI的功能。 基于bean工厂，我们还会发现有多种Spring应用上下文的实现。所有的Spring模块都构建于核心 容器之上。

+ 面向切面编程(AOP)/Aspects Spring对面向切面编程提供了丰富的支持。这个模块是Spring应 用系统中开发切面的基础，与DI一样，AOP可以帮助应用对象解耦。

+ 数据访问与集成(Data Access/Integration)

  > Spring的JDBC和DAO模块封装了大量样板代码，这样可以使得数据库代码变得简洁，也可以更专 注于我们的业务，还可以避免数据库资源释放失败而引起的问题。 另外，Spring AOP为数据访问 提供了事务管理服务，同时Spring还对ORM进行了集成，如Hibernate、MyBatis等。该模块由 JDBC、Transactions、ORM、OXM 和 JMS 等模块组成。

+ Web 该模块提供了SpringMVC框架给Web应用，还提供了多种构建和其它应用交互的远程调用方 案。 SpringMVC框架在Web层提升了应用的松耦合水平。
+ Test 为了使得开发者能够很方便的进行测试，Spring提供了测试模块以致力于Spring应用的测 试。 通过该模块，Spring为使用Servlet、JNDI等编写单元测试提供了一系列的mock对象实现。

# 五、**Spring** 框架版本

![image-20211103002743320](https://cdn.wuzx.cool/image-20211103002743320.png)