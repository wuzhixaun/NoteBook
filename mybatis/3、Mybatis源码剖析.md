[TOC]

# 一、传统方式

## 1.1 源码剖析**-**初始化

``` java
// 1. 读取配置文件，读成字节输入流，注意：现在还没解析
InputStream resourceAsStream = Resources.getResourceAsStream("sqlMapConfig.xml");

// 2. 解析配置文件，封装Configuration对象   创建DefaultSqlSessionFactory对象
SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(resourceAsStream);

// 3. 生产了DefaultSqlsession实例对象   设置了事务不自动提交  完成了executor对象的创建
SqlSession sqlSession = sqlSessionFactory.openSession();

// 4.(1)根据statementid来从Configuration中map集合中获取到了指定的MappedStatement对象
//(2)将查询任务委派了executor执行器
User user =  sqlSession.selectOne("com.lagou.mapper.IUserMapper.findById",1);
System.out.println(user);
User user2 =  sqlSession.selectOne("com.lagou.mapper.IUserMapper.findById",1);
System.out.println(user2);

// 5.释放资源
sqlSession.close();
```

## 1.2 初始化

``` java
// 1我们最初调用的build
public SqlSessionFactory build (InputStream inputStream){
		//调用了重载方法
    return build(inputStream, null, null);
}

    // 2.调用的重载方法
      public SqlSessionFactory build(InputStream inputStream, String environment, Properties properties) {
          try {
              // 创建 XMLConfigBuilder, XMLConfigBuilder是专门解析mybatis的配置文件的类
              XMLConfigBuilder parser = new XMLConfigBuilder(inputStream, environment, properties);
              // 执行 XML 解析
              // 创建 DefaultSqlSessionFactory 对象
              return build(parser.parse());
          } catch (Exception e) {
              throw ExceptionFactory.wrapException("Error building SqlSession.", e);
          } finally {
              ErrorContext.instance().reset();
              try {
                  inputStream.close();
              } catch (IOException e) {
                  // Intentionally ignore. Prefer previous error.
              }
          }
      }
      
     /**
     * 3解析 XML 成 Configuration 对象。
     *
     * @return Configuration 对象
     */
    public Configuration parse() {
        // 若已解析，抛出 BuilderException 异常
        if (parsed) {
            throw new BuilderException("Each XMLConfigBuilder can only be used once.");
        }
        // 标记已解析
        parsed = true;
        ///parser是XPathParser解析器对象，读取节点内数据，<configuration>是MyBatis配置文件中的顶层标签
        // 解析 XML configuration 节点
        parseConfiguration(parser.evalNode("/configuration"));
        return configuration;
    }
    
    
    
    /**
     * 4、解析 XML
     *
     * 具体 MyBatis 有哪些 XML 标签，参见 《XML 映射配置文件》http://www.mybatis.org/mybatis-3/zh/configuration.html
     *
     * @param root 根节点
     */
    private void parseConfiguration(XNode root) {
        try {
            //issue #117 read properties first
            // 解析 <properties /> 标签
            propertiesElement(root.evalNode("properties"));
            // 解析 <settings /> 标签
            Properties settings = settingsAsProperties(root.evalNode("settings"));
            // 加载自定义的 VFS 实现类
            loadCustomVfs(settings);
            // 解析 <typeAliases /> 标签
            typeAliasesElement(root.evalNode("typeAliases"));
            // 解析 <plugins /> 标签
            pluginElement(root.evalNode("plugins"));
            // 解析 <objectFactory /> 标签
            objectFactoryElement(root.evalNode("objectFactory"));
            // 解析 <objectWrapperFactory /> 标签
            objectWrapperFactoryElement(root.evalNode("objectWrapperFactory"));
            // 解析 <reflectorFactory /> 标签
            reflectorFactoryElement(root.evalNode("reflectorFactory"));
            // 赋值 <settings /> 到 Configuration 属性
            settingsElement(settings);
            // read it after objectFactory and objectWrapperFactory issue #631
            // 解析 <environments /> 标签
            environmentsElement(root.evalNode("environments"));
            // 解析 <databaseIdProvider /> 标签
            databaseIdProviderElement(root.evalNode("databaseIdProvider"));
            // 解析 <typeHandlers /> 标签
            typeHandlerElement(root.evalNode("typeHandlers"));
            // 解析 <mappers /> 标签
            mapperElement(root.evalNode("mappers"));
        } catch (Exception e) {
            throw new BuilderException("Error parsing SQL Mapper Configuration. Cause: " + e, e);
        }
    }
    
    
     
// 5.调用的重载方法
public SqlSessionFactory build(Configuration config) {
//创建了 DefaultSqlSessionFactory 对象，传入 Configuration 对象。
  return new DefaultSqlSessionFactory(config);
}
      
```

