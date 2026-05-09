# Maven 项目管理详解

## 一、什么是 Maven？

### 1.1 核心概念

**Maven** 是一个强大的**项目管理工具**，专门用于：
- **依赖管理** - 自动下载 jar 包
- **构建管理** - 编译、测试、打包
- **项目结构管理** - 统一目录结构

### 1.2 为什么要用 Maven？

**没有 Maven 的痛苦（C++ 或旧 Java）：**
```
项目文件夹/
├── lib/
│   ├── spring-5.3.30.jar        # 手动下载
│   ├── mybatis-3.5.9.jar        # 手动下载
│   ├── spring-security-5.7.12.jar  # 手动下载
│   └── 几十个 jar...            # 容易版本冲突
├── src/
│   └── ...
└── build.sh                      # 手动写构建脚本
```
**问题**：
- 手动下载 jar 太麻烦
- 版本冲突找不到原因
- 构建脚本复杂难维护

**有 Maven 的爽：**
```xml
<!-- pom.xml -->
<dependencies>
    <!-- Spring 框架 -->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-context</artifactId>
        <version>5.3.30</version>
    </dependency>
    <!-- MyBatis -->
    <dependency>
        <groupId>org.mybatis</groupId>
        <artifactId>mybatis</artifactId>
        <version>3.5.9</version>
    </dependency>
    <!-- 就这么简单！Maven 自动下载所有依赖！ -->
</dependencies>
```
**好处**：
- 自动下载依赖
- 自动管理版本
- 统一构建流程

## 二、本项目 pom.xml 详解

### 2.1 完整 pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
    http://maven.apache.org/xsd/maven-4.0.0.xsd">
    
    <!-- 1. 项目基本信息 -->
    <modelVersion>4.0.0</modelVersion>
    <groupId>ik.am</groupId>
    <artifactId>spring-jpetstore</artifactId>
    <version>1.0.0</version>
    <packaging>war</packaging>
    <name>Spring JPetStore</name>
    
    <!-- 2. 依赖版本管理 -->
    <properties>
        <java.version>17</java.version>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <spring.version>5.3.30</spring.version>
        <spring.security.version>5.7.12</spring.security.version>
        <spring.data.version>2.7.18</spring.data.version>
        <mybatis.version>3.5.9</mybatis.version>
        <mybatis.spring.version>2.0.7</mybatis.spring.version>
        <h2.version>1.4.200</h2.version>
    </properties>
    
    <!-- 3. 依赖声明 -->
    <dependencies>
        <!-- Spring 框架 -->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
            <version>${spring.version}</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-webmvc</artifactId>
            <version>${spring.version}</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-jdbc</artifactId>
            <version>${spring.version}</version>
        </dependency>
        
        <!-- Spring Security -->
        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-web</artifactId>
            <version>${spring.security.version}</version>
        </dependency>
        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-config</artifactId>
            <version>${spring.security.version}</version>
        </dependency>
        
        <!-- MyBatis -->
        <dependency>
            <groupId>org.mybatis</groupId>
            <artifactId>mybatis</artifactId>
            <version>${mybatis.version}</version>
        </dependency>
        <dependency>
            <groupId>org.mybatis</groupId>
            <artifactId>mybatis-spring</artifactId>
            <version>${mybatis.spring.version}</version>
        </dependency>
        
        <!-- H2 数据库 -->
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <version>${h2.version}</version>
        </dependency>
        
        <!-- Servlet API -->
        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>javax.servlet-api</artifactId>
            <version>3.1.0</version>
            <scope>provided</scope>
        </dependency>
        
        <!-- JSP -->
        <dependency>
            <groupId>javax.servlet.jsp</groupId>
            <artifactId>javax.servlet.jsp-api</artifactId>
            <version>2.3.1</version>
            <scope>provided</scope>
        </dependency>
        
        <!-- JSTL -->
        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>jstl</artifactId>
            <version>1.2</version>
        </dependency>
        
        <!-- 数据库连接池 -->
        <dependency>
            <groupId>commons-dbcp</groupId>
            <artifactId>commons-dbcp</artifactId>
            <version>1.4</version>
        </dependency>
        
        <!-- 测试 -->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-test</artifactId>
            <version>${spring.version}</version>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter-api</artifactId>
            <version>5.9.1</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
    
    <!-- 4. 构建配置 -->
    <build>
        <finalName>spring-jpetstore</finalName>
        
        <plugins>
            <!-- Java 编译插件 -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.8.1</version>
                <configuration>
                    <source>${java.version}</source>
                    <target>${java.version}</target>
                </configuration>
            </plugin>
            
            <!-- Tomcat 7 插件（用于运行项目） -->
            <plugin>
                <groupId>org.apache.tomcat.maven</groupId>
                <artifactId>tomcat7-maven-plugin</artifactId>
                <version>2.2</version>
                <configuration>
                    <port>8088</port>
                    <path>/spring-jpetstore</path>
                    <uriEncoding>UTF-8</uriEncoding>
                    <additionalJvmArgs>
                        --add-opens=java.base/java.lang=ALL-UNNAMED
                        --add-opens=java.base/java.lang.reflect=ALL-UNNAMED
                        --add-opens=java.base/java.io=ALL-UNNAMED
                        --add-opens=java.base/java.util=ALL-UNNAMED
                    </additionalJvmArgs>
                </configuration>
            </plugin>
        </plugins>
    </build>
    
    <!-- 5. 仓库配置（阿里云镜像加速） -->
    <repositories>
        <repository>
            <id>aliyun</id>
            <name>Aliyun Maven</name>
            <url>https://maven.aliyun.com/repository/public</url>
            <releases>
                <enabled>true</enabled>
            </releases>
            <snapshots>
                <enabled>false</enabled>
            </snapshots>
        </repository>
    </repositories>
    
    <pluginRepositories>
        <pluginRepository>
            <id>aliyun</id>
            <name>Aliyun Maven</name>
            <url>https://maven.aliyun.com/repository/public</url>
            <releases>
                <enabled>true</enabled>
            </releases>
            <snapshots>
                <enabled>false</enabled>
            </snapshots>
        </pluginRepository>
    </pluginRepositories>
    
