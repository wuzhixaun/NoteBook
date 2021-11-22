# SpringBoot RUN方法执行流程

## 1、查看main方法
``` java
@SpringBootApplication // 能够扫描Spring组件并自动配置Spring Boot
public class  SpringbootApplication {
    public static void main(String[] args) {
        SpringApplication.run(SpringbootApplication.class, args);
    }
}
```

## 2、点进run方法

``` java
    public static ConfigurableApplicationContext run(Class<?> primarySource, String... args) { // 调用重载方法
        return run(new Class[]{primarySource}, args);
    }

    public static ConfigurableApplicationContext run(Class<?>[] primarySources, String[] args) { // 两件事:1.初始化SpringApplication 2.执行run方法
        return (new SpringApplication(primarySources)).run(args);
    }
```

+ 初始化SpringApplication对象
+ 执行run方法

# 3、初始化SpringApplication对象

``` java
public SpringApplication(Class<?>... primarySources) {
        this((ResourceLoader)null, primarySources);
    }

    public SpringApplication(ResourceLoader resourceLoader, Class<?>... primarySources) {
        this.sources = new LinkedHashSet();
        this.bannerMode = Mode.CONSOLE;
        this.logStartupInfo = true;
        this.addCommandLineProperties = true;
        this.addConversionService = true;
        this.headless = true;
        this.registerShutdownHook = true;
        this.additionalProfiles = Collections.emptySet();
        this.isCustomEnvironment = false;
        this.lazyInitialization = false;
        this.applicationContextFactory = ApplicationContextFactory.DEFAULT;
        this.applicationStartup = ApplicationStartup.DEFAULT;
        // 设置资源加载器
        this.resourceLoader = resourceLoader;
        // 断言加载资源类不能为null
        Assert.notNull(primarySources, "PrimarySources must not be null");
        // 将primarySources数组转换为List，最后放到LinkedHashSet集合中
        this.primarySources = new LinkedHashSet(Arrays.asList(primarySources));
        //【1.1 推断应用类型，后面会根据类型初始化对应的环境。常用的一般都是servlet环境 】
        this.webApplicationType = WebApplicationType.deduceFromClasspath();
        this.bootstrapRegistryInitializers = this.getBootstrapRegistryInitializersFromSpringFactories();
				
// 【1.2 初始化classpath下 META-INF/spring.factories中已配置的 ApplicationContextInitializer 】       
      this.setInitializers(this.getSpringFactoriesInstances(ApplicationContextInitializer.class));
// 【1.3 初始化classpath下所有已配置的 ApplicationListener 】
        this.setListeners(this.getSpringFactoriesInstances(ApplicationListener.class));
// 【1.4 根据调用栈，推断出 main 方法的类名 】
        this.mainApplicationClass = this.deduceMainApplicationClass();
    }
```

## 4、 **run(args)**源码剖析

``` java
public ConfigurableApplicationContext run(String... args) {
        //记录程序运行时间
        StopWatch stopWatch = new StopWatch();
        stopWatch.start();
  	    // 注解bootstrap 初始化器到BootStrapContext上下文中
        DefaultBootstrapContext bootstrapContext = this.createBootstrapContext();
        ConfigurableApplicationContext context = null;
  			// 设置 java.awt.headless属性
        this.configureHeadlessProperty();
  			//从META-INF/spring.factories中获取监听器 `SpringApplicationRunListener`
        //1、获取并启动监听器
        SpringApplicationRunListeners listeners = this.getRunListeners(args);
  			// 循环遍历启动监听器
        listeners.starting(bootstrapContext, this.mainApplicationClass);

        try {
          
            // 封装参数对象
            ApplicationArguments applicationArguments = new DefaultApplicationArguments(args);
            //2、构造应用上下文环境,看构建的是SERVLET、REACTIVE、还是普通环境
            ConfigurableEnvironment environment = this.prepareEnvironment(listeners, bootstrapContext, applicationArguments);
            //处理需要忽略的Bean
            this.configureIgnoreBeanInfo(environment);
            //打印banner
            Banner printedBanner = this.printBanner(environment);
            //3、初始化应用上下文
            context = this.createApplicationContext();
            context.setApplicationStartup(this.applicationStartup);
          //4、刷新应用上下文前的准备阶段
            this.prepareContext(bootstrapContext, context, environment, listeners, applicationArguments, printedBanner);
          //5、刷新应用上下文
            this.refreshContext(context);
          //刷新应用上下文后的扩展接口
            this.afterRefresh(context, applicationArguments);
          //时间记录停止
            stopWatch.stop();
            if (this.logStartupInfo) {
                (new StartupInfoLogger(this.mainApplicationClass)).logStarted(this.getApplicationLog(), stopWatch);
            }
						//发布容器启动完成事件
            listeners.started(context);
          	// 将ApplicationRunner、CommandLineRunner注入到list里面并排序，然后循环调用Runner的run方法
            this.callRunners(context, applicationArguments);
        } catch (Throwable var10) {
            this.handleRunFailure(context, var10, listeners);
            throw new IllegalStateException(var10);
        }

        try {
            listeners.running(context);
            return context;
        } catch (Throwable var9) {
            this.handleRunFailure(context, var9, (SpringApplicationRunListeners)null);
            throw new IllegalStateException(var9);
        }
    }
```

以后就是主要分六步

+ 第1步：创建并启动监听器listener

+ 第2步：构建上下文环境，看是创建看构建的是SERVLET、REACTIVE、还是普通环境ApplicationEnvironment

+ 第3步：初始化应用上下文

+ 第4步：刷新应用上下文前的准备阶段，

+ 第5步：刷新上下文并且注册了一个钩子（JVM关闭就会关闭这个上下文）

+ 第6步：刷新应用上下文后的扩展接口，afterRefresh这个是一个空实现的方法

# 解析六步源码

## 第1步：创建并启动监听器listener