+ MyBatis在初始化的时候，会将MyBatis的配置信息全部加载到内存中，使用 org.apache.ibatis.session.Configuratio n 实例来存储
+ 

### 1.2.1 Configuration对象进行介绍

``` XML
 Configuration对象的结构和xml配置文件的对象几乎相同。
回顾一下xml中的配置标签有哪些:
properties (属性)，settings (设置)，typeAliases (类型别名)，typeHandlers (类型处理 器)，objectFactory (对象工厂)，mappers (映射器)等 Configuration也有对应的对象属性来封 装它们
也就是说，初始化配置文件信息的本质就是创建Configuration对象，将解析的xml数据封装到 Configuration内部属性中
```

### 1.2.2 MappedStatement介绍

MappedStatement与Mapper配置文件中的一个select/update/insert/delete节点相对应。 mapper中配置的标签都被封装到了此对象中，主要用途是描述一条SQL语句

``` java
 Map<String, MappedStatement> mappedStatements = new StrictMap<MappedStatement>
("Mapped Statements collection")
```

## 2、源码剖析**-**执行**SQL**流程



### 2.1 SqlSession介绍

> SqlSession是一个接口，它有两个实现类:DefaultSqlSession (默认)和 SqlSessionManager (弃用，不做介绍)
>
> SqlSession是MyBatis中用于和数据库交互的顶层类，通常将它与ThreadLocal绑定，一个会话使用一 个SqlSession,并且在使用完毕后需要close

``` java
SqlSession中的两个最重要的参数，configuration与初始化时的相同，Executor为执行器
public class DefaultSqlSession implements SqlSession {
		private final Configuration configuration;
		private final Executor executor;
j
```

### 2.2 Executor 介绍

>  Executor也是一个接口，他有三个常用的实现类:
>
> + BatchExecutor (重用语句并执行批量更新)
> + ReuseExecutor (重用预处理语句 prepared statements)
> + SimpleExecutor (普通的执行器，默认)

``` java
 SqlSession sqlSession = factory.openSession();
List<User> list =
sqlSession.selectList("com.lagou.mapper.UserMapper.getUserByName");

 
//6. 进入 o penSession 方法。
public SqlSession openSession() {
  //getDefaultExecutorType()传递的是SimpleExecutor
  return openSessionFromDataSource(configuration.getDefaultExecutorType(), null, false);
}

    //7. 进入openSessionFromDataSource。
    //ExecutorType 为Executor的类型，TransactionIsolationLevel为事务隔离级别，autoCommit是否开启事务
    //openSession的多个重载方法可以指定获得的SeqSession的Executor类型和事务的处理
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

执行 sqlsession 中的 api

``` java
    public <E> List<E> selectList(String statement, Object parameter, RowBounds rowBounds) {
        try {
            //根据传入的全限定名+方法名从映射的Map中取出MappedStatement对象
            MappedStatement ms = configuration.getMappedStatement(statement);
            // 执行查询
          	// 调用Executor中的方法处理
         		 //RowBounds是用来逻辑分⻚
         		 // wrapCollection(parameter)是用来装饰集合或者数组参数
            return executor.query(ms, wrapCollection(parameter), rowBounds, Executor.NO_RESULT_HANDLER);
        } catch (Exception e) {
            throw ExceptionFactory.wrapException("Error querying database.  Cause: " + e, e);
        } finally {
            ErrorContext.instance().reset();
        }
    }