</project>
```

### 2.2 项目基本信息

```xml
<!-- POM 模型版本 -->
<modelVersion>4.0.0</modelVersion>

<!-- 项目坐标 -->
<groupId>ik.am</groupId>              <!-- 组织名（类似 C++ 命名空间） -->
<artifactId>spring-jpetstore</artifactId>  <!-- 项目名 -->
<version>1.0.0</version>             <!-- 版本号 -->
<packaging>war</packaging>           <!-- 打包方式：war（Web） -->
```

**Maven 坐标（Coordinates）：**
```
groupId:artifactId:version:packaging
```
示例：
```
ik.am:spring-jpetstore:1.0.0:war
```

### 2.3 依赖版本管理（properties）

```xml
<properties>
    <java.version>17</java.version>
    <spring.version>5.3.30</spring.version>
    <spring.security.version>5.7.12</spring.security.version>
</properties>
```
**好处**：版本号统一管理，方便升级

### 2.4 依赖声明（dependencies）

```xml
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-context</artifactId>
    <version>${spring.version}</version>
</dependency>
```

**依赖范围（scope）：**
| scope | 说明 | 示例 |
|-------|------|------|
| `compile` | 编译时需要，打包时包含（默认） | Spring 核心 |
| `provided` | 编译时需要，打包时不包含 | Servlet API |
| `test` | 只在测试时需要 | JUnit |
| `runtime` | 运行时需要，编译时不需要 | H2 数据库 |

**示例：**
```xml
<!-- 测试依赖，只在测试时使用 -->
<dependency>
    <groupId>org.junit.jupiter</groupId>
    <artifactId>junit-jupiter-api</artifactId>
    <version>5.9.1</version>
    <scope>test</scope>
</dependency>

<!-- Servlet API，Tomcat 提供，不需要打包 -->
<dependency>
    <groupId>javax.servlet</groupId>
    <artifactId>javax.servlet-api</artifactId>
    <version>3.1.0</version>
    <scope>provided</scope>
