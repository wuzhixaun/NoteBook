# 为什么需要分布式ID(分布式集群环境下的全局唯一ID)

![image-20211209232217699](https://cdn.wuzx.cool/image-20211209232217699.png)

# UUID

**UUID** 是指Universally Unique Identifier，翻译为中文是通用唯一识别码

产生重复 UUID 并造成错误的情况非常低，是故大可不必考虑此问题。 Java中得到一个UUID，可以使用java.util包提供的方法



# 独立数据库的自增ID

在这个数据库中创建一张表，这张表的ID设置为自增，其他地方 需要全局唯一ID的时候，就模拟向这个Mysql数据库的这张表中模拟插入一条记录，此时ID会自 增，然后我们可以通过Mysql的select last_insert_id() 获取到刚刚这张表中自增生成的ID.



当分布式集群环境中哪个应用需要获取一个全局唯一的分布式ID的时候，就可以使用代码连接这个 数据库实例，执行如下sql语句即可。

``` sql
 insert into DISTRIBUTE_ID(createtime) values(NOW()); 
 select LAST_INSERT_ID();
```

## 注意: 

+ 1)这里的createtime字段无实际意义，是为了随便插入一条数据以至于能够自增id。

+ 2)使用独立的Mysql实例生成分布式id，虽然可行，但是性能和可靠性都不够好，因为你需要代 码连接到数据库才能获取到id，性能无法保障，另外mysql数据库实例挂掉了，那么就无法获取分 布式id了。

# SnowFlake 雪花算法(可以用，推荐)

雪花算法是`Twitter`推出的一个用于生成分布式ID的策略。

雪花算法是一个算法，基于这个算法可以生成ID，生成的ID是一个long型，那么在Java中一个long 型是8个字节，算下来是64bit，如下是使用雪花算法生成的一个ID的二进制形式示意:

![image-20211209233549330](https://cdn.wuzx.cool/image-20211209233549330.png)

+ 滴滴的tinyid(基于数 据库实现)、
+ 百度的uidgenerator(基于SnowFlake)
+ 美团的leaf(基于数据库和SnowFlake) 

# 借助Redis的Incr命令获取全局唯一ID(推荐)

Redis Incr 命令将 key 中储存的数字值增一。如果 key 不存在，那么 key 的值会先被初始化为 0，然后再执行 INCR 操作。