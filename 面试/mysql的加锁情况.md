# mysql的加锁情况

## 1、REPEATABLE-READ隔离级别+表无显式主键和索引

创建表t,没有索引和主键，并插入测试数据

```sql
create table t(id int default null,name char(20) default null);
insert into t values(10,'10'),(20,'20'),(30,'30');
```

手动开启事务，执行语句并采用for update方式（当前读）

```sql
begin;
select * from t for update;
show engine innodb status\G
```

从返回的信息中，可以看到对表添加了IX锁和4个记录锁，表中的三行记录上分别添加了Next-key Lock锁，防止有数据变化发生幻读，例如进行了更新、删除操作。同时会出现“ 0: len 8; hex 73757072656d756d; asc supremum;;”这样的描述信息，此操作也是为了防止幻读，会将最大索引值之后的间隙锁住并用supremum表示高于表中任何一个索引的值。

同表下，如果加上where条件之后，是否会产生Next-key Lock呢？执行如下语句：

```sql
begin;
select * from t where id = 10 for update;
show engine innodb status\G
```

从上述反馈信息中，可以发现跟不加where条件的加锁情况是一样的，会同时出现多个行的临键锁和supremum，这到底是为什么呢？

出现supremum的原因是：虽然where的条件是10，但是每次插入记录时所需要生成的聚簇索引Row_id还是自增的，每次都会在表的最后插入，所以就有可能插入id=10这条记录，因此要添加一个supremum防止数据插入。

**出现其他行的临键锁的原因是：为了防止幻读，如果不添加Next-Key Lock锁，这时若有其他会话执行DELETE或者UPDATE语句，则都会造成幻读。**

## 2、REPEATABLE-READ隔离级别+表有显式主键无索引

创建如下表并添加数据：

```sql
create table t2(id int primary key not null,name char(20) default null);
insert into t2 values(10,'10'),(20,'20'),(30,'30');
```

在此情况下要分为三种情况来进行分析，不同情况的加锁方式也不同：

1、不带where条件

```sql
begin;
select * from t2 for update;
show engine innodb status\G
```

通过上述信息可以看到，与之前的加锁方式是相同的。

2、where条件是主键字段

```sql
begin;
select * from t2 where id = 10 for update;
show engine innodb status\G
```

通过上述信息可以看到，只会对表中添加IX锁和对主键添加了记录锁（X locks rec but not gap）,并且只锁住了where条件id=10这条记录，因为主键已经保证了唯一性，所以在插入时就不会是id=10这条记录。

3、where条件包含主键字段和非关键字段

```sql
begin;
select * from t2 where id = 10 and name = '10' for update;
show engine innodb status\G
```

通过看到，加锁方式与where条件是主键字段的加锁方式相同，因为根据主键字段可以直接定位一条记录。

## 3、REPEATABLE-READ隔离级别+表无显式主键有索引

1、不带where条件，跟之前的情况类似

2、where条件是普通索引字段或者（普通索引字段+非索引字段）

创建如下表：

```sql
create table t3(id int default null,name char(20) default null);
create index idx_id on t3(id);
insert into t3 values(10,'10'),(20,'20'),(30,'30');
```

执行如下语句：

```sql
begin;
select * from t3 where id = 10 for update;
show engine innodb status\G
```

通过上述信息可以看到，对表添加了IX锁，对id=10的索引添加了Next-Key Lock锁，区间是负无穷到10，对索引对应的聚集索引添加了X记录锁，为了防止幻读，对索引记录区间（10，20）添加间隙锁。

此时大家可以开启一个新的事务，插入负无穷到id=19的全部记录都会被阻塞，而大于等于20 的值不会被阻塞

3、where条件是唯一索引字段或者（唯一索引字段+非索引字段）

创建如下表：

```sql
create table t4(id int default null,name char(20) default null);
create unique index idx_id on t4(id);
insert into t4 values(10,'10'),(20,'20'),(30,'30');
```

执行如下语句：

```sql
begin;
select * from t4 where id = 10 for update;
show engine innodb status\G
```

通过上述信息可以看到，此方式与where条件是主键字段的加锁情况相同，表无显式主键则会把唯一索引作为主键，因为是主键，所以不能再插入id=10这条记录，因此也不需要间隙锁。