```

## 源码剖析**-executor**

``` java
    //此方法在SimpleExecutor的父类BaseExecutor中实现
    @Override
    public <E> List<E> query(MappedStatement ms, Object parameter, RowBounds rowBounds, ResultHandler resultHandler) throws SQLException {
        //根据传入的参数动态获得SQL语句，最后返回用BoundSql对象表示
        BoundSql boundSql = ms.getBoundSql(parameter);
        //为本次查询创建缓存的Key
        CacheKey key = createCacheKey(ms, parameter, rowBounds, boundSql);
        // 查询
        return query(ms, parameter, rowBounds, resultHandler, key, boundSql);
    }

    // 从数据库中读取操作
    private <E> List<E> queryFromDatabase(MappedStatement ms, Object parameter, RowBounds rowBounds, ResultHandler resultHandler, CacheKey key, BoundSql boundSql) throws SQLException {
        List<E> list;
        // 在缓存中，添加占位对象。此处的占位符，和延迟加载有关，可见 `DeferredLoad#canLoad()` 方法
        localCache.putObject(key, EXECUTION_PLACEHOLDER);
        try {
            // 执行读操作
            list = doQuery(ms, parameter, rowBounds, resultHandler, boundSql);
        } finally {
            // 从缓存中，移除占位对象
            localCache.removeObject(key);
        }
        // 添加到缓存中
        localCache.putObject(key, list);
        // 暂时忽略，存储过程相关
        if (ms.getStatementType() == StatementType.CALLABLE) {
            localOutputParameterCache.putObject(key, parameter);
        }
        return list;
    }

    public <E> List<E> doQuery(MappedStatement ms, Object parameter, RowBounds rowBounds, ResultHandler resultHandler, BoundSql boundSql) throws SQLException {
        Statement stmt = null;
        try {
            Configuration configuration = ms.getConfiguration();
            // 传入参数创建StatementHanlder对象来执行查询
            StatementHandler handler = configuration.newStatementHandler(wrapper, ms, parameter, rowBounds, resultHandler, boundSql);
            // 创建jdbc中的statement对象
            stmt = prepareStatement(handler, ms.getStatementLog());
            // 执行 StatementHandler  ，进行读操作
            return handler.query(stmt, resultHandler);
        } finally {
            // 关闭 StatementHandler 对象
            closeStatement(stmt);
        }
    }


    // 初始化 StatementHandler 对象
    private Statement prepareStatement(StatementHandler handler, Log statementLog) throws SQLException {
        Statement stmt;
        // 获得 Connection 对象
        Connection connection = getConnection(statementLog);
        // 创建 Statement 或 PrepareStatement 对象
        stmt = handler.prepare(connection, transaction.getTimeout());
        // 设置 SQL 上的参数，例如 PrepareStatement 对象上的占位符
        handler.parameterize(stmt);
        return stmt;
    }
```

> Executor.query()方法几经转折,最后会创建一个StatementHandler对象，然后将必要的参数传 递给
>
> StatementHandler，使用StatementHandler来完成对数据库的查询，最终返回List结果集
>
> 从上面的代码中我们可以看出，Executor的功能和作用是:
>
> ![image-20211030001728653](https://cdn.wuzx.cool/image-20211030001728653.png)

## 源码剖析**-StatementHandler**

StatementHandler对象主要完成两个工作:

+ 对于JDBC的PreparedStatement类型的对象，创建的过程中，我们使用的是SQL语句字符串会包 含若干个?占位符，我们其后再对占位符进行设值。StatementHandler通过 parameterize(statement)方法对 S tatement 进行设值;
+ StatementHandler 通过 List query(Statement statement, ResultHandler resultHandler)方法来 完成执行Statement，和将Statement对象返回的resultSet封装成List

``` java
public void parameterize(Statement statement) throws SQLException {
        //使用ParameterHandler对象来完成对Statement的设值
        parameterHandler.setParameters((PreparedStatement) statement);
    }


   public void setParameters(PreparedStatement ps) {
        ErrorContext.instance().activity("setting parameters").object(mappedStatement.getParameterMap().getId());
        // 遍历 ParameterMapping 数组
        List<ParameterMapping> parameterMappings = boundSql.getParameterMappings();
        if (parameterMappings != null) {
            for (int i = 0; i < parameterMappings.size(); i++) {
                // 获得 ParameterMapping 对象
                ParameterMapping parameterMapping = parameterMappings.get(i);
                if (parameterMapping.getMode() != ParameterMode.OUT) {
                    // 获得值
                    Object value;
                    String propertyName = parameterMapping.getProperty();
                    if (boundSql.hasAdditionalParameter(propertyName)) { // issue #448 ask first for additional params
                        value = boundSql.getAdditionalParameter(propertyName);
                    } else if (parameterObject == null) {
                        value = null;
                    } else if (typeHandlerRegistry.hasTypeHandler(parameterObject.getClass())) {
                        value = parameterObject;
                    } else {
                        MetaObject metaObject = configuration.newMetaObject(parameterObject);
                        value = metaObject.getValue(propertyName);
                    }
                    // 获得 typeHandler、jdbcType 属性
                    TypeHandler typeHandler = parameterMapping.getTypeHandler();
                    JdbcType jdbcType = parameterMapping.getJdbcType();
                    if (value == null && jdbcType == null) {
                        jdbcType = configuration.getJdbcTypeForNull();
                    }
                    // 设置 ? 占位符的参数
                    try {
                        typeHandler.setParameter(ps, i + 1, value, jdbcType);
                    } catch (TypeException | SQLException e) {
                        throw new TypeException("Could not set parameters for mapping: " + parameterMapping + ". Cause: " + e, e);
                    }
                }
            }
        }
    }
