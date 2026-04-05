# Habit Check-In Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a habit check-in feature where users can create custom habits, track daily check-ins, view statistics, and delete habits.

**Architecture:** Backend integrated into eladmin-app module using Spring Boot/JPA, frontend using Flutter with provider-based state management.

**Tech Stack:** Java 17, Spring Boot, JPA, MySQL, Flutter, Dart

---

### Task 1: Create database migration file

**Files:**
- Create: `backend/eladmin-app/src/main/resources/db/migration/V3__create_habit_tables.sql`

- [ ] **Step 1: Write migration SQL**

```sql
-- 习惯打卡目标表
CREATE TABLE habit (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    name VARCHAR(64) NOT NULL COMMENT '习惯名称',
    icon VARCHAR(32) NOT NULL DEFAULT 'check_circle' COMMENT '图标名称',
    description VARCHAR(255) COMMENT '描述',
    color VARCHAR(16) DEFAULT '#4CAF50' COMMENT '主题颜色',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否激活',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user (user_id),
    FOREIGN KEY (user_id) REFERENCES app_user(id) ON DELETE CASCADE
) COMMENT='习惯打卡目标';

-- 打卡记录表
CREATE TABLE habit_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    habit_id BIGINT NOT NULL COMMENT '习惯ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    record_date DATE NOT NULL COMMENT '打卡日期',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_habit_date (habit_id, record_date),
    INDEX idx_user_date (user_id, record_date),
    FOREIGN KEY (habit_id) REFERENCES habit(id) ON DELETE CASCADE
) COMMENT='打卡记录';

-- 内置模板表
CREATE TABLE habit_template (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(64) NOT NULL COMMENT '模板名称',
    icon VARCHAR(32) NOT NULL COMMENT '图标名称',
    description VARCHAR(255) COMMENT '描述',
    category VARCHAR(32) COMMENT '分类',
    sort_order INT DEFAULT 0 COMMENT '排序'
) COMMENT='习惯内置模板';

-- 插入内置模板数据
INSERT INTO habit_template (name, icon, description, category, sort_order) VALUES
('晨跑', 'directions_run', '每天早晨跑步', '运动', 1),
('早睡', 'bedtime', '每晚10点前睡觉', '健康', 2),
('早起', 'wb_sunny', '每天7点前起床', '健康', 3),
('阅读', 'menu_book', '每天阅读30分钟', '学习', 4),
('喝水', 'water_drop', '每天喝8杯水', '健康', 5),
('冥想', 'spa', '每天冥想10分钟', '健康', 6),
('运动', 'fitness_center', '每天运动1小时', '运动', 7),
('学习', 'school', '每天学习新知识', '学习', 8);
```

- [ ] **Step 2: Commit**

```bash
git add backend/eladmin-app/src/main/resources/db/migration/V3__create_habit_tables.sql
git commit -m "feat(habit): add database migration for habit tables"
```

---

### Task 2: Create Habit entity

**Files:**
- Create: `backend/eladmin-app/src/main/java/com/littlegrid/modules/app/domain/Habit.java`

- [ ] **Step 1: Write Habit entity class**

```java
package com.littlegrid.modules.app.domain;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "habit")
@Schema(description = "习惯打卡目标")
public class Habit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    @Schema(description = "习惯ID")
    private Long id;

    @Column(name = "user_id", nullable = false)
    @Schema(description = "用户ID")
    private Long userId;

    @Column(name = "name", nullable = false, length = 64)
    @Schema(description = "习惯名称")
    private String name;

    @Column(name = "icon", nullable = false, length = 32)
    @Schema(description = "图标名称")
    private String icon = "check_circle";

    @Column(name = "description", length = 255)
    @Schema(description = "描述")
    private String description;

    @Column(name = "color", length = 16)
    @Schema(description = "主题颜色")
    private String color = "#4CAF50";

    @Column(name = "is_active")
    @Schema(description = "是否激活")
    private Boolean isActive = true;

    @Column(name = "created_at", updatable = false)
    @Schema(description = "创建时间")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    @Schema(description = "更新时间")
    private LocalDateTime updatedAt;
}
```

- [ ] **Step 2: Commit**

```bash
git add backend/eladmin-app/src/main/java/com/littlegrid/modules/app/domain/Habit.java
git commit -m "feat(habit): add Habit entity"
```

---

### Task 3: Create HabitRecord entity

**Files:**
- Create: `backend/eladmin-app/src/main/java/com/littlegrid/modules/app/domain/HabitRecord.java`

- [ ] **Step 1: Write HabitRecord entity class**

```java
package com.littlegrid.modules.app.domain;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDate;

@Data
@Entity
@Table(name = "habit_record")
@Schema(description = "打卡记录")
public class HabitRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    @Schema(description = "记录ID")
    private Long id;

    @Column(name = "habit_id", nullable = false)
    @Schema(description = "习惯ID")
    private Long habitId;

    @Column(name = "user_id", nullable = false)
    @Schema(description = "用户ID")
    private Long userId;

    @Column(name = "record_date", nullable = false)
    @Schema(description = "打卡日期")
    private LocalDate recordDate;

    @Column(name = "created_at", updatable = false)
    @Schema(description = "创建时间")
    private LocalDateTime createdAt;
}
```

- [ ] **Step 2: Commit**

```bash
git add backend/eladmin-app/src/main/java/com/littlegrid/modules/app/domain/HabitRecord.java
git commit -m "feat(habit): add HabitRecord entity"
```

