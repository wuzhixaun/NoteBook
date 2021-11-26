# 一、**会话超时**

+ 配置session会话超时时间，默认为30分钟，但是Spring Boot中的会话超时时间至少为60秒,当session超时后, 默认跳转到登录页面.

  ``` properties
  #session设置
  #配置session超时时间 
  server.servlet.session.timeout=60
  ```

+ 自定义设置session超时后地址,设置session管理和失效后跳转地址

  ``` java
          http.sessionManagement() //设置session管理
                  .invalidSessionUrl("/toLoginPage") // 失效跳转页面，默认是登录页
                  .expiredUrl("/toLoginPage");//设置session过期后跳转路径
  ```

# 二、**并发控制**

并发控制即同一个账号同时在线个数,同一个账号同时在线个数如果设置为1表示，该账号在同一时 间内只能有一个有效的登录，如果同一个账号又在其它地方登录，那么就将上次登录的会话过期，即后 面的登录会踢掉前面的登录

+ 设置最大会话数量

  ``` java
          http.sessionManagement() //设置session管理
                  .invalidSessionUrl("/toLoginPage") // 失效跳转页面，默认是登录页
                  .maximumSessions(1) //设置session最大会话数量 ,1同一时间只能有一个
                  .maxSessionsPreventsLogin(false)//当达到最大会话个数时阻止登录
                  .expiredUrl("/toLoginPage");//设置session过期后跳转路径
  ```

+ 阻止用户第二次登录

  ``` jav
    http.sessionManagement() //设置session管理
                  .invalidSessionUrl("/toLoginPage") // 失效跳转页面，默认是登录页
                  .maximumSessions(1) //设置session最大会话数量 ,1同一时间只能有一个
                  .maxSessionsPreventsLogin(true)//当达到最大会话个数时阻止登录
                  .expiredUrl("/toLoginPage");//设置session过期后跳转路径
  ```

# 三、Session集群

实际场景中一个服务会至少有两台服务器在提供服务，在服务器前面会有一个nginx做负载均衡， 用户访问nginx，nginx再决定去访问哪一台服务器。当一台服务宕机了之后，另一台服务器也可以继续 提供服务，保证服务不中断。如果我们将session保存在Web容器(比如tomcat)中，如果一个用户第一 次访问被分配到服务器1上面需要登录，当某些访问突然被分配到服务器二上，因为服务器二上没有用 户在服务器一上登录的会话session信息，服务器二还会再次让用户登录，用户已经登录了还让登录就 感觉不正常了

![image-20211125232602116](https://cdn.wuzx.cool/image-20211125232602116.png)

解决这个问题的思路是用户登录的会话信息不能再保存到Web服务器中，而是保存到一个单独的库 (redis、mongodb、jdbc等)中，所有服务器都访问同一个库，都从同一个库来获取用户的session信 息，如用户在服务器一上登录，将会话信息保存到库中，用户的下次请求被分配到服务器二，服务器二 从库中检查session是否已经存在，如果存在就不用再登录了，可以直接访问服务了。

![image-20211125232618670](https://cdn.wuzx.cool/image-20211125232618670.png)

``` properties
#使用redis共享session 
spring.session.store-type=redis
```

# 四、**跨域与CORS**

跨域，实质上是浏览器的一种保护处理。如果产生了跨域，服务器在返回结果时就会被浏览器拦截 (注意:此时请求是可以正常发起的，只是浏览器对其进行了拦截)，导致响应的内容不可用. 产生跨域的 几种情况有一下:

![image-20211125234432729](https://cdn.wuzx.cool/image-20211125234432729.png)

##  **解决跨域**

+ JSONP

  > 1. 浏览器允许一些带src属性的标签跨域，也就是在某些标签的src属性上写url地址是不会产生跨 域问题

+ CORS解决跨域

  > 1. CORS是一个W3C标准，全称是"跨域资源共享"(Cross-origin resource sharing)。CORS需要 浏览器和服务器同时支持。目前，所有浏览器都支持该功能，IE浏览器不能低于IE10。浏览器在发 起真正的请求之前，会发起一个OPTIONS类型的预检请求，用于请求服务器是否允许跨域，在得 到许可的情况下才会发起请求

## **基于Spring Security的CORS支持**

+ 声明跨域配置源

  ``` java
  /**
  * 跨域配置信息源
  *
  * @return */
  public CorsConfigurationSource corsConfigurationSource() { CorsConfiguration corsConfiguration = new CorsConfiguration(); // 设置允许跨域的站点
  corsConfiguration.addAllowedOrigin("*");
  // 设置允许跨域的http方法 corsConfiguration.addAllowedMethod("*");
  // 设置允许跨域的请求头
  corsConfiguration.addAllowedHeader("*");
  // 允许带凭证
  corsConfiguration.setAllowCredentials(true);
  // 对所有的url生效
          UrlBasedCorsConfigurationSource source = new
  UrlBasedCorsConfigurationSource();
          source.registerCorsConfiguration("/**", corsConfiguration);
          return source;
      }
  ```

+ 开启跨域支持

  ``` java
  //允许跨域 
  http.cors().configurationSource(corsConfigurationSource());
  ```

  