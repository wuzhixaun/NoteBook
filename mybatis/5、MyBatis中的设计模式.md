# 设计模式

我们都知道设计模式分为3类23种设计模式，Mybatis至少用到了以下的设计模式的使用

![image-20211031115424677](https://cdn.wuzx.cool/image-20211031115424677.png)

# BUildeer构建者模式

Builder模式，属于`创建类模式`它的定义是"将一个复杂对象的构建与它的表示分离，使得同样的构建过程可以创建不同的表 示。”一般来说，如果一个对象的构建比较复杂，超出了构造函数所能包含的范 围，就可以使用工厂模式和Builder模式，相对于工厂模式会产出一个完整的产品，Builder应用于更加 复杂的对象的构建，甚至只会构建产品的一个部分，直白来说，就是使用多个简单的对象一步一步构建 成一个复杂的对象

## 主要步骤:

+  将需要构建的目标类分成多个部件(电脑可以分为主机、显示器、键盘、音箱等部件);
+  创建构建类;
+ 依次创建部件;
+ 将部件组装成目标对象

``` java
// 创建目标类对象
public class Computer {
    // 显示器
    private String displayer;
    // 主机
    private String mainUnit;
    // 鼠标
    private String mouse;
    // 键盘
    private String keyboard;
}
```

``` java
// 创建构建类对象
public class ComputerBuilder {
    Computer computer = new Computer();	
    public void installDisplayer(String displayer) {
        computer.setDisplayer(displayer);
    }
    public void installMainUnit(String mianUnit) {
        computer.setMainUnit(mianUnit);
    }
    public void installMouse(String mouse) {
        computer.setMouse(mouse);
    }
    public void installKeyboard(String keyboard) {
        computer.setKeyboard(keyboard);
    }
    public Computer Builder() {
        return computer;
    }
}
```

``` java
// 将部分类组装
    public static void main(String[] args) {
        ComputerBuilder computerBuilder = new ComputerBuilder();
        computerBuilder.installDisplayer("显万器");
        computerBuilder.installMainUnit("主机");
        computerBuilder.installKeyboard("键盘");
        computerBuilder.installMouse("鼠标");
        Computer computer = computerBuilder.Builder();
        System.out.println(computer);
    }
```

### Mybaits使用的构建者模式

SqlSessionFactory 的构建过程:Mybatis的初始化工作非常复杂，不是只用一个构造函数就能搞定的。所以使用了建造者模式，使用了 大 量的Builder，进行分层构造，核心对象Configuration使用了 XmlConfigBuilder来进行构造

![image-20211031121557782](https://cdn.wuzx.cool/image-20211031121557782.png)

在Mybatis环境的初始化过程中，SqlSessionFactoryBuilder会调用XMLConfigBuilder读取所有的 MybatisMapConfig.xml 和所有的 *Mapper.xml 文件，构建 Mybatis 运行的核心对象 Configuration 对 象，然后将该Configuration对象作为参数构建一个SqlSessionFactory对象。

其中 XMLConfigBuilder 在构建 Configuration 对象时，也会调用 XMLMapperBuilder 用于读取 *Mapper 文件，而XMLMapperBuilder会使用XMLStatementBuilder来读取和build所有的SQL语句。

在这个过程中，有一个相似的特点，就是这些Builder会读取文件或者配置，然后做大量的XpathParser 解析、配置或语法的解析、反射生成对象、存入结果缓存等步骤，这么多的工作都不是一个构造函数所 能包括的，因此大量采用了 Builder模式来解决

![image-20211031121830635](https://cdn.wuzx.cool/image-20211031121830635.png)

SqlSessionFactoryBuilder类根据不同的输入参数来构建SqlSessionFactory这个工厂对象

# 工厂模式

在Mybatis中比如SqlSessionFactory使用的是工厂模式，该工厂没有那么复杂的逻辑，是一个简单工厂 模式

简单工厂模式(Simple Factory Pattern):又称为静态工厂方法(Static Factory Method)模式，它属于创 建型模式。

在简单工厂模式中，可以根据参数的不同返回不同类的实例。简单工厂模式专⻔定义一个类来负责创建
其他类的实例，被创建的实例通常都具有共同的父类



### **Mybatis** 体现:

Mybatis中执行Sql语句、获取Mappers、管理事务的核心接口SqlSession的创建过程使用到了工厂模

式。有一个 SqlSessionFactory 来负责 SqlSession 的创建

![image-20211031123254955](https://cdn.wuzx.cool/image-20211031123254955.png)

SqlSessionFactory
 可以看到，该Factory的openSession ()方法重载了很多个，分别支 持**autoCommit**、**Executor**、**Transaction**等参数的输入，来构建核心的SqlSession对象。 在**DefaultSqlSessionFactory**的默认工厂实现里，有一个方法可以看出工厂怎么产出一个产品:

``` java
    private SqlSession openSessionFromDataSource(ExecutorType execType, TransactionIsolationLevel level, boolean autoCommit) {
        Transaction tx = null;
        try {
            // 获得 Environment 对象
            final Environment environment = configuration.getEnvironment();
            // 创建 Transaction 对象
            final TransactionFactory transactionFactory = getTransactionFactoryFromEnvironment(environment);
            tx = transactionFactory.newTransaction(environment.getDataSource(), level, autoCommit);
            // 创建 Executor 对象
            final Executor executor = configuration.newExecutor(tx, execType);
            // 创建 DefaultSqlSession 对象
            return new DefaultSqlSession(configuration, executor, autoCommit);
        } catch (Exception e) {
            // 如果发生异常，则关闭 Transaction 对象
            closeTransaction(tx); // may have fetched a connection so lets call close()
            throw ExceptionFactory.wrapException("Error opening session.  Cause: " + e, e);
        } finally {
            ErrorContext.instance().reset();
        }
    }
```

这是一个openSession调用的底层方法，该方法先从configuration读取对应的环境配置，然后初始化 TransactionFactory 获得一个 Transaction 对象，然后通过 Transaction 获取一个 Executor 对象，最 后通过configuration、Executor、是否autoCommit三个参数构建了 SqlSession



# 代理模式

代理模式(Proxy Pattern):给某一个对象提供一个代理，并由代理对象控制对原对象的引用。代理模式 的英文叫做Proxy，它是一种对象结构型模式，代理模式分为静态代理和动态代理，我们来介绍动态代 理





## **Mybatis**中实现:

代理模式可以认为是Mybatis的核心使用的模式，正是由于这个模式，我们只需要编写Mapper.java接 口，不需要实现，由Mybati s后台帮我们完成具体SQL的执行。

当我们使用Configuration的getMapper方法时，会调用mapperRegistry.getMapper方法，而该方法又 会调用 mapperProxyFactory.newInstance(sqlSession)来生成一个具体的代理:



非常典型的，该MapperProxy类实现了InvocationHandler接口，并且实现了该接口的invoke方法。通 过这种方式，我们只需要编写Mapper.java接口类，当真正执行一个Mapper接口的时候，就会转发给 MapperProxy.invoke方法，而该方法则会调用后续的 sqlSession.cud>executor.execute>prepareStatement 等一系列方法，完成 SQL 的执行和返回