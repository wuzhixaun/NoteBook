# **核心注解自查**

| **注解**       | **功能**                                                 |
| -------------- | -------------------------------------------------------- |
| @Bean          | 容器中注册组件                                           |
| @Primary       | 同类组件如果有多个，标注主组件                           |
| @DependsOn     | 组件之间声明依赖关系                                     |
| @Lazy          | 组件懒加载（最后使用的时候才创建）                       |
| @Scope         | 声明组件的作用范围(SCOPE_PROTOTYPE,SCOPE_SINGLETON)      |
| @Configuration | 声明这是一个配置类，替换以前配置文件                     |
| @Component     | @Controller、@Service、@Repository                       |
| @Indexed       | 加速注解，所有标注了 @Indexed 的组件，直接会启动快速加载 |
| @Order         | 数字越小优先级越高，越先工作                             |
| @ComponentScan | 包扫描                                                   |
| @Conditional   | 条件注入                                                 |
| @Import        | 导入第三方jar包中的组件，或定制批量导入组件逻辑          |

| **注解**         | **功能**                                                     |
| ---------------- | ------------------------------------------------------------ |
| @ImportResource  | 导入以前的xml配置文件，让其生效                              |
| @Profile         | 基于多环境激活                                               |
| @PropertySource  | 外部properties配置文件和JavaBean进行绑定.结合ConfigurationProperties |
| @PropertySources | @PropertySource组合注解                                      |
| @Autowired       | 自动装配                                                     |
| @Qualifier       | 精确指定                                                     |
| @Value           | 取值、计算机环境变量、JVM系统。xxxx。@Value(“${xx}”)         |
| @Lookup          | 单例组件依赖非单例组件，非单例组件获取需要使用方法           |

# **核心组件接口分析**BeanFactory

![image-20220608005017359](https://cdn.wuzx.cool/image-20220608005017359.png)

BeanFactory

- HierarchicalBeanFactory：定义父子工厂（父子容器）

- ListableBeanFacotory：的实现是DefaultListableBeanFactory，保存了ioc容器中的核心信息

-  AutowireCapableBeanFactory：提供自动装配能力

- AnnotationApplicationContext组合了档案馆，他有自动装配能力。

# bean定义信息注册流程

![BeanDefintion信息的注册](https://cdn.wuzx.cool/BeanDefintion%E4%BF%A1%E6%81%AF%E7%9A%84%E6%B3%A8%E5%86%8C.jpg)