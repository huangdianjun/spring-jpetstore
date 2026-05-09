# Spring Security 详解与实战

## 一、什么是 Spring Security？

### 1.1 核心概念

**Spring Security** 是一个强大的**安全框架**，专门用于处理认证和授权。

**Spring Security 两大功能：**
1. **认证（Authentication）** - 你是谁？（登录验证）
2. **授权（Authorization）** - 你能做什么？（权限控制）

### 1.2 为什么要用 Spring Security？

**自己手写安全代码（噩梦！）：**
```java
// 伪代码：自己写登录
public String login(HttpServletRequest request) {
    String username = request.getParameter("j_username");
    String password = request.getParameter("j_password");
    
    // 手动查数据库
    User user = userRepository.findByUsername(username);
    
    // 手动验证密码
    if (!password.equals(user.getPassword())) {
        return "error";
    }
    
    // 手动处理 Session
    request.getSession().setAttribute("user", user);
    
    // 还得考虑 CSRF、密码加密... 太麻烦了！
    return "success";
}
```
**问题**：太复杂！容易有安全漏洞！

**Spring Security 风格（爽！）：**
```xml
<!-- spring-security.xml -->
<sec:form-login
    login-page="/account/signonForm"
    login-processing-url="/account/signon"
    username-parameter="j_username"
    password-parameter="j_password"
    authentication-failure-url="/account/signonForm?error=true" />
```
**好处**：一行配置搞定！安全、可靠！

## 二、Spring Security 核心概念

### 2.1 认证（Authentication）

**认证流程：**
```
1. 用户输入用户名密码
2. Spring Security 获取用户信息
3. Spring Security 验证密码
4. 验证成功，用户登录
```

### 2.2 授权（Authorization）

**授权流程：**
```
1. 用户访问某个 URL
2. Spring Security 检查用户是否有权限
3. 有权限：放行
4. 没权限：跳转到错误页面
```

### 2.3 核心对象

| 对象 | 说明 |
|------|------|
| **UserDetails** | 用户信息接口 |
| **UserDetailsService** | 加载用户信息的服务 |
| **PasswordEncoder** | 密码加密器 |
| **Authentication** | 认证对象 |

## 三、本项目 Spring Security 配置详解

### 3.1 完整的 spring-security.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans:beans xmlns="http://www.springframework.org/schema/security"
    xmlns:beans="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="...">
    
    <!-- 1. HTTP 安全配置 -->
    <http auto-config="true" use-expressions="true">
        
        <!-- 静态资源允许匿名访问 -->
        <intercept-url pattern="/css/**" access="permitAll" />
        <intercept-url pattern="/images/**" access="permitAll" />
        <intercept-url pattern="/**/favicon.ico" access="permitAll" />
        
        <!-- 商品目录允许匿名访问 -->
        <intercept-url pattern="/catalog/**" access="permitAll" />
        
        <!-- 购物车需要身份验证 -->
        <intercept-url pattern="/cart/**" access="isAuthenticated()" />
        
        <!-- 订单需要身份验证 -->
        <intercept-url pattern="/order/**" access="isAuthenticated()" />
        
        <!-- 账户部分 -->
        <intercept-url pattern="/account/signonForm" access="permitAll" />
        <intercept-url pattern="/account/signon" access="permitAll" />
        <intercept-url pattern="/account/newAccount" access="permitAll" />
        <intercept-url pattern="/account/editAccount" access="isAuthenticated()" />
        
        <!-- 登出 -->
        <logout logout-url="/account/signoff"
            logout-success-url="/catalog" />
        
        <!-- 表单登录 -->
        <form-login login-page="/account/signonForm"
            login-processing-url="/account/signon"
            username-parameter="j_username"
            password-parameter="j_password"
            authentication-failure-url="/account/signonForm?error=true" />
            
    </http>
    
    <!-- 2. 认证管理器配置 -->
    <authentication-manager alias="authenticationManager">
        <authentication-provider user-service-ref="userDetailsService">
            <password-encoder ref="passwordEncoder" />
        </authentication-provider>
    </authentication-manager>
    
    <!-- 3. 自定义 UserDetailsService -->
    <beans:bean id="userDetailsService"
        class="ik.am.jpetstore.domain.service.user.UserDetailsServiceImpl" />
    
    <!-- 4. 密码编码器 -->
    <beans:bean id="passwordEncoder"
        class="ik.am.jpetstore.domain.service.user.PlainTextPasswordEncoder" />

