# Littlegrid Backend Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 基于 eladmin 脚手架搭建 Littlegrid 后端服务，支持用户认证、数据同步和工具服务。

**Architecture:** Spring Boot 3.2 单体架构，多模块设计。保留 eladmin 核心（用户、权限、菜单），新增 sync、tools、auth 业务模块。

**Tech Stack:** Java 17, Spring Boot 3.2.x, MySQL 8.0, MyBatis-Plus 3.5.x, Redis 7.x, Maven 3.9.x

---

## Phase 1: 项目初始化

### Task 1: 克隆 eladmin 项目

**Files:**
- Create: `backend/` 目录结构

- [ ] **Step 1: 克隆 eladmin 到 backend 目录**

```bash
cd /home/nano/littlegrid
git clone https://github.com/elunez/eladmin.git backend
cd backend
```

- [ ] **Step 2: 移除 eladmin 的 .git 目录，纳入主项目管理**

```bash
rm -rf backend/.git
```

- [ ] **Step 3: 验证项目结构**

```bash
ls -la backend/
```

Expected: 看到 `eladmin-common/`, `eladmin-system/`, `eladmin-admin/` 等目录

---

### Task 2: 升级 Spring Boot 版本

**Files:**
- Modify: `backend/pom.xml`
- Modify: `backend/eladmin-*/pom.xml`

- [ ] **Step 1: 检查当前 Spring Boot 版本**

```bash
grep -r "spring-boot-starter-parent" backend/pom.xml
```

- [ ] **Step 2: 修改父 pom.xml 中的版本号**

在 `backend/pom.xml` 中修改：

```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.2.5</version>
</parent>
```

同时更新其他依赖版本：

```xml
<properties>
    <java.version>17</java.version>
    <mybatis-plus.version>3.5.5</mybatis-plus.version>
    <hutool.version>5.8.26</hutool.version>
    <jwt.version>0.12.5</jwt.version>
</properties>
```

- [ ] **Step 3: 修复 Spring Boot 3.x 兼容性问题**

Spring Boot 3.x 需要：
- `javax.*` 改为 `jakarta.*`
- 检查所有 import 语句

```bash
# 查找需要修改的 javax import
grep -r "import javax\." backend/ --include="*.java" | head -20
```

- [ ] **Step 4: 尝试编译项目**

```bash
cd backend
mvn clean compile -DskipTests
```

Expected: 编译成功或有明确的错误提示

- [ ] **Step 5: Commit**

```bash
git add backend/
git commit -m "feat(backend): initialize eladmin project with Spring Boot 3.2 upgrade"
```

---

### Task 3: 添加新模块结构

**Files:**
- Create: `backend/eladmin-sync/pom.xml`
- Create: `backend/eladmin-tools/pom.xml`
- Create: `backend/eladmin-auth/pom.xml`
- Modify: `backend/pom.xml`

- [ ] **Step 1: 在父 pom.xml 中添加新模块**

```xml
<modules>
    <module>eladmin-common</module>
    <module>eladmin-system</module>
    <module>eladmin-tools</module>
    <module>eladmin-sync</module>
    <module>eladmin-auth</module>
    <module>eladmin-admin</module>
</modules>
```

- [ ] **Step 2: 创建 eladmin-sync 模块 pom.xml**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <groupId>me.zhengjie</groupId>
        <artifactId>eladmin</artifactId>
        <version>3.1.0</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>eladmin-sync</artifactId>
    <name>同步模块</name>

    <dependencies>
        <dependency>
            <groupId>me.zhengjie</groupId>
            <artifactId>eladmin-common</artifactId>
            <version>${project.version}</version>
        </dependency>
    </dependencies>
</project>
```

- [ ] **Step 3: 创建 eladmin-tools 模块 pom.xml**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <groupId>me.zhengjie</groupId>
        <artifactId>eladmin</artifactId>
        <version>3.1.0</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>eladmin-tools</artifactId>
    <name>工具服务模块</name>

    <dependencies>
        <dependency>
            <groupId>me.zhengjie</groupId>
            <artifactId>eladmin-common</artifactId>
            <version>${project.version}</version>
        </dependency>
    </dependencies>
</project>
```

- [ ] **Step 4: 创建 eladmin-auth 模块 pom.xml**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <groupId>me.zhengjie</groupId>
        <artifactId>eladmin</artifactId>
        <version>3.1.0</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>eladmin-auth</artifactId>
    <name>认证模块</name>

    <dependencies>
        <dependency>
            <groupId>me.zhengjie</groupId>
            <artifactId>eladmin-common</artifactId>
            <version>${project.version}</version>
        </dependency>
        <dependency>
            <groupId>me.zhengjie</groupId>
            <artifactId>eladmin-system</artifactId>
            <version>${project.version}</version>
        </dependency>
    </dependencies>
