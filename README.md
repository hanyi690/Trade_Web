以下是根据您的实验报告内容为您生成的 `README.md` 文件。该文件结构清晰，涵盖了项目概述、技术栈、核心功能及部署指南，适合直接放置在 GitHub 仓库中。

---

# E-Shop 电子商务系统

这是一个基于 **Spring Boot 3** 开发的完整电子商务网站项目，实现了从商品浏览、购物车管理到订单处理及邮件通知的全流程业务逻辑，并支持 Docker 容器化在线部署 。

## 🌐 在线演示

* 
**部署地址**: [http://8.138.57.61](http://8.138.57.61) 


* 
**代码托管**: [GitHub - hanyi690/eshop](https://github.com/hanyi690/eshop) 



---

## ✨ 核心功能

### 🛒 顾客端

* 
**用户体系**: 支持用户注册、登录及注销功能 。


* 
**购物流程**: 提供产品列表展示、详情查看、购物车管理、模拟支付及订单生成 。


* 
**订单追踪**: 用户可查看个人订单状态及历史记录 。


* 
**邮件通知**: 订单支付完成后，系统通过异步邮件服务发送确认信息（支持 SSL/465端口）。



### 🏪 商家端

* 
**商品管理**: 支持商品目录的增删改查及库存管理 。


* 
**订单处理**: 实时监控订单状态流转，处理发货流程 。


* 
**销售统计**: 提供可视化报表，展示今日销量、历史订单数及销售趋势 。



### 🛠 管理端

* 
**全局监控**: 查看平台总用户数、商铺数量及全站总流水统计 。


* 
**数据统计**: 采用 JPQL 聚合查询（如 `SUM`）优化数据库层面统计性能 。



---

## 🚀 技术栈

| 维度 | 技术选型 |
| --- | --- |
| **开发语言** | Java 21 

 |
| **核心框架** | Spring Boot 3.2.4 (Spring MVC, Data JPA, Security) 

 |
| **数据库** | SQL Server 2019 / H2 (开发环境) 

 |
| **前端技术** | JSP, JSTL, Bootstrap 5 

 |
| **构建部署** | Maven 3.8+, Docker, Linux (Ubuntu 22.04 LTS) 

 |

---

## 🏗 系统架构

系统采用典型的**分层架构**，确保各模块职责清晰 ：

* 
**表现层**: 使用 JSP 作为视图模板，结合 Controller 处理 HTTP 请求 。


* 
**业务逻辑层**: 封装订单计算、权限校验等核心逻辑，并使用 `@Transactional` 保证事务一致性 。


* 
**数据访问层**: 基于 Spring Data JPA 实现，利用 Hibernate 自动管理实体映射 。


* 
**权限安全**: 基于 **Spring Security** 实现 RBAC（基于角色的访问控制），区分 `ADMIN`、`MERCHANT`、`CONSUMER` 三种角色 。



---

## 📦 部署指南

### 1. 项目打包

```bash
mvn clean package -DskipTests

```

这将生成可执行的 WAR 包 `target/eshop-1.0.0.war` 。

### 2. Docker 构建

项目包含一个用于在线环境的 Dockerfile ：

```dockerfile
FROM eclipse-temurin:21-jdk-alpine
WORKDIR /app
COPY target/eshop-1.0.0.war app.war
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.war"]

```

### 3. 运行容器

启动时通过环境变量注入数据库与邮件配置 ：

```bash
docker run -d -p 80:8080 \
  -e DB_URL="jdbc:sqlserver://<db_host>:1433;databaseName=eshop" \
  -e DB_USER="sa" \
  -e DB_PASS="StrongPass123!" \
  -e MAIL_PASS="your_mail_token" \
  --name eshop-web \
  my-eshop-image

```

---

## 👨‍💻 开发者

* 
**姓名**: 甘顺豪 


* 
**班级**: 23级计科2班 


* 
**学校**: 华南理工大学 



