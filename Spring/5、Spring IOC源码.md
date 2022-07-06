

# **Spring IoC**的容器体系

IoC容器是Spring的核心模块，是抽象了对象管理、依赖关系管理的框架解决方案。Spring 提供了很多 的容器，其中 BeanFactory 是顶层容器(根容器)，不能被实例化，它定义了所有 IoC 容器 必须遵从 的一套原则，具体的容器实现可以增加额外的功能，比如我们常用到的ApplicationContext，其下更具 体的实现如 ClassPathXmlApplicationContext 包含了解析 xml 等一系列的内容， AnnotationConfigApplicationContext 则是包含了注解解析等一系列的内容。Spring IoC 容器继承体系 非常聪明，需要使用哪个层次用哪个层次即可，不必使用功能大而全的。

BeanFactory 顶级接口方法栈如下

![image-20211109224310204](https://cdn.wuzx.cool/image-20211109224310204.png)

![image-20211109224331224](https://cdn.wuzx.cool/image-20211109224331224.png)

通过其接口设计，我们可以看到我们一贯使用的 ApplicationContext 除了继承BeanFactory的子接口， 还继承了ResourceLoader、MessageSource等接口，因此其提供的功能也就更丰富了

# B**ean**生命周期关键时机点

Bean对象创建的几个关键时机点代码层级的调用都在 AbstractApplicationContext 类 的 refresh 方法中，可⻅这个方法对于Spring IoC 容器初始化来说相当 关键，汇总如下:

| 关键点                            | 触发代码                                                     |
| --------------------------------- | ------------------------------------------------------------ |
| 构造器                            | refresh#finishBeanFactoryInitialization(beanFactory)(beanFactory) |
| BeanFactoryPostProcessor 初始化   | refresh#invokeBeanFactoryPostProcessors(beanFactory)         |
| BeanFactoryPostProcessor 方法调用 | refresh#invokeBeanFactoryPostProcessors(beanFactory)         |
| BeanPostProcessor 初始化          | registerBeanPostProcessors(beanFactory)                      |
| BeanPostProcessor 方法调用        | refresh#finishBeanFactoryInitialization(beanFactory)         |

# **Spring IoC**容器初始化主流程

Spring IoC 容器初始化的关键环节就在 AbstractApplicationContext#refresh() 方法中 ，我们查看 refresh 方法来俯瞰容器创建的主体流程，主体流程下的具体子流程我们后面再来讨论

``` java
 @Override
public void refresh() throws BeansException, IllegalStateException {
    synchronized (this.startupShutdownMonitor) {
// 第一步:刷新前的预处理 
 prepareRefresh();
/*
第二步: 获取BeanFactory;默认实现是DefaultListableBeanFactory
加载BeanDefition 并注册到 BeanDefitionRegistry
*/ 
ConfigurableListableBeanFactory beanFactory =obtainFreshBeanFactory();
      
// 第三步:BeanFactory的预准备工作(BeanFactory进行一些设置，比如context的类加载器等)
prepareBeanFactory(beanFactory);
try {
// 第四步:BeanFactory准备工作完成后进行的后置处理工作 
  postProcessBeanFactory(beanFactory);
// 第五步:实例化并调用实现了BeanFactoryPostProcessor接口的Bean 	  
  invokeBeanFactoryPostProcessors(beanFactory);
// 第六步:注册BeanPostProcessor(Bean的后置处理器)，在创建bean的前后等执行
  registerBeanPostProcessors(beanFactory);
// 第七步:初始化MessageSource组件(做国际化功能;消息绑定，消息解析); 
  initMessageSource();
// 第八步:初始化事件派发器 
  initApplicationEventMulticaster();
  // 第九步:子类重写这个方法，在容器刷新的时候可以自定义逻辑
  onRefresh();
  // 第十步:注册应用的监听器。就是注册实现了ApplicationListener接口的监听器 
  registerListeners(); 
/*
第十一步:
初始化所有剩下的非懒加载的单例bean 初始化创建非懒加载方式的单例Bean实例(未设置属性)
填充属性 初始化方法调用(比如调用afterPropertiesSet方法、init-method方法) 调用BeanPostProcessor(后置处理器)对实例bean进行后置处
*/
  finishBeanFactoryInitialization(beanFactory);
/*第十二步: 完成context的刷新。主要是调用LifecycleProcessor的onRefresh()方法，并且发布事件
(ContextRefreshedEvent)*/
  finishRefresh();
```



# **BeanFactory**创建流程

## 获取**BeanFactory**子流程

![image-20211109233334433](https://cdn.wuzx.cool/image-20211109233334433.png)

## **BeanDefinition**加载解析及注册子流程

### 1.该子流程涉及到如下几个关键步骤

**Resource**定位:指对BeanDefinition的资源定位过程。通俗讲就是找到定义Javabean信息的XML文 件，并将其封装成Resource对象。

**BeanDefinition**载入 :把用户定义好的Javabean表示为IoC容器内部的数据结构，这个容器内部的数 据结构就是BeanDefinition。

注册**BeanDefinition**到 **IoC** 容器

![image-20211109233704223](https://cdn.wuzx.cool/image-20211109233704223.png)

# **Bean**创建流程

通过最开始的关键时机点分析，我们知道Bean创建子流程入口在AbstractApplicationContext#refresh()方法的finishBeanFactoryInitialization(beanFactory) 处

![image-20211109233753489](https://cdn.wuzx.cool/image-20211109233753489.png)

+ 进入finishBeanFactoryInitialization

  ![](https://cdn.wuzx.cool/image-20211109233811062.png)

+ 继续进入DefaultListableBeanFactory类的preInstantiateSingletons方法，我们找到下面部分的 代码，看到工厂Bean或者普通Bean，最终都是通过getBean的方法获取实例

  ![image-20211109233852698](https://cdn.wuzx.cool/image-20211109233852698.png)

+ 继续跟踪下去，我们进入到了AbstractBeanFactory类的doGetBean方法，这个方法中的代码很 多，我们直接找到核心部分

  ![image-20211109233913022](https://cdn.wuzx.cool/image-20211109233913022.png)

+ 接着进入到AbstractAutowireCapableBeanFactory类的方法，找到以下代码部分

  ![image-20211109233932670](https://cdn.wuzx.cool/image-20211109233932670.png)

+ 进入doCreateBean方法看看，该方法我们关注两块重点区域

  + 创建Bean实例，此时尚未设置属性

    ![image-20211109234003517](https://cdn.wuzx.cool/image-20211109234003517.png)

  + 给Bean填充属性，调用初始化方法，应用BeanPostProcessor后置处理器

  ![](https://cdn.wuzx.cool/image-20211109234026968.png)