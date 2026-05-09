# MyBatis 详解与实战

## 一、什么是 MyBatis？

### 1.1 核心概念

**MyBatis** 是一款优秀的**持久层框架**，它简化了 JDBC 操作，让你专注于 SQL 本身。

**MyBatis 核心特点：**
- SQL 写在 XML 文件里，和代码分离
- 自动映射结果到 Java 对象
- 自动处理 JDBC 细节

### 1.2 为什么不用 JDBC？

**JDBC 代码（噩梦！）：**
```java
// C++ 或 Java JDBC 风格
Connection conn = DriverManager.getConnection(...);
PreparedStatement stmt = conn.prepareStatement("SELECT * FROM PRODUCT WHERE PRODUCTID = ?");
stmt.setString(1, productId);
ResultSet rs = stmt.executeQuery();

if (rs.next()) {
    Product product = new Product();
    product.setProductId(rs.getString("PRODUCTID"));
    product.setName(rs.getString("NAME"));
    // ... 手动映射几十行
}

rs.close();
stmt.close();
conn.close();
```
**问题**：太繁琐！大量重复代码！

**MyBatis 代码（爽！）：**
```java
// MyBatis 风格
Product product = productRepository.getProduct(productId);
// 就这么简单！
```

### 1.3 MyBatis vs 其他框架对比

| 框架 | 特点 | 适用场景 |
|------|------|----------|
| **MyBatis** | SQL 写在 XML，灵活 | 复杂查询、SQL 优化 |
| **Hibernate** | ORM 映射，自动 SQL | 简单 CRUD，快速开发 |
| **Spring Data JPA** | 基于 Hibernate | 简单查询、快速开发 |

## 二、MyBatis 核心组件

### 2.1 项目结构

```
src/main/resources/ik/am/jpetstore/domain/repository/
├── account/
│   └── AccountRepository.xml       # MyBatis 映射文件
├── category/
│   └── CategoryRepository.xml
├── product/
│   └── ProductRepository.xml
└── ...
```

### 2.2 Repository 接口

```java
package ik.am.jpetstore.domain.repository.account;

import ik.am.jpetstore.domain.model.Account;

public interface AccountRepository {
    // 方法 1：按用户名查询
    Account getAccountByUsername(String username);
    
    // 方法 2：按用户名和密码查询
    Account getAccountByUsernameAndPassword(String username, String password);
    
    // 方法 3：插入账户
    void insertAccount(Account account);
    
    // 方法 4：更新账户
    void updateAccount(Account account);
}
```

### 2.3 MyBatis 映射文件（XML）

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" 
"http://mybatis.org/dtd/mybatis-3-mapper.dtd">

<!-- 命名空间：对应 Repository 接口 -->
<mapper namespace="ik.am.jpetstore.domain.repository.account.AccountRepository">

    <!-- 查询单个对象 -->
    <select id="getAccountByUsername" parameterType="string" resultType="Account">
        SELECT
            SIGNON.USERNAME,
            SIGNON.PASSWORD,
            ACCOUNT.EMAIL,
            ACCOUNT.FIRSTNAME,
            ACCOUNT.LASTNAME,
            ACCOUNT.STATUS,
            ACCOUNT.ADDR1 AS address1,
            ACCOUNT.ADDR2 AS address2,
            ACCOUNT.CITY,
            ACCOUNT.STATE,
            ACCOUNT.ZIP,
            ACCOUNT.COUNTRY,
            ACCOUNT.PHONE,
            PROFILE.LANGPREF AS languagePreference,
            PROFILE.FAVCATEGORY AS favouriteCategoryId,
            PROFILE.MYLISTOPT AS listOption,
            PROFILE.BANNEROPT AS bannerOption,
            BANNERDATA.BANNERNAME
        FROM ACCOUNT, PROFILE, SIGNON, BANNERDATA
        WHERE ACCOUNT.USERID = #{username}
          AND SIGNON.USERNAME = ACCOUNT.USERID
          AND PROFILE.USERID = ACCOUNT.USERID
          AND PROFILE.FAVCATEGORY = BANNERDATA.FAVCATEGORY
    </select>
    
    <!-- 查询多个对象 -->
    <select id="getProductListByCategory" parameterType="string" resultType="Product">
        SELECT PRODUCTID, NAME, DESCN, CATEGORY
        FROM PRODUCT
        WHERE CATEGORY = #{categoryId}
    </select>
    
    <!-- 插入操作 -->
    <insert id="insertAccount" parameterType="Account">
        INSERT INTO ACCOUNT (
            EMAIL, FIRSTNAME, LASTNAME, STATUS, ADDR1, ADDR2, CITY, STATE, ZIP, COUNTRY, PHONE, USERID
        ) VALUES (
            #{email}, #{firstName}, #{lastName}, #{status}, #{address1},
            #{address2,jdbcType=VARCHAR}, #{city}, #{state}, #{zip},
            #{country}, #{phone}, #{username}
        )
    </insert>
    
    <!-- 更新操作 -->
    <update id="updateAccount" parameterType="Account">
        UPDATE ACCOUNT SET
            EMAIL = #{email},
            FIRSTNAME = #{firstName},
            LASTNAME = #{lastName},
            STATUS = #{status},
            ADDR1 = #{address1},
            ADDR2 = #{address2,jdbcType=VARCHAR},
            CITY = #{city},
            STATE = #{state},
            ZIP = #{zip},
            COUNTRY = #{country},
            PHONE = #{phone}
        WHERE USERID = #{username}
    </update>
    
    <!-- 删除操作 -->
    <delete id="deleteAccount" parameterType="string">
        DELETE FROM ACCOUNT WHERE USERID = #{username}
    </delete>

