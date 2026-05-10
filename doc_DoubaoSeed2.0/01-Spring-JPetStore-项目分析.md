# Spring JPetStore 项目分析总结

## 一、项目概述

**Spring JPetStore** 是一个基于 Spring 框架的宠物商店示例应用程序，是学习 Java Web 开发的经典案例。这个项目展示了如何使用 Spring 全家桶构建一个完整的 Web 应用。

### 技术栈
- **Java 17** - 编程语言
- **Spring Framework 5.3.30** - 核心框架
- **Spring Security 5.7.12** - 安全框架
- **Spring MVC** - Web 框架
- **MyBatis 3.2.8** - ORM 框架
- **H2 Database** - 内存数据库
- **Maven** - 构建工具
- **JSP/JSTL** - 视图层
- **SLF4J + Logback** - 日志框架

### 项目结构
```
spring-jpetstore/
├── src/
│   ├── main/
│   │   ├── java/ik/am/jpetstore/
│   │   │   ├── app/                    # 应用层（Controller等）
│   │   │   └── domain/                 # 领域层（模型、服务、仓库）
│   │   ├── resources/
│   │   │   ├── META-INF/
│   │   │   │   ├── dozer/             # 对象映射配置
│   │   │   │   └── spring/            # Spring 配置文件
│   │   │   ├── database/              # 数据库脚本
│   │   │   └── ik/am/jpetstore/       # MyBatis 映射文件
│   │   └── webapp/
│   │       ├── WEB-INF/views/         # JSP 视图
│   │       ├── css/                   # 样式文件
│   │       └── images/                # 图片资源
└── pom.xml                            # Maven 配置
```

## 二、核心架构设计

### 分层架构（Layered Architecture）
项目采用典型的**分层架构**，从上到下依次为：

```
┌─────────────────────────────────────┐
│     Web 层 (app 包)                  │
│  - Controllers 控制器                │
│  - Forms 表单对象                    │
│  - Helpers 助手类                    │
└──────────────┬──────────────────────┘
               │ 调用
┌──────────────▼──────────────────────┐
│    服务层 (domain/service 包)        │
│  - 业务逻辑                          │
│  - 事务管理                          │
└──────────────┬──────────────────────┘
               │ 调用
┌──────────────▼──────────────────────┐
│  持久层 (domain/repository 包)        │
│  - MyBatis Mapper                    │
│  - 数据访问                          │
└──────────────┬──────────────────────┘
               │ 操作
┌──────────────▼──────────────────────┐
│     数据库层                          │
│  - H2 内存数据库                      │
└─────────────────────────────────────┘
```

### 包结构说明

#### 1. **app 包（应用层）**
- `account/` - 账户相关控制器
- `cart/` - 购物车相关控制器
- `catalog/` - 商品目录控制器
- `order/` - 订单相关控制器
- `common/session/` - 会话管理工具

#### 2. **domain 包（领域层）**
- `model/` - 实体类（Account、Cart、Product、Order等）
- `service/` - 服务接口和实现
- `repository/` - 数据访问接口
- `common/exception/` - 异常类

## 三、核心技术详解

### 3.1 Spring 依赖注入

**@Inject 注解（类似 @Autowired）**
```java
@Service("userDetailsService")
public class UserDetailsServiceImpl implements UserDetailsService {
    @Inject
    protected AccountService accountService;  // 自动注入
    
    @Inject
    protected CatalogService catalogService;
}
```

**C++ 对比：**
- Java 中的 `@Inject` 类似于 C++ 中的依赖注入，但 Java 通过注解和容器自动管理
- C++ 需要手动管理对象生命周期和依赖关系，或使用框架（如 Boost.DI）

### 3.2 Spring MVC Controller

```java
@Controller
@RequestMapping("catalog")
public class CatalogController {
    @Inject
    protected CatalogService catalogService;
    
    @RequestMapping("viewCategory")
    public String viewCategory(@RequestParam("categoryId") String categoryId, Model model) {
        List<Product> productList = catalogService.getProductListByCategory(categoryId);
        Category category = catalogService.getCategory(categoryId);
        model.addAttribute("productList", productList);
        model.addAttribute("category", category);
        return "catalog/Category";
    }
}
```

**关键点：**
- `@Controller` - 标记为控制器
- `@RequestMapping` - 定义 URL 映射
- `@RequestParam` - 获取请求参数
- `Model` - 向视图传递数据
- 返回值 - 视图名称

### 3.3 Spring Security 安全认证

