# Spring MVC 详解与实战

## 一、什么是 Spring MVC？

### 1.1 核心概念

**Spring MVC** 是基于 Spring 框架的 Web 框架，实现了 **MVC（Model-View-Controller）** 设计模式。

**MVC 架构图示：**
```
用户请求
   ↓
[Controller] 控制器 - 处理请求，调用业务逻辑
   ↓
[Model] 模型 - 存放数据
   ↓
[View] 视图 - 渲染界面
   ↓
用户响应
```

### 1.2 Spring MVC 与其他技术对比

| 技术 | 说明 | 特点 |
|------|------|------|
| **Spring MVC** | 基于 Spring 的 MVC 框架 | 强大、灵活、生态丰富 |
| **Servlet** | 原生 Java Web 技术 | 基础、但需要写很多代码 |
| **Struts 2** | 老的 MVC 框架 | 配置复杂、已过时 |
| **Spring Boot Web** | 自动化配置的 Spring MVC | 现代、简化配置 |

## 二、Spring MVC 核心组件

### 2.1 DispatcherServlet（前端控制器）

**DispatcherServlet** 是 Spring MVC 的核心！所有请求都先经过它。

**工作流程：**
```
1. 用户请求到达 DispatcherServlet
2. DispatcherServlet 找对应的 Controller
3. Controller 处理请求
4. Controller 返回 Model 和 View
5. DispatcherServlet 找 ViewResolver
6. ViewResolver 找 JSP 文件
7. JSP 渲染数据
8. 返回响应给用户
```

**项目中的配置：**
```xml
<!-- web.xml -->
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

### 2.2 Controller（控制器）

#### 2.2.1 什么是 Controller？

**Controller** 负责接收用户请求、调用业务逻辑、返回响应。

**本项目中的示例：**
```java
@Controller
@RequestMapping("catalog")
public class CatalogController {
    
    @Inject
    protected CatalogService catalogService;
    
    // 方法 1：访问分类页面
    @RequestMapping("viewCategory")
    public String viewCategory(@RequestParam("categoryId") String categoryId, Model model) {
        List<Product> productList = catalogService.getProductListByCategory(categoryId);
        Category category = catalogService.getCategory(categoryId);
        model.addAttribute("productList", productList);
        model.addAttribute("category", category);
        return "catalog/Category";  // 返回视图名称
    }
    
    // 方法 2：搜索商品
    @RequestMapping(params = "keyword")
    public String searchProducts(@Validated ProductSearchForm form,
            BindingResult result, Model model) {
        // ...
    }
}
```

#### 2.2.2 常用注解详解

**@Controller** - 标记为控制器
```java
@Controller  // Spring 会扫描到它，注册为 Bean
public class CatalogController { ... }
```

**@RequestMapping** - URL 映射
```java
@RequestMapping("catalog")  // 类级别：/catalog 开头
public class CatalogController {
    
    @RequestMapping("viewCategory")  // 方法级别：/catalog/viewCategory
    public String viewCategory() { ... }
    
    // 可简写为 @GetMapping、@PostMapping 等
    @GetMapping("viewProduct")
    public String viewProduct() { ... }
}
```

**@RequestParam** - 获取请求参数
```java
@RequestMapping("viewCategory")
public String viewCategory(
    @RequestParam("categoryId") String categoryId,  // 获取 URL 参数
    Model model
) {
    // ...
}
```

**@ModelAttribute** - 获取表单对象
```java
@RequestMapping("addItem")
public String addItem(@ModelAttribute("cartItem") CartItem cartItem) {
    cart.add(cartItem);
    return "cart/Cart";
}
```

#### 2.2.3 方法返回值

**返回 String（视图名称）：**
```java
@RequestMapping("viewCategory")
public String viewCategory(Model model) {
    // 添加数据到 Model
    model.addAttribute("productList", products);
    return "catalog/Category";  // 返回视图名称
}
```

**返回 void：**
```java
@RequestMapping("download")
public void download(HttpServletResponse response) {
    // 直接写入响应
}
```

### 2.3 Model（模型）

**Model** 是存放数据的容器，Controller 把数据放到 Model，然后传给 View。

**用法示例：**
```java
@RequestMapping("viewCategory")
public String viewCategory(@RequestParam("categoryId") String categoryId, Model model) {
    
    // 1. 从 Service 获取数据
    List<Product> productList = catalogService.getProductListByCategory(categoryId);
    Category category = catalogService.getCategory(categoryId);
    
    // 2. 把数据放到 Model
    model.addAttribute("productList", productList);  // 键值对
    model.addAttribute("category", category);
    
    // 3. 返回视图名
    return "catalog/Category";
}
```

### 2.4 View（视图）

**View** 负责渲染页面，本项目使用 **JSP**。

**ViewResolver（视图解析器）配置：**
```xml
<!-- spring-mvc.xml -->
<bean id="viewResolver"
    class="org.springframework.web.servlet.view.InternalResourceViewResolver">
    <property name="prefix" value="/WEB-INF/views/" />  <!-- 前缀 -->
    <property name="suffix" value=".jsp" />             <!-- 后缀 -->
    <property name="order" value="2" />
