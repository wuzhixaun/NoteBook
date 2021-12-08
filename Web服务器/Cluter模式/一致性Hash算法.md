# 分布式和集群

> 分布式和集群是不一样的，分布式一定是集群，但是集群不一定是分布式
>
> 因为集群就是多个实例一起 工作，分布式将一个系统拆分之后那就是多个实例;集群并不一定是分布式，因为复制型的集群不是拆 分而是复制

# 一、Hash算法应用场景

Hash算法在分布式集群架构中的应用场景

> Hash算法在很多分布式集群产品中都有应用，比如分布式集群架构Redis、Hadoop、ElasticSearch，Mysql分库分表，Nginx负载均衡等

+ 请求的负载均衡(比如nginx的ip_hash策略)

  ginx的IP_hash策略可以在客户端ip不变的情况下，将其发出的请求始终路由到同一个目标服务

  器上，实现会话粘滞，避免处理session共享问题

  ![image-20211208224812109](https://cdn.wuzx.cool/image-20211208224812109.png)

+ 分布式存储

  以分布式内存数据库Redis为例,集群中有redis1，redis2，redis3 三台Redis服务器

  那么,在进行数据存储时,<key1,value1>数据存储到哪个服务器当中呢?针对key进行hash处理 hash(key1)%3=index, 使用余数index锁定存储的具体服务器节点



# 二、普通**Hash**算法存在的问题

![image-20211208230504450](https://cdn.wuzx.cool/image-20211208230504450.png)

> 后台服务器很多台，客户端也有很多，那么影响是很大的，缩容和扩容都会存
> 在这样的问题，大量用户的请求会被路由到其他的目标服务器处理，用户在原来服务器中的会话都会丢
> 失。

# 三、一致性**Hash**算法

## 一致性哈希算法思路如下:

![image-20211208230730347](https://cdn.wuzx.cool/image-20211208230730347.png)

## 服务器缩容

![image-20211208231154415](https://cdn.wuzx.cool/image-20211208231154415.png)

## 服务器扩容

![image-20211208231418166](https://cdn.wuzx.cool/image-20211208231418166.png)



## 一致性hash算法 + 虚拟节点方案

![image-20211208232055682](https://cdn.wuzx.cool/image-20211208232055682.png)

+ 如前所述，每一台服务器负责一段，一致性哈希算法对于节点的增减都只需重定位环空间中的一小 部分数据，具有较好的容错性和可扩展性。但是，一致性哈希算法在服务节点太少时，容易因为节点分部不均匀而造成数据倾斜问题。例如系统中 只有两台服务器，其环分布如下，节点2只能负责非常小的一段，大量的客户端请求落在了节点1上，这就是数据(请求)倾斜问题

+ 为了解决这种数据倾斜问题，一致性哈希算法引入了虚拟节点机制，即对每一个服务节点计算多个哈希，每个计算结果位置都放置一个此服务节点，称为虚拟节点。具体做法可以在服务器ip或主机名的后面增加编号来实现。比如，可以为每台服务器计算三个虚拟节 点，于是可以分别计算 “节点1的ip#1”、“节点1的ip#2”、“节点1的ip#3”、“节点2的ip#1”、“节点2的 ip#2”、“节点2的ip#3”的哈希值，于是形成六个虚拟节点，当客户端被路由到虚拟节点的时候其实是被 路由到该虚拟节点所对应的真实节点

# 四、手写Hash算法

## 普通hash算法

``` java
public class GeneralHash {

    public static void main(String[] args) {
        // 定义客户端ip
        String[] clients = new String[]{"10.78.12.3", "113.25.63.1", "126.12.3.8"};
        int serverCount = 3;
        for (String client : clients) {
            int hash = Math.abs(client.hashCode());
            int index = hash % serverCount;
            System.out.println("客户端ip: " + client + " 路由服务器：" + index);
        }

    }
}
```

## 一致性hash算法

``` java
public class ConsistentHash {


    public static void main(String[] args) {

        // step1 服务器节点Iphash对应哈希环
        String[] tomcatServer = new String[]{"123.111.0.1", "123.103.3.1", "123.20.35.2", "123.98.26.3"};

        SortedMap<Integer, String> hashServerMap = new TreeMap<>();

        for (String server : tomcatServer) {
            // ip对应的hash值
            final int hash = Math.abs(server.hashCode());
            // 存储 hash 对应服务器
            hashServerMap.put(hash, server);
        }

        //  step2 客户端IP求出hash值
        String[] clients = new String[]{"10.78.12.3", "113.25.63.1", "126.12.3.8"};

        for (String client : clients) {
            // ip对应的hash值
            final int hash = Math.abs(client.hashCode());

            final SortedMap<Integer, String> integerStringSortedMap = hashServerMap.tailMap(hash);

            if (integerStringSortedMap.isEmpty()) {
                final Integer firstKey = hashServerMap.firstKey();
                System.out.println("客户端：" + client + "服务器：" + hashServerMap.get(firstKey));
            } else {
                final Integer firstKey = integerStringSortedMap.firstKey();
                System.out.println("客户端：" + client + "服务器：" + integerStringSortedMap.get(firstKey));
            }
        }
    }
}
```

## 一致性Hash算法实现(含虚拟节点)

``` java
public class ConsistentHashVirtual {


    public static void main(String[] args) {

        // step1 服务器节点Iphash对应哈希环
        String[] tomcatServer = new String[]{"123.111.0.1", "123.103.3.1", "123.20.35.2", "123.98.26.3"};

        SortedMap<Integer, String> hashServerMap = new TreeMap<>();

        //  定义每个服务器虚拟多少个节点
        int virtualCount = 3;

        for (String server : tomcatServer) {
            // ip对应的hash值
            final int hash = Math.abs(server.hashCode());
            // 存储 hash 对应服务器
            hashServerMap.put(hash, server);

            for (int i = 0; i < virtualCount; i++) {
                // ip对应的hash值
                final int virtualHash = Math.abs((server+"#"+i).hashCode());
                // 存储 hash 对应服务器
                hashServerMap.put(virtualHash, "虚拟节点"+ server);
            }
        }

        //  step2 客户端IP求出hash值
        String[] clients = new String[]{"10.78.12.3", "113.25.63.1", "126.12.3.8"};

        for (String client : clients) {
            // ip对应的hash值
            final int hash = Math.abs(client.hashCode());

            final SortedMap<Integer, String> integerStringSortedMap = hashServerMap.tailMap(hash);

            if (integerStringSortedMap.isEmpty()) {
                final Integer firstKey = hashServerMap.firstKey();
                System.out.println("客户端：" + client + "服务器：" + hashServerMap.get(firstKey));
            } else {
                final Integer firstKey = integerStringSortedMap.firstKey();
                System.out.println("客户端：" + client + "服务器：" + integerStringSortedMap.get(firstKey));
            }
        }
    }
}

```