**配置文件 spring-security.xml：**
```xml
<sec:http auto-config="true" use-expressions="true">
    <sec:form-login login-page="/account/signonForm"
        login-processing-url="/account/signon"
        username-parameter="j_username"       <!-- 自定义用户名参数名 -->
        password-parameter="j_password"       <!-- 自定义密码参数名 -->
        authentication-failure-url="/account/signonForm?error=true" />
    <sec:intercept-url pattern="/order/**" access="isAuthenticated()" />
</sec:http>

<sec:authentication-manager>
    <sec:authentication-provider user-service-ref="userDetailsService">
    </sec:authentication-provider>
</sec:authentication-manager>
```

**自定义密码编码器：**
```java
public class PlainTextPasswordEncoder implements PasswordEncoder {
    @Override
    public String encode(CharSequence rawPassword) {
        return rawPassword.toString();
    }
    
    @Override
    public boolean matches(CharSequence rawPassword, String encodedPassword) {
        return rawPassword.toString().equals(encodedPassword);
    }
}
```

### 3.4 MyBatis 数据访问

**Repository 接口：**
```java
public interface AccountRepository {
    Account getAccountByUsername(String username);
    Account getAccountByUsernameAndPassword(String username, String password);
    void insertAccount(Account account);
}
```

**MyBatis 映射文件（AccountRepository.xml）：**
```xml
<select id="getAccountByUsername" parameterType="string" resultType="Account">
    SELECT SIGNON.USERNAME, SIGNON.PASSWORD, ...
    FROM ACCOUNT, PROFILE, SIGNON, BANNERDATA
    WHERE ACCOUNT.USERID = #{username}
    AND SIGNON.USERNAME = ACCOUNT.USERID
    AND PROFILE.USERID = ACCOUNT.USERID
</select>
```

**C++ 对比：**
- MyBatis 类似于 C++ 中的 ORM 库（如 ODB）
- MyBatis 使用 XML 或注解定义 SQL 映射，更加灵活
- Java 有更好的 SQL 映射支持

### 3.5 Session 管理

**Spring Session 范围 Bean：**
```xml
<bean id="cart" class="ik.am.jpetstore.domain.model.Cart"
    scope="session">
    <aop:scoped-proxy />
</bean>
```

**说明：**
- `scope="session"` - 每个用户会话一个 Cart 实例
- `aop:scoped-proxy` - 使用 AOP 代理实现会话范围

## 四、Spring 配置文件详解

### 4.1 applicationContext.xml（主配置文件）
```xml
<!-- 国际化资源文件 -->
<bean id="messageSource" class="org.springframework.context.support.ReloadableResourceBundleMessageSource">
    <property name="basenames">
        <list>
            <value>i18n/application-messages</value>
        </list>
    </property>
</bean>

<!-- 导入其他配置 -->
<import resource="classpath:META-INF/spring/spring-jpetstore-domain.xml" />

<!-- Dozer 对象映射 -->
<bean class="org.dozer.spring.DozerBeanMapperFactoryBean">
    <property name="mappingFiles" value="classpath*:/META-INF/dozer/**/*-mapping.xml" />
</bean>
```

### 4.2 spring-mvc.xml（Web 配置）
```xml
<!-- 启用注解驱动 -->
<mvc:annotation-driven>
    <mvc:argument-resolvers>
        <bean class="org.springframework.data.web.PageableHandlerMethodArgumentResolver" />
    </mvc:argument-resolvers>
</mvc:annotation-driven>

<!-- 扫描 Controller -->
<context:component-scan base-package="ik.am.jpetstore.app" />

<!-- 视图解析器 -->
<bean id="viewResolver" class="org.springframework.web.servlet.view.InternalResourceViewResolver">
    <property name="prefix" value="/WEB-INF/views/" />
    <property name="suffix" value=".jsp" />
</bean>

<!-- 静态资源处理 -->
<mvc:resources mapping="/resources/**" location="/resources/,classpath:META-INF/resources/" />
```

### 4.3 web.xml（Web 应用配置）
```xml
<!-- Spring 上下文加载监听器 -->
<listener>
    <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
</listener>

<!-- Spring MVC DispatcherServlet -->
<servlet>
    <servlet-name>appServlet</servlet-name>
    <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
    <init-param>
        <param-name>contextConfigLocation</param-name>
        <param-value>classpath*:META-INF/spring/spring-mvc.xml</param-value>
    </init-param>
    <load-on-startup>1</load-on-startup>
</servlet>

<!-- Spring Security 过滤器 -->
<filter>
    <filter-name>springSecurityFilterChain</filter-name>
    <filter-class>org.springframework.web.filter.DelegatingFilterProxy</filter-class>
</filter>
```

## 五、数据库设计

### 5.1 H2 内存数据库

