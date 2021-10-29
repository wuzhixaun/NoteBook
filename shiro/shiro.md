![v2-d3b4a390efe2c4555e033683b0c98568_1440w](http://cdn.wuzx.cool/v2-d3b4a390efe2c4555e033683b0c98568_1440w.png)

# 简介

Shiro是一个强大的简单易用的Java安全框架，主要用来更便捷的`认证`，`授权`，`加密`，`会话管理`。Shiro首要的和最重要的目标就是容易使用并且容易理解  	

Shiro是一个有许多特性的全面的安全框架，下面这幅图可以了解Shiro的特性：

![img](E:\Users\admin\Pictures\Saved Pictures\426671-4f553a3555dcf438.png)

可以看出shiro除了基本的认证，授权，会话管理，加密之外，还有许多额外的特性。

# Shiro架构

Shiro有三个主要的概念：`Subject`，`SecurityManager`，`Realms`

![img](E:\Users\admin\Pictures\Saved Pictures\426671-5458508e59ae958a.png)

+ `Subject`：当前参与应用安全部分的主角。可以是用户，可以试第三方服务，可以是cron 任务，或者任何东西。主要指一个正在与当前软件交互的东西。
     所有Subject都需要SecurityManager，当你与Subject进行交互，这些交互行为实际上被转换为与SecurityManager的交互

+ `SecurityManager`：安全管理员，Shiro架构的核心，它就像Shiro内部所有原件的保护伞。然而一旦配置了SecurityManager，SecurityManager就用到的比较少，开发者大部分时间都花在Subject上面。
     请记得，当你与Subject进行交互的时候，实际上是SecurityManager在背后帮你举起Subject来做一些安全操作。

+ `Realms`：Realms作为Shiro和你的应用的连接桥，当需要与安全数据交互的时候，像用户账户，或者访问控制，Shiro就从一个或多个Realms中查找。
     Shiro提供了一些可以直接使用的Realms，如果默认的Realms不能满足你的需求，你也可以定制自己的Realms

![img](E:\Users\admin\Pictures\Saved Pictures\webp)

# 身份认证流程

![img](E:\Users\admin\Pictures\Saved Pictures\4.png)

流程如下：

1. 首先调用 `Subject.login(token)` 进行登录，其会自动委托给 `Security Manager`，调用之前必须通过 `SecurityUtils.setSecurityManager()` 设置；
2. `SecurityManager` 负责真正的身份验证逻辑；它会委托给 `Authenticator` 进行身份验证；
3. `Authenticator` 才是真正的身份验证者，`Shiro API` 中核心的身份认证入口点，此处可以自定义插入自己的实现；
4. `Authenticator` 可能会委托给相应的 `AuthenticationStrategy` 进行多 `Realm` 身份验证，默认 `ModularRealmAuthenticator` 会调用 `AuthenticationStrategy` 进行多 `Realm` 身份验证；
5. `Authenticator `会把相应的 `token` 传入 `Realm`，从 `Realm` 获取身份验证信息，如果没有返回 / 抛出异常表示身份验证成功了。此处可以配置多个 `Realm`，将按照相应的顺序及策略进行访问。

# 授权流程

![img](E:\Users\admin\Pictures\Saved Pictures\202101141719562904.png)

## 流程如下：

1. 首先调用 Subject.isPermitted*/hasRole*接口，其会委托给 SecurityManager，而 SecurityManager 接着会委托给 Authorizer；
2. Authorizer 是真正的授权者，如果我们调用如 isPermitted(“user:view”)，其首先会通过 PermissionResolver 把字符串转换成相应的 Permission 实例；
3. 在进行授权之前，其会调用相应的 Realm 获取 Subject 相应的角色/权限用于匹配传入的角色/权限；
4. Authorizer 会判断 Realm 的角色/权限是否和传入的匹配，如果有多个 Realm，会委托给 ModularRealmAuthorizer 进行循环判断，如果匹配如 isPermitted*/hasRole* 会返回 true，否则返回 false 表示授权失败。

ModularRealmAuthorizer 进行多 Realm 匹配流程：

- 首先检查相应的 Realm 是否实现了实现了 Authorizer；
- 如果实现了 Authorizer，那么接着调用其相应的 isPermitted*/hasRole* 接口进行匹配；
- 如果有一个 Realm 匹配那么将返回 true，否则返回 false。

如果 Realm 进行授权的话，应该继承 AuthorizingRealm，其流程是：

- 如果调用 hasRole*，则直接获取 AuthorizationInfo.getRoles() 与传入的角色比较即可；首先如果调用如 isPermitted(“user:view”)，首先通过 PermissionResolver 将权限字符串转换成相应的 Permission 实例，默认使用 WildcardPermissionResolver，即转换为通配符的 WildcardPermission；
- 通过 AuthorizationInfo.getObjectPermissions() 得到 Permission 实例集合；通过 AuthorizationInfo.getStringPermissions() 得到字符串集合并通过 PermissionResolver 解析为 Permission 实例；然后获取用户的角色，并通过 RolePermissionResolver 解析角色对应的权限集合（默认没有实现，可以自己提供）；
- 接着调用 Permission.implies(Permission p) 逐个与传入的权限比较，如果有匹配的则返回 true，否则 false。