```

StatementHandler 的List query(Statement statement, ResultHandler resultHandler)方法的实现，是调用了 ResultSetHandler 的 handleResultSets(Statement)方法。

ResultSetHandler 的 handleResultSets(Statement)方法会将 Statement 语句执行后生成的 resultSet 结 果集转换成List结果集

``` 
    public <E> List<E> query(Statement statement, ResultHandler resultHandler) throws SQLException {
        PreparedStatement ps = (PreparedStatement) statement;
        // 执行查询
        ps.execute();
        // 处理返回结果
        return resultSetHandler.handleResultSets(ps);
    }
    
    
    public List<Object> handleResultSets(Statement stmt) throws SQLException {
        ErrorContext.instance().activity("handling results").object(mappedStatement.getId());

        // 多 ResultSet 的结果集合，每个 ResultSet 对应一个 Object 对象。而实际上，每个 Object 是 List<Object> 对象。
        // 在不考虑存储过程的多 ResultSet 的情况，普通的查询，实际就一个 ResultSet ，也就是说，multipleResults 最多就一个元素。
        final List<Object> multipleResults = new ArrayList<>();

        int resultSetCount = 0;
        // 获得首个 ResultSet 对象，并封装成 ResultSetWrapper 对象
        ResultSetWrapper rsw = getFirstResultSet(stmt);

        // 获得 ResultMap 数组
        // 在不考虑存储过程的多 ResultSet 的情况，普通的查询，实际就一个 ResultSet ，也就是说，resultMaps 就一个元素。
        List<ResultMap> resultMaps = mappedStatement.getResultMaps();
        int resultMapCount = resultMaps.size();
        validateResultMapsCount(rsw, resultMapCount); // 校验
        while (rsw != null && resultMapCount > resultSetCount) {
            // 获得 ResultMap 对象
            ResultMap resultMap = resultMaps.get(resultSetCount);
            // 处理 ResultSet ，将结果添加到 multipleResults 中
            handleResultSet(rsw, resultMap, multipleResults, null);
            // 获得下一个 ResultSet 对象，并封装成 ResultSetWrapper 对象
            rsw = getNextResultSet(stmt);
            // 清理
            cleanUpAfterHandlingResultSet();
            // resultSetCount ++
            resultSetCount++;
        }

        // 因为 `mappedStatement.resultSets` 只在存储过程中使用，本系列暂时不考虑，忽略即可
        String[] resultSets = mappedStatement.getResultSets();
        if (resultSets != null) {
            while (rsw != null && resultSetCount < resultSets.length) {
                ResultMapping parentMapping = nextResultMaps.get(resultSets[resultSetCount]);
                if (parentMapping != null) {
                    String nestedResultMapId = parentMapping.getNestedResultMapId();
                    ResultMap resultMap = configuration.getResultMap(nestedResultMapId);
                    handleResultSet(rsw, resultMap, null, parentMapping);
                }
                rsw = getNextResultSet(stmt);
                cleanUpAfterHandlingResultSet();
                resultSetCount++;
            }
        }

        // 如果是 multipleResults 单元素，则取首元素返回
        return collapseSingleResultList(multipleResults);
    }