---

### Task 4: Create HabitTemplate entity

**Files:**
- Create: `backend/eladmin-app/src/main/java/com/littlegrid/modules/app/domain/HabitTemplate.java`

- [ ] **Step 1: Write HabitTemplate entity class**

```java
package com.littlegrid.modules.app.domain;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "habit_template")
@Schema(description = "习惯内置模板")
public class HabitTemplate {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    @Schema(description = "模板ID")
    private Integer id;

    @Column(name = "name", nullable = false, length = 64)
    @Schema(description = "模板名称")
    private String name;

    @Column(name = "icon", nullable = false, length = 32)
    @Schema(description = "图标名称")
    private String icon;

    @Column(name = "description", length = 255)
    @Schema(description = "描述")
    private String description;

    @Column(name = "category", length = 32)
    @Schema(description = "分类")
    private String category;

    @Column(name = "sort_order")
    @Schema(description = "排序")
    private Integer sortOrder = 0;
}
```

- [ ] **Step 2: Commit**

```bash
git add backend/eladmin-app/src/main/java/com/littlegrid/modules/app/domain/HabitTemplate.java
git commit -m "feat(habit): add HabitTemplate entity"
```

---

### Task 5: Create HabitDTO

**Files:**
- Create: `backend/eladmin-app/src/main/java/com/littlegrid/modules/app/service/dto/HabitDTO.java`

- [ ] **Step 1: Write HabitDTO class**

```java
package com.littlegrid.modules.app.service.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "习惯信息DTO")
public class HabitDTO {

    @Schema(description = "习惯ID")
    private Long id;

    @Schema(description = "习惯名称")
    private String name;

    @Schema(description = "图标名称")
    private String icon;

    @Schema(description = "描述")
    private String description;

    @Schema(description = "主题颜色")
    private String color;

    @Schema(description = "是否激活")
    private Boolean isActive;

    @Schema(description = "已完成天数")
    private Integer completedDays;

    @Schema(description = "今日是否已打卡")
    private Boolean todayChecked;

    @Schema(description = "创建时间")
    private LocalDateTime createdAt;
}
```

- [ ] **Step 2: Commit**

```bash
git add backend/eladmin-app/src/main/java/com/littlegrid/modules/app/service/dto/HabitDTO.java
git commit -m "feat(habit): add HabitDTO"
```

---

### Task 6: Create HabitCreateDTO

**Files:**
- Create: `backend/eladmin-app/src/main/java/com/littlegrid/modules/app/service/dto/HabitCreateDTO.java`

- [ ] **Step 1: Write HabitCreateDTO class**

```java
package com.littlegrid.modules.app.service.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "创建习惯请求DTO")
public class HabitCreateDTO {

    @NotBlank(message = "习惯名称不能为空")
    @Size(max = 64, message = "习惯名称不能超过64个字符")
    @Schema(description = "习惯名称")
    private String name;

    @NotBlank(message = "图标不能为空")
    @Size(max = 32, message = "图标名称不能超过32个字符")
    @Schema(description = "图标名称")
    private String icon;

    @Size(max = 255, message = "描述不能超过255个字符")
    @Schema(description = "描述")
    private String description;

    @Size(max = 16, message = "颜色代码不能超过16个字符")
    @Schema(description = "主题颜色")
    private String color = "#4CAF50";
}
```

- [ ] **Step 2: Commit**

```bash
git add backend/eladmin-app/src/main/java/com/littlegrid/modules/app/service/dto/HabitCreateDTO.java
git commit -m "feat(habit): add HabitCreateDTO"
```

---

### Task 7: Create CheckInResultDTO

**Files:**
- Create: `backend/eladmin-app/src/main/java/com/littlegrid/modules/app/service/dto/CheckInResultDTO.java`

- [ ] **Step 1: Write CheckInResultDTO class**

```java
package com.littlegrid.modules.app.service.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "打卡结果DTO")
public class CheckInResultDTO {

    @Schema(description = "今日是否已打卡")
    private Boolean todayChecked;

    @Schema(description = "已完成天数")
    private Integer completedDays;
}
```

- [ ] **Step 2: Commit**

```bash
git add backend/eladmin-app/src/main/java/com/littlegrid/modules/app/service/dto/CheckInResultDTO.java
git commit -m "feat(habit): add CheckInResultDTO"
```

---

### Task 8: Create HabitStatsDTO

**Files:**
- Create: `backend/eladmin-app/src/main/java/com/littlegrid/modules/app/service/dto/HabitStatsDTO.java`

- [ ] **Step 1: Write HabitStatsDTO class**

```java
package com.littlegrid.modules.app.service.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "习惯统计DTO")
public class HabitStatsDTO {

    @Schema(description = "总打卡天数")
    private Integer totalDays;

    @Schema(description = "当前连续打卡天数")
    private Integer currentStreak;

    @Schema(description = "最长连续打卡天数")
    private Integer longestStreak;

    @Schema(description = "打卡记录")
    private List<DailyRecordDTO> records;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Schema(description = "每日记录DTO")
    public static class DailyRecordDTO {
        @Schema(description = "日期")
        private LocalDate date;

        @Schema(description = "是否已打卡")
        private Boolean checked;
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add backend/eladmin-app/src/main/java/com/littlegrid/modules/app/service/dto/HabitStatsDTO.java
git commit -m "feat(habit): add HabitStatsDTO"
```

---

### Task 9: Create HabitTemplateDTO

