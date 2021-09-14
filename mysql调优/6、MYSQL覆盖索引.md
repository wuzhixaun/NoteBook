# 基本介绍



+ 如果一个索引包含所有需要查询的字段的值，我们称之为`覆盖索引`
+ 不是所有类型的所有都可以称为覆盖索引，覆盖索引必须要存储索引列的值
+ 不同的存储实现覆盖索引的方式不同，不是所有的引擎都支持覆盖索引，`memory`不支持覆盖索引



# 优势



+ 索引的条目通常小于数据行大小，那么mysql救护极大的较少数据访问量
+ 因为索引是按照列值顺序存储的，所以对应IO密集型的范围查询会比随机从磁盘读取每一行的IO要少的多
+ 一些存储引擎如MYSAM在内存缓存所以，数据则依赖于操作系统来缓存，因此要访问数据需要一些系统调用，这可能会导致严重的性能问题
+ 由于`INNODB`的聚簇所以，覆盖索引对`INNODB`表特别有用



# 案例

1、当发起一个被索引覆盖的查询时，在explain的extra列可以看到using index的信息，此时就使用了覆盖索引

```
mysql> explain select store_id,film_id from inventory\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: inventory
   partitions: NULL
         type: index
possible_keys: NULL
          key: idx_store_id_film_id
      key_len: 3
          ref: NULL
         rows: 4581
     filtered: 100.00
        Extra: Using index
1 row in set, 1 warning (0.01 sec)
```

2、在大多数存储引擎中，覆盖索引只能覆盖那些只访问索引中部分列的查询。不过，可以进一步的进行优化，可以使用innodb的二级索引来覆盖查询。

例如：actor使用innodb存储引擎，并在last_name字段又二级索引，虽然该索引的列不包括主键actor_id，但也能够用于对actor_id做覆盖查询

```
mysql> explain select actor_id,last_name from actor where last_name='HOPPER'\G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: actor
   partitions: NULL
         type: ref
possible_keys: idx_actor_last_name
          key: idx_actor_last_name
      key_len: 137
          ref: const
         rows: 2
     filtered: 100.00
        Extra: Using index
1 row in set, 1 warning (0.00 sec)
```