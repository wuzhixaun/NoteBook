#  一、**MVC** 体系结构

## 1.1三层架构

 C/S 架构，也就是客户端/服务器;另一种是 B/S 架构 ，也就是浏览器服务器。在 JavaEE 开发中，几乎全都是基于 B/S 架构的开发。那么在 B/S 架构中，系 统标准的三层架构包括:表现层、业务层、持久层。三层架构在我们的实际开发中使用的非常多，所以 我们课程中的案例也都是基于三层架构设计的

### 	1.1.1 表现层 :

> 也就是我们常说的web 层。它负责接收客户端请求，向客户端响应结果，通常客户端使用http 协 议请求web 层，web 需要接收 http 请求，完成 http 响应

+ 表现层包括展示层和控制层:控制层负责接收请求，展示层负责结果的展示。
+ 表现层依赖业务层，接收到客户端请求一般会调用业务层进行业务处理，并将处理结果响应给客户端
+ 现层的设计一般都使用 MVC 模型。(MVC 是表现层的设计模型，和其他层没有关系)

### 1.1.2 业务层

> 也就是我们常说的 service 层。它负责业务逻辑处理，和我们开发项目的需求息息相关。web 层依赖业
>
> 务层，但是业务层不依赖 web 层。 业务层在业务处理时可能会依赖持久层，如果要对数据持久化需要保证事务一致性。(也就是我们说的， 事务应该放到业务层来控制)

### 1.1.3 持久层 :

> 也就是我们是常说的 dao 层。负责数据持久化，包括数据层即数据库和数据访问层，数据库是对数据进 行持久化的载体，数据访问层是业务层和持久层交互的接口，业务层需要通过数据访问层将数据持久化 到数据库中。通俗的讲，持久层就是和数据库交互，对数据库表进行增删改查的。

## 1.2 **MVC**设计模式

MVC 全名是 Model View Controller，是 模型(model)-视图(view)-控制器(controller) 的缩写， 是一种用于设计创建 Web 应用程序表现层的模式。MVC 中每个部分各司其职

+ Model(模型):模型包含业务模型和数据模型，数据模型用于封装数据，业务模型用于处理业务。

+ View(视图): 通常指的就是我们的 jsp 或者 html。作用一般就是展示数据的。通常视图是依据 模型数据创建的。

+ Controller(控制器): 是应用程序中处理用户交互的部分。作用一般就是处理程序逻辑的。 MVC提倡:每一层只编写自己的东⻄，不编写任何其他的代码;分层是为了解耦，解耦是为了维

  护方便和分工协作。

# 二、Spring MVC 
SpringMVC 全名叫 Spring Web MVC，是一种基于 Java 的实现 MVC 设计模型的请求驱动类型的轻量级Web 框架，属于 SpringFrameWork 的后续产品。

![image-20211111230049031](https://cdn.wuzx.cool/image-20211111230049031.png)

Spring MVC和Struts2一样，都是 为了解决表现层问题 的web框架，它们都是基于 MVC 设计模 式的。而这些表现层框架的主要职责就是处理前端HTTP请求。

Spring MVC 本质可以认为是对servlet的封装，简化了我们serlvet的开发 

作用:1)接收请求 2)返回响应，跳转⻚面

![image-20211111230121026](https://cdn.wuzx.cool/image-20211111230121026.png)

# 三、**Spring Web MVC** 工作流程

![image-20211111230157530](https://cdn.wuzx.cool/image-20211111230157530.png)

+ 第一步：用户发送请求到前端控制器`DispatcherServlet`
+ 第二步：`DispatcherServlet`收到请求调用`HandlerMapping`处理器映射器
+ 第三步：`HandlerMapping`处理器映射器根据请求`Url`找到具体的`Handler(后端控制器)`，此时生成的是处理器执行器(Handler(处理器)、Interceptor(处理器拦截器)登)
+ 第四步：`DispatcherServlet`调用`HandlerAdapter处理器`去调用`Handler`，因为此时不知道Handler是何种形式，所以需要处理器适配器
+ 第五步：处理器适配器执行`Handler(后端控制器)`
+ 第六步：`Handler`执行完成之后返回`ModelAndView`给`HandlerAdapter处理器`
+ 第七步:  处理器适配器向`DispatcherServlet前端控制器`返回 ModelAndView,ModelAndView 是SpringMVC 框架的一个 底层对 象，包括 Model 和 View
+ 第八步：`DispatcherServlet前端控制器`请求`ViewResolver视图解析器`解析当前逻辑视图为物理视图即 视图返回hello，视图解析器解析 为 html/hello.html
+ 第九步：视图解析器向前端控制器返回View
+ 第十步：前端控制器进行视图渲染，就是将模型数据(在 ModelAndView 对象中)填充到 request 域
+ 第十一步：前端控制器向用户响应结果