**Files:**
- Create: `backend/eladmin-app/src/main/java/com/littlegrid/modules/app/service/dto/HabitTemplateDTO.java`

- [ ] **Step 1: Write HabitTemplateDTO class**

```java
package com.littlegrid.modules.app.service.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "习惯模板DTO")
public class HabitTemplateDTO {

    @Schema(description = "模板ID")
    private Integer id;

    @Schema(description = "模板名称")
    private String name;

    @Schema(description = "图标名称")
    private String icon;

    @Schema(description = "描述")
    private String description;

    @Schema(description = "分类")
    private String category;

    @Schema(description = "排序")
    private Integer sortOrder;
}
```

- [ ] **Step 2: Commit**

```bash
git add backend/eladmin-app/src/main/java/com/littlegrid/modules/app/service/dto/HabitTemplateDTO.java
git commit -m "feat(habit): add HabitTemplateDTO"
```

---

### Task 10: Create HabitRepository

**Files:**
- Create: `backend/eladmin-app/src/main/java/com/littlegrid/modules/app/repository/HabitRepository.java`

- [ ] **Step 1: Write HabitRepository interface**

```java
package com.littlegrid.modules.app.repository;

import com.littlegrid.modules.app.domain.Habit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HabitRepository extends JpaRepository<Habit, Long> {

    List<Habit> findByUserIdAndIsActive(Long userId, Boolean isActive);

    void deleteByUserId(Long userId);
}
```

- [ ] **Step 2: Commit**

```bash
git add backend/eladmin-app/src/main/java/com/littlegrid/modules/app/repository/HabitRepository.java
git commit -m "feat(habit): add HabitRepository"
```

---

### Task 11: Create HabitRecordRepository

**Files:**
- Create: `backend/eladmin-app/src/main/java/com/littlegrid/modules/app/repository/HabitRecordRepository.java`

- [ ] **Step 1: Write HabitRecordRepository interface**

```java
package com.littlegrid.modules.app.repository;

import com.littlegrid.modules.app.domain.HabitRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface HabitRecordRepository extends JpaRepository<HabitRecord, Long> {

    Optional<HabitRecord> findByHabitIdAndRecordDate(Long habitId, LocalDate recordDate);

    List<HabitRecord> findByHabitIdOrderByRecordDateDesc(Long habitId);

    List<HabitRecord> findByHabitIdAndRecordDateBetweenOrderByRecordDate(
        Long habitId, LocalDate startDate, LocalDate endDate);

    Long countByHabitId(Long habitId);

    @Query("SELECT hr FROM HabitRecord hr WHERE hr.habitId = :habitId AND hr.recordDate <= :endDate " +
           "ORDER BY hr.recordDate DESC")
    List<HabitRecord> findByHabitIdUpToDateOrderByDateDesc(
        @Param("habitId") Long habitId, @Date("endDate") LocalDate endDate);
}
```

- [ ] **Step 2: Commit**

```bash
git add backend/eladmin-app/src/main/java/com/littlegrid/modules/app/repository/HabitRecordRepository.java
git commit -m "feat(habit): add HabitRecordRepository"
```

---

### Task 12: Create HabitTemplateRepository

**Files:**
- Create: `backend/eladmin-app/src/main/java/com/littlegrid/modules/app/repository/HabitTemplateRepository.java`

- [ ] **Step 1: Write HabitTemplateRepository interface**

```java
package com.littlegrid.modules.app.repository;

import com.littlegrid.modules.app.domain.HabitTemplate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HabitTemplateRepository extends JpaRepository<HabitTemplate, Integer> {

    List<HabitTemplate> findAllByOrderBySortOrderAsc();
}
```

- [ ] **Step 2: Commit**

```bash
git add backend/eladmin-app/src/main/java/com/littlegrid/modules/app/repository/HabitTemplateRepository.java
git commit -m "feat(habit): add HabitTemplateRepository"
```

---

### Task 13: Create HabitService interface



**Files:**
- Create: `backend/eladmin-app/src/main/java/com/littlegrid/modules/app/service/HabitService.java`

- [ ] **Step 1: Write HabitService interface**

```java
package com.littlegrid.modules.app.service;

import com.littlegrid.modules.app.service.dto.*;

import java.util.List;

public interface HabitService {

    List<HabitDTO> getUserHabits(Long userId);

    HabitDTO createHabit(Long userId, HabitCreateDTO dto);

    void deleteHabit(Long userId, Long habitId);

    CheckInResultDTO toggleCheckIn(Long userId, Long habitId, java.time.LocalDate date);

    HabitStatsDTO getHabitStats(Long userId, Long habitId, java.time.LocalDate startDate, java.time.LocalDate endDate);

    List<HabitTemplateDTO> getTemplates();
}
```

- [ ] **Step 2: Commit**

```bash
git add backend/eladmin-app/src/main/java/com/littlegrid/modules/app/service/HabitService.java
git commit -m "feat(habit): add HabitService interface"
```

---

### Task 14: Create HabitServiceImpl

**Files:**
- Create: `backend/eladmin-app/src/main/java/com/littlegrid/modules/app/service/impl/HabitServiceImpl.java`

- [ ] **Step 1: Write HabitServiceImpl class**