</project>
```

- [ ] **Step 5: 创建模块目录结构**

```bash
mkdir -p backend/eladmin-sync/src/main/java/me/zhengjie/modules/sync
mkdir -p backend/eladmin-sync/src/main/resources/mapper
mkdir -p backend/eladmin-sync/src/test/java/me/zhengjie/modules/sync

mkdir -p backend/eladmin-tools/src/main/java/me/zhengjie/modules/tools
mkdir -p backend/eladmin-tools/src/main/resources/mapper
mkdir -p backend/eladmin-tools/src/test/java/me/zhengjie/modules/tools

mkdir -p backend/eladmin-auth/src/main/java/me/zhengjie/modules/auth
mkdir -p backend/eladmin-auth/src/test/java/me/zhengjie/modules/auth
```

- [ ] **Step 6: 验证项目编译**

```bash
cd backend
mvn clean compile -DskipTests
```

Expected: BUILD SUCCESS

- [ ] **Step 7: Commit**

```bash
git add backend/
git commit -m "feat(backend): add sync, tools, auth modules structure"
```

---

## Phase 2: 数据库初始化

### Task 4: 创建业务表 SQL 脚本

**Files:**
- Create: `backend/sql/business_tables.sql`

- [ ] **Step 1: 创建 SQL 脚本文件**

```sql
-- backend/sql/business_tables.sql