</mapper>
```

## 三、MyBatis 核心元素详解

### 3.1 参数占位符

**两种参数方式：**

| 方式 | 说明 | 示例 |
|------|------|------|
| `#{param}` | 预编译（推荐），防 SQL 注入 | `#{username}` |
| `${param}` | 字符串替换（谨慎使用） | `${tableName}` |

**正确用法：**
```xml
<!-- 预编译：安全，防 SQL 注入 -->
<select id="getAccountByUsername" parameterType="string" resultType="Account">
    SELECT * FROM ACCOUNT WHERE USERID = #{username}
</select>
```

**危险用法（别用！）：**
```xml
<!-- 字符串替换：有 SQL 注入风险！ -->
<select id="getAccountByUsername" parameterType="string" resultType="Account">
    SELECT * FROM ACCOUNT WHERE USERID = '${username}'
</select>
```

### 3.2 结果映射（resultType）

**方式一：自动映射（同名）**
```java
public class Account {
    private String username;   // 对应数据库 USERNAME
    private String email;      // 对应数据库 EMAIL
    // ...
}
```

**方式二：别名映射（不同名）**
```xml
<select id="getAccountByUsername" resultType="Account">
    SELECT 
        USERNAME, 
        EMAIL, 
        ADDR1 AS address1,  <!-- 别名映射！ -->
        ADDR2 AS address2   <!-- 别名映射！ -->
    FROM ACCOUNT
</select>
```

**方式三：resultMap（复杂情况）**
```xml
<resultMap id="AccountResultMap" type="Account">
    <id property="username" column="USERNAME" />
    <result property="email" column="EMAIL" />
    <result property="address1" column="ADDR1" />
</resultMap>

<select id="getAccountByUsername" resultMap="AccountResultMap">
    SELECT * FROM ACCOUNT WHERE USERID = #{username}
</select>
```

### 3.3 parameterType（参数类型）

**基本类型：**
```xml
<select id="getAccountByUsername" parameterType="string" resultType="Account">
    SELECT * FROM ACCOUNT WHERE USERID = #{username}
</select>
```

**对象类型：**
```xml
<insert id="insertAccount" parameterType="Account">
    INSERT INTO ACCOUNT (EMAIL, FIRSTNAME, LASTNAME, USERID)
    VALUES (#{email}, #{firstName}, #{lastName}, #{username})
</insert>
```

**多参数：**
```xml
<select id="getAccountByUsernameAndPassword" resultType="Account">
    SELECT * FROM ACCOUNT
    WHERE USERNAME = #{param1} AND PASSWORD = #{param2}
</select>
```

## 四、MyBatis 与 Spring 集成

### 4.1 本项目配置

**spring-jpetstore-infra.xml：**
```xml
<!-- 1. 数据源（H2 内存数据库） -->
<bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
    <property name="driverClassName" value="org.h2.Driver" />
    <property name="url" value="jdbc:h2:mem:jpetstore;DB_CLOSE_DELAY=-1" />
    <property name="username" value="sa" />
    <property name="password" value="" />
</bean>

<!-- 2. SqlSessionFactoryBean -->
<bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
    <property name="dataSource" ref="dataSource" />
    <property name="configLocation" value="classpath:mybatis-config.xml" />
    <property name="mapperLocations" value="classpath*:ik/am/jpetstore/domain/repository/**/*.xml" />
</bean>

<!-- 3. MapperScannerConfigurer - 自动扫描 Repository 接口 -->
<bean class="org.mybatis.spring.mapper.MapperScannerConfigurer">
    <property name="basePackage" value="ik.am.jpetstore.domain.repository" />
</bean>

<!-- 4. 事务管理器 -->
<bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
    <property name="dataSource" ref="dataSource" />
</bean>

<!-- 5. 启用事务注解 -->
<tx:annotation-driven transaction-manager="transactionManager" />
```