```java
package com.littlegrid.modules.app.service.impl;

import com.littlegrid.exception.EntityNotFoundException;
import com.littlegrid.modules.app.domain.*;
import com.littlegrid.modules.app.repository.*;
import com.littlegrid.modules.app.service.HabitService;
import com.littlegrid.modules.app.service.dto.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class HabitServiceImpl implements HabitService {

    private final HabitRepository habitRepository;
    private final HabitRecordRepository habitRecordRepository;
    private final HabitTemplateRepository habitTemplateRepository;

    @Override
    public List<HabitDTO> getUserHabits(Long userId) {
        List<Habit> habits = habitRepository.findByUserIdAndIsActive(userId, true);
        LocalDate today = LocalDate.now();

        return habits.stream().map(habit -> {
            List<HabitRecord> records = habitRecordRepository.findByHabitIdOrderByRecordDateDesc(habit.getId());
            boolean todayChecked = records.stream()
                .anyMatch(r -> r.getRecordDate().equals(today));

            return new HabitDTO(
                habit.getId(),
                habit.getName(),
                habit.getIcon(),
                habit.getDescription(),
                habit.getColor(),
                habit.getIsActive(),
                (int) records.size(),
                todayChecked,
                habit.getCreatedAt()
            );
        }).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public HabitDTO createHabit(Long userId, HabitCreateDTO dto) {
        Habit habit = new Habit();
        habit.setUserId(userId);
        habit.setName(dto.getName());
        habit.setIcon(dto.getIcon());
        habit.setDescription(dto.getDescription());
        habit.setColor(dto.getColor() != null ? dto.getColor() : "#4CAF50");
        habit.setIsActive(true);

        Habit saved = habitRepository.save(habit);

        return new HabitDTO(
            saved.getId(),
            saved.getName(),
            saved.getIcon(),
            saved.getDescription(),
            saved.getColor(),
            saved.getIsActive(),
            0,
            false,
            saved.getCreatedAt()
        );
    }

    @Override
    @Transactional
    public void deleteHabit(Long userId, Long habitId) {
        Habit habit = habitRepository.findById(habitId)
            .orElseThrow(() -> new EntityNotFoundException(Habit.class, habitId));

        if (!habit.getUserId().equals(userId)) {
            throw new IllegalArgumentException("无权删除此习惯");
        }

        habitRepository.delete(habit);
    }

    @Override
    @Transactional
    public CheckInResultDTO toggleCheckIn(Long userId, Long habitId, LocalDate date) {
        Habit habit = habitRepository.findById(habitId)
            .orElseThrow(() -> new EntityNotFoundException(Habit.class, habitId));

        if (!habit.getUserId().equals(userId)) {
            throw new IllegalArgumentException("无权操作此习惯");
        }

        var existing = habitRecordRepository.findByHabitIdAndRecordDate(habitId, date);
        boolean checkedIn;

        if (existing.isPresent()) {
            habitRecordRepository.delete(existing.get());
            checkedIn = false;
        } else {
            HabitRecord record = new HabitRecord();
            record.setHabitId(habitId);
            record.setUserId(userId);
            record.setRecordDate(date);
            habitRecordRepository.save(record);
            checkedIn = true;
        }

        int completedDays = (int) habitRecordRepository.countByHabitId(habitId);

        return new CheckInResultDTO(checkedIn, completedDays);
    }

    @Override
    public HabitStatsDTO getHabitStats(Long userId, Long habitId, LocalDate startDate, LocalDate endDate) {
        Habit habit = habitRepository.findById(habitId)
            .orElseThrow(() -> new EntityNotFoundException(Habit.class, habitId));

        if (!habit.getUserId().equals(userId)) {
            throw new IllegalArgumentException("无权查看此习惯统计");
        }

        List<HabitRecord> records = habitRecordRepository
            .findByHabitIdAndRecordDateBetweenOrderByRecordDate(habitId, startDate, endDate);

        int totalDays = records.size();
        int currentStreak = calculateCurrentStreak(records, endDate);
        int longestStreak = calculateLongestStreak(records);

        List<HabitStatsDTO.DailyRecordDTO> dailyRecords = records.stream()
            .map(r -> new HabitStatsDTO.DailyRecordDTO(r.getRecordDate(), true))
            .collect(Collectors.toList());

        return new HabitStatsDTO(totalDays, currentStreak, longestStreak, dailyRecords);
    }

    @Override
    public List<HabitTemplateDTO> getTemplates() {
        return habitTemplateRepository.findAllByOrderBySortOrderAsc().stream()
            .map(t -> new HabitTemplateDTO(
                t.getId(),
                t.getName(),
                t.getIcon(),
                t.getDescription(),
                t.getCategory(),
                t.getSortOrder()
            ))
            .collect(Collectors.toList());
    }

    private int calculateCurrentStreak(List<HabitRecord> records, LocalDate asOfDate) {
        if (records.isEmpty()) return 0;

        int streak = 0;
        LocalDate currentDate = asOfDate;

        for (HabitRecord record : records) {
            if (record.getRecordDate().equals(currentDate)) {
                streak++;
                currentDate = currentDate.minusDays(1);
            } else {
                break;
            }
        }

        return streak;
    }

    private int calculateLongestStreak(List<HabitRecord> records) {
        if (records.isEmpty()) return 0;

        int longestStreak = 0;
        int currentStreak = 1;

        records.sort(Comparator.comparing(HabitRecord::getRecordDate));

        for (int i = 1; i < records.size(); i++) {
            LocalDate prev = records.get(i - 1).getRecordDate();
            LocalDate curr = records.get(i).getRecordDate();

            if (curr.equals(prev.plusDays(1))) {
                currentStreak++;
            } else {
                longestStreak = Math.max(longestStreak, currentStreak);
                currentStreak = 1;
            }
        }

        return Math.max(longestStreak, currentStreak);
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add backend/eladmin-app/src/main/java/com/littlegrid/modules/app/service/impl/HabitServiceImpl.java
git commit -m "feat(habit): add HabitServiceImpl"
```

