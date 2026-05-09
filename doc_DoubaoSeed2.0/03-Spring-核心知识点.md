# Spring 核心知识点详解

## 一、IoC（控制反转）

### 1.1 什么是 IoC？

**IoC（Inversion of Control，控制反转）** 是一种设计思想，把对象的创建权从程序员手中交给容器（容器可以是 Spring、或者其他 DI 容器）。

**C++ 对比：**
- C++ 中：你手动 `new` 一个对象，决定它的生命周期
- Java + Spring：Spring 容器帮你创建和管理对象，你直接用就行

### 1.2 为什么要用 IoC？

**例子对比：**

**C++ 风格（手动管理）：**
```cpp
// C++ 示例
class OrderService {
private:
    OrderRepository* repo;
public:
    OrderService() {
        repo = new OrderRepositoryImpl();  // 手动创建
    }
    // ...
};
```
**问题**：OrderService 和 OrderRepositoryImpl 强耦合，要换个实现需要改代码

**Spring 风格（IoC）：**
```java
@Service
public class OrderService {
    @Inject
    private OrderRepository repo;  // Spring 自动注入
    
    // 不用写构造函数创建对象！
}
```
**好处**：松耦合，想换个实现只改配置就行

### 1.3 IoC 容器

Spring IoC 容器的核心工作：
1. **读取配置**（XML 或注解）
2. **创建 Bean**（对象）
3. **管理生命周期**（创建、初始化、销毁）
4. **注入依赖**（自动装配）

## 二、DI（依赖注入）

### 2.1 什么是 DI？

**DI（Dependency Injection，依赖注入）** 是 IoC 的具体实现方式：容器把一个对象需要的依赖对象注入进去。

### 2.2 三种注入方式

**1. 构造器注入（推荐）**
```java
@Service
public class OrderService {
    private final OrderRepository repo;
    
    @Inject
    public OrderService(OrderRepository repo) {
        this.repo = repo;  // 构造器注入
    }
}
```
**优点**：依赖不可变，保证对象完整性

**2. Setter 注入**
```java
@Service
public class OrderService {
    private OrderRepository repo;
    
    @Inject
    public void setRepo(OrderRepository repo) {
        this.repo = repo;  // Setter 注入
    }
}
```
**优点**：可选依赖，灵活性好

**3. 字段注入（@Autowired/@Inject）**
```java
@Service
public class OrderService {
    @Inject
    private OrderRepository repo;  // 直接在字段上注入
}
```
**优点**：代码少，简单
**缺点**：难以测试，违反单一职责原则

### 2.3 常用注解

| 注解 | 说明 | 所在包 |
|------|------|--------|
| `@Component` | 通用组件注解 | `org.springframework.stereotype` |
| `@Service` | 服务层组件 | `org.springframework.stereotype` |
| `@Repository` | 持久层组件 | `org.springframework.stereotype` |
| `@Controller` | 控制器组件 | `org.springframework.stereotype` |
| `@Inject` / `@Autowired` | 自动注入 | `javax.inject` / `org.springframework.beans.factory.annotation` |

**示例代码：**
```java
@Repository  // 标记为持久层 Bean
public class AccountRepositoryImpl implements AccountRepository {
    // ...
}

@Service  // 标记为服务层 Bean
public class AccountServiceImpl implements AccountService {
    @Inject
    private AccountRepository repo;  // 自动注入
}

@Controller  // 标记为控制器 Bean
public class AccountController {
    @Inject
    private AccountService service;  // 自动注入
}
```

## 三、Bean（Spring Bean）

### 3.1 什么是 Bean？

**Bean** 就是 Spring 容器管理的对象。

### 3.2 Bean 的定义方式

**方式一：注解（最常用）**
```java
@Service
public class AccountService {
    // 这个类会被 Spring 作为 Bean 管理
}
```

**方式二：XML 配置**
```xml
<bean id="accountService" class="ik.am.jpetstore.domain.service.account.AccountServiceImpl" />
```

**方式三：@Configuration + @Bean**
```java
@Configuration
public class AppConfig {
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new PlainTextPasswordEncoder();
    }
}
```

### 3.3 Bean 的作用域（Scope）

| 作用域 | 说明 | 示例 |
|--------|------|------|
| singleton | 单例（默认），全应用只有一个 | 服务、仓库 |
| prototype | 每次请求创建新实例 | 临时对象 |
| request | Web：每个 HTTP 请求一个 | Request |
| session | Web：每个会话一个 | Shopping Cart |

**项目中的示例：**
```xml
<!-- 购物车是 session 作用域，每个用户一个 -->
<bean id="cart" class="ik.am.jpetstore.domain.model.Cart"
    scope="session">
    <aop:scoped-proxy />
</bean>
```

### 3.4 Bean 的生命周期

1. **实例化**（Instantiation）：`new` 对象
2. **属性赋值**（Populate）：注入依赖
3. **初始化前**（BeanPostProcessor）
4. **初始化**（InitializingBean）
5. **使用中**（Ready to use）
6. **销毁**（DisposableBean）

## 四、AOP（面向切面编程）

### 4.1 什么是 AOP？

**AOP（Aspect-Oriented Programming，面向切面编程）** 把日志、事务、安全等**横切关注点**从业务逻辑中分离出来。

**生活例子：**
- 餐馆里：厨师负责做菜（核心业务），服务员负责端盘子、结账（横切关注点）
- 软件中：服务负责业务逻辑，AOP 负责日志、事务、安全