### 4.2 使用 Repository

**Service 层调用：**
```java
@Service
public class AccountServiceImpl implements AccountService {
    
    @Inject
    private AccountRepository accountRepository;  // 自动注入
    
    @Override
    public Account getAccount(String username) {
        return accountRepository.getAccountByUsername(username);
    }
    
    @Override
    @Transactional  // 开启事务！
    public void insertAccount(Account account) {
        accountRepository.insertAccount(account);
        accountRepository.insertProfile(account);
        accountRepository.insertSignon(account);
        // 如果中间抛异常，自动回滚！
    }
}
```

## 五、实战：项目中的 Repository 分析

### 5.1 AccountRepository 完整示例

**接口：**
```java
public interface AccountRepository {
    Account getAccountByUsername(String username);
    Account getAccountByUsernameAndPassword(String username, String password);
    void insertAccount(Account account);
    void insertProfile(Account account);
    void insertSignon(Account account);
    void updateAccount(Account account);
    void updateProfile(Account account);
    void updateSignon(Account account);
}
```

**XML 映射：**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" 
"http://mybatis.org/dtd/mybatis-3-mapper.dtd">

<mapper namespace="ik.am.jpetstore.domain.repository.account.AccountRepository">

    <!-- 查询 1：按用户名查 -->
    <select id="getAccountByUsername" parameterType="string" resultType="Account">
        SELECT
            SIGNON.USERNAME,
            SIGNON.PASSWORD,
            ACCOUNT.EMAIL,
            ACCOUNT.FIRSTNAME,
            ACCOUNT.LASTNAME,
            ACCOUNT.STATUS,
            ACCOUNT.ADDR1 AS address1,
            ACCOUNT.ADDR2 AS address2,
            ACCOUNT.CITY,
            ACCOUNT.STATE,
            ACCOUNT.ZIP,
            ACCOUNT.COUNTRY,
            ACCOUNT.PHONE,
            PROFILE.LANGPREF AS languagePreference,
            PROFILE.FAVCATEGORY AS favouriteCategoryId,
            PROFILE.MYLISTOPT AS listOption,
            PROFILE.BANNEROPT AS bannerOption,
            BANNERDATA.BANNERNAME
        FROM ACCOUNT, PROFILE, SIGNON, BANNERDATA
        WHERE ACCOUNT.USERID = #{username}
          AND SIGNON.USERNAME = ACCOUNT.USERID
          AND PROFILE.USERID = ACCOUNT.USERID
          AND PROFILE.FAVCATEGORY = BANNERDATA.FAVCATEGORY
    </select>
    
    <!-- 查询 2：按用户名和密码查 -->
    <select id="getAccountByUsernameAndPassword" parameterType="Account" resultType="Account">
        SELECT
            SIGNON.USERNAME,
            SIGNON.PASSWORD,
            ACCOUNT.EMAIL,
            ACCOUNT.FIRSTNAME,
            ACCOUNT.LASTNAME,
            ACCOUNT.STATUS,
            ACCOUNT.ADDR1 AS address1,
            ACCOUNT.ADDR2 AS address2,
            ACCOUNT.CITY,
            ACCOUNT.STATE,
            ACCOUNT.ZIP,
            ACCOUNT.COUNTRY,
            ACCOUNT.PHONE,
            PROFILE.LANGPREF AS languagePreference,
            PROFILE.FAVCATEGORY AS favouriteCategoryId,
            PROFILE.MYLISTOPT AS listOption,
            PROFILE.BANNEROPT AS bannerOption,
            BANNERDATA.BANNERNAME
        FROM ACCOUNT, PROFILE, SIGNON, BANNERDATA
        WHERE ACCOUNT.USERID = #{param1}
          AND SIGNON.PASSWORD = #{param2}
          AND SIGNON.USERNAME = ACCOUNT.USERID
          AND PROFILE.USERID = ACCOUNT.USERID
          AND PROFILE.FAVCATEGORY = BANNERDATA.FAVCATEGORY
    </select>
    
    <!-- 插入：Account -->
    <insert id="insertAccount" parameterType="Account">
        INSERT INTO ACCOUNT (
            EMAIL, FIRSTNAME, LASTNAME, STATUS, ADDR1, ADDR2, CITY, STATE, ZIP, COUNTRY, PHONE, USERID
        ) VALUES (
            #{email}, #{firstName}, #{lastName}, #{status}, #{address1},
            #{address2,jdbcType=VARCHAR}, #{city}, #{state}, #{zip},
            #{country}, #{phone}, #{username}
        )
    </insert>
    
    <!-- 插入：Profile -->
    <insert id="insertProfile" parameterType="Account">
        INSERT INTO PROFILE (LANGPREF, FAVCATEGORY, MYLISTOPT, BANNEROPT, USERID)
        VALUES (#{languagePreference}, #{favouriteCategoryId}, #{listOption}, #{bannerOption}, #{username})
    </insert>
    
    <!-- 插入：Signon -->
    <insert id="insertSignon" parameterType="Account">
        INSERT INTO SIGNON (PASSWORD, USERNAME)
        VALUES (#{password}, #{username})
    </insert>
    
    <!-- 更新：Account -->
    <update id="updateAccount" parameterType="Account">
        UPDATE ACCOUNT SET
            EMAIL = #{email},
            FIRSTNAME = #{firstName},
            LASTNAME = #{lastName},
            STATUS = #{status},
            ADDR1 = #{address1},
            ADDR2 = #{address2,jdbcType=VARCHAR},
            CITY = #{city},
            STATE = #{state},
            ZIP = #{zip},
            COUNTRY = #{country},
            PHONE = #{phone}
        WHERE USERID = #{username}
    </update>
    
    <!-- 更新：Profile -->
    <update id="updateProfile" parameterType="Account">
        UPDATE PROFILE SET
            LANGPREF = #{languagePreference},
            FAVCATEGORY = #{favouriteCategoryId},
            MYLISTOPT = #{listOption},
            BANNEROPT = #{bannerOption}
        WHERE USERID = #{username}
    </update>
    
    <!-- 更新：Signon -->
    <update id="updateSignon" parameterType="Account">
        UPDATE SIGNON SET PASSWORD = #{password}
        WHERE USERNAME = #{username}
    </update>
    
</mapper>
```

### 5.2 ProductRepository 示例

```java
public interface ProductRepository {
    List<Product> getProductListByCategory(String categoryId);
    Product getProduct(String productId);
    List<Product> searchProductList(String keywords);
}
```

```xml
<mapper namespace="ik.am.jpetstore.domain.repository.product.ProductRepository">

    <select id="getProductListByCategory" parameterType="string" resultType="Product">
        SELECT PRODUCTID, NAME, DESCN, CATEGORY
        FROM PRODUCT
        WHERE CATEGORY = #{categoryId}
    </select>
    
    <select id="getProduct" parameterType="string" resultType="Product">
        SELECT PRODUCTID, NAME, DESCN, CATEGORY
        FROM PRODUCT
        WHERE PRODUCTID = #{productId}
    </select>
    
    <select id="searchProductList" parameterType="string" resultType="Product">
        SELECT PRODUCTID, NAME, DESCN, CATEGORY
        FROM PRODUCT
        WHERE lower(name) LIKE #{keywords} OR lower(descn) LIKE #{keywords}
    </select>

</mapper>
```

## 六、MyBatis 缓存机制

### 6.1 一级缓存（默认开启）

**一级缓存**是 SqlSession 级别的缓存，同一个 SqlSession 内相同查询会缓存。

**本项目启用：**
```xml
<mapper namespace="...">
    <cache />  <!-- 启用二级缓存 -->
</mapper>
```

**日志中看到：**
```
DEBUG: Cache Hit Ratio [ik.am.jpetstore.domain.repository.account.AccountRepository]: 0.0
```

### 6.2 二级缓存（可选）

**二级缓存**是 Mapper 级别的缓存，不同 SqlSession 可以共享。

**配置：**
```xml
<cache
    eviction="LRU"
    flushInterval="60000"
    size="512"
    readOnly="true" />
```

## 七、C++ 开发者对比

### 7.1 C++ 数据库访问方式

**C++ 风格（比如 MySQL Connector/C++）：**
```cpp
#include <mysql_connection.h>
#include <mysql_driver.h>

sql::Driver* driver = sql::mysql::get_driver_instance();
sql::Connection* conn = driver->connect("tcp://127.0.0.1:3306", "user", "password");
sql::Statement* stmt = conn->createStatement();
sql::ResultSet* rs = stmt->executeQuery("SELECT * FROM PRODUCT");

while (rs->next()) {
    // 手动赋值！
    std::string productId = rs->getString("PRODUCTID");
    std::string name = rs->getString("NAME");
}

delete rs;
delete stmt;
delete conn;
```
**问题**：繁琐，手动管理连接，手动映射！

**Java + MyBatis 风格：**
```java
@Service
public class ProductServiceImpl {
    @Inject
    private ProductRepository repo;
    
    public List<Product> getProductList(String categoryId) {
        return repo.getProductListByCategory(categoryId);  // 就这么简单！
    }
}
```
**好处**：自动连接、自动映射、自动管理事务！

### 7.2 类比理解

**MyBatis = SQL 自动映射器**

- **JDBC** = 手动写每一行代码，像手写机器码
- **MyBatis** = 写 SQL，剩下的让框架做，像写高级语言

## 八、常见问题与解决

### 8.1 SQL 注入

**问题**：使用 `${param}` 导致 SQL 注入

**解决**：永远用 `#{param}`！
```xml
<!-- 正确！ -->
<select id="getAccount" resultType="Account">
    SELECT * FROM ACCOUNT WHERE USERID = #{username}
</select>

<!-- 错误！ -->
<select id="getAccount" resultType="Account">
    SELECT * FROM ACCOUNT WHERE USERID = '${username}'
</select>
```

### 8.2 空值处理

**问题**：null 值插入报错

**解决**：指定 jdbcType
```xml
<insert id="insertAccount">
    INSERT INTO ACCOUNT (ADDR2) VALUES (#{address2,jdbcType=VARCHAR})
</insert>
```

### 8.3 结果映射失败

**问题**：属性为 null

**排查步骤：**
1. 检查列名和属性名是否一致
2. 使用别名 AS
3. 检查是否有 @Column 注解

### 8.4 日志调试

**开启 SQL 日志：**
```xml
<!-- logback.xml -->
<logger name="java.sql" level="DEBUG" />
<logger name="jdbc.sql" level="DEBUG" />
```

**日志输出：**
```
DEBUG: jdbc.sql -  SELECT ... FROM PRODUCT WHERE CATEGORY = 'FISH'
```

## 九、最佳实践

### 9.1 SQL 和代码分离

**推荐**：SQL 放在 XML 里
```xml
<!-- AccountRepository.xml -->
<select id="getAccountByUsername" resultType="Account">
    SELECT ... FROM ...
</select>
```
**好处**：SQL 容易维护，DBA 能看懂

### 9.2 使用参数化查询

**推荐**：
```xml
<select id="getAccount" resultType="Account">
    SELECT * FROM ACCOUNT WHERE USERID = #{username}
</select>
```
**原因**：安全，防止 SQL 注入

### 9.3 正确使用事务

**推荐**：
```java
@Service
public class AccountServiceImpl {
    
    @Transactional  // Service 层加事务！
    public void insertAccount(Account account) {
        accountRepository.insertAccount(account);
        accountRepository.insertProfile(account);
        accountRepository.insertSignon(account);
    }
}
```
**不推荐**：
```java
@Transactional  // 不要在 Repository 层加！
public interface AccountRepository {
    void insertAccount(Account account);
}
```

### 9.4 查询优化

**推荐**：只查需要的列
```xml
<!-- 只查需要的 -->
<select id="getProductList" resultType="Product">
    SELECT PRODUCTID, NAME, DESCN
    FROM PRODUCT
</select>
```
**不推荐**：
```xml
<!-- 不要 SELECT * -->
<select id="getProductList" resultType="Product">
    SELECT * FROM PRODUCT
</select>
```

## 十、调试技巧

### 10.1 打印 SQL

**logback 配置：**
```xml
<logger name="java.sql" level="DEBUG" />
<logger name="jdbc.sql" level="DEBUG" />
```

### 10.2 打印参数

**XML 里添加：**
```xml
<select id="getAccountByUsername" ...>
    #{username} <!-- 看这里！ -->
</select>
```

### 10.3 测试 Repository

**单元测试：**
```java
@SpringJUnitWebConfig(locations = { "classpath*:/META-INF/spring/applicationContext.xml" })
public class AccountRepositoryTest {
    
    @Inject
    private AccountRepository repo;
    
    @Test
    public void testGetAccount() {
        Account account = repo.getAccountByUsername("j2ee");
        assertNotNull(account);
        assertEquals("j2ee", account.getUsername());
    }
}
```

---

## 总结

**MyBatis 三大核心：**
1. **Repository 接口** - 定义方法
2. **XML 映射文件** - 写 SQL
3. **自动映射** - 结果自动转为 Java 对象

**记住这句话：**
> SQL 你写，剩下的脏活累活 MyBatis 全干！
