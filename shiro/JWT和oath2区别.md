# JWT简介

[JSON Web Token (JWT)](https://auth0.com/learn/json-web-tokens/)是用于创建断言某些声明的令牌的标准。例如，服务器可以生成具有“以管理员身份登录”声明的令牌，并将其提供给客户端。然后客户端可以使用该令牌来证明他们以管理员身份登录。令牌由服务器的密钥签名，因此服务器能够验证令牌是否合法。

标头标识用于生成签名的算法，看起来像这样：

```javascript
header = '{"alg":"HS256","typ":"JWT"}'
```

`HS256` 表示此令牌是使用 HMAC-SHA256 签名的。

有效载荷包含我们希望做出的声明：

```javascript
payload = '{"loggedInAs":"admin","iat":1422779638}'
```

正如 JWT 规范中所建议的，我们包含了一个名为 的时间戳`iat`，它是“issued at”的缩写。

签名是通过 base64url 对标头和有效负载进行编码并用句点作为分隔符将它们连接起来计算的：

```javascript
key = 'secretkey'
unsignedToken = encodeBase64(header) + '.' + encodeBase64(payload)
signature = HMAC-SHA256(key, unsignedToken)
```

总而言之，我们对签名进行 base64url 编码，并使用句点将三部分连接在一起：

```javascript
token = encodeBase64(header) + '.' + encodeBase64(payload) + '.' + encodeBase64(signature)

# token is now:
# eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJsb2dnZWRJbkFzIjoiYWRtaW4iLCJpYXQiOjE0MjI3Nzk2Mzh9.gzSraSYS8EXBxLN_oWnFSRgCzcmJmMjLiuyu5CSpyHI
```

# JWT应用

> 服务器端：
>
> 1-生成head
>
> 2-生成payload，通常带有expired过期时间
>
> 3-第三段：
>
> 1和2密文拼接，
>
> 对第2部分密文进行sh256加密+盐
>
> 然后发送给浏览器
>
> 浏览器：
>
> 每次携带token
>
> 服务器端
>
> 获取token
>
> 切割
>
> 逐段解密，可验证过期时间
>
> 第二段第三段，加密对比，密文，如果相等，标识token为被修改过



# Oath2

## 是什么

> OAuth是访问委派的开放网络标准，通常用于互联网用户授予网站或应用程序访问其信息在其他网站上，但不给他们密码的一种方式

## 解决问题

+ 任何身份认证，本质解决的问题是双方不信任问题
+ 开放平台依托知名，不用本地存储大量的信息，得到很好的应用

## 角色

+ 资源拥有者（Resource Owner）
+ 代理（浏览器）或者手机APP平台（user-agent）
+ 客户端/第三方应用（client）
+ 资源服务器（resource server）
+ 授权服务器（authorization server）

## 授权流程

+ https://tools.ietf.org/html/rfc6749
+ 一栏来说edirect_uri透视这个网站的单点登陆系

## 参考网站

+ RFC 7379 https://tools.ietf.org/html/rfc6749
+ 微信公众平台 https://developers.weixin.qq.com/doc/oplatform/Website_App/WeChat_Login/Wechat_Login.html
+ 阮一峰 http://www.ruanyifeng.com/blog/2019/04/oauth_design.html

## 开放平台由什么组成？

+ 开发者中心
+ 网关
  + 限流
  + 鉴权
+ 授权平台