**schema.sql - 建表脚本：**
```sql
CREATE TABLE ACCOUNT (
    USERID VARCHAR(80),
    EMAIL VARCHAR(80),
    FIRSTNAME VARCHAR(80),
    LASTNAME VARCHAR(80),
    STATUS VARCHAR(2),
    ADDR1 VARCHAR(80),
    ADDR2 VARCHAR(40),
    CITY VARCHAR(80),
    STATE VARCHAR(80),
    ZIP VARCHAR(20),
    COUNTRY VARCHAR(20),
    PHONE VARCHAR(80),
    PRIMARY KEY (USERID)
);

CREATE TABLE SIGNON (
    USERNAME VARCHAR(80),
    PASSWORD VARCHAR(80),
    PRIMARY KEY (USERNAME)
);

CREATE TABLE PRODUCT (
    PRODUCTID VARCHAR(10),
    CATEGORY VARCHAR(10),
    NAME VARCHAR(80),
    DESCN VARCHAR(255),
    PRIMARY KEY (PRODUCTID)
);
```

**data.sql - 初始化数据：**
```sql
INSERT INTO SIGNON VALUES ('j2ee', 'j2ee');
INSERT INTO SIGNON VALUES ('ACID', 'ACID');

INSERT INTO ACCOUNT VALUES ('j2ee', 'yourname@yourdomain.com', ...);
```

### 5.2 数据库初始化流程
1. 应用启动时自动执行 H2-schema.sql 建表
2. 执行 H2-dataload.sql 加载数据
3. **注意**：H2 是内存数据库，重启应用后数据会重置！


#### 🗄️ 查询 H2 数据库的方法
本项目使用 H2 内存数据库 ，我来告诉你几种查询方式：

##### 方法 1：使用 H2 控制台（推荐，最直观）
H2 自带一个 Web 控制台，你可以用它直接查询数据库：
 步骤 1：先启动项目
```
cd d:\Project\Java\spring-jpetstore
mvn tomcat7:run
``` 步骤 2：访问 H2 控制台
等项目启动后，浏览器打开：

```
http://localhost:8088/spring-jpetstore/h2-console
``` 步骤 3：配置连接参数
在控制台页面输入：
   | 配置项 | 值 |
   |--------|-----|
   | Driver Class | org.h2.Driver |
   | JDBC URL | jdbc:h2:mem:spring-petstore;MODE=PostgreSQL |
   | 用户名 | sa |
   | 密码 | （留空） |
点击「Connect」就可以查询了！   

 步骤 4：查询数据
点击「Connect」连接后，你就可以执行 SQL 了！例如：

```
-- 查询所有用户
SELECT * FROM SIGNON;

-- 查询商品
SELECT * FROM PRODUCT;

-- 查询购物车示例
SELECT * FROM ACCOUNT;
```
##### 方法 2：查看数据库初始化脚本（了解数据结构）
项目的数据库初始化脚本在：

```
d:\Project\Java\spring-jpetstore\src\main\resources\database\
├── H2-ddl.sql          # 建表语句
└── H2-dataload.sql     # 初始数据
```
你可以直接查看 H2-dataload.sql 了解有哪些数据。

## 六、启动和部署

### 6.1 开发环境启动

**方式一：使用 Maven 插件（推荐）**
```bash
# 进入项目目录
cd d:\Project\Java\spring-jpetstore

# 使用 Tomcat7 Maven 插件启动
mvn tomcat7:run
```

**方式二：编译打包后部署**
```bash
# 编译打包
mvn clean package

# 生成的 WAR 文件在 target/spring-jpetstore.war
# 可以部署到 Tomcat/webapps 目录
```

### 6.2 访问应用
- **应用地址**：http://localhost:8088/spring-jpetstore/
- **登录页面**：http://localhost:8088/spring-jpetstore/account/signonForm
- **测试账户**：j2ee / j2ee
- **管理账户**：ACID / ACID

### 6.3 pom.xml 关键配置
```xml
<!-- Maven 编译插件 -->
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <version>3.8.1</version>
    <configuration>
        <source>17</source>
        <target>17</target>
    </configuration>
</plugin>

<!-- Tomcat7 Maven 插件 -->
<plugin>
    <groupId>org.apache.tomcat.maven</groupId>
    <artifactId>tomcat7-maven-plugin</artifactId>
    <version>2.2</version>
    <configuration>
        <port>8088</port>
        <path>/spring-jpetstore</path>
        <!-- Java 17 模块系统参数 -->
        <additionalJvmArgs>--add-opens=java.base/java.lang=ALL-UNNAMED ...</additionalJvmArgs>
    </configuration>
</plugin>

<!-- 阿里云仓库（国内加速） -->
<repository>
    <id>aliyun</id>
    <url>https://maven.aliyun.com/repository/public</url>
</repository>
```

## 七、C++ 开发者视角

### 7.1 C++ vs Java 对比

