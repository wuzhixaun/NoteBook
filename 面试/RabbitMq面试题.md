# 一、**RabbitMQ如何保证消息不丢失?**

![image-20220719001320529](https://cdn.wuzx.cool/image-20220719001320529.png)

## 1. 哪些环节可能造成消息环节的丢失

其中，1，2，4三个场景都是跨网络的，而跨网络就肯定会有丢消息的可能

然后关于3这个环节，通常MQ存盘时都会先写入操作系统的缓存page cache 中，然后再由操作系统异步的将消息写入硬盘。这个中间有个时间差，就可能会造 成消息丢失。如果服务挂了，缓存中还没有来得及写入硬盘的消息就会丢失。这也 是任何用户态的应用程序无法避免的。

对于任何MQ产品，都应该从这四个方面来考虑数据的安全性。那我们看看用 RabbitMQ时要如何解决这个问题。

## **2、RabbitMQ消息零丢失方案:**

### 2.1 **生产者保证消息正确发送到RibbitMQ**

+ 同步: 通过生产者 channel.waitForConfirmsOrDie(time)指定一个等待确认的完成时间，如果超过这个时间会抛出异常

+ 异步: 再生产者注册监听器来对消息进行确认，

  + ``` java
    // 注入两个回调确认函数，第一个是生产者发送消息时候调用，第二个生产者收到broker的消息确认调用两个 函数需要通过sequenceNumber自行完成消息的前后对应。sequenceNumber的
    channel.addConfirmListener(ConfirmCallbackvar1, ConfirmCallbackvar2);
    
    // 生成一个全局递增的序列号
    int sequenceNumber = channel.getNextPublishSeqNo());
    ```

+ 手动开启事务:channel.txSelect() 开启事务; channel.txCommit() 提交事务; channel.txRollback() 回滚事务; 用这几个方法 来进行事务管理。但是这种方式需要手动控制事务逻辑，并且手动事务会对channel 产生阻塞，造成吞吐量下降

### 2.2 **RabbitMQ消息存盘不丢消息**

> 这个在RabbitMQ中比较好处理，对于Classic经典队列，直接将队列声明成为持 久化队列即可。
>
> 而新增的Quorum队列和Stream队列，都是明显的持久化队列，能 更好的保证服务端消息不会丢失。

### 2.3 RabbitMQ主从消息同步不丢失消息

> 普通集群，消息是分散存储的，不会主动进行消息同步
>
> 构建镜像模式集群，数据主动在集群各个节点当中同步，消息丢失的概率情况比较小

### 2.4 RabbitMQ消费者不丢失消息

> RabbitMQ 给我们提供了消费者应答（ack）机制，默认情况下这个机制是自动应答.我们可以启动手动应答模式。

``` java
@RabbitListener(queues = "queue")
    public void listen(String object, Message message, Channel channel) {
        long deliveryTag = message.getMessageProperties().getDeliveryTag();
        log.info("消费成功：{},消息内容:{}", deliveryTag, object);
        try {
            /**
             * 执行业务代码...
             * */
            channel.basicAck(deliveryTag, false);
        } catch (IOException e) {
            log.error("签收失败", e);
            try {
                channel.basicNack(deliveryTag, false, true);
            } catch (IOException exception) {
                log.error("拒签失败", exception);
            }
        }
    }

```

> 但是如果线上发生异常，basicNack的最后一个参数代表 否重回队列，如果false那么我们将注解丢弃，所以我们肯定是写true。那么发生异常，这个消息会被重回消息队列顶端，然后继续推送到消费端，然后就造成活锁现象，继续被消费，继续报错，重回队列，继续被消费......死循环

所以真实的场景一般是三种选择：

+ 当消费失败，我们可以将消息存到redis，记录消费次数，记录消费次数，如果三次还是失败了，那么就丢弃消息，记录日志在数据库中。

+ 直接丢弃，不重回队列，记录日志，发送邮件通知开发人员手工处理

+ 利用Springboot消息重试功能，设置超过多少次

  + ``` yaml
    spring:
      rabbitmq:
        listener:
          simple:
            retry:
              enabled: true
              max-attempts: 3 #重试次数
    ```

  + ``` java
    消费者代码
    @RabbitListener(queues = "queue")
        public void listen(String object, Message message, Channel channel) throws IOException {
            try {
                /**
                 * 执行业务代码...
                 * */
                int i = 1 / 0; //故意报错测试
            } catch (Exception e) {
                log.error("签收失败", e);
                /**
                 * 记录日志、发送邮件、保存消息到数据库，落库之前判断如果消息已经落库就不保存
                 * */
                throw new RuntimeException("消息消费失败");
            }
        }
    
    注意一定要手动 throw 一个异常，因为 SpringBoot 触发重试是根据方法中发生未捕捉的异常来决定的。值得注意的是这个重试是 SpringBoot 提供的，重新执行消费者方法，而不是让 RabbitMQ 重新推送消息
    ```



# **二、如何保证消息幂等?**

```
处理幂等问题的关键是要给每个消息一个唯一的标识,springboot 发送消息指定消息id
```

``` java
Boolean flag = stringRedisTemplate.opsForValue().setIfAbsent("orderNo+couponId");
    //先检查这条消息是不是已经消费过了
    if (!Boolean.TRUE.equals(flag)) {
        return;
    }
    //执行业务...
    //消费过的标识存储到 Redis，10 秒过期
   stringRedisTemplate.opsForValue().set("orderNo+couponId","1", Duration.ofSeconds(10L));
```

# 三、如何保证消息的顺序?

>某些场景下，需要保证消息的消费顺序，例如一个下单过程，需要先完成扣款，
>然后扣减库存，然后通知快递发货，这个顺序不能乱。如果每个步骤都通过消息进
>行异步通知的话，这一组消息就必须保证他们的消费顺序是一致的

> 在RabbitMQ当中，针对消息顺序的设计其实是比较弱的。唯一比较好的策略就 是 单队列+单消息推送。即一组有序消息，只发到一个队列中，利用队列的FIFO特 性保证消息在队列内顺序不会乱。但是，显然，这是以极度消耗性能作为代价的， 在实际适应过程中，应该尽量避免这种场景
>
> 消费者进行消费时，保证只有一个消费者，同时指定prefetch属性为1，即 每次RabbitMQ都只往客户端推送一个消息。像这样:
>
> ``` yam
> spring.rabbitmq.listener.simple.prefetch=1



# **四、关于RabbitMQ的数据堆积问 题**

RabbitMQ一直以来都有一个缺点，就是对于消息堆积问题的处理不好。当 RabbitMQ中有大量消息堆积时，整体性能会严重下降。

+ 生产端：
  + 对于生产者端，最明显的方式自然是降低消息生产的速度。**对生产者发消息接口进行适当限流（不太推荐，影响用户体验）**但是，生产者端产生 消息的速度通常是跟业务息息相关的，
+ 服务端：使用懒加载机制(忽略)
+ 消费者端：
  + **多部署几台消费者实例（推荐）**
  + **适当增加 prefetch 的数量，让消费端一次多接受一些消息（推荐，可以和第二种方案一起用）**
+ 当确实遇到紧急状况，来不及调整消费者端时，可以紧急上线一个消费者组，专 门用来将消息快速转录。保存到数据库或者Redis，然后再慢慢进行处理

# 五、**RabbitMQ的备份与恢复**

RabbitMQ有一个data目录会保存分配到该节点上的所有消息。我们的实验环境 中，默认是在/var/lib/rabbitmq/mnesia目录下 这个目录里面的备份分为两个 部分，一个是元数据(定义结构的数据)，一个是消息存储目录,直接复制到新的