</dependency>
```

### 2.5 构建配置（build）

```xml
<build>
    <finalName>spring-jpetstore</finalName>  <!-- 打包文件名 -->
    
    <plugins>
        <!-- 编译插件 -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <version>3.8.1</version>
            <configuration>
                <source>17</source>  <!-- 源代码版本 -->
                <target>17</target>  <!-- 目标字节码版本 -->
            </configuration>
        </plugin>
        
        <!-- Tomcat 插件 -->
        <plugin>
            <groupId>org.apache.tomcat.maven</groupId>
            <artifactId>tomcat7-maven-plugin</artifactId>
            <version>2.2</version>
            <configuration>
                <port>8088</port>
                <path>/spring-jpetstore</path>
            </configuration>
        </plugin>
    </plugins>
</build>
```

## 三、Maven 常用命令

### 3.1 核心命令

| 命令 | 说明 |
|------|------|
| `mvn clean` | 清理输出目录 |
| `mvn compile` | 编译源代码 |
| `mvn test` | 运行测试 |
| `mvn package` | 打包（war/jar） |
| `mvn install` | 安装到本地仓库 |
| `mvn tomcat7:run` | 启动 Tomcat（本项目使用） |

### 3.2 组合命令

```bash
# 清理并编译
mvn clean compile

# 清理并打包
mvn clean package

# 清理、编译、测试、打包
mvn clean package

# 本项目常用：启动 Tomcat
mvn tomcat7:run
```

## 四、Maven 生命周期

### 4.1 三大生命周期

| 生命周期 | 说明 |
|----------|------|
| `clean` | 清理 |
| `default` | 构建、测试、打包 |
| `site` | 生成站点文档 |

### 4.2 Default 生命周期阶段

```
validate → initialize → generate-sources → process-sources
→ generate-resources → process-resources → compile → ...
→ test → prepare-package → package → ...
→ install → deploy
```

**执行一个阶段时，前面的阶段都会执行！**
```bash
mvn package
# 实际上执行了：
# validate → ... → compile → ... → test → ... → package
```

## 五、Maven 项目结构

### 5.1 标准目录结构

```
spring-jpetstore/
├── pom.xml                          # Maven 配置文件
│
├── src/
│   ├── main/                        # 主代码
│   │   ├── java/                    # Java 源代码
│   │   │   └── ik/am/jpetstore/
│   │   │       ├── app/             # Controller
│   │   │       └── domain/          # Service, Repository
│   │   ├── resources/               # 资源文件
│   │   │   ├── META-INF/spring/     # Spring 配置
│   │   │   ├── mybatis-config.xml
│   │   │   ├── database/            # 数据库脚本
│   │   │   └── logback.xml
│   │   └── webapp/                  # Web 应用
│   │       ├── WEB-INF/
│   │       │   ├── views/           # JSP
│   │       │   └── web.xml
│   │       ├── css/
│   │       └── images/
│   └── test/                        # 测试代码
│       └── java/
│           └── ik/am/jpetstore/
│
└── target/                          # Maven 输出目录（自动生成）
    ├── classes/                     # 编译后的 class
    ├── test-classes/                # 测试 class
    └── spring-jpetstore.war         # 打包后的 war
```

### 5.2 目录说明

| 目录 | 说明 |
|------|------|
| `src/main/java` | 主代码 |
| `src/main/resources` | 主资源文件（配置、XML） |
| `src/main/webapp` | Web 应用（JSP、CSS、JS） |
| `src/test/java` | 测试代码 |
| `target` | 输出目录（不要提交到 Git） |

## 六、本项目修复的 Maven 问题

### 6.1 问题 1：Maven 依赖下载慢

**原始问题**：从 Maven 中央仓库下载很慢

**解决**：配置阿里云镜像
```xml
<repositories>
    <repository>
        <id>aliyun</id>
        <name>Aliyun Maven</name>
        <url>https://maven.aliyun.com/repository/public</url>
    </repository>
