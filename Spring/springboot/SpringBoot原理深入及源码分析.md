# 一、依赖管理

## 1.1 **为什么导入dependency时不需要指定版本**

``` xml
<!-- Spring Boot父项目依赖管理 -->    
<parent>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-parent</artifactId>
  <version>2.5.7</version>
  <relativePath/> <!-- lookup parent from repository -->
</parent>
```

上述代码中，将spring-boot-starter-parent依赖作为Spring Boot项目的统一父项目依赖管理，并 将项目版本号统一为2.2.9.RELEASE，该版本号根据实际开发需求是可以修改的使用“Ctrl+鼠标左键”进入并查看spring-boot-starter-parent底层源文件，先看spring-boot- starter-parent做了哪些事

``` xml
  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-dependencies</artifactId>
    <version>2.5.7</version>
  </parent>  
<properties>
    <java.version>1.8</java.version>
    <resource.delimiter>@</resource.delimiter>
    <maven.compiler.source>${java.version}</maven.compiler.source>
    <maven.compiler.target>${java.version}</maven.compiler.target>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
  </properties>
```

再来看 spring-boot-starter-parent 的「build」节点

``` pom
  <build>
    <resources>
      <resource>
        <directory>${basedir}/src/main/resources</directory>
        <filtering>true</filtering>
        <includes>
          <include>**/application*.yml</include>
          <include>**/application*.yaml</include>
          <include>**/application*.properties</include>
        </includes>
      </resource>
      <resource>
        <directory>${basedir}/src/main/resources</directory>
        <excludes>
          <exclude>**/application*.yml</exclude>
          <exclude>**/application*.yaml</exclude>
          <exclude>**/application*.properties</exclude>
        </excludes>
      </resource>
    </resources>
```

最后来看spring-boot-starter-parent的父依赖 `spring-boot-dependencies` 

+ 定义了很多properties
+ 还有`dependencyManagement`

``` pom
 <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>org.apache.activemq</groupId>
        <artifactId>activemq-amqp</artifactId>
        <version>${activemq.version}</version>
      </dependency>
      <dependency>
        <groupId>org.apache.activemq</groupId>
        <artifactId>activemq-blueprint</artifactId>
        <version>${activemq.version}</version>
      </dependency>
      <dependency>
        <groupId>org.apache.activemq</groupId>
        <artifactId>activemq-broker</artifactId>
        <version>${activemq.version}</version>
      </dependency>
      <dependency>
      .....
    <dependencyManagement>  
```

所以 spring-boot-starter-parent 通过继承 spring-boot-dependencies 从而实现了SpringBoot的版本依 赖管理,所以我们的SpringBoot工程继承spring-boot-starter-parent后已经具备版本锁定等配置了,这也 就是在 Spring Boot 项目中**部分依赖**不需要写版本号的原因

# 二、 **源码剖析-自动配置**

