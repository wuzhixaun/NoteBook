# 一、**过滤器链加载源码**

## 1.1 **过滤器链加载流程分析**

![image-20211127101719691](https://cdn.wuzx.cool/image-20211127101719691.png)

## 1.2 过滤器链加载流程源码分析
### 1.2.1 spring boot启动中会加载spring.factories文件, 在文件中有对应针对Spring Security的过滤器链的配置信息

> \# 安全过滤器自动配置 
>
> org.springframework.boot.autoconfigure.security.servlet.SecurityFilterAutoConfiguration

### 1.2.2 SecurityFilterAutoConfiguration类

``` java
@Configuration(proxyBeanMethods = false)
@ConditionalOnWebApplication(type = Type.SERVLET)
@EnableConfigurationProperties({SecurityProperties.class})  // Security配置类
@ConditionalOnClass({AbstractSecurityWebApplicationInitializer.class, SessionCreationPolicy.class})
@AutoConfigureAfter({SecurityAutoConfiguration.class})  //// 这个类加载完后去加载 SecurityAutoConfiguration配置
public class SecurityFilterAutoConfiguration {
}
```

``` java
@ConfigurationProperties(
    prefix = "spring.security"
)
public class SecurityProperties {
    
    public static class User {
        private String name = "user"; //框架默认初始化的user
        private String password = UUID.randomUUID().toString(); // 随机uuid生成的密码
    }
}
```

### 1.2.3 SecurityAutoConfiguration

``` java
@Configuration(proxyBeanMethods = false)
@ConditionalOnClass({DefaultAuthenticationEventPublisher.class})
@EnableConfigurationProperties({SecurityProperties.class})
@Import({SpringBootWebSecurityConfiguration.class, WebSecurityEnablerConfiguration.class, SecurityDataConfiguration.class})
public class SecurityAutoConfiguration {
}
```

### 1.2.4 WebSecurityEnablerConfiguration (web安全启用配置)

``` java
@Configuration(proxyBeanMethods = false)
@ConditionalOnMissingBean(name = {"springSecurityFilterChain"})
@ConditionalOnClass({EnableWebSecurity.class})
@ConditionalOnWebApplication(type = Type.SERVLET)
@EnableWebSecurity
class WebSecurityEnablerConfiguration {
}
```

### 1.2.5 EnableWebSecurity

``` java
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE})
@Documented
@Import({WebSecurityConfiguration.class, SpringWebMvcImportSelector.class, OAuth2ImportSelector.class})
@EnableGlobalAuthentication
@Configuration
public @interface EnableWebSecurity {
}
```

> @EnableWebSecurity注解有两个作用
>
> + 1: 加载了WebSecurityConfiguration配置类, 配置安全认证 策略。
> + 2: 加载了AuthenticationConfiguration, 配置了认证信息

### 1.2.6 WebSecurityConfiguration

``` java
@Configuration(
    proxyBeanMethods = false
)
public class WebSecurityConfiguration implements ImportAware, BeanClassLoaderAware {
  
  @Bean(name = {"springSecurityFilterChain"})
    public Filter springSecurityFilterChain() throws Exception {
        boolean hasConfigurers = this.webSecurityConfigurers != null && !this.webSecurityConfigurers.isEmpty();
        if (!hasConfigurers) {
            WebSecurityConfigurerAdapter adapter = (WebSecurityConfigurerAdapter)this.objectObjectPostProcessor.postProcess(new WebSecurityConfigurerAdapter() {
            });
            this.webSecurity.apply(adapter);
        }

        return (Filter)this.webSecurity.build();
    }
}
```

> `springSecurityFilterChain`方法 真正声明了`过滤器链`,webSecurity.build()是构建filter的方法

# 二、认证流程源码

## 2.1**认证流程分析**

在整个过滤器链中, `UsernamePasswordAuthenticationFilter`是来处理整个用户认证的流程的

![image-20211127114505895](https://cdn.wuzx.cool/image-20211127114505895.png)

## 2.2 **认证流程源码跟踪**

``` java
public Authentication attemptAuthentication(HttpServletRequest request,
            HttpServletResponse response) throws AuthenticationException {
//1.检查是否是post请求
if (postOnly && !request.getMethod().equals("POST")) {
            throw new AuthenticationServiceException(
                    "Authentication method not supported: " +
request.getMethod());
        }
//2.获取用户名和密码
String username = obtainUsername(request); String password = obtainPassword(request);
        if (username == null) {
            username = "";
}
        if (password == null) {
            password = "";
}
username = username.trim(); //3.创建AuthenticationToken,此时是未认证的状态 UsernamePasswordAuthenticationToken authRequest = new
UsernamePasswordAuthenticationToken(
                username, password);
        // Allow subclasses to set the "details" property
setDetails(request, authRequest); //4.调用AuthenticationManager进行认证.
return this.getAuthenticationManager().authenticate(authRequest);
}
```

### UsernamePasswordAuthenticationToken

``` java
public UsernamePasswordAuthenticationToken(Object principal, Object
credentials) {
super(null);
this.principal = principal;//设置用户名 this.credentials = credentials;//设置密码 setAuthenticated(false);//设置认证状态为-未认证
}
```

### AuthenticationManager-->ProviderManager-->AbstractUserDetailsAuthenticationProvider

``` java
public Authentication authenticate(Authentication authentication)
            throws AuthenticationException {
        Assert.isInstanceOf(UsernamePasswordAuthenticationToken.class,
authentication,
                () -> messages.getMessage(
"AbstractUserDetailsAuthenticationProvider.onlySupports",
supported"));
// 1.获取用户名
"Only UsernamePasswordAuthenticationToken is
        String username = (authentication.getPrincipal() == null) ?
"NONE_PROVIDED"
: authentication.getName(); // 2.尝试从缓存中获取
        boolean cacheWasUsed = true;
        UserDetails user = this.userCache.getUserFromCache(username);
        if (user == null) {
            cacheWasUsed = false;
try { //3.检索User
                user = retrieveUser(username,
                        (UsernamePasswordAuthenticationToken)
authentication);
            }
..... }
try {
//4. 认证前检查user状态 preAuthenticationChecks.check(user); //5. 附加认证证检查 additionalAuthenticationChecks(user,
                    (UsernamePasswordAuthenticationToken) authentication);
}
.....
//6. 认证后检查user状态 postAuthenticationChecks.check(user);
.....
// 7. 创建认证成功的UsernamePasswordAuthenticationToken并将认证状态设置为
true
        return createSuccessAuthentication(principalToReturn,
authentication, user);
```

### retrieveUser方法

``` java
protected final UserDetails retrieveUser(String username,
            UsernamePasswordAuthenticationToken authentication)
            throws AuthenticationException {
        prepareTimingAttackProtection();
        try {
//调用自定义UserDetailsService的loadUserByUsername的方法
            UserDetails loadedUser =
this.getUserDetailsService().loadUserByUsername(username);
            if (loadedUser == null) {
                throw new InternalAuthenticationServiceException(
                        "UserDetailsService returned null, which is an
interface contract violation");
}
            return loadedUser;
        }
.... }
```

### additionalAuthenticationChecks方法

``` java
protected void additionalAuthenticationChecks(UserDetails userDetails,
            UsernamePasswordAuthenticationToken authentication)
            throws AuthenticationException {
.....
// 1.获取前端密码
        String presentedPassword =
authentication.getCredentials().toString();
// 2.与数据库中的密码进行比对
        if (!passwordEncoder.matches(presentedPassword,
userDetails.getPassword())) {
            logger.debug("Authentication failed: password does not match
stored value");
            throw new BadCredentialsException(messages.getMessage(
"AbstractUserDetailsAuthenticationProvider.badCredentials",
                    "Bad credentials"));
} }
```

### AbstractAuthenticationProcessingFilter--doFilter方法

``` java
public void doFilter(ServletRequest req, ServletResponse res, FilterChain
chain)
            throws IOException, ServletException {
            .....
        Authentication authResult;
try { //1.调用子类方法
            authResult = attemptAuthentication(request, response);
            ...
              //2.session策略验证
        sessionStrategy.onAuthentication(authResult, request, response);
    }
....
// 3.成功身份验证
    successfulAuthentication(request, response, chain, authResult);
}
```

### successfulAuthentication方法

``` java
protected void successfulAuthentication(HttpServletRequest request,
            HttpServletResponse response, FilterChain chain, Authentication
authResult)
            throws IOException, ServletException {
        ....
// 1.将认证的用户放入SecurityContext中 
SecurityContextHolder.getContext().setAuthentication(authResult); 
  // 2.检查是不是记住我
rememberMeServices.loginSuccess(request, response, authResult); ...
// 3.调用自定义MyAuthenticationService的onAuthenticationSuccess方法 
  successHandler.onAuthenticationSuccess(request, response,authResult);
}
```

# 三、记住我流程
![image-20211127120823435](https://cdn.wuzx.cool/image-20211127120823435.png)

# 四、csrf
![image-20211127120905321](https://cdn.wuzx.cool/image-20211127120905321.png)

# 五、授权流程
![image-20211127120934292](https://cdn.wuzx.cool/image-20211127120934292.png)