</bean>
```

**完整流程：**
```
Controller 返回 "catalog/Category"
   ↓
ViewResolver 拼接
   ↓
/WEB-INF/views/catalog/Category.jsp
   ↓
找 JSP 文件渲染
```

### 2.5 View 层（JSP）

**示例 JSP：**
```jsp
<%@ include file="../common/IncludeTop.jsp"%>
<div id="Catalog">
    <h2>${category.name}</h2>
    <table>
        <c:forEach items="${productList}" var="product">
            <tr>
                <td>
                    <a href="catalog/viewProduct?productId=${product.productId}">
                        <c:out value="${product.name}" />
                    </a>
                </td>
            </tr>
        </c:forEach>
    </table>
</div>
<%@ include file="../common/IncludeBottom.jsp"%>
```

## 三、Spring MVC 配置详解

### 3.1 完整 spring-mvc.xml 解析

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mvc="http://www.springframework.org/schema/mvc"
    xmlns:context="http://www.springframework.org/schema/context"
    xsi:schemaLocation="...">
    
    <!-- 1. 启用注解驱动 -->
    <mvc:annotation-driven>
        <mvc:argument-resolvers>
            <bean class="org.springframework.data.web.PageableHandlerMethodArgumentResolver" />
        </mvc:argument-resolvers>
    </mvc:annotation-driven>
    
    <!-- 2. 扫描 Controller 包 -->
    <context:component-scan base-package="ik.am.jpetstore.app" />
    
    <!-- 3. 静态资源处理 -->
    <mvc:resources mapping="/resources/**"
        location="/resources/,classpath:META-INF/resources/"
        cache-period="#{60 * 60}" />
    
    <!-- 4. 默认 Servlet 处理器（处理静态文件） -->
    <mvc:default-servlet-handler />
    
    <!-- 5. 视图解析器 -->
    <bean id="viewResolver"
        class="org.springframework.web.servlet.view.InternalResourceViewResolver">
        <property name="prefix" value="/WEB-INF/views/" />
        <property name="suffix" value=".jsp" />
    </bean>
    
    <!-- 6. 异常处理 -->
    <bean class="org.springframework.web.servlet.handler.SimpleMappingExceptionResolver">
        <property name="defaultErrorView" value="systemError" />
        <property name="defaultStatusCode" value="500" />
    </bean>
    
    <!-- 7. Session 作用域的 Bean（购物车） -->
    <bean id="cart" class="ik.am.jpetstore.domain.model.Cart"
        scope="session">
        <aop:scoped-proxy />
    </bean>
    
</beans>
```

### 3.2 静态资源配置

**为什么要配置？**
- CSS、JS、图片等静态文件不需要经过 Controller
- 直接让容器返回就行

**配置方式：**
```xml
<mvc:resources mapping="/resources/**"
    location="/resources/,classpath:META-INF/resources/"
    cache-period="#{60 * 60}" />

<mvc:default-servlet-handler />
```

**项目中的访问：**
```jsp
<link rel="stylesheet" type="text/css" href="css/jpetstore.css">
<img src="images/banner_fish.gif">
```

## 四、实战：项目中的 Controller 分析

### 4.1 CatalogController（商品目录）