</beans:beans>
```

### 3.2 web.xml 配置

```xml
<!-- Spring Security 过滤器链 -->
<filter>
    <filter-name>springSecurityFilterChain</filter-name>
    <filter-class>org.springframework.web.filter.DelegatingFilterProxy</filter-class>
</filter>
<filter-mapping>
    <filter-name>springSecurityFilterChain</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>
```

## 四、核心组件详解

### 4.1 UserDetailsService

**UserDetailsService** 负责从数据库加载用户信息。

**本项目实现：**
```java
@Service("userDetailsService")
public class UserDetailsServiceImpl implements UserDetailsService {
    
    @Inject
    private AccountService accountService;
    
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        
        // 1. 从数据库查询账户
        Account account = accountService.getAccount(username);
        
        // 2. 如果账户不存在，抛异常
        if (account == null) {
            throw new UsernameNotFoundException(username + " not found.");
        }
        
        // 3. 创建 UserDetails 对象
        List<GrantedAuthority> grantedAuthorities = new ArrayList<>();
        grantedAuthorities.add(new SimpleGrantedAuthority("ROLE_USER"));
        
        // 4. 返回用户信息
        return new User(account.getUsername(), account.getPassword(), grantedAuthorities);
    }
}
```

**流程图：**
```
用户登录
   ↓
Spring Security 调用 UserDetailsService
   ↓
loadUserByUsername(username)
   ↓
从数据库查用户
   ↓
返回 UserDetails
   ↓
Spring Security 验证密码
   ↓
登录成功！
```

### 4.2 PasswordEncoder

**PasswordEncoder** 负责密码加密和验证。

**本项目实现（明文）：**
```java
public class PlainTextPasswordEncoder implements PasswordEncoder {
    
    @Override
    public String encode(CharSequence rawPassword) {
        return rawPassword.toString();  // 直接返回（不加密）
    }
    
    @Override
    public boolean matches(CharSequence rawPassword, String encodedPassword) {
        // 直接比较
        return rawPassword.toString().equals(encodedPassword);
    }
}
```

**生产环境推荐（BCrypt）：**
```java
public class BcryptPasswordEncoder implements PasswordEncoder {
    private BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
    
    @Override
    public String encode(CharSequence rawPassword) {
        return encoder.encode(rawPassword);  // BCrypt 加密
    }
    
    @Override
    public boolean matches(CharSequence rawPassword, String encodedPassword) {
        return encoder.matches(rawPassword, encodedPassword);  // 验证
    }
}
```

### 4.3 表单登录（form-login）

**配置详解：**
```xml
<sec:form-login
    login-page="/account/signonForm"              <!-- 自定义登录页 -->
    login-processing-url="/account/signon"       <!-- 登录处理 URL -->
    username-parameter="j_username"              <!-- 用户名参数名 -->
    password-parameter="j_password"              <!-- 密码参数名 -->
    authentication-failure-url="/account/signonForm?error=true" />  <!-- 失败跳转 -->
```

**JSP 登录表单：**
```jsp
<form method="post" action="signon">
    <c:if test="${not empty param.error}">
        <b>Invalid username or password.</b>
    </c:if>
    
    <input type="text" name="j_username" />  <!-- 对应配置 -->
    <input type="password" name="j_password" />  <!-- 对应配置 -->
    
    <input type="submit" value="Login" />
</form>
```

### 4.4 授权规则（intercept-url）

**配置详解：**
```xml
<!-- 允许匿名访问 -->
<intercept-url pattern="/catalog/**" access="permitAll" />
<intercept-url pattern="/css/**" access="permitAll" />