</repositories>
```

### 6.2 问题 2：Java 17 模块系统问题

**原始问题**：
```
java.lang.reflect.InaccessibleObjectException:
Unable to make field private final java.lang.Object[] java.util.ArrayList.elementData accessible:
module java.base does not "opens java.util" to unnamed module
```

**解决**：Tomcat 插件配置 JVM 参数
```xml
<plugin>
    <groupId>org.apache.tomcat.maven</groupId>
    <artifactId>tomcat7-maven-plugin</artifactId>
    <configuration>
        <additionalJvmArgs>
            --add-opens=java.base/java.lang=ALL-UNNAMED
            --add-opens=java.base/java.lang.reflect=ALL-UNNAMED
            --add-opens=java.base/java.io=ALL-UNNAMED
            --add-opens=java.base/java.util=ALL-UNNAMED
        </additionalJvmArgs>
    </configuration>
</plugin>
```

### 6.3 问题 3：依赖冲突

**解决**：统一版本，用 properties 管理
```xml
<properties>
    <spring.version>5.3.30</spring.version>
    <spring.security.version>5.7.12</spring.security.version>
</properties>

<dependencies>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-context</artifactId>
        <version>${spring.version}</version>
    </dependency>
</dependencies>
```

## 七、C++ 开发者对比

### 7.1 构建工具对比

| C++ 工具 | Maven |
|----------|-------|
| Make/CMake | Maven |
| 手动下载库 | 自动下载依赖 |
| 手动管理版本 | 自动管理版本 |
| 复杂的 Makefile | 简单的 pom.xml |

**C++ CMake 对比：**
```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.10)
project(myproject)
find_package(Boost REQUIRED)  # 手动找库
add_executable(main main.cpp)
target_link_libraries(main ${Boost_LIBRARIES})
```

**Maven 对比：**
```xml
<!-- pom.xml -->
<project>
    <dependencies>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
            <version>5.3.30</version>
        </dependency>
    </dependencies>
</project>
```

### 7.2 类比理解

**Maven = 智能的包管理器 + 构建系统**
- **CMake** = 构建系统
- **Conan/vcpkg** = C++ 包管理器
- **Maven** = 两者合二为一！

## 八、Maven 仓库

### 8.1 仓库类型

| 仓库 | 说明 |
|------|------|
| **本地仓库** | 你电脑上的 `~/.m2/repository` |
| **远程仓库** | 比如 Maven Central、阿里云 |

### 8.2 仓库查找顺序

```
1. 本地仓库（~/.m2/repository）
2. 没有 → 远程仓库（阿里云）
3. 下载 → 保存到本地仓库
```

### 8.3 本地仓库位置

```
Windows: C:\Users\你的用户名\.m2\repository
Mac/Linux: ~/.m2/repository
```

## 九、最佳实践

### 9.1 使用 properties 管理版本

**推荐**：
```xml
<properties>
    <spring.version>5.3.30</spring.version>
</properties>

<dependency>
    <artifactId>spring-context</artifactId>
    <version>${spring.version}</version>
</dependency>
```

### 9.2 显式声明 scope

**推荐**：
```xml
<dependency>
    <groupId>javax.servlet</groupId>
    <artifactId>javax.servlet-api</artifactId>
    <version>3.1.0</version>
    <scope>provided</scope>  <!-- 显式声明 -->
</dependency>
```

### 9.3 使用国内镜像

**推荐**：
```xml
<repository>
    <id>aliyun</id>
    <url>https://maven.aliyun.com/repository/public</url>
</repository>
```

### 9.4 不要提交 target 目录

**.gitignore：**
```
target/
*.iml
.idea/
```

## 十、调试技巧

### 10.1 查看依赖树

```bash
mvn dependency:tree
```
**输出：**
```
[INFO] ik.am:spring-jpetstore:war:1.0.0
[INFO] +- org.springframework:spring-context:jar:5.3.30:compile
[INFO] |  +- org.springframework:spring-aop:jar:5.3.30:compile
[INFO] |  +- org.springframework:spring-beans:jar:5.3.30:compile
[INFO] |  \- org.springframework:spring-core:jar:5.3.30:compile
```

### 10.2 查看依赖冲突

```bash
mvn dependency:tree -Dverbose
```

### 10.3 跳过测试

```bash
mvn package -DskipTests
```

---

## 总结

**Maven 三大功能：**
1. **依赖管理** - 自动下载 jar 包
2. **构建管理** - 编译、测试、打包
3. **项目结构** - 统一的目录结构

**记住一句话：**
> 依赖、构建、结构，Maven 全部搞定！