---

### Task 15: Create HabitController

**Files:**
- Create: `backend/eladmin-app/src/main/java/com/littlegrid/modules/app/rest/HabitController.java`

- [ ] **Step 1: Write HabitController class**

```java
package com.littlegrid.modules.app.rest;

import com.littlegrid.modules.app.service.HabitService;
import com.littlegrid.modules.app.service.dto.*;
import com.littlegrid.utils.SecurityUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/app")
@Tag(name = "APP: 习惯打卡")
public class HabitController {

    private final HabitService habitService;

    @Operation(summary = "获取习惯列表")
    @GetMapping("/habits")
    public ResponseEntity<Map<String, Object>> getHabits() {
        Long userId = SecurityUtils.getCurrentUserId();
        List<HabitDTO> habits = habitService.getUserHabits(userId);

        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("message", "success");
        response.put("data", habits);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "创建习惯")
    @PostMapping("/habits")
    public ResponseEntity<Map<String, Object>> createHabit(@Valid @RequestBody HabitCreateDTO dto) {
        Long userId = SecurityUtils.getCurrentUserId();
        HabitDTO habit = habitService.createHabit(userId, dto);

        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("message", "创建成功");
        response.put("data", habit);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "删除习惯")
    @DeleteMapping("/habits/{id}")
    public ResponseEntity<Map<String, Object>> deleteHabit(@PathVariable Long id) {
        Long userId = SecurityUtils.getCurrentUserId();
        habitService.deleteHabit(userId, id);

        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("message", "删除成功");
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "打卡/取消打卡")
    @PostMapping("/habits/{id}/check-in")
    public ResponseEntity<Map<String, Object>> checkIn(
            @PathVariable Long id,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) String date) {
        Long userId = SecurityUtils.getCurrentUserId();
        LocalDate checkDate = date != null ? LocalDate.parse(date) : LocalDate.now();

        CheckInResultDTO result = habitService.toggleCheckIn(userId, id, checkDate);

        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("message", result.getTodayChecked() ? "打卡成功" : "取消打卡成功");
        response.put("data", result);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "获取习惯统计")
    @GetMapping("/habits/{id}/stats")
    public ResponseEntity<Map<String, Object>> getStats(
            @PathVariable Long id,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) String startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) String endDate) {
        Long userId = SecurityUtils.getCurrentUserId();

        LocalDate start = startDate != null ? LocalDate.parse(startDate) : LocalDate.now().minusMonths(1);
        LocalDate end = endDate != null ? LocalDate.parse(endDate) : LocalDate.now();

        HabitStatsDTO stats = habitService.getHabitStats(userId, id, start, end);

        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("message", "success");
        response.put("data", stats);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "获取内置模板")
    @GetMapping("/habit-templates")
    public ResponseEntity<Map<String, Object>> getTemplates() {
        SecurityUtils.getCurrentUserId();
        List<HabitTemplateDTO> templates = habitService.getTemplates();

        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("message", "success");
        response.put("data", templates);
        return ResponseEntity.ok(response);
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add backend/eladmin-app/src/main/java/com/littlegrid/modules/app/rest/HabitController.java
git commit -m "feat(habit): add HabitController"
```

---

### Task 16: Create Habit model in Flutter

**Files:**
- Create: `app/lib/tools/habit/models/habit.dart`

- [ ] **Step 1: Write Habit model**

```dart
class Habit {
  final int id;
  final String name;
  final String icon;
  final String? description;
  final String color;
  final bool isActive;
  final int completedDays;
  final bool todayChecked;
  final DateTime? createdAt;

  Habit({
    required this.id.id,
    required this.name,
    required this.icon,
    this.description,
    required this.color,
    required this.isActive,
    required this.completedDays,
    required this.todayChecked,
    this.createdAt,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String?,
      color: json['color'] as String? ?? '#4CAF50',
      isActive: json['isActive'] as bool? ?? true,
      completedDays: json['completedDays'] as int? ?? 0,
      todayChecked: json['todayChecked'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/habit/models/habit.dart
git commit -m "feat(habit): add Habit model"
```

---

### Task 17: Create HabitTemplate model in Flutter

**Files:**
- Create: `app/lib/tools/habit/models/habit_template.dart`

- [ ] **Step 1: Write HabitTemplate model**

```dart
class HabitTemplate {
  final int id;
  final String name;
  final String icon;
  final String? description;
  final String? category;
  final int? sortOrder;

  HabitTemplate({
    required this.id,
    required this.name,
    required this.icon,
    this.description,
    this.category,
    this.sortOrder,
  });

  factory HabitTemplate.fromJson(Map<String, dynamic> json) {
    return HabitTemplate(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      sortOrder: json['sortOrder'] as int?,
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/habit/models/habit_template.dart
git commit -m "feat(habit): add HabitTemplate model"
```

---

### Task 18: Create HabitStats model in Flutter

**Files:**
- Create: `app/lib/tools/habit/models/habit_stats.dart`

- [ ] **Step 1: Write HabitStats model**