```



# 二、Mapper代理方式

MyBatis初始化时对接口的处理:MapperRegistry是Configuration中的一个属性， 它内部维护一个HashMap用于存放mapper接口的工厂类，每个接口对应一个工厂类。mappers中可以配置接口的包路径，或者某个具体的接口类。

## 源码剖析**-getmapper()**

``` java
    public <T> T getMapper(Class<T> type) {
        return configuration.getMapper(type, this);
    }
    public <T> T getMapper(Class<T> type, SqlSession sqlSession) {
        return mapperRegistry.getMapper(type, sqlSession);
    }
    public <T> T getMapper(Class<T> type, SqlSession sqlSession) {
        // 获得 MapperProxyFactory 对象
        final MapperProxyFactory<T> mapperProxyFactory = (MapperProxyFactory<T>) knownMappers.get(type);
        // 不存在，则抛出 BindingException 异常
        if (mapperProxyFactory == null) {
            throw new BindingException("Type " + type + " is not known to the MapperRegistry.");
        }
        /// 通过动态代理工厂生成实例。
        try {
            return mapperProxyFactory.newInstance(sqlSession);
        } catch (Exception e) {
            throw new BindingException("Error getting mapper instance. Cause: " + e, e);
        }
    }

   //MapperProxyFactory类中的newInstance方法
    public T newInstance(SqlSession sqlSession) {
        // 创建了JDK动态代理的invocationHandler接口的实现类mapperProxy
        final MapperProxy<T> mapperProxy = new MapperProxy<>(sqlSession, mapperInterface, methodCache);
        // 调用了重载方法
        return newInstance(mapperProxy);
    }
    protected T newInstance(MapperProxy<T> mapperProxy) {

        return (T) Proxy.newProxyInstance(mapperInterface.getClassLoader(), new Class[]{mapperInterface}, mapperProxy);
    }
```

## 源码剖析**-invoke()** 



``` java
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        try {
            // 如果是 Object 定义的方法，直接调用
            if (Object.class.equals(method.getDeclaringClass())) {
                return method.invoke(this, args);

            } else if (isDefaultMethod(method)) {
                return invokeDefaultMethod(proxy, method, args);
            }
        } catch (Throwable t) {
            throw ExceptionUtil.unwrapThrowable(t);
        }
        // 获得 MapperMethod 对象
        final MapperMethod mapperMethod = cachedMapperMethod(method);
        // 重点在这：MapperMethod最终调用了执行的方法
        return mapperMethod.execute(sqlSession, args);
    }
public Object execute(SqlSession sqlSession, Object[] args) {
        Object result;
        //判断mapper中的方法类型，最终调用的还是SqlSession中的方法
        switch (command.getType()) {
            case INSERT: {
                // 转换参数
                Object param = method.convertArgsToSqlCommandParam(args);
                // 执行 INSERT 操作
                // 转换 rowCount
                result = rowCountResult(sqlSession.insert(command.getName(), param));
                break;
            }
            case UPDATE: {
                // 转换参数
                Object param = method.convertArgsToSqlCommandParam(args);
                // 转换 rowCount
                result = rowCountResult(sqlSession.update(command.getName(), param));
                break;
            }
            case DELETE: {
                // 转换参数
                Object param = method.convertArgsToSqlCommandParam(args);
                // 转换 rowCount
                result = rowCountResult(sqlSession.delete(command.getName(), param));
                break;
            }
            case SELECT:
                // 无返回，并且有 ResultHandler 方法参数，则将查询的结果，提交给 ResultHandler 进行处理
                if (method.returnsVoid() && method.hasResultHandler()) {
                    executeWithResultHandler(sqlSession, args);
                    result = null;
                // 执行查询，返回列表
                } else if (method.returnsMany()) {
                    result = executeForMany(sqlSession, args);
                // 执行查询，返回 Map
                } else if (method.returnsMap()) {
                    result = executeForMap(sqlSession, args);
                // 执行查询，返回 Cursor
                } else if (method.returnsCursor()) {
                    result = executeForCursor(sqlSession, args);
                // 执行查询，返回单个对象
                } else {
                    // 转换参数
                    Object param = method.convertArgsToSqlCommandParam(args);
                    // 查询单条
                    result = sqlSession.selectOne(command.getName(), param);
                    if (method.returnsOptional() &&
                            (result == null || !method.getReturnType().equals(result.getClass()))) {
                        result = Optional.ofNullable(result);
                    }
                }
                break;
            case FLUSH:
                result = sqlSession.flushStatements();
                break;
            default:
                throw new BindingException("Unknown execution method for: " + command.getName());
        }
        // 返回结果为 null ，并且返回类型为基本类型，则抛出 BindingException 异常
        if (result == null && method.getReturnType().isPrimitive() && !method.returnsVoid()) {
            throw new BindingException("Mapper method '" + command.getName()
                    + " attempted to return null from a method with a primitive return type (" + method.getReturnType() + ").");
        }
        // 返回结果
        return result;
    }

```