<!-- 需要身份验证 -->
<intercept-url pattern="/cart/**" access="isAuthenticated()" />
<intercept-url pattern="/order/**" access="isAuthenticated()" />
<intercept-url pattern="/account/editAccount" access="isAuthenticated()" />
```

**权限表达式：**
| 表达式 | 说明 |
|--------|------|
| `permitAll` | 所有人都可以访问 |
| `isAuthenticated()` | 需要登录 |
| `hasRole('ADMIN')` | 需要 ADMIN 角色 |
| `hasAnyRole('ADMIN','USER')` | 需要任意一个角色 |

### 4.5 登出（logout）

**配置：**
```xml
<sec:logout
    logout-url="/account/signoff"         <!-- 登出 URL -->
    logout-success-url="/catalog" />      <!-- 登出后跳转 -->
```

**使用：**
```jsp
<a href="account/signoff">Sign Off</a>
```

## 五、实战：项目中的 Security 使用

### 5.1 登录流程完整示例

**步骤 1：用户访问登录页面**
```
GET /account/signonForm
   ↓
InterceptorUrl: permitAll
   ↓
Controller 返回登录页面
   ↓
用户看到 signonForm.jsp
```

**步骤 2：用户输入用户名密码**
```jsp
<form method="post" action="signon">
    <input type="text" name="j_username" value="j2ee" />
    <input type="password" name="j_password" value="j2ee" />
    <input type="submit" value="Login" />
</form>
```

**步骤 3：Spring Security 处理登录**
```
POST /account/signon
   ↓
Spring Security 过滤器拦截
   ↓
调用 UserDetailsService.loadUserByUsername("j2ee")
   ↓
从数据库查询，返回 UserDetails
   ↓
PasswordEncoder.matches("j2ee", "j2ee") → true
   ↓
认证成功！
   ↓
跳转到默认成功页面（主页）
```

**步骤 4：登录成功后访问需要权限的页面**
```
GET /cart/viewCart
   ↓
intercept-url: isAuthenticated()
   ↓
用户已登录，放行！
   ↓
CartController 处理请求
   ↓
返回购物车页面
```

### 5.2 获取当前登录用户

**在 Controller 中：**
```java
@RequestMapping("editAccount")
public String editAccountForm(Authentication authentication, Model model) {
    
    // 获取当前登录用户名
    String username = authentication.getName();
    
    // 查询完整账户信息
    Account account = accountService.getAccount(username);
    
    // 放到 Model
    model.addAttribute("account", account);
    
    return "account/EditAccountForm";
}
```

**在 JSP 中：**
```jsp
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<!-- 显示当前用户名 -->
<p>Welcome, <sec:authentication property="name" /></p>

<!-- 如果已登录，显示登出链接 -->
<sec:authorize access="isAuthenticated()">
    <a href="account/signoff">Sign Off</a>
</sec:authorize>

<!-- 如果没登录，显示登录链接 -->
<sec:authorize access="!isAuthenticated()">
    <a href="account/signonForm">Sign In</a>
</sec:authorize>
```

### 5.3 常见问题：登录失败

**问题**：登录时返回 Bad credentials

**排查步骤：**

1. **检查表单参数名**
   ```xml
   <form-login
       username-parameter="j_username"  <!-- 必须和 JSP 的 name 一致！ -->
       password-parameter="j_password" />
   ```
   ```jsp
   <input name="j_username" />  <!-- 必须对应！ -->
   <input name="j_password" />  <!-- 必须对应！ -->
   ```

2. **检查数据库中是否有用户**
   ```sql
   SELECT * FROM SIGNON WHERE USERNAME = 'j2ee';
   ```
   本项目的初始化脚本：
   ```sql
   INSERT INTO signon VALUES ('j2ee','j2ee');
   ```

3. **检查 PasswordEncoder**
   确保密码验证逻辑正确

4. **看日志**
   ```
   DEBUG: authentication - Authentication attempt using org.springframework.security.authentication.dao.DaoAuthenticationProvider
   DEBUG: dao.DaoAuthenticationProvider - Authentication failed: password does not match stored value
   ```

## 六、本项目修复的 Security 问题

### 6.1 问题 1：参数名不匹配

**原始配置（Spring Security 5 旧版默认）：**
```xml
<sec:form-login ... />
<!-- 默认参数名：username / password -->
```

**JSP 表单：**
```jsp
<input name="j_username" />
<input name="j_password" />
```

**问题**：参数名不匹配！Spring Security 拿不到用户名密码

**修复：**
```xml
<sec:form-login
    username-parameter="j_username"  <!-- 指定参数名 -->
    password-parameter="j_password" />  <!-- 指定参数名 -->