## 4、REPEATABLE-READ隔离级别+表有显式主键和索引

此情况可以分为以下几种：

1、表有显式主键和普通索引

创建如下表：

```sql
create table t5(id int not null,name char(20) default null,primary key(id),key idx_name(name));
insert into t5 values(10,'10'),(20,'20'),(30,'30');
```

(1)不带where条件

```sql
begin;
select * from t5 for update;
show engine innodb status\G
```

通过上述信息可以看到，首先对表添加IX锁，然后对supremum添加临键锁，对name索引列添加临键锁，对主键索引添加X记录锁

(2)where条件是普通索引字段

```sql
begin;
select * from t5 where name='10' for update;
show engine innodb status\G
```

通过上述信息可以看到，首先对表添加IX锁，然后对name添加临键锁，对主键索引列添加X记录锁，为了防止幻读，对name的（10，20）添加间隙锁

(3)where条件是主键字段

```sql
begin;
select * from t5 where id=10 for update;
show engine innodb status\G
```

通过上述信息可以看到，对表添加了意向锁，对主键添加了记录锁。

(4)where条件同时包含普通索引字段和主键索引字段

```sql
begin;
select * from t5 where id=10 and name='10' for update;
show engine innodb status\G
```

此处大家需要注意，如果在执行过程中使用的是主键索引，那么跟使用主键字段是一致的，如果使用的是普通索引，那么跟普通字段是类似的，其实本质点就在于加锁的字段不同而已。

2、表有显式主键和唯一索引

创建如下表：

```sql
create table t6(id int not null,name char(20) default null,primary key(id),unique key idx_name(name));
insert into t6 values(10,'10'),(20,'20'),(30,'30');
```

(1)不带where条件

```sql
begin;
select * from t6 for update;
show engine innodb status\G
```

通过上述信息可以看到，首先对表添加IX锁，然后对supremum添加临键锁，对name索引列添加临键锁，对主键索引添加X记录锁

(2)where条件是唯一索引字段

```sql
begin;
select * from t6 where name='10' for update;
show engine innodb status\G
```

通过上述信息可以看到，首先对表添加IX锁，然后对name和主键添加行锁

(3)where条件是主键字段

```sql
begin;
select * from t6 where id=10 for update;
show engine innodb status\G
```

通过上述信息可以看到，首先对表添加IX锁，然后主键添加行锁

(4)where条件是唯一索引字段和主键字段

```sql
begin;
select * from t6 where id=10 and name='10' for update;
show engine innodb status\G
```

此处大家需要注意，如果在执行过程中使用的是主键索引，那么跟使用主键字段是一致的，如果使用的是唯一索引，那么跟唯一索引字段是一样的，其实本质点就在于加锁的字段不同而已。

## 5、READ-COMMITTED隔离级别+表无显式主键和索引

创建表t,没有索引和主键，并插入测试数据

```sql
create table t7(id int default null,name char(20) default null);
insert into t7 values(10,'10'),(20,'20'),(30,'30');
```

手动开启事务，执行语句并采用for update方式（当前读）

```sql
begin;
select * from t7 for update;
show engine innodb status\G
```

通过上述信息可以看到，首先对表添加IX锁，然后对表的三行记录添加记录锁（聚簇索引）

同表下，如果加上where条件之后，是否会产生Next-key Lock呢？执行如下语句：

```sql
begin;
select * from t7 where id = 10 for update;
show engine innodb status\G
```

通过上述信息可以看到，首先对表添加IX锁，然后会对聚集索引添加记录锁，因为RC隔离级别无法解决幻读问题，所以不会添加临键锁。

## 6、READ-COMMITTED隔离级别+表有显式主键无索引

创建如下表并添加数据：

```sql
create table t8(id int primary key not null,name char(20) default null);
insert into t8 values(10,'10'),(20,'20'),(30,'30');
```

在此情况下要分为三种情况来进行分析，不同情况的加锁方式也不同：

1、不带where条件

```sql
begin;
select * from t8 for update;
show engine innodb status\G
```

通过上述信息可以看到，首先对表添加IX锁，然后对表的三行记录添加记录锁（主键）

2、where条件是主键字段

```sql
begin;
select * from t8 where id = 10 for update;
show engine innodb status\G
```