``` java
@SpringBootApplication // 能够扫描Spring组件并自动配置Spring Boot
public class  SpringbootApplication {
    public static void main(String[] args) {
        SpringApplication.run(SpringbootApplication.class, args);
    }
}


@Documented // 表示注解可以记录在javaDoc中
@Inherited // 表示可以被子类继承该注解
@SpringBootConfiguration // 标注这个类是一个配置类
@EnableAutoConfiguration // 启动自动配置功能
@ComponentScan(excludeFilters = { // 包扫描类 
  @Filter(type = FilterType.CUSTOM,classes = {TypeExcludeFilter.class}),
  @Filter( type = FilterType.CUSTOM, classes = {AutoConfigurationExcludeFilter.class}
)}
)
public @interface SpringBootApplication {
}


@Target({ElementType.TYPE}) // 表示该注解作用在类上面
@Retention(RetentionPolicy.RUNTIME) // 表示注解的生命周期，Runtime运行时
@Documented // 表示注解可以记录在javaDoc中
@Configuration // 表示这个是一个配置类
@Indexed
public @interface SpringBootConfiguration {
}


/**
 * 最重要的注解
 **/
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Inherited
@AutoConfigurationPackage // 自动配置包
@Import({AutoConfigurationImportSelector.class})// 借助@import来	收集所有符合自动配置条件@Configuration的bean定义，并加载都IOC容器
public @interface EnableAutoConfiguration {
}


@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Inherited
@Import({Registrar.class}) // 默认将主配置@SpringBootApplication 类所在的包以及子包里面的类加载到IOC容器
public @interface AutoConfigurationPackage {
}

class Registrar implements ImportBeanDefinitionRegistrar, DeterminableImports {
        Registrar() {
        }
// 获取的是项目主程序启动类所在的目录
// metadata: 注解标注的元数据信息
public void registerBeanDefinitions(AnnotationMetadata metadata, BeanDefinitionRegistry registry) {
  // 默认扫描@SpringAplication标注的主配置类所在的包以及子包下的组件
       AutoConfigurationPackages.register(registry, (String[])(new AutoConfigurationPackages.PackageImports(metadata)).getPackageNames().toArray(new String[0]));
}

public Set<Object> determineImports(AnnotationMetadata metadata) {
            return Collections.singleton(new AutoConfigurationPackages.PackageImports(metadata));
	}
}


public class AutoConfigurationImportSelector{
  
  
  		// 告诉SpringBoot需要导入哪些组件
      public String[] selectImports(AnnotationMetadata annotationMetadata) {
        // 判断 enableautoconfiguration注解是否开启，默认开启(是否进行自动配置)
        if (!this.isEnabled(annotationMetadata)) {
            return NO_IMPORTS;
        } else {
            // 加载配置文件
            AutoConfigurationImportSelector.AutoConfigurationEntry autoConfigurationEntry = this.getAutoConfigurationEntry(annotationMetadata);
            return StringUtils.toStringArray(autoConfigurationEntry.getConfigurations());
        }
    }
}


// 获取符合条件的自动配置类，避免加载不必要的自动配置类从而造成内存浪费 

protected AutoConfigurationEntry getAutoConfigurationEntry(
        AutoConfigurationMetadata autoConfigurationMetadata,
AnnotationMetadata annotationMetadata) {
// 获取是否有配置spring.boot.enableautoconfiguration属性，默认返回true 
  if (!isEnabled(annotationMetadata)) {
        return EMPTY_ENTRY;
    }
// 获得@Congiguration标注的Configuration类即被审视introspectedClass的注解数据， // 比如:@SpringBootApplication(exclude = FreeMarkerAutoConfiguration.class) // 将会获取到exclude = FreeMarkerAutoConfiguration.class和excludeName=""的注解
数据
AnnotationAttributes attributes = getAttributes(annotationMetadata);
// 【1】得到spring.factories文件配置的所有自动配置类
List<String> configurations = getCandidateConfigurations(annotationMetadata,
attributes);
// 利用LinkedHashSet移除重复的配置类
configurations = removeDuplicates(configurations);
// 得到要排除的自动配置类，比如注解属性exclude的配置类
// 比如:@SpringBootApplication(exclude = FreeMarkerAutoConfiguration.class) // 将会获取到exclude = FreeMarkerAutoConfiguration.class的注解数据
Set<String> exclusions = getExclusions(annotationMetadata, attributes);
// 检查要被排除的配置类，因为有些不是自动配置类，故要抛出异常 checkExcludedClasses(configurations, exclusions);
// 【2】将要排除的配置类移除
configurations.removeAll(exclusions);
// 【3】因为从spring.factories文件获取的自动配置类太多，如果有些不必要的自动配置类都加载
进内存，会造成内存浪费，因此这里需要进行过滤
// 注意这里会调用AutoConfigurationImportFilter的match方法来判断是否符合
@ConditionalOnBean,@ConditionalOnClass或@ConditionalOnWebApplication，后面会重点分 析一下
configurations = filter(configurations, autoConfigurationMetadata);
// 【4】获取了符合条件的自动配置类后，此时触发AutoConfigurationImportEvent事件，
// 目的是告诉ConditionEvaluationReport条件评估报告器对象来记录符合条件的自动配置类
// 该事件什么时候会被触发?--> 在刷新容器时调用invokeBeanFactoryPostProcessors后置处
理器时触发
fireAutoConfigurationImportEvents(configurations, exclusions);
// 【5】将符合条件和要排除的自动配置类封装进AutoConfigurationEntry对象，并返回 return new AutoConfigurationEntry(configurations, exclusions);
}



```

总结：

1. **从spring.factories配置文件中加载自动配置类;**
2. *加载的自动配置类中排除掉**`@EnableAutoConfiguration`注解的`exclude`属性指定的自动配置类
3. 然后再用`AutoConfigurationImportFilter`接口过滤自动配置类是否符合注解标准(若有标注的话)`@ConditionOnClass`、 `ConditionOnBean`和`ConditionOnWebApplication`的条件，若都符合条件返回匹配结果
4. 然后出发`AutoConfigurationImportEvent`事件，告诉`ConditionEvaluationReport`条件评估报告器对象分别记录符合条件和`Exclude`的自动配置类
5. 最后Spring再将筛选后自动配置的类注入到IOC容器

![image-20211122002552109](https://cdn.wuzx.cool/image-20211122002552109.png)