```dart
class HabitStats {
  final int totalDays;
  final int currentStreak;
  final int longestStreak;
  final List<DailyRecord> records;

  HabitStats({
    required this.totalDays,
    required this.currentStreak,
    required this.longestStreak,
    required this.records,
  });

  factory HabitStats.fromJson(Map<String, dynamic> json) {
    final recordsList = json['records'] as List? ?? [];
    return HabitStats(
      totalDays: json['totalDays'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      records: recordsList
          .map((r) => DailyRecord.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DailyRecord {
  final DateTime date;
  final bool checked;

  DailyRecord({
    required this.date,
    required this.checked,
  });

  factory DailyRecord.fromJson(Map<String, dynamic> json) {
    return DailyRecord(
      date: DateTime.parse(json['date']),
      checked: json['checked'] as bool? ?? false,
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/habit/models/habit_stats.dart
git commit -m "feat(habit): add HabitStats model"
```

---

### Task 19: Create HabitService in Flutter

**Files:**
- Create: `app/lib/tools/habit/services/habit_service.dart`

- [ ] **Step 1: Write HabitService class**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/habit.dart';
import '../models/habit_template.dart';
import '../models/habit_stats.dart';
import '../../../core/constants/api_constants.dart';

class HabitService {
  final String _baseUrl;
  final http.Client _client;

  HabitService({
    required String baseUrl,
    http.Client? client,
  }) : _baseUrl = baseUrl, _client = client ?? http.Client();