通过上述信息可以看到，首先对表添加IX锁，然后对表id=10的积累添加记录锁

3、where条件包含主键字段和非关键字段

```sql
begin;
select * from t8 where id = 10 and name = '10' for update;
show engine innodb status\G
```

通过上述信息可以看到，首先对表添加IX锁，然后对表id=10的积累添加记录锁

## 7、READ-COMMITTED隔离级别+表无显式主键有索引

创建如下表：

```sql
create table t9(id int default null,name char(20) default null);
create index idx_id on t9(id);
insert into t9 values(10,'10'),(20,'20'),(30,'30');
```

1、不带where条件，跟之前的情况类似

```sql
begin;
select * from t9 for update;
show engine innodb status\G
```

通过上述信息可以看到，首先对表添加IX锁，然后对表的三行记录添加记录锁（聚簇索引）

2、where条件是普通索引字段或者（普通索引字段+非索引字段）

执行如下语句：

```sql
begin;
select * from t9 where id = 10 for update;
show engine innodb status\G
```

通过上述信息可以看到，对表添加了IX锁，对id=10的索引添加了行锁，对索引对应的聚集索引添加了行锁，

3、where条件是唯一索引字段或者（唯一索引字段+非索引字段）

创建如下表：

```sql
create table t10(id int default null,name char(20) default null);
create unique index idx_id on t10(id);
insert into t10 values(10,'10'),(20,'20'),(30,'30');
```

执行如下语句：

```sql
begin;
select * from t10 where id = 10 for update;
show engine innodb status\G
```

通过上述信息可以看到，对表添加了IX锁，对id=10的索引添加了行锁，对索引对应的聚集索引添加了行锁。

## 8、READ-COMMITTED隔离级别+表有显式主键和索引

此情况可以分为以下几种：

1、表有显式主键和普通索引

创建如下表：

```sql
create table t11(id int not null,name char(20) default null,primary key(id),key idx_name(name));
insert into t11 values(10,'10'),(20,'20'),(30,'30');
```

(1)不带where条件

```sql
begin;
select * from t11 for update;
show engine innodb status\G
```

通过上述信息可以看到，首先对表添加IX锁，然后对name索引列添加记录锁，对主键索引添加X记录锁

(2)where条件是普通索引字段

```sql
begin;
select * from t11 where name='10' for update;
show engine innodb status\G
```

通过上述信息可以看到，首先对表添加IX锁，然后对name添加X记录锁，对主键索引列添加X记录锁

(3)where条件是主键字段

```sql
begin;
select * from t11 where id=10 for update;
show engine innodb status\G
```

通过上述信息可以看到，对表添加了意向锁，对主键添加了记录锁。

(4)where条件同时包含普通索引字段和主键索引字段

```sql
begin;
select * from t11 where id=10 and name='10' for update;
show engine innodb status\G
```

此处大家需要注意，如果在执行过程中使用的是主键索引，那么跟使用主键字段是一致的，如果使用的是普通索引，那么跟普通字段是类似的，其实本质点就在于加锁的字段不同而已。

2、表有显式主键和唯一索引

创建如下表：

```sql
create table t12(id int not null,name char(20) default null,primary key(id),unique key idx_name(name));
insert into t12 values(10,'10'),(20,'20'),(30,'30');
```

(1)不带where条件

```sql
begin;
select * from t12 for update;
show engine innodb status\G
```

通过上述信息可以看到，首先对表添加IX锁，然后对name索引列添加X记录锁，对主键索引添加X记录锁

(2)where条件是唯一索引字段

```sql
begin;
select * from t12 where name='10' for update;
show engine innodb status\G
```

通过上述信息可以看到，首先对表添加IX锁，然后对name和主键添加行锁

(3)where条件是主键字段

```sql
begin;
select * from t12 where id=10 for update;
show engine innodb status\G
```

通过上述信息可以看到，首先对表添加IX锁，然后主键添加行锁

(4)where条件是唯一索引字段和主键字段

```sql
begin;
select * from t6 where id=10 and name='10' for update;
show engine innodb status\G
```

此处大家需要注意，如果在执行过程中使用的是主键索引，那么跟使用主键字段是一致的，如果使用的是唯一索引，那么跟唯一索引字段是一样的，其实本质点就在于加锁的字段不同而已。