```java
@Controller
@RequestMapping("catalog")
public class CatalogController {
    @Inject
    protected CatalogService catalogService;
    
    // 主页
    @RequestMapping
    public String main() {
        return "catalog/Main";
    }
    
    // 查看分类
    @RequestMapping("viewCategory")
    public String viewCategory(@RequestParam("categoryId") String categoryId, Model model) {
        List<Product> productList = catalogService.getProductListByCategory(categoryId);
        Category category = catalogService.getCategory(categoryId);
        model.addAttribute("productList", productList);
        model.addAttribute("category", category);
        return "catalog/Category";
    }
    
    // 查看商品
    @RequestMapping("viewProduct")
    public String viewProduct(@RequestParam("productId") String productId, Model model) {
        List<Item> itemList = catalogService.getItemListByProduct(productId);
        Product product = catalogService.getProduct(productId);
        model.addAttribute("itemList", itemList);
        model.addAttribute("product", product);
        return "catalog/Product";
    }
    
    // 搜索
    @RequestMapping(params = "keyword")
    public String searchProducts(@Validated ProductSearchForm form,
            BindingResult result, Model model) {
        if (result.hasErrors()) {
            return "common/Error";
        }
        String keyword = form.getKeyword().toLowerCase();
        List<Product> productList = catalogService.searchProductList(keyword);
        model.addAttribute("productList", productList);
        return "catalog/SearchProducts";
    }
}
```

### 4.2 CartController（购物车）

```java
@Controller
@RequestMapping("cart")
public class CartController {
    @Inject
    protected Cart cart;  // Session 作用域的 Bean
    
    @Inject
    protected CatalogService catalogService;
    
    @RequestMapping("addItem")
    public String addItem(@RequestParam("itemId") String itemId) {
        if (!cart.containsItemId(itemId)) {
            Item item = catalogService.getItem(itemId);
            cart.add(item);
        }
        return "cart/Cart";
    }
    
    @RequestMapping("viewCart")
    public String viewCart() {
        return "cart/Cart";
    }
    
    @RequestMapping("removeItem")
    public String removeItem(@RequestParam("itemId") String itemId) {
        cart.remove(itemId);
        return "cart/Cart";
    }
    
    @RequestMapping("updateCart")
    public String updateCart(@Validated CartForm cartForm, Model model) {
        // ...
        return "cart/Cart";
    }
}
```

## 五、表单处理与验证

### 5.1 表单对象（Form Object）

```java
public class AccountForm {
    private String username;
    private String password;
    private String email;
    private String firstName;
    private String lastName;
    
    // Getters and Setters
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    // ...
}
```

### 5.2 表单绑定

```java
@RequestMapping("newAccount")
public String newAccountForm(@ModelAttribute("accountForm") AccountForm form) {
    return "account/NewAccountForm";
}

@RequestMapping(value = "newAccount", method = RequestMethod.POST)
public String newAccount(@Validated AccountForm form,
        BindingResult result, Model model) {
    
    // 表单验证
    if (result.hasErrors()) {
        return "account/NewAccountForm";
    }
    
    // 转换 Form 到 Domain Object
    Account account = new Account();
    BeanUtils.copyProperties(form, account);
    
    // 保存账户
    accountService.insertAccount(account);
    
    return "redirect:/account/signonForm";
}
```

### 5.3 表单验证

**自定义验证器：**
```java
@Component
public class PasswordEqualsValidator implements Validator {
    
    @Override
    public boolean supports(Class<?> clazz) {
        return AccountForm.class.isAssignableFrom(clazz);
    }
    
    @Override
    public void validate(Object target, Errors errors) {
        AccountForm form = (AccountForm) target;
        
        if (form.isRepeatedPassword()) {
            if (!form.getPassword().equals(form.getRepeatedPassword())) {
                errors.rejectValue("password", "MISMATCH_PASSWORD");
            }
        }
    }
}
```

## 六、C++ 开发者对比

### 6.1 HTTP 处理对比

**C++ 风格（比如 CGI）：**
```cpp
// C++ CGI 伪代码
#include <iostream>
#include <string>

int main() {
    // 手动解析表单
    std::string data = read_cgi_input();
    std::string username = parse_param(data, "username");
    
    // 手动输出 HTML
    std::cout << "Content-type: text/html\n\n";
    std::cout << "<html>...";
    return 0;
}
```
**问题**：太麻烦，需要手动处理所有 HTTP 细节