### 4.2 AOP 术语

| 术语 | 说明 |
|------|------|
| Aspect（切面） | 横切关注点的模块化，比如日志切面 |
| Advice（通知） | 切面要做的具体动作 |
| Join Point（连接点） | 能插入切面的位置，比如方法调用 |
| Pointcut（切点） | 真正应用切面的地方 |

### 4.3 本项目中的 AOP 应用

**事务管理（@Transactional）：**
```java
@Service
public class AccountServiceImpl implements AccountService {
    
    @Transactional  // 这个方法有事务！
    public void insertAccount(Account account) {
        accountRepository.insertAccount(account);
        accountRepository.insertProfile(account);
        accountRepository.insertSignon(account);
        // 如果中间抛异常，Spring 会自动回滚！
    }
}
```

## 五、Spring 配置方式

### 5.1 XML 配置（本项目使用）

**applicationContext.xml：**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">
    
    <!-- 组件扫描 -->
    <context:component-scan base-package="ik.am.jpetstore" />
    
    <!-- 定义 Bean -->
    <bean id="passwordEncoder" class="ik.am.jpetstore.domain.service.user.PlainTextPasswordEncoder" />
    
    <!-- 导入其他配置文件 -->
    <import resource="classpath:META-INF/spring/spring-jpetstore-domain.xml" />
</beans>
```

### 5.2 注解配置

**@Configuration + @Bean：**
```java
@Configuration
@ComponentScan("ik.am.jpetstore")
public class AppConfig {
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new PlainTextPasswordEncoder();
    }
}
```

### 5.3 Java + XML 混合（本项目）

```xml
<!-- web.xml -->
<context-param>
    <param-name>contextConfigLocation</param-name>
    <param-value>
        classpath*:META-INF/spring/applicationContext.xml
        classpath*:META-INF/spring/spring-security.xml
    </param-value>
</context-param>
```

## 六、Spring 核心容器工作流程

### 6.1 IoC 容器启动流程

```
1. 读取配置文件（web.xml）
2. 创建 ApplicationContext
3. 扫描组件（@Component、@Service 等）
4. 创建 Bean 实例
5. 注入依赖
6. 初始化 Bean
7. 应用启动完成
```

### 6.2 本项目的容器初始化

**web.xml 配置：**
```xml
<!-- 1. 配置 ContextLoaderListener，启动 IoC 容器 -->
<listener>
    <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
</listener>

<!-- 2. 告诉容器去哪里找配置文件 -->
<context-param>
    <param-name>contextConfigLocation</param-name>
    <param-value>
        classpath*:META-INF/spring/applicationContext.xml
        classpath*:META-INF/spring/spring-security.xml
    </param-value>
</context-param>
```

**Spring MVC DispatcherServlet 配置：**
```xml
<servlet>
    <servlet-name>appServlet</servlet-name>
    <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
    <init-param>
        <param-name>contextConfigLocation</param-name>
        <param-value>classpath*:META-INF/spring/spring-mvc.xml</param-value>
    </init-param>
    <load-on-startup>1</load-on-startup>
</servlet>
```

## 七、C++ 开发者特别笔记

### 7.1 思维转变

**从 C++ 到 Java + Spring 的关键转变：**

| 方面 | C++ | Java + Spring |
|------|-----|---------------|
| **对象创建** | 手动 `new` | 容器管理 |
| **依赖关系** | 指针/引用 | 依赖注入 |
| **内存管理** | 手动管理 | GC + 容器 |
| **配置** | 代码里写死 | 配置文件/注解 |
| **面向对象** | 纯 OOP 可选 | 强制 OOP |

### 7.2 类比理解

**Spring 容器 = 智能工厂**
- 你向工厂下订单（配置）：我需要一个 OrderService
- 工厂检查它需要什么零件（依赖）
- 工厂组装好给你（注入依赖）
- 工厂负责产品生命周期（创建到销毁）

**IoC = 把工厂建起来**
- 以前：你是工人，自己做产品
- 现在：你是客户，找工厂下单

## 八、最佳实践

### 8.1 使用注解而不是 XML

**推荐：**
```java
@Service
public class OrderService {
    @Inject
    private OrderRepository repo;
}
```
**不推荐：**
```xml
<bean id="orderService" class="...">
    <property name="repo" ref="orderRepository" />
</bean>
```

### 8.2 优先使用构造器注入

**推荐：**
```java
@Service
public class OrderService {
    private final OrderRepository repo;
    
    @Inject
    public OrderService(OrderRepository repo) {
        this.repo = repo;
    }
}
```
**原因**：
1. 依赖不可变（final）
2. 更容易单元测试（可以 mock）
3. 保证对象完整性

### 8.3 给 Bean 起个好名字

**清晰的命名：**
```java
@Service("userDetailsService")  // 明确 Bean 名字
public class UserDetailsServiceImpl {
    // ...
}
```

### 8.4 使用合适的作用域

- 无状态服务 → singleton
- 用户数据 → session 或 request
- 临时对象 → prototype

---

## 总结

**Spring 核心三大件：**
1. **IoC** - 控制反转，对象给容器管
2. **DI** - 依赖注入，容器帮你注入
3. **AOP** - 面向切面，横切关注点分离

**记住这句话：**
> 你写业务代码，Spring 管生命周期和依赖关系！