```

### 6.2 问题 2：密码加密问题

**Spring Security 5 默认行为**：需要加密密码

**修复**：自定义 PlainTextPasswordEncoder 处理明文密码

## 七、C++ 开发者对比

### 7.1 安全实现对比

**C++ 风格（自己写）：**
```cpp
// 伪代码：C++ 自己实现安全
void handle_login(HttpRequest* req) {
    // 手动解析 POST 参数
    std::string username = req->get_param("username");
    std::string password = req->get_param("password");
    
    // 手动查数据库
    User* user = db->find_user(username);
    
    // 手动验证密码
    if (!user || user->password != password) {
        send_error("Invalid login");
        return;
    }
    
    // 手动处理 Session
    Session* session = req->create_session();
    session->set("user", user);
    
    // 还得考虑：CSRF、XSS、Session 固定...
    // 这得写多少代码！
}
```
**问题**：太复杂！容易漏！

**Java + Spring Security 风格：**
```xml
<sec:form-login
    login-page="/account/signonForm"
    username-parameter="j_username"
    password-parameter="j_password" />
```
**好处**：就这么简单！Spring Security 全搞定！

### 7.2 类比理解

**Spring Security = 智能保安**
- 保安（Spring Security）站在门口（Filter）
- 每个访问者（HTTP 请求）都得先过保安这一关
- 保安验证身份（Authentication）
- 保安检查权限（Authorization）
- 合法放行，非法拦截

## 八、Spring Security 进阶功能

### 8.1 记住我（Remember Me）

**配置：**
```xml
<sec:remember-me
    key="uniqueAndSecret"
    token-validity-seconds="86400" />
```

**JSP：**
```jsp
<input type="checkbox" name="remember-me" /> Remember me
```

### 8.2 CSRF 保护（默认开启）

**Spring Security 自动防 CSRF**，JSP 里要加：
```jsp
<form method="post" action="...">
    <sec:csrfInput />  <!-- 自动生成 CSRF Token -->
    <!-- ... -->
</form>
```

### 8.3 密码加密（推荐 BCrypt）

**配置：**
```xml
<beans:bean id="passwordEncoder"
    class="org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder" />
```

**加密密码保存到数据库：**
```java
String rawPassword = "password123";
String encodedPassword = passwordEncoder.encode(rawPassword);
// $2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH
```

## 九、最佳实践

### 9.1 永远用 HTTPS（生产环境）

**原因**：防止密码明文传输

### 9.2 密码加密

**推荐**：BCrypt 或 Argon2
```java
BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
```

### 9.3 最小权限原则

**推荐**：
```xml
<intercept-url pattern="/admin/**" access="hasRole('ADMIN')" />
<intercept-url pattern="/**" access="permitAll" />
```

### 9.4 配置登出

**推荐**：
```xml
<logout
    logout-url="/account/signoff"
    logout-success-url="/catalog"
    invalidate-session="true" />
```

## 十、调试技巧

### 10.1 开启 Security 日志

**logback.xml：**
```xml
<logger name="org.springframework.security" level="DEBUG" />
```

### 10.2 查看认证过程

**日志输出：**
```
DEBUG: security.web.FilterChainProxy - /account/signon at position 1 of 10
DEBUG: authentication.ProviderManager - Authentication attempt using DaoAuthenticationProvider
DEBUG: dao.DaoAuthenticationProvider - Authentication successful
```

---

## 总结

**Spring Security 两大核心：**
1. **认证（Authentication）** - 验证你是谁
2. **授权（Authorization）** - 检查你能做什么

**记住一句话：**
> 登录、权限、登出，Spring Security 全部搞定！