  Future<List<Habit>> getHabits(String token) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/app/habits'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final habits = data['data'] as List;
      return habits.map((h) => Habit.fromJson(h)).toList();
    } else {
      throw Exception('Failed to load habits');
    }
  }

  Future<Habit> createHabit(String token, Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/app/habits'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(utf8.decode(response.bodyBytes));
      return Habit.fromJson(responseData['data']);
    } else {
      throw Exception('Failed to create habit');
    }
  }

  Future<void> deleteHabit(String token, int habitId) async {
    final response = await _client.delete(
      Uri.parse('$_baseUrl/api/app/habits/$habitId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete habit');
    }
  }

  Future<Map<String, dynamic>> toggleCheckIn(String token, int habitId, DateTime date) async {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final response = await _client.post(
      Uri.parse('$_baseUrl/api/app/habits/$habitId/check-in'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'date': dateStr}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['data'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to toggle check-in');
    }
  }

  Future<HabitStats> getStats(
    String token,
    int habitId,
    DateTime start,
    DateTime end,
  ) async {
    final startDate = '${start(start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    final endDate = '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';

    final response = await _client.get(
      Uri.parse('$_baseUrl/api/app/habits/$habitId/stats?startDate=$startDate&endDate=$endDate'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return HabitStats.fromJson(data['data']);
    } else {
      throw Exception('Failed to load stats');
    }
  }

  Future<List<HabitTemplate>> getTemplates(String token) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/app/habit-templates'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final templates = data['data'] as List;
      return templates.map((t) => HabitTemplate.fromJson(t)).toList();
    } else {
      throw Exception('Failed to load templates');
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/habit/services/habit_service.dart
git commit -m "feat(habit): add HabitService"
```

---

### Task 20: Create HabitProvider in Flutter

**Files:**
- Create: `app/lib/tools/habit/providers/habit_provider.dart`

- [ ] **Step 1: Write HabitProvider class**

```dart
import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/habit_template.dart';
import '../models/habit_stats.dart';
import '../services/habit_service.dart';

class HabitProvider extends ChangeNotifier {
  final HabitService _habitService;
  final String _token;

  List<Habit> _habits = [];
  List<HabitTemplate> _templates = [];
  bool _isLoading = false;
  String? _errorMessage;

  HabitProvider({
    required HabitService habitService,
    required String token,
  }) : _habitService = habitService, _token = token;

  List<Habit> get habits => _habits;
  List<HabitTemplate> get templates => _templates;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadHabits() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _habits = await _habitService.getHabits(_token);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Habit?> createHabit(Map<String, dynamic> data) async {
    try {
      final habit = await _habitService.createHabit(_token, data);
      _habits.add(habit);
      notifyListeners();
      return habit;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> deleteHabit(int habitId) async {
    try {
      await _habitService.deleteHabit(_token, habitId);
      _habits.removeWhere((h) => h.id == habitId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleCheckIn(int habitId, DateTime date) async {
    try {
      final result = await _habitService.toggleCheckIn(_token, habitId, date);
      final index = _habits.indexWhere((h) => h.id == habitId);
      if (index != -1) {
        _habits[index] = Habit(
          id: _habits[index].id,
          name: _habits[index].name,
          icon: _habits[index].icon,
          description: _habits[index].description,
          color: _habits[index].color,
          isActive: _habits[index].isActive,
          completedDays: result['completedDays'] as int,
          todayChecked: result['todayChecked'] as bool,
          createdAt: _habits[index].createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<HabitStats?> getStats(int habitId, DateTime start, DateTime end) async {
    try {
      return await _habitService.getStats(_token, habitId, start, end);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> loadTemplates() async {
    try {
      _templates = await _habitService.getTemplates(_token);
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/habit/providers/habit_provider.dart
git commit -m "feat(habit): add HabitProvider"
```

---

### Task 21: Create HabitCard widget

**Files:**
- Create: `app/lib/tools/habit/widgets/habit_card.dart`

- [ ] **Step 1: Write HabitCard widget**

```dart
import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onCheckIn;

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = Color(int.parse(habit.color.replaceAll('#', '0xFF')));

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconData(habit.icon),
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '已完成 ${habit.completedDays} 天',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (habit.todayChecked)
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 36,
                )
              else
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  color: Colors.grey[400],
                  iconSize: 36,
                  onPressed: onCheckIn,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'directions_run': Icons.directions_run,
      'bedtime': Icons.bedtime,
      'wb_sunny': Icons.wb_sunny,
      'menu_book': Icons.menu_book,
      'water_drop': Icons.water_drop,
      'spa': Icons.spa,
      'fitness_center': Icons.fitness_center,
      'school': Icons.school,
      'check_circle': Icons.check_circle,
    };
    return iconMap[iconName] ?? Icons.check_circle;
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/habit/widgets/habit_card.dart
git commit -m "feat(habit): add HabitCard widget"
```

---

### Task 22: Create HabitPage (main page)

**Files:**
- Create: `app/lib/tools/habit/habit_page.dart`

- [ ] **Step 1: Write HabitPage class**

```dart
import 'package:flutter/material.dart';
import 'providers/habit_provider.dart';
import 'widgets/habit_card.dart';
import 'habit_create_page.dart';
import 'habit_stats_page.dart';
import '../../../core/utils/logger.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  @override
  State<HabitPage> createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  late HabitProvider _habitProvider;

  @override
  void initState() {
    super.initState();
    _habitProvider = HabitProvider(
      habitService: _habitService,
      token: 'YOUR_TOKEN_HERE',
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HabitProvider>.value(
      value: _habitProvider,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('习惯打卡'),
        ),
        body: Consumer<HabitProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.habits.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '还没有习惯，点击右下角按钮创建',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.habits.length,
              itemBuilder: (context, index) {
                final habit = provider.habits[index];
                return HabitCard(
                  habit: habit,
                  onTap: () => _navigateToStats(context, habit),
                  onCheckIn: () => _toggleCheckIn(context, habit.id),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToCreate(context),
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    try {
      await _habitProvider.loadHabits();
      await _habitProvider.habitTemplates();
    } catch (e) {
      AppLogger.e('Failed to load habits', e);
    }
  }

  Future<void> _toggleCheckIn(BuildContext context, int habitId) async {
    await _habitProvider.toggleCheckIn(habitId, DateTime.now());
  }

  void _navigateToCreate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HabitCreatePage(),
      ),
    ).then((_) => _loadData());
  }

  void _navigateToStats(BuildContext context, habit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitStatsPage(habit: habit),
      ),
    ).then((_) => _loadData());
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/habit/habit_page.dart
git commit -m "feat(habit): add HabitPage"
```

---

### Task 23: Create HabitCreatePage

**Files:**
- Create: `app/lib/tools/habit/habit_create_page.dart`

- [ ] **Step 1: Write HabitCreatePage class**

```dart
import 'package:flutter/material.dart';
import 'providers/habit_provider.dart';
import 'models/habit_template.dart';

class HabitCreatePage extends StatefulWidget {
  const HabitCreatePage({super.key});

  @override
  State<HabitCreatePage> createState() => _HabitCreatePageState();
}

class _HabitCreatePageState extends State<HabitCreatePage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedIcon = 'check_circle';
  String _selectedColor = '#4CAF50';
  HabitTemplate? _selectedTemplate;

  final List<String> _icons = [
    'directions_run', 'bedtime', 'wb_sunny', 'menu_book',
    'water_drop', 'spa', 'fitness_center', 'school', 'check_circle',
  ];

  final List<String> _colors = [
    '#4CAF50', '#2196F3', '#FF9800', '#F44336',
    '#9C27B0', '#795548', '#607D8B', '#FF5722',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建习惯'),
        actions: [
          TextButton(
            onPressed: _selectedTemplate == null ? null : () => _selectedTemplate = null,
            child: const Text('清空'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTemplateSelector(),
            const SizedBox(height: 24),
            _buildNameField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildIconSelector(),
            const SizedBox(height: 16),
            _buildColorSelector(),
            const SizedBox(height: 24),
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateSelector() {
    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        if (provider.templates.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '快速选择模板',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.templates.length,
                itemBuilder: (context, index) {
                  final template = provider.templates[index];
                  return _TemplateChip(
                    template: template,
                    isSelected: _selectedTemplate?.id == template.id,
                    onTap: () => _selectTemplate(template),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: '习惯名称',
        border: OutlineInputBorder(),
        hintText: '例如：晨跑、阅读、喝水',
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: '描述（可选）',
        border: OutlineInputBorder(),
        hintText: '简单描述这个习惯',
      ),
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择图标',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _icons.map((icon) {
            return _IconChoice(
              icon: icon,
              isSelected: _selectedIcon == icon,
              onTap: () => setState(() => _selectedIcon = icon),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择颜色',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _colors.map((color) {
            return _ColorChoice(
              color: color,
              isSelected: _selectedColor == color,
              onTap: () => setState(() => _selectedColor = color),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _nameController.text.isEmpty ? null : _createHabit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
        ),
        child: const Text('创建习惯', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  void _selectTemplate(HabitTemplate template) {
    setState(() {
      _selectedTemplate = template;
      _nameController.text = template.name;
      _selectedIcon = template.icon;
    });
  }

  Future<void> _createHabit() async {
    final provider = context.read<HabitProvider>();
    final habit = await provider.createHabit({
      'name': _nameController.text,
      'icon': _selectedIcon,
      'description': _descriptionController.text,
      'color': _selectedColor,
    });

    if (habit != null) {
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}

class _TemplateChip extends StatelessWidget {
  final HabitTemplate template;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateChip({
    super.key,
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          template.name,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _IconChoice extends StatelessWidget {
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _IconChoice({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconData(icon);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
              : null,
        ),
        child: Icon(iconData, color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600]),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'directions_run': Icons.directions_run,
      'bedtime': Icons.bedtime,
      'wb_sunny': Icons.wb_sunny,
      'menu_book': Icons.menu_book,
      'water_drop': Icons.water_drop,
      'spa': Icons.spa,
      'fitness_center': Icons.fitness_center,
      'school': Icons.school,
      'check_circle': Icons.check_circle,
    };
    return iconMap[iconName] ?? Icons.check_circle;
  }
}

class _ColorChoice extends StatelessWidget {
  final String color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorChoice({
    super.key,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorValue = Color(int.parse(color.replaceAll('#', '0xFF')));
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colorValue,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Colors.black, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/habit/habit_create_page.dart
git commit -m "feat(habit): add HabitCreatePage"
```

---

### Task 24: Create HabitStatsPage

**Files:**
- Create: `app/lib/tools/habit/habit_stats_page.dart`

- [ ] **Step 1: Write HabitStatsPage class**

```dart
import 'package:flutter/material.dart';
import 'models/habit.dart';
import 'models/habit_stats.dart';
import 'providers/habit_provider.dart';
import '../../../core/utils/logger.dart';

class HabitStatsPage extends StatefulWidget {
  final Habit habit;

  const HabitStatsPage({
    super.key,
    required this.habit,
  });

  @override
  State<HabitStatsPage> createState() => _HabitStatsPageState();
}

class _HabitStatsPageState extends State<HabitStatsPage> {
  HabitStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats != null
              ? _buildStatsContent()
              : const Center(child: Text('加载失败')),
    );
  }

  Widget _buildStatsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 24),
          _buildCalendarView(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('总打卡天数', '${_stats!.totalDays} 天')),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('当前连续', '${_stats!.currentStreak} 天')),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatCard('最长连续', '${_stats!.longestStreak} 天'),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 1, 1);
    final endDate = DateTime(now.year, now.month + 1, 0);

    final checkedDates = _stats!.records.map((r) => r.date).toSet();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '打卡记录',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _buildCalendarDays(startDate, endDate, checkedDates),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCalendarDays(DateTime start, DateTime end, Set<DateTime> checkedDates) {
    final days = <Widget>[];
    final now = DateTime.now();

    for (var date = start; date.isBefore(end) || date.isAtSameMomentAs(end); date = date.add(const Duration(days: 1)) {
      final isChecked = checkedDates.any((d) => d.isAtSameMomentAs(date));
      final isToday = date.isAtSameMomentAs(now);
      final isFuture = date.isAfter(now);

      days.add(
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isChecked
                ? Theme.of(context).primaryColor
                : isToday
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: isToday
                ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: isChecked
                    ? Colors.white
                    : isToday
                        ? Theme.of(context).primaryColor
                        : isFuture
                            ? Colors.grey[300]
                            : Colors.grey[600],
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }

    return days;
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month - 1, 1);
      final end = DateTime(now.year, now.month + 1, 0);

      final provider = context.read<HabitProvider>();
      final stats = await provider.getStats(widget.habit.id, start, end);

      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.e('Failed to load stats', e);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除习惯'),
        content: Text('确定要删除"${widget.habit.name}"吗？所有打卡记录也将被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteHabit();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteHabit() async {
    final provider = context.read<HabitProvider>();
    await provider.deleteHabit(widget.habit.id);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/habit/habit_stats_page.dart
git commit -m "feat(habit): add HabitStatsPage"
```

---

### Task 25: Create HabitTool (tool registration)

**Files:**
- Create: `app/lib/tools/habit/habit_tool.dart`

- [ ] **Step 1: Write HabitTool class**

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'habit_page.dart';

class HabitTool implements ToolModule {
  @override
  String get id => 'habit';

  @override
  String get name => '习惯打卡';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.check_circle;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 2;

  @override
  Widget buildPage(BuildContext(BuildContext) {
    return const HabitPage();
  }

  @override
  ToolSettings? get settings => null;

  @override
  Future<void> onInit() async {}

  @override
  Future<void> onDispose() async {}

  @override
  void onEnter() {}

  @override
  void onExit() {}
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/habit/habit_tool.dart
git commit -m "feat(habit): add HabitTool registration"
```

---

### Task 26: Register HabitTool in ToolRegistry

**Files:**
- Modify: `app/lib/core/services/tool_registry.dart`

- [ ] **Step 1: Add HabitTool import and registration**

Find the ToolRegistry class and add:

```dart
import '../tools/habit/habit_tool.dart';
```

Then in the `getAll()` method, add:
```dart
HabitTool(),
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/core/services/tool_registry.dart
git commit -m "feat(habit): register HabitTool in ToolRegistry"
```

---

### Task 27: Add http dependency to pubspec.yaml

**Files:**
- Modify: `app/pubspec.yaml`

- [ ] **Step 1: Add http dependency**

Add under dependencies:
```yaml
  http: ^1.1.0
```

- [ ] **Step 2: Run flutter pub get**

```bash
cd app && flutter pub get
```

Expected: http package downloaded successfully

- [ ] **Step 3: Commit**

```bash
git add app/pubspec.yaml app/pubspec.lock
git commit -m "feat(habit): add http dependency"
```