-- 数据同步模块表
CREATE TABLE IF NOT EXISTS sync_device (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    device_id VARCHAR(64) NOT NULL COMMENT '设备唯一标识',
    device_name VARCHAR(100) COMMENT '设备名称',
    device_type VARCHAR(20) COMMENT '设备类型: android/ios/web',
    last_sync_time DATETIME COMMENT '最后同步时间',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_device (user_id, device_id),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户设备表';

CREATE TABLE IF NOT EXISTS sync_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    device_id VARCHAR(64) NOT NULL COMMENT '设备ID',
    sync_type TINYINT NOT NULL COMMENT '同步类型: 1上传 2下载',
    data_size BIGINT COMMENT '数据大小(字节)',
    status TINYINT DEFAULT 1 COMMENT '状态: 1成功 2失败',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_created_time (created_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='同步记录表';

CREATE TABLE IF NOT EXISTS sync_data (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    data_type VARCHAR(50) NOT NULL COMMENT '数据类型: calculator/calendar/config等',
    data_content JSON NOT NULL COMMENT '数据内容(JSON格式)',
    version INT DEFAULT 1 COMMENT '数据版本',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_type (user_id, data_type),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='同步数据表';

-- 工具服务模块表
CREATE TABLE IF NOT EXISTS tool_calculator_history (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    expression VARCHAR(500) NOT NULL COMMENT '表达式',
    result VARCHAR(200) NOT NULL COMMENT '计算结果',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_created_time (created_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='计算器历史表';

CREATE TABLE IF NOT EXISTS tool_calendar_event (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    title VARCHAR(200) NOT NULL COMMENT '事件标题',
    description TEXT COMMENT '事件描述',
    event_date DATE NOT NULL COMMENT '事件日期',
    event_time TIME COMMENT '事件时间',
    reminder TINYINT DEFAULT 0 COMMENT '是否提醒',
    reminder_time DATETIME COMMENT '提醒时间',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_event_date (event_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='日历事件表';

CREATE TABLE IF NOT EXISTS tool_user_config (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL UNIQUE COMMENT '用户ID',
    config_json JSON COMMENT '配置信息(JSON格式)',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户工具配置表';

-- 第三方账号绑定表
CREATE TABLE IF NOT EXISTS social_user (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '系统用户ID',
    platform VARCHAR(20) NOT NULL COMMENT '平台: wechat/google等',
    open_id VARCHAR(100) NOT NULL COMMENT '平台唯一标识',
    union_id VARCHAR(100) COMMENT '联合ID',
    nickname VARCHAR(100) COMMENT '昵称',
    avatar VARCHAR(500) COMMENT '头像URL',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_platform_openid (platform, open_id),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='社交账号绑定表';
```

- [ ] **Step 2: Commit**

```bash
mkdir -p backend/sql
# 写入上述 SQL 文件
git add backend/sql/
git commit -m "feat(backend): add business tables SQL script"
```

---

## Phase 3: 同步模块实现

### Task 5: 实现同步模块实体类

**Files:**
- Create: `backend/eladmin-sync/src/main/java/me/zhengjie/modules/sync/domain/SyncDevice.java`
- Create: `backend/eladmin-sync/src/main/java/me/zhengjie/modules/sync/domain/SyncRecord.java`
- Create: `backend/eladmin-sync/src/main/java/me/zhengjie/modules/sync/domain/SyncData.java`

- [ ] **Step 1: 创建 SyncDevice 实体**

```java
package me.zhengjie.modules.sync.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("sync_device")
public class SyncDevice {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String deviceId;
    private String deviceName;
    private String deviceType;
    private LocalDateTime lastSyncTime;
    private LocalDateTime createdTime;
    private LocalDateTime updatedTime;
}
```

- [ ] **Step 2: 创建 SyncRecord 实体**

```java
package me.zhengjie.modules.sync.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("sync_record")
public class SyncRecord {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String deviceId;
    private Integer syncType;  // 1上传 2下载
    private Long dataSize;
    private Integer status;    // 1成功 2失败
    private LocalDateTime createdTime;
}
```

- [ ] **Step 3: 创建 SyncData 实体**

```java
package me.zhengjie.modules.sync.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("sync_data")
public class SyncData {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String dataType;
    private String dataContent;  // JSON 字符串
    private Integer version;
    private LocalDateTime createdTime;
    private LocalDateTime updatedTime;
}
```

- [ ] **Step 4: Commit**

```bash
git add backend/eladmin-sync/
git commit -m "feat(sync): add entity classes for sync module"
```

---

### Task 6: 实现同步模块 Mapper

**Files:**
- Create: `backend/eladmin-sync/src/main/java/me/zhengjie/modules/sync/mapper/SyncDeviceMapper.java`
- Create: `backend/eladmin-sync/src/main/java/me/zhengjie/modules/sync/mapper/SyncRecordMapper.java`
- Create: `backend/eladmin-sync/src/main/java/me/zhengjie/modules/sync/mapper/SyncDataMapper.java`

- [ ] **Step 1: 创建 Mapper 接口**

```java
// SyncDeviceMapper.java
package me.zhengjie.modules.sync.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import me.zhengjie.modules.sync.domain.SyncDevice;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface SyncDeviceMapper extends BaseMapper<SyncDevice> {
}

// SyncRecordMapper.java
package me.zhengjie.modules.sync.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import me.zhengjie.modules.sync.domain.SyncRecord;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface SyncRecordMapper extends BaseMapper<SyncRecord> {
}

// SyncDataMapper.java
package me.zhengjie.modules.sync.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import me.zhengjie.modules.sync.domain.SyncData;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface SyncDataMapper extends BaseMapper<SyncData> {
}
```

- [ ] **Step 2: Commit**

```bash
git add backend/eladmin-sync/
git commit -m "feat(sync): add mapper interfaces for sync module"
```

---

### Task 7: 实现同步模块 Service

**Files:**
- Create: `backend/eladmin-sync/src/main/java/me/zhengjie/modules/sync/service/SyncService.java`
- Create: `backend/eladmin-sync/src/main/java/me/zhengjie/modules/sync/service/impl/SyncServiceImpl.java`
- Create: `backend/eladmin-sync/src/main/java/me/zhengjie/modules/sync/service/dto/SyncUploadDTO.java`
- Create: `backend/eladmin-sync/src/main/java/me/zhengjie/modules/sync/service/dto/SyncDataVO.java`

- [ ] **Step 1: 创建 DTO 类**

```java
// SyncUploadDTO.java
package me.zhengjie.modules.sync.service.dto;

import lombok.Data;

@Data
public class SyncUploadDTO {
    private String dataType;
    private String dataContent;
}

// SyncDataVO.java
package me.zhengjie.modules.sync.service.dto;

import lombok.Data;

@Data
public class SyncDataVO {
    private String dataContent;
    private Integer version;
}
```

- [ ] **Step 2: 创建 Service 接口**

```java
package me.zhengjie.modules.sync.service;

import me.zhengjie.modules.sync.service.dto.SyncDataVO;
import me.zhengjie.modules.sync.service.dto.SyncUploadDTO;

public interface SyncService {
    Long upload(Long userId, String deviceId, SyncUploadDTO dto);
    SyncDataVO download(Long userId, String dataType);
}
```

- [ ] **Step 3: 创建 Service 实现**

```java
package me.zhengjie.modules.sync.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import me.zhengjie.modules.sync.domain.SyncData;
import me.zhengjie.modules.sync.domain.SyncDevice;
import me.zhengjie.modules.sync.domain.SyncRecord;
import me.zhengjie.modules.sync.mapper.SyncDataMapper;
import me.zhengjie.modules.sync.mapper.SyncDeviceMapper;
import me.zhengjie.modules.sync.mapper.SyncRecordMapper;
import me.zhengjie.modules.sync.service.SyncService;
import me.zhengjie.modules.sync.service.dto.SyncDataVO;
import me.zhengjie.modules.sync.service.dto.SyncUploadDTO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class SyncServiceImpl implements SyncService {

    private final SyncDataMapper syncDataMapper;
    private final SyncDeviceMapper syncDeviceMapper;
    private final SyncRecordMapper syncRecordMapper;

    @Override
    @Transactional
    public Long upload(Long userId, String deviceId, SyncUploadDTO dto) {
        // 更新或创建同步数据
        SyncData syncData = syncDataMapper.selectOne(
            new LambdaQueryWrapper<SyncData>()
                .eq(SyncData::getUserId, userId)
                .eq(SyncData::getDataType, dto.getDataType())
        );

        long dataSize = dto.getDataContent().getBytes().length;

        if (syncData == null) {
            syncData = new SyncData();
            syncData.setUserId(userId);
            syncData.setDataType(dto.getDataType());
            syncData.setDataContent(dto.getDataContent());
            syncData.setVersion(1);
            syncDataMapper.insert(syncData);
        } else {
            syncData.setDataContent(dto.getDataContent());
            syncData.setVersion(syncData.getVersion() + 1);
            syncDataMapper.updateById(syncData);
        }

        // 记录同步操作
        SyncRecord record = new SyncRecord();
        record.setUserId(userId);
        record.setDeviceId(deviceId);
        record.setSyncType(1); // 上传
        record.setDataSize(dataSize);
        record.setStatus(1); // 成功
        syncRecordMapper.insert(record);

        // 更新设备同步时间
        updateDeviceSyncTime(userId, deviceId);

        return syncData.getId();
    }

    @Override
    public SyncDataVO download(Long userId, String dataType) {
        SyncData syncData = syncDataMapper.selectOne(
            new LambdaQueryWrapper<SyncData>()
                .eq(SyncData::getUserId, userId)
                .eq(SyncData::getDataType, dataType)
        );

        if (syncData == null) {
            return null;
        }

        SyncDataVO vo = new SyncDataVO();
        vo.setDataContent(syncData.getDataContent());
        vo.setVersion(syncData.getVersion());
        return vo;
    }

    private void updateDeviceSyncTime(Long userId, String deviceId) {
        SyncDevice device = syncDeviceMapper.selectOne(
            new LambdaQueryWrapper<SyncDevice>()
                .eq(SyncDevice::getUserId, userId)
                .eq(SyncDevice::getDeviceId, deviceId)
        );

        if (device != null) {
            device.setLastSyncTime(LocalDateTime.now());
            syncDeviceMapper.updateById(device);
        }
    }
}
```

- [ ] **Step 4: Commit**

```bash
git add backend/eladmin-sync/
git commit -m "feat(sync): implement sync service with upload/download"
```

---

### Task 8: 实现同步模块 Controller

**Files:**
- Create: `backend/eladmin-sync/src/main/java/me/zhengjie/modules/sync/rest/SyncController.java`

- [ ] **Step 1: 创建 Controller**

```java
package me.zhengjie.modules.sync.rest;

import lombok.RequiredArgsConstructor;
import me.zhengjie.modules.sync.service.SyncService;
import me.zhengjie.modules.sync.service.dto.SyncDataVO;
import me.zhengjie.modules.sync.service.dto.SyncUploadDTO;
import me.zhengjie.utils.SecurityUtils;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/sync")
@RequiredArgsConstructor
public class SyncController {

    private final SyncService syncService;

    @PostMapping("/upload")
    public ResponseEntity<Long> upload(@RequestBody SyncUploadDTO dto,
                                       @RequestHeader("X-Device-Id") String deviceId) {
        Long userId = SecurityUtils.getCurrentUserId();
        Long syncId = syncService.upload(userId, deviceId, dto);
        return ResponseEntity.ok(syncId);
    }

    @GetMapping("/download")
    public ResponseEntity<SyncDataVO> download(@RequestParam String dataType) {
        Long userId = SecurityUtils.getCurrentUserId();
        SyncDataVO data = syncService.download(userId, dataType);
        if (data == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(data);
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add backend/eladmin-sync/
git commit -m "feat(sync): add sync controller with upload/download endpoints"
```

---

## Phase 4: 工具模块实现

### Task 9: 实现工具模块实体类

**Files:**
- Create: `backend/eladmin-tools/src/main/java/me/zhengjie/modules/tools/domain/CalculatorHistory.java`
- Create: `backend/eladmin-tools/src/main/java/me/zhengjie/modules/tools/domain/CalendarEvent.java`
- Create: `backend/eladmin-tools/src/main/java/me/zhengjie/modules/tools/domain/UserConfig.java`

- [ ] **Step 1: 创建 CalculatorHistory 实体**

```java
package me.zhengjie.modules.tools.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("tool_calculator_history")
public class CalculatorHistory {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String expression;
    private String result;
    private LocalDateTime createdTime;
}
```

- [ ] **Step 2: 创建 CalendarEvent 实体**

```java
package me.zhengjie.modules.tools.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Data
@TableName("tool_calendar_event")
public class CalendarEvent {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String title;
    private String description;
    private LocalDate eventDate;
    private LocalTime eventTime;
    private Integer reminder;
    private LocalDateTime reminderTime;
    private LocalDateTime createdTime;
    private LocalDateTime updatedTime;
}
```

- [ ] **Step 3: 创建 UserConfig 实体**

```java
package me.zhengjie.modules.tools.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("tool_user_config")
public class UserConfig {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String configJson;
    private LocalDateTime createdTime;
    private LocalDateTime updatedTime;
}
```

- [ ] **Step 4: Commit**

```bash
git add backend/eladmin-tools/
git commit -m "feat(tools): add entity classes for calculator, calendar, config"
```

---

### Task 10: 实现工具模块 Mapper 和 Service

**Files:**
- Create: `backend/eladmin-tools/src/main/java/me/zhengjie/modules/tools/mapper/*.java`
- Create: `backend/eladmin-tools/src/main/java/me/zhengjie/modules/tools/service/*.java`

- [ ] **Step 1: 创建 Mapper 接口**

```java
// CalculatorHistoryMapper.java
package me.zhengjie.modules.tools.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import me.zhengjie.modules.tools.domain.CalculatorHistory;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface CalculatorHistoryMapper extends BaseMapper<CalculatorHistory> {
}

// CalendarEventMapper.java
package me.zhengjie.modules.tools.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import me.zhengjie.modules.tools.domain.CalendarEvent;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface CalendarEventMapper extends BaseMapper<CalendarEvent> {
}

// UserConfigMapper.java
package me.zhengjie.modules.tools.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import me.zhengjie.modules.tools.domain.UserConfig;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserConfigMapper extends BaseMapper<UserConfig> {
}
```

- [ ] **Step 2: 创建 Service 接口和实现**

```java
// CalculatorHistoryService.java
package me.zhengjie.modules.tools.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import me.zhengjie.modules.tools.domain.CalculatorHistory;

public interface CalculatorHistoryService {
    Page<CalculatorHistory> getPage(Long userId, int page, int size);
    Long save(Long userId, String expression, String result);
    void delete(Long userId, Long id);
}

// CalculatorHistoryServiceImpl.java
package me.zhengjie.modules.tools.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import me.zhengjie.modules.tools.domain.CalculatorHistory;
import me.zhengjie.modules.tools.mapper.CalculatorHistoryMapper;
import me.zhengjie.modules.tools.service.CalculatorHistoryService;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CalculatorHistoryServiceImpl implements CalculatorHistoryService {

    private final CalculatorHistoryMapper mapper;

    @Override
    public Page<CalculatorHistory> getPage(Long userId, int page, int size) {
        return mapper.selectPage(
            new Page<>(page, size),
            new LambdaQueryWrapper<CalculatorHistory>()
                .eq(CalculatorHistory::getUserId, userId)
                .orderByDesc(CalculatorHistory::getCreatedTime)
        );
    }

    @Override
    public Long save(Long userId, String expression, String result) {
        CalculatorHistory history = new CalculatorHistory();
        history.setUserId(userId);
        history.setExpression(expression);
        history.setResult(result);
        mapper.insert(history);
        return history.getId();
    }

    @Override
    public void delete(Long userId, Long id) {
        mapper.delete(
            new LambdaQueryWrapper<CalculatorHistory>()
                .eq(CalculatorHistory::getId, id)
                .eq(CalculatorHistory::getUserId, userId)
        );
    }
}
```

- [ ] **Step 3: 创建 CalendarEventService**

```java
// CalendarEventService.java
package me.zhengjie.modules.tools.service;

import me.zhengjie.modules.tools.domain.CalendarEvent;
import java.time.YearMonth;
import java.util.List;

public interface CalendarEventService {
    List<CalendarEvent> getByMonth(Long userId, YearMonth month);
    Long create(Long userId, CalendarEvent event);
    void update(Long userId, CalendarEvent event);
    void delete(Long userId, Long id);
}

// CalendarEventServiceImpl.java
package me.zhengjie.modules.tools.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import me.zhengjie.modules.tools.domain.CalendarEvent;
import me.zhengjie.modules.tools.mapper.CalendarEventMapper;
import me.zhengjie.modules.tools.service.CalendarEventService;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CalendarEventServiceImpl implements CalendarEventService {

    private final CalendarEventMapper mapper;

    @Override
    public List<CalendarEvent> getByMonth(Long userId, YearMonth month) {
        LocalDate start = month.atDay(1);
        LocalDate end = month.atEndOfMonth();

        return mapper.selectList(
            new LambdaQueryWrapper<CalendarEvent>()
                .eq(CalendarEvent::getUserId, userId)
                .between(CalendarEvent::getEventDate, start, end)
                .orderByAsc(CalendarEvent::getEventDate, CalendarEvent::getEventTime)
        );
    }

    @Override
    public Long create(Long userId, CalendarEvent event) {
        event.setUserId(userId);
        mapper.insert(event);
        return event.getId();
    }

    @Override
    public void update(Long userId, CalendarEvent event) {
        CalendarEvent existing = mapper.selectById(event.getId());
        if (existing != null && existing.getUserId().equals(userId)) {
            event.setUserId(userId);
            mapper.updateById(event);
        }
    }

    @Override
    public void delete(Long userId, Long id) {
        mapper.delete(
            new LambdaQueryWrapper<CalendarEvent>()
                .eq(CalendarEvent::getId, id)
                .eq(CalendarEvent::getUserId, userId)
        );
    }
}
```

- [ ] **Step 4: 创建 UserConfigService**

```java
// UserConfigService.java
package me.zhengjie.modules.tools.service;

import me.zhengjie.modules.tools.domain.UserConfig;

public interface UserConfigService {
    UserConfig getByUserId(Long userId);
    void saveOrUpdate(Long userId, String configJson);
}

// UserConfigServiceImpl.java
package me.zhengjie.modules.tools.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import me.zhengjie.modules.tools.domain.UserConfig;
import me.zhengjie.modules.tools.mapper.UserConfigMapper;
import me.zhengjie.modules.tools.service.UserConfigService;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserConfigServiceImpl implements UserConfigService {

    private final UserConfigMapper mapper;

    @Override
    public UserConfig getByUserId(Long userId) {
        return mapper.selectOne(
            new LambdaQueryWrapper<UserConfig>()
                .eq(UserConfig::getUserId, userId)
        );
    }

    @Override
    public void saveOrUpdate(Long userId, String configJson) {
        UserConfig config = getByUserId(userId);
        if (config == null) {
            config = new UserConfig();
            config.setUserId(userId);
            config.setConfigJson(configJson);
            mapper.insert(config);
        } else {
            config.setConfigJson(configJson);
            mapper.updateById(config);
        }
    }
}
```

- [ ] **Step 5: Commit**

```bash
git add backend/eladmin-tools/
git commit -m "feat(tools): implement mapper and service for calculator, calendar, config"
```

---

### Task 11: 实现工具模块 Controller

**Files:**
- Create: `backend/eladmin-tools/src/main/java/me/zhengjie/modules/tools/rest/ToolsController.java`

- [ ] **Step 1: 创建 Controller**

```java
package me.zhengjie.modules.tools.rest;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import me.zhengjie.modules.tools.domain.CalendarEvent;
import me.zhengjie.modules.tools.domain.CalculatorHistory;
import me.zhengjie.modules.tools.domain.UserConfig;
import me.zhengjie.modules.tools.service.CalendarEventService;
import me.zhengjie.modules.tools.service.CalculatorHistoryService;
import me.zhengjie.modules.tools.service.UserConfigService;
import me.zhengjie.utils.SecurityUtils;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.YearMonth;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/tools")
@RequiredArgsConstructor
public class ToolsController {

    private final CalculatorHistoryService calculatorService;
    private final CalendarEventService calendarService;
    private final UserConfigService configService;

    // Calculator endpoints
    @GetMapping("/calculator/history")
    public ResponseEntity<Map<String, Object>> getCalculatorHistory(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        Long userId = SecurityUtils.getCurrentUserId();
        Page<CalculatorHistory> pageData = calculatorService.getPage(userId, page, size);

        Map<String, Object> result = new HashMap<>();
        result.put("history", pageData.getRecords());
        result.put("total", pageData.getTotal());
        return ResponseEntity.ok(result);
    }

    @PostMapping("/calculator/history")
    public ResponseEntity<Long> saveCalculatorHistory(@RequestBody Map<String, String> body) {
        Long userId = SecurityUtils.getCurrentUserId();
        Long id = calculatorService.save(userId, body.get("expression"), body.get("result"));
        return ResponseEntity.ok(id);
    }

    @DeleteMapping("/calculator/history/{id}")
    public ResponseEntity<Void> deleteCalculatorHistory(@PathVariable Long id) {
        Long userId = SecurityUtils.getCurrentUserId();
        calculatorService.delete(userId, id);
        return ResponseEntity.ok().build();
    }

    // Calendar endpoints
    @GetMapping("/calendar/events")
    public ResponseEntity<List<CalendarEvent>> getCalendarEvents(
            @RequestParam int year,
            @RequestParam int month) {
        Long userId = SecurityUtils.getCurrentUserId();
        List<CalendarEvent> events = calendarService.getByMonth(userId, YearMonth.of(year, month));
        return ResponseEntity.ok(events);
    }

    @PostMapping("/calendar/events")
    public ResponseEntity<Long> createCalendarEvent(@RequestBody CalendarEvent event) {
        Long userId = SecurityUtils.getCurrentUserId();
        Long id = calendarService.create(userId, event);
        return ResponseEntity.ok(id);
    }

    @PutMapping("/calendar/events/{id}")
    public ResponseEntity<Void> updateCalendarEvent(@PathVariable Long id, @RequestBody CalendarEvent event) {
        Long userId = SecurityUtils.getCurrentUserId();
        event.setId(id);
        calendarService.update(userId, event);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/calendar/events/{id}")
    public ResponseEntity<Void> deleteCalendarEvent(@PathVariable Long id) {
        Long userId = SecurityUtils.getCurrentUserId();
        calendarService.delete(userId, id);
        return ResponseEntity.ok().build();
    }

    // Config endpoints
    @GetMapping("/config")
    public ResponseEntity<UserConfig> getConfig() {
        Long userId = SecurityUtils.getCurrentUserId();
        UserConfig config = configService.getByUserId(userId);
        return ResponseEntity.ok(config);
    }

    @PutMapping("/config")
    public ResponseEntity<Void> updateConfig(@RequestBody Map<String, String> body) {
        Long userId = SecurityUtils.getCurrentUserId();
        configService.saveOrUpdate(userId, body.get("config"));
        return ResponseEntity.ok().build();
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add backend/eladmin-tools/
git commit -m "feat(tools): add tools controller with calculator, calendar, config endpoints"
```

---

## Phase 5: 认证模块优化

### Task 12: 抽取认证模块并预留微信登录接口

**Files:**
- Create: `backend/eladmin-auth/src/main/java/me/zhengjie/modules/auth/service/WechatAuthService.java`
- Create: `backend/eladmin-auth/src/main/java/me/zhengjie/modules/auth/controller/AuthController.java`
- Modify: `backend/eladmin-admin/pom.xml` (添加 auth 模块依赖)

- [ ] **Step 1: 创建微信登录服务接口**

```java
package me.zhengjie.modules.auth.service;

import java.util.Map;

public interface WechatAuthService {
    /**
     * 通过微信授权码登录
     * @param code 微信返回的授权码
     * @return 包含 token 和用户信息的 Map
     */
    Map<String, Object> loginByCode(String code);

    /**
     * 绑定微信账号
     * @param userId 系统用户ID
     * @param code 微信授权码
     */
    void bindWechat(Long userId, String code);
}
```

- [ ] **Step 2: 创建微信登录服务实现（预留）**

```java
package me.zhengjie.modules.auth.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import me.zhengjie.modules.auth.service.WechatAuthService;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class WechatAuthServiceImpl implements WechatAuthService {

    // TODO: 配置微信开放平台参数
    // private String appId;
    // private String appSecret;

    @Override
    public Map<String, Object> loginByCode(String code) {
        // TODO: 实现微信登录逻辑
        // 1. 通过 code 获取 access_token 和 openid
        // 2. 通过 access_token 获取用户信息
        // 3. 查找或创建本地用户
        // 4. 生成 JWT token
        log.info("Wechat login with code: {}", code);
        throw new UnsupportedOperationException("微信登录功能暂未开放，请联系管理员");
    }

    @Override
    public void bindWechat(Long userId, String code) {
        // TODO: 实现微信绑定逻辑
        log.info("Bind wechat for user: {} with code: {}", userId, code);
        throw new UnsupportedOperationException("微信绑定功能暂未开放，请联系管理员");
    }
}
```

- [ ] **Step 3: 创建认证 Controller**

```java
package me.zhengjie.modules.auth.controller;

import lombok.RequiredArgsConstructor;
import me.zhengjie.modules.auth.service.WechatAuthService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final WechatAuthService wechatAuthService;

    @PostMapping("/wechat/login")
    public ResponseEntity<Map<String, Object>> wechatLogin(@RequestBody Map<String, String> body) {
        String code = body.get("code");
        Map<String, Object> result = wechatAuthService.loginByCode(code);
        return ResponseEntity.ok(result);
    }

    @PostMapping("/wechat/bind")
    public ResponseEntity<Void> bindWechat(@RequestBody Map<String, String> body) {
        // 需要登录后才能绑定
        Long userId = Long.valueOf(body.get("userId")); // 从 SecurityContext 获取
        String code = body.get("code");
        wechatAuthService.bindWechat(userId, code);
        return ResponseEntity.ok().build();
    }
}
```

- [ ] **Step 4: 更新 eladmin-admin 的 pom.xml 添加依赖**

```xml
<dependency>
    <groupId>me.zhengjie</groupId>
    <artifactId>eladmin-auth</artifactId>
    <version>${project.version}</version>
</dependency>
<dependency>
    <groupId>me.zhengjie</groupId>
    <artifactId>eladmin-sync</artifactId>
    <version>${project.version}</version>
</dependency>
<dependency>
    <groupId>me.zhengjie</groupId>
    <artifactId>eladmin-tools</artifactId>
    <version>${project.version}</version>
</dependency>
```

- [ ] **Step 5: Commit**

```bash
git add backend/
git commit -m "feat(auth): add wechat auth service interface (placeholder for future)"
```

---

## Phase 6: 集成测试

### Task 13: 启动项目并验证

- [ ] **Step 1: 配置数据库连接**

修改 `backend/eladmin-admin/src/main/resources/application.yml`:

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/littlegrid?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai
    username: root
    password: your_password
```

- [ ] **Step 2: 执行数据库初始化脚本**

```bash
# 先执行 eladmin 原有的系统表脚本
mysql -u root -p littlegrid < backend/sql/eladmin_tables.sql

# 再执行业务表脚本
mysql -u root -p littlegrid < backend/sql/business_tables.sql
```

- [ ] **Step 3: 启动项目**

```bash
cd backend
mvn spring-boot:run -pl eladmin-admin
```

- [ ] **Step 4: 验证 API 可访问**

```bash
# 测试健康检查
curl http://localhost:8000/actuator/health

# 测试登录接口
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"123456"}'
```

- [ ] **Step 5: Commit**

```bash
git add backend/
git commit -m "feat(backend): complete backend setup with all modules"
```

---

## 任务清单总览

| Phase | Task | 描述 | 状态 |
|-------|------|------|------|
| 1 | Task 1 | 克隆 eladmin 项目 | - [ ] |
| 1 | Task 2 | 升级 Spring Boot 版本 | - [ ] |
| 1 | Task 3 | 添加新模块结构 | - [ ] |
| 2 | Task 4 | 创建业务表 SQL 脚本 | - [ ] |
| 3 | Task 5 | 实现同步模块实体类 | - [ ] |
| 3 | Task 6 | 实现同步模块 Mapper | - [ ] |
| 3 | Task 7 | 实现同步模块 Service | - [ ] |
| 3 | Task 8 | 实现同步模块 Controller | - [ ] |
| 4 | Task 9 | 实现工具模块实体类 | - [ ] |
| 4 | Task 10 | 实现工具模块 Mapper 和 Service | - [ ] |
| 4 | Task 11 | 实现工具模块 Controller | - [ ] |
| 5 | Task 12 | 抽取认证模块并预留微信登录 | - [ ] |
| 6 | Task 13 | 启动项目并验证 | - [ ] |