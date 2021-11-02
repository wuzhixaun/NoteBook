# **SpringBoot + Mybatis + MP**

使用SpringBoot将进一步的简化MP的整合，需要注意的是，由于使用SpringBoot需要继承parent，所 以需要重新创
 建工程，并不是创建子Module。

# 创建工程

![image-20211101235050762](https://cdn.wuzx.cool/image-20211101235050762.png)

# 导入依赖

```
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter</artifactId>
        <version>2.5.6</version>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
        <version>2.5.6</version>
    </dependency>
    <dependency>
        <groupId>com.baomidou</groupId>
        <artifactId>mybatis-plus-boot-starter</artifactId>
        <version>3.4.3.4</version>
    </dependency>

    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>1.18.22</version>
    </dependency>

    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
        <version>5.1.49</version>
    </dependency>
</dependencies>
```

log4j.properties:

``` properties
log4j.rootLogger=DEBUG,A1
log4j.appender.A1=org.apache.log4j.ConsoleAppender
log4j.appender.A1.layout=org.apache.log4j.PatternLayout
log4j.appender.A1.layout.ConversionPattern=[%t] [%c]-[%p] %m%n
```

# 编写**application.properties**

``` properties
spring.datasource.driver-class-name=com.mysql.jdbc.Driver
spring.datasource.url=jdbc:mysql://127.0.0.1:3306/mp?
useUnicode=true&characterEncoding=utf8&autoReconnect=true&allowMultiQueries=tr
ue&useSSL=false
spring.datasource.username=root
spring.datasource.password=root
```

# 编写**pojo**

``` java
@Data
public class User {
    private Long id;
    private String name;
    private Integer age;
    private String email;
}
```

# 编写**mapper**

``` java
public interface UserMapper extends BaseMapper<User> {
}
```

# 编写启动类

``` java 
@MapperScan("com.lagou.mp.mapper") //设置mapper接口的扫描包 @SpringBootApplication
public class MyApplication {
    public static void main(String[] args) {
        SpringApplication.run(MyApplication.class, args);
}
```

# 编写测试类

``` java
@RunWith(SpringRunner.class)
@SpringBootTest
public class UserMapperTest {
@Autowired
    private UserMapper userMapper;
@Test
    public void testSelect() {
        List<User> userList = userMapper.selectList(null);
        for (User user : userList) {
} }
```

# 测试结果

``` sql
2021-11-01 23:49:30.121  INFO 1703 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Start completed.
User(id=1, name=Jone, age=18, email=test1@baomidou.com)
User(id=2, name=Jack, age=20, email=test2@baomidou.com)
User(id=3, name=Tom, age=28, email=test3@baomidou.com)
User(id=4, name=Sandy, age=21, email=test4@baomidou.com)
User(id=5, name=Billie, age=24, email=test5@baomidou.com)
2021-11-01 23:49:30.241  INFO 1703 --- [ionShutdownHook] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Shutdown initiated...
```