**Java + Spring MVC 风格：**
```java
@Controller
@RequestMapping("account")
public class AccountController {
    
    @RequestMapping("newAccount")
    public String newAccount(@ModelAttribute AccountForm form) {
        // Spring 自动帮你处理所有 HTTP 细节
        // 你只需要关心业务逻辑！
        accountService.insertAccount(form);
        return "redirect:/account/signonForm";
    }
}
```
**好处**：框架处理 HTTP，你只写业务！

### 6.2 理解流程

**类比：餐厅点菜**
```
顾客 = 用户
服务员 = DispatcherServlet
厨师 = Controller
菜单 = Model
菜 = View
```

**流程对应：**
1. 顾客（用户）向服务员（DispatcherServlet）点菜
2. 服务员找到负责这道菜的厨师（Controller）
3. 厨师准备菜（业务逻辑）
4. 菜做好放在盘子里（Model）
5. 服务员用盘子端菜给顾客（View）

## 七、常见问题与解决

### 7.1 404 Not Found

**问题**：访问 URL 返回 404

**排查步骤：**
1. 检查 @RequestMapping 路径是否正确
2. 检查 ViewResolver 的 prefix 和 suffix
3. 检查 JSP 文件是否存在

### 7.2 中文乱码

**问题**：提交表单中文乱码

**解决**：配置 CharacterEncodingFilter
```xml
<filter>
    <filter-name>CharacterEncodingFilter</filter-name>
    <filter-class>org.springframework.web.filter.CharacterEncodingFilter</filter-class>
    <init-param>
        <param-name>encoding</param-name>
        <param-value>UTF-8</param-value>
    </init-param>
    <init-param>
        <param-name>forceEncoding</param-name>
        <param-value>true</param-value>
    </init-param>
</filter>
<filter-mapping>
    <filter-name>CharacterEncodingFilter</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>
```

### 7.3 静态资源 404

**问题**：CSS/JS/图片找不到

**解决**：配置 <mvc:resources> 和 <mvc:default-servlet-handler>

## 八、最佳实践

### 8.1 分层 Controller

- **CatalogController** - 商品目录
- **AccountController** - 账户
- **CartController** - 购物车
- **OrderController** - 订单

### 8.2 RESTful URL

**推荐：**
```
/catalog/viewCategory?categoryId=FISH
/catalog/viewProduct?productId=FI-SW-01
```
**不推荐：**
```
/viewCategory.do
/viewProduct.action
```

### 8.3 使用 ModelAttribute 传递对象

**推荐：**
```java
@RequestMapping("editAccount")
public String editAccountForm(@ModelAttribute("accountForm") AccountForm form) {
    // ...
}
```
**原因**：表单回显更方便

### 8.4 业务逻辑放在 Service 层，不要在 Controller

**推荐：**
```java
@RequestMapping("newAccount")
public String newAccount(@ModelAttribute AccountForm form) {
    accountService.insertAccount(form);  // 调用 Service
    return "redirect:/account/signonForm";
}
```
**不推荐：**
```java
@RequestMapping("newAccount")
public String newAccount(@ModelAttribute AccountForm form) {
    // 不要在这里写业务逻辑！
    accountRepository.insert(form);  // 错误：直接操作 Repository
    return "redirect:/account/signonForm";
}
```

## 九、调试技巧

### 9.1 打印请求参数

```java
@RequestMapping("viewCategory")
public String viewCategory(@RequestParam("categoryId") String categoryId) {
    System.out.println("categoryId = " + categoryId);  // 打印日志
    // ...
}
```

### 9.2 打印 Model 数据

```java
@RequestMapping("viewCategory")
public String viewCategory(Model model) {
    // 遍历 Model 查看所有数据
    for (String key : model.asMap().keySet()) {
        System.out.println("Model: " + key + " = " + model.asMap().get(key));
    }
    // ...
}
```

---

## 总结

**Spring MVC 三大核心：**
1. **Controller** - 处理请求
2. **Model** - 存放数据
3. **View** - 渲染页面

**记住一句话：**
> Controller 负责接客，Model 负责装货，View 负责展示！