| 特性 | C++ | Java |
|------|-----|------|
| **内存管理** | 手动（new/delete） | 自动（GC） |
| **依赖注入** | 需要框架或手动 | Spring 容器自动 |
| **多态** | 虚函数、模板 | 接口、继承 |
| **编译模型** | 源文件->目标文件->链接 | 源文件->字节码->JIT |
| **标准库** | STL | JDK |
| **并发** | 线程、互斥锁 | synchronized、线程池 |
| **Web 开发** | 需要框架（CGI、FastCGI） | Servlet、Spring MVC |
| **跨平台** | 需重新编译 | 一次编写，到处运行 |

### 7.2 Java 开发思维转变

**1. 一切皆对象**
- C++ 支持面向过程和面向对象
- Java 纯粹面向对象，甚至 main 函数都在类中

**2. 容器管理**
```java
// C++ 风格：手动创建对象
AccountService service = new AccountServiceImpl();
service.setAccountRepository(new AccountRepositoryImpl());

// Java 风格：Spring 容器管理
@Service
public class AccountServiceImpl {
    @Inject
    private AccountRepository accountRepository;  // 自动注入
}
```

**3. 注解驱动**
- C++ 没有内置注解（C++20 才有属性）
- Java 注解是语言特性，广泛用于框架

### 7.3 重要概念

**Bean：** Spring 管理的对象
```java
@Service  // 标记为 Bean
public class AccountServiceImpl { ... }
```

**IoC（控制反转）：** 把对象创建权交给容器
- C++：你自己 new 对象
- Java：Spring 帮你创建对象，你直接用

**AOP（面向切面编程）：** 在方法前后添加额外逻辑
```java
// 日志、事务、安全等横切关注点
@Transactional  // 自动事务管理
public void insertAccount(Account account) {
    // 方法执行时自动开启/提交/回滚事务
}
```

## 八、常见问题和解决方案

### 8.1 Maven 依赖下载慢

**问题**：默认从 Maven Central 下载，国内很慢

**解决**：在 pom.xml 中配置阿里云镜像
```xml
<repository>
    <id>aliyun</id>
    <url>https://maven.aliyun.com/repository/public</url>
</repository>
```

### 8.2 Java 17 模块系统问题

**问题**：Spring 4.x 在 Java 17 上出现 `InaccessibleObjectException`

**解决**：在 tomcat7-maven-plugin 中添加 JVM 参数
```xml
<additionalJvmArgs>
    --add-opens=java.base/java.lang=ALL-UNNAMED
    --add-opens=java.base/java.lang.reflect=ALL-UNNAMED
    --add-opens=java.base/java.io=ALL-UNNAMED
    --add-opens=java.base/java.util=ALL-UNNAMED
</additionalJvmArgs>
```

### 8.3 登录表单参数名问题

**问题**：Spring Security 5.x 默认参数名是 `username`/`password`

**解决**：在 spring-security.xml 中自定义参数名
```xml
<sec:form-login 
    username-parameter="j_username"
    password-parameter="j_password" />
```

### 8.4 JSP 标签库找不到

**问题**：自定义标签库 URL 无法解析

**解决**：使用标准 JSTL 标签库
```jsp
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!-- 使用 fn:escapeXml 替代自定义的 f:h -->
```

## 九、学习建议

### 9.1 学习路径

**阶段一：Java 基础**
- 学习 Java 语法、OOP、集合类
- 理解 Java 异常、IO、并发

**阶段二：Web 基础**
- 学习 Servlet、JSP、HTTP 协议
- 理解请求-响应模型

**阶段三：Spring 基础**
- IoC 容器、依赖注入
- AOP 编程
- Spring MVC

**阶段四：数据访问**
- JDBC、MyBatis
- 事务管理

**阶段五：安全框架**
- Spring Security 认证、授权

### 9.2 代码阅读建议

1. **从 Controllers 开始** - `CatalogController`、`AccountController`
2. **了解 Service 层** - `AccountService`、`CatalogService`
3. **理解 Repository** - `AccountRepository`、`ProductRepository`
4. **查看配置** - spring-mvc.xml、spring-security.xml
5. **了解 JSP 视图** - 视图如何渲染数据

### 9.3 实验建议

1. **添加新功能**：比如增加商品评价功能
2. **更换数据库**：从 H2 改为 MySQL
3. **优化性能**：添加缓存、优化 SQL
4. **学习新技术**：Spring Boot、Spring Data JPA

## 十、扩展阅读

- **Spring 官方文档**：https://spring.io/projects/spring-framework
- **MyBatis 官方文档**：https://mybatis.org/mybatis-3/
- **Spring Security 官方文档**：https://spring.io/projects/spring-security
- **Java EE 教程**：https://docs.oracle.com/javaee/
- **Maven 入门**：https://maven.apache.org/guides/

---

**祝您学习愉快！** 🎉

如有问题，请查看 `我的错误/log.txt` 或运行日志！
