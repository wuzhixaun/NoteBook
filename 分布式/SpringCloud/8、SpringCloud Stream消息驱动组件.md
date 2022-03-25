![stream](https://cdn.wuzx.cool/stream.png)

# 一、**Stream**解决的痛点问题

> Spring Cloud Stream 消息驱动组件帮助我们更快速，更方便，更友好的去构建消息 驱动微服务的
>
> MQ消息中间件广泛应用在`应用解耦合`、`异步消息处理`、`流量削峰`等场景中
>
> 不同的MQ消息中间件内部机制包括使用方式都会有所不同，比如RabbitMQ中有 Exchange(交换机/交换器)这一概念，kafka有Topic、Partition分区这些概念， MQ消息中间件的差异性不利于我们上层的开发应用，当我们的系统希望从原有的 RabbitMQ切换到Kafka时，我们会发现比较困难，很多要操作可能重来(因为应用 程序和具体的某一款**MQ**消息中间件耦合在一起了)
>
> Spring Cloud Stream进行了很好的上层抽象，可以让我们与具体消息中间件解耦 合，屏蔽掉了底层具体MQ消息中间件的细节差异，就像Hibernate屏蔽掉了具体数 据库(Mysql/Oracle一样)。如此一来，我们学习、开发、维护MQ都会变得轻松。 目前Spring Cloud Stream支持RabbitMQ和Kafka

本质:屏蔽掉了底层不同**MQ**消息中间件之间的差异，统一了**MQ**的编程模型，降低 了学习、开发、维护**MQ**的成本

# 二、**Stream**重要概念

> Spring Cloud Stream 是一个构建消息驱动微服务的框架。应用程序通过inputs(相 当于消息消费者consumer)或者outputs(相当于消息生产者producer)来与 Spring Cloud Stream中的binder对象交互，而Binder对象是用来屏蔽底层MQ细节 的，它负责与具体的消息中间件交互

![image-20220325012105250](https://cdn.wuzx.cool/image-20220325012105250.png)

## **Binder**绑定器

Binder绑定器是Spring Cloud Stream 中非常核心的概念，就是通过它来屏蔽底层 不同MQ消息中间件的细节差异，当需要更换为其他消息中间件时，我们需要做的就 是更换对应的**Binder**绑定器而不需要修改任何应用逻辑(Binder绑定器的实现是框 架内置的，Spring Cloud Stream目前支持Rabbit、Kafka两种消息队列)

# 三、传统**MQ**模型与**Stream**消息驱动模型

![image-20220325012155961](https://cdn.wuzx.cool/image-20220325012155961.png)

# 四、**Stream**消息通信方式及编程模型

## 4.1 **Stream**消息通信方式

> Stream中的消息通信方式遵循了发布—订阅模式。
>
> 在Spring Cloud Stream中的消息通信方式遵循了发布-订阅模式，当一条消息被投 递到消息中间件之 后，它会通过共享的 Topic 主题进行广播，消息消费者在订阅的 主题中收到它并触发自身的业务逻辑处理。这里所提到的 Topic 主题是Spring Cloud Stream中的一个抽象概念，用来代表发布共享消息给消 费者的地方

## 4.2  **Stream**编程注解

![image-20220325012320656](https://cdn.wuzx.cool/image-20220325012320656.png)

# 五、**Stream**高级之自定义消息通道

``` java
public interface LogProcessor {

    String INPUT_LOG = "input_log";
    String OUTPUT_LOG = "output_log";

    @Input(INPUT_LOG)
    SubscribableChannel inputLog();

    @Output(OUTPUT_LOG)
    MessageChannel outputLog();
}
```

+ 在 @EnableBinding 注解中，绑定自定义的接口，使用 @StreamListener 做监听的时候,指定输入消息的channel

  ``` java
  @EnableBinding(LogProcessor.class)
  public class LogMessageConsumerServiceImpl {
  
  
      @StreamListener(LogProcessor.INPUT_LOG)
      public void receiveMessage(Message<String> message) {
          System.out.println("========LOG接受消息:" + message);
      }
  }
  ```

+ 配置文件绑定

  ``` yaml
        bindings: # 关联整合通道和binder对象
          input: # output是我们定义的通道名称，此处不能乱改
            destination: wuzxExchange # 要使用的Exchange名称(消息队列主题名称)
            context-type: text/plain # 消息类型设置，比如json
            binder: localRabbitBinder # 关联MQ服务
            group: wuzxGroup
          input_log:
            destination: wuzxTestExchange
            context-type: text/plain # 消息类型设置，比如json
            binder: localRabbitBinder # 关联MQ服务
            group: wuzxTestGroup
          output_log:
            destination: wuzxTestExchange
            context-type: text/plain # 消息类型设置，比如json
            binder: localRabbitBinder # 关联MQ服务
  ```

  # 六、**Stream**高级之消息分组

  > 消费者端有两个(消费同一个MQ的同一个主题)，但是呢我们的 业务场景中希望这个主题的一个Message只能被一个消费者端消费处理，此时我们 就可以使用消息分组。

  # 解决的问题:能解决消息重复消费问题

  多个消费者实例配置为同一个group名称(在同一个group中的多个消费者只有 一个可以获取到消息并消费)

  ``` yaml
          input_log:
            destination: wuzxTestExchange
            context-type: text/plain # 消息类型设置，比如json
            binder: localRabbitBinder # 关联MQ服务
            group: wuzxTestGroup
  ```

  