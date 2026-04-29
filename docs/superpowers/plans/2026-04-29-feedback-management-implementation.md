# 反馈管理功能实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox syntax for tracking.

**Goal:** 实现完整的反馈管理功能，包括APP端提交反馈、Admin端查看和管理反馈、AdminWeb前端界面

**Architecture:**
- grid-app: 实现APP端反馈API（POST /api/feedback）
- grid-admin: 实现Admin端反馈管理API（分页列表、详情、标记已读）
- admin: 实现AdminWeb前端界面（列表页、详情抽屉、菜单配置）

**Tech Stack:** Spring Boot 2.7, JPA, Next.js 14, TypeScript

---

## 任务1: 创建数据库SQL脚本

**Files:**
- Create: `backend/sql/V1__create_feedback_table.sql`

- [ ] **Step 1: 创建SQL脚本**

```sql
-- 反馈表
CREATE TABLE IF NOT EXISTS feedback (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    type VARCHAR(20) NOT NULL COMMENT '反馈类型：SUGGESTION-建议，ISSUE-问题',
    description VARCHAR(500) NOT NULL COMMENT '反馈描述',
    screenshots TEXT NULL COMMENT '截图URL列表(JSON格式)',
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '状态：PENDING-待处理，READ-已读',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_user_id (user_id),
    INDEX idx_type (type),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='反馈表';
```

- [ ] **Step 2: 提交git**

```bash
cd /home/nano/little-grid
git add backend/sql/V1__create_feedback_table.sql
git commit -m "feat: 创建feedback表SQL脚本"
```

---

## 任务2: 创建grid-app枚举类

**Files:**
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/feedback/enums/FeedbackType.java`
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/feedback/enums/FeedbackStatus.java`

- [ ] **Step 1: 创建FeedbackType枚举**

```java
package com.naon.grid.modules.app.feedback.enums;

public enum FeedbackType {
    SUGGESTION("功能建议"),
    ISSUE("问题反馈");

    private final String description;

    FeedbackType(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}
```

- [ ] **Step 2: 创建FeedbackStatus枚举**

```java
package com.naon.grid.modules.app.feedback.enums;

public enum FeedbackStatus {
    PENDING("待处理"),
    READ("已读");

    private final String description;

    FeedbackStatus(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}
```

- [ ] **Step 3: 提交git**

```bash
git add backend/grid-app/src/main/java/com/naon/grid/modules/app/feedback/enums/
git commit -m "feat: 创建反馈相关枚举类"
```

---

## 任务3: 创建grid-app Feedback实体类

**Files:**
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/feedback/domain/Feedback.java`

- [ ] **Step 1: 创建Feedback实体**

```java
package com.naon.grid.modules.app.feedback.domain;

import com.naon.grid.modules.app.feedback.enums.FeedbackStatus;
import com.naon.grid.modules.app.feedback.enums.FeedbackType;
import lombok.Getter;
import lombok.Setter;

import javax.persistence.*;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import java.io.Serializable;
import java.util.Date;

@Entity
@Getter
@Setter
@Table(name = "feedback")
public class Feedback implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @Column(name = "user_id", nullable = false)
    private Long userId;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false, length = 20)
    private FeedbackType type;

    @NotBlank(message = "描述不能为空")
    @Size(max = 500, message = "描述最多500字")
    @Column(name = "description", nullable = false, length = 500)
    private String description;

    @Column(name = "screenshots", columnDefinition = "TEXT")
    private String screenshots;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private FeedbackStatus status = FeedbackStatus.PENDING;

    @Column(name = "created_at")
    private Date createdAt;

    @Column(name = "updated_at")
    private Date updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = new Date();
        updatedAt = new Date();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = new Date();
    }
}
```

- [ ] **Step 2: 提交git**

```bash
git add backend/grid-app/src/main/java/com/naon/grid/modules/app/feedback/domain/Feedback.java
git commit -m "feat: 创建Feedback实体类"
```

---

## 任务4: 创建grid-app Repository

**Files:**
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/feedback/repository/FeedbackRepository.java`

- [ ] **Step 1: 创建FeedbackRepository**

```java
package com.naon.grid.modules.app.feedback.repository;

import com.naon.grid.modules.app.feedback.domain.Feedback;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface FeedbackRepository extends JpaRepository<Feedback, Long> {

    @Query("SELECT f FROM Feedback f WHERE " +
           "(:type IS NULL OR f.type = :type) AND " +
           "(:status IS NULL OR f.status = :status) " +
           "ORDER BY f.createdAt DESC")
    Page<Feedback> findByTypeAndStatus(
            @Param("type") String type,
            @Param("status") String status,
            Pageable pageable);
}
```

- [ ] **Step 2: 提交git**

```bash
git add backend/grid-app/src/main/java/com/naon/grid/modules/app/feedback/repository/FeedbackRepository.java
git commit -m "feat: 创建FeedbackRepository"
```

---

## 任务5: 创建grid-app DTO类

**Files:**
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/feedback/service/dto/SubmitFeedbackDTO.java`
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/feedback/service/dto/FeedbackDTO.java`

- [ ] **Step 1: 创建SubmitFeedbackDTO**

```java
package com.naon.grid.modules.app.feedback.service.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import java.util.List;

@Data
public class SubmitFeedbackDTO {

    @NotNull(message = "反馈类型不能为空")
    private String type;

    @NotBlank(message = "描述不能为空")
    @Size(max = 500, message = "描述最多500字")
    private String description;

    private List<String> screenshots;
}
```

- [ ] **Step 2: 创建FeedbackDTO**

```java
package com.naon.grid.modules.app.feedback.service.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FeedbackDTO {
    private Long id;
    private Long userId;
    private String type;
    private String description;
    private String status;
    private Long createdAt;
}
```

- [ ] **Step 3: 提交git**

```bash
git add backend/grid-app/src/main/java/com/naon/grid/modules/app/feedback/service/dto/
git commit -m "feat: 创建反馈相关DTO类"
```

---

## 任务6: 创建grid-app Service接口和实现

**Files:**
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/feedback/service/FeedbackService.java`
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/feedback/service/impl/FeedbackServiceImpl.java`

- [ ] **Step 1: 创建FeedbackService接口**

```java
package com.naon.grid.modules.app.feedback.service;

import com.naon.grid.modules.app.feedback.service.dto.FeedbackDTO;
import com.naon.grid.modules.app.feedback.service.dto.SubmitFeedbackDTO;

public interface FeedbackService {

    FeedbackDTO submitFeedback(Long userId, SubmitFeedbackDTO dto);
}
```

- [ ] **Step 2: 创建FeedbackServiceImpl实现**

```java
package com.naon.grid.modules.app.feedback.service.impl;

import com.alibaba.fastjson2.JSON;
import com.naon.grid.modules.app.feedback.domain.Feedback;
import com.naon.grid.modules.app.feedback.enums.FeedbackStatus;
import com.naon.grid.modules.app.feedback.enums.FeedbackType;
import com.naon.grid.modules.app.feedback.repository.FeedbackRepository;
import com.naon.grid.modules.app.feedback.service.FeedbackService;
import com.naon.grid.modules.app.feedback.service.dto.FeedbackDTO;
import com.naon.grid.modules.app.feedback.service.dto.SubmitFeedbackDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class FeedbackServiceImpl implements FeedbackService {

    private final FeedbackRepository feedbackRepository;

    @Override
    @Transactional
    public FeedbackDTO submitFeedback(Long userId, SubmitFeedbackDTO dto) {
        Feedback feedback = new Feedback();
        feedback.setUserId(userId);
        feedback.setType(FeedbackType.valueOf(dto.getType()));
        feedback.setDescription(dto.getDescription());
        feedback.setStatus(FeedbackStatus.PENDING);

        if (dto.getScreenshots() != null && !dto.getScreenshots().isEmpty()) {
            feedback.setScreenshots(JSON.toJSONString(dto.getScreenshots()));
        }

        feedback = feedbackRepository.save(feedback);
        return toFeedbackDTO(feedback);
    }

    private FeedbackDTO toFeedbackDTO(Feedback feedback) {
        return FeedbackDTO.builder()
                .id(feedback.getId())
                .userId(feedback.getUserId())
                .type(feedback.getType().name())
                .description(feedback.getDescription())
                .status(feedback.getStatus().name())
                .createdAt(feedback.getCreatedAt().getTime())
                .build();
    }
}
```

- [ ] **Step 3: 提交git**

```bash
git add backend/grid-app/src/main/java/com/naon/grid/modules/app/feedback/service/
git commit -m "feat: 创建FeedbackService接口和实现"
```

---

## 任务7: 创建grid-app Controller

**Files:**
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/feedback/rest/FeedbackController.java`

- [ ] **Step 1: 创建FeedbackController**

```java
package com.naon.grid.modules.app.feedback.rest;

import com.naon.grid.config.SecurityProperties;
import com.naon.grid.modules.app.feedback.service.FeedbackService;
import com.naon.grid.modules.app.feedback.service.dto.FeedbackDTO;
import com.naon.grid.modules.app.feedback.service.dto.SubmitFeedbackDTO;
import com.naon.grid.modules.app.security.AppTokenProvider;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/feedback")
@Api(tags = "APP：反馈接口")
public class FeedbackController {

    private final FeedbackService feedbackService;
    private final AppTokenProvider appTokenProvider;
    private final SecurityProperties securityProperties;

    @PostMapping
    @ApiOperation("提交反馈")
    public ResponseEntity<Map<String, Object>> submitFeedback(
            @Validated @RequestBody SubmitFeedbackDTO dto,
            HttpServletRequest request) {
        Long userId = getUserIdFromRequest(request);
        FeedbackDTO feedback = feedbackService.submitFeedback(userId, dto);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "提交成功");
        result.put("data", feedback);
        return ResponseEntity.ok(result);
    }

    private Long getUserIdFromRequest(HttpServletRequest request) {
        String authHeader = request.getHeader(securityProperties.getHeader());
        if (authHeader == null || !authHeader.startsWith(securityProperties.getTokenStartWith())) {
            throw new com.naon.grid.exception.BadRequestException("请先登录");
        }
        String token = authHeader.substring(securityProperties.getTokenStartWith().length());
        if (!appTokenProvider.validateToken(token)) {
            throw new com.naon.grid.exception.BadRequestException("登录状态已过期，请重新登录");
        }
        return appTokenProvider.getUserIdFromToken(token);
    }
}
```

- [ ] **Step 2: 提交git**

```bash
git add backend/grid-app/src/main/java/com/naon/grid/modules/app/feedback/rest/FeedbackController.java
git commit -m "feat: 创建FeedbackController"
```

---

## 任务8: 创建grid-admin DTO类

**Files:**
- Create: `backend/grid-admin/src/main/java/com/naon/grid/admin/dto/AdminFeedbackListDTO.java`
- Create: `backend/grid-admin/src/main/java/com/naon/grid/admin/dto/AdminFeedbackDetailDTO.java`

- [ ] **Step 1: 创建AdminFeedbackListDTO**

```java
package com.naon.grid.admin.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AdminFeedbackListDTO {
    private Long id;
    private Long userId;
    private String userNickname;
    private String type;
    private String description;
    private Integer screenshotCount;
    private String status;
    private Long createdAt;
}
```

- [ ] **Step 2: 创建AdminFeedbackDetailDTO**

```java
package com.naon.grid.admin.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AdminFeedbackDetailDTO {
    private Long id;
    private Long userId;
    private String userNickname;
    private String userAvatar;
    private String type;
    private String description;
    private List<String> screenshots;
    private String status;
    private Long createdAt;
}
```

- [ ] **Step 3: 提交git**

```bash
git add backend/grid-admin/src/main/java/com/naon/grid/admin/dto/AdminFeedback*.java
git commit -m "feat: 创建Admin端反馈DTO类"
```

---

## 任务9: 创建grid-admin Service

**Files:**
- Create: `backend/grid-admin/src/main/java/com/naon/grid/admin/service/FeedbackAdminService.java`

- [ ] **Step 1: 创建FeedbackAdminService**

```java
package com.naon.grid.admin.service;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.TypeReference;
import com.naon.grid.admin.dto.AdminFeedbackDetailDTO;
import com.naon.grid.admin.dto.AdminFeedbackListDTO;
import com.naon.grid.exception.EntityNotFoundException;
import com.naon.grid.modules.app.domain.GridUser;
import com.naon.grid.modules.app.feedback.domain.Feedback;
import com.naon.grid.modules.app.feedback.enums.FeedbackStatus;
import com.naon.grid.modules.app.feedback.repository.FeedbackRepository;
import com.naon.grid.modules.app.repository.GridUserRepository;
import com.naon.grid.utils.PageResult;
import com.naon.grid.utils.PageUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class FeedbackAdminService {

    private final FeedbackRepository feedbackRepository;
    private final GridUserRepository gridUserRepository;

    public PageResult<AdminFeedbackListDTO> getFeedbackList(int page, int size, String type, String status) {
        Pageable pageable = PageRequest.of(page - 1, size);
        Page<Feedback> feedbackPage = feedbackRepository.findByTypeAndStatus(type, status, pageable);

        List<Long> userIds = feedbackPage.getContent().stream()
                .map(Feedback::getUserId)
                .distinct()
                .collect(Collectors.toList());

        Map<Long, GridUser> userMap = userIds.isEmpty() ? Map.of() :
                gridUserRepository.findAllById(userIds).stream()
                        .collect(Collectors.toMap(GridUser::getId, u -> u));

        List<AdminFeedbackListDTO> dtoList = feedbackPage.getContent().stream()
                .map(f -> toListDTO(f, userMap.get(f.getUserId())))
                .collect(Collectors.toList());

        return PageUtil.toPage(dtoList, feedbackPage.getTotalElements());
    }

    public AdminFeedbackDetailDTO getFeedbackDetail(Long id) {
        Feedback feedback = feedbackRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException(Feedback.class, "id", String.valueOf(id)));

        GridUser user = gridUserRepository.findById(feedback.getUserId()).orElse(null);
        return toDetailDTO(feedback, user);
    }

    @Transactional
    public void markAsRead(Long id) {
        Feedback feedback = feedbackRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException(Feedback.class, "id", String.valueOf(id)));
        feedback.setStatus(FeedbackStatus.READ);
        feedbackRepository.save(feedback);
    }

    private AdminFeedbackListDTO toListDTO(Feedback feedback, GridUser user) {
        List<String> screenshots = parseScreenshots(feedback.getScreenshots());
        return AdminFeedbackListDTO.builder()
                .id(feedback.getId())
                .userId(feedback.getUserId())
                .userNickname(user != null ? user.getNickname() : null)
                .type(feedback.getType().name())
                .description(feedback.getDescription())
                .screenshotCount(screenshots.size())
                .status(feedback.getStatus().name())
                .createdAt(feedback.getCreatedAt().getTime())
                .build();
    }

    private AdminFeedbackDetailDTO toDetailDTO(Feedback feedback, GridUser user) {
        return AdminFeedbackDetailDTO.builder()
                .id(feedback.getId())
                .userId(feedback.getUserId())
                .userNickname(user != null ? user.getNickname() : null)
                .userAvatar(user != null ? user.getAvatar() : null)
                .type(feedback.getType().name())
                .description(feedback.getDescription())
                .screenshots(parseScreenshots(feedback.getScreenshots()))
                .status(feedback.getStatus().name())
                .createdAt(feedback.getCreatedAt().getTime())
                .build();
    }

    private List<String> parseScreenshots(String screenshotsJson) {
        if (screenshotsJson == null || screenshotsJson.isEmpty()) {
            return List.of();
        }
        try {
            return JSON.parseObject(screenshotsJson, new TypeReference<List<String>>() {});
        } catch (Exception e) {
            log.warn("Failed to parse screenshots JSON: {}", screenshotsJson);
            return List.of();
        }
    }
}
```

- [ ] **Step 2: 检查GridUserRepository是否存在**

让我先检查一下GridUserRepository是否存在：

```bash
ls -la backend/grid-app/src/main/java/com/naon/grid/modules/app/repository/
```

如果不存在，我们需要创建它：

```java
package com.naon.grid.modules.app.repository;

import com.naon.grid.modules.app.domain.GridUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface GridUserRepository extends JpaRepository<GridUser, Long> {
}
```

- [ ] **Step 3: 提交git**

```bash
git add backend/grid-admin/src/main/java/com/naon/grid/admin/service/FeedbackAdminService.java
# 如果创建了GridUserRepository，也一并添加
git add backend/grid-app/src/main/java/com/naon/grid/modules/app/repository/GridUserRepository.java
git commit -m "feat: 创建FeedbackAdminService"
```

---

## 任务10: 创建grid-admin Controller

**Files:**
- Create: `backend/grid-admin/src/main/java/com/naon/grid/admin/rest/FeedbackAdminController.java`

- [ ] **Step 1: 创建FeedbackAdminController**

```java
package com.naon.grid.admin.rest;

import com.naon.grid.admin.dto.AdminFeedbackDetailDTO;
import com.naon.grid.admin.service.FeedbackAdminService;
import com.naon.grid.utils.PageResult;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/feedback")
@RequiredArgsConstructor
@Api(tags = "Admin：反馈管理")
public class FeedbackAdminController {

    private final FeedbackAdminService feedbackAdminService;

    @GetMapping
    @ApiOperation("获取反馈列表")
    public ResponseEntity<PageResult<AdminFeedbackListDTO>> getFeedbackList(
            @ApiParam("页码，从1开始") @RequestParam(defaultValue = "1") int page,
            @ApiParam("每页数量") @RequestParam(defaultValue = "20") int size,
            @ApiParam("反馈类型过滤") @RequestParam(required = false) String type,
            @ApiParam("状态过滤") @RequestParam(required = false) String status) {
        return ResponseEntity.ok(feedbackAdminService.getFeedbackList(page, size, type, status));
    }

    @GetMapping("/{id}")
    @ApiOperation("获取反馈详情")
    public ResponseEntity<AdminFeedbackDetailDTO> getFeedbackDetail(@PathVariable Long id) {
        return ResponseEntity.ok(feedbackAdminService.getFeedbackDetail(id));
    }

    @PutMapping("/{id}/read")
    @ApiOperation("标记已读")
    public ResponseEntity<Map<String, Object>> markAsRead(@PathVariable Long id) {
        feedbackAdminService.markAsRead(id);
        Map<String, Object> result = new HashMap<>();
        result.put("message", "操作成功");
        return ResponseEntity.ok(result);
    }
}
```

- [ ] **Step 2: 添加AdminFeedbackListDTO的import**

确认`AdminFeedbackListDTO`的import语句正确。

- [ ] **Step 3: 提交git**

```bash
git add backend/grid-admin/src/main/java/com/naon/grid/admin/rest/FeedbackAdminController.java
git commit -m "feat: 创建FeedbackAdminController"
```

---

## 任务11: 创建AdminWeb前端use-feedback钩子

**Files:**
- Create: `admin/app/dashboard/content/feedback/hooks/use-feedback.ts`

- [ ] **Step 1: 创建use-feedback钩子**

```typescript
'use client'

import { useState, useCallback } from 'react'

const API_BASE = '/api/admin/feedback'

function getAuthHeaders(): HeadersInit {
  const token = typeof window !== 'undefined' ? localStorage.getItem('adminToken') : null
  return {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
  }
}

export interface FeedbackListItem {
  id: number
  userId: number
  userNickname: string | null
  type: 'SUGGESTION' | 'ISSUE'
  description: string
  screenshotCount: number
  status: 'PENDING' | 'READ'
  createdAt: number
}

export interface FeedbackDetail {
  id: number
  userId: number
  userNickname: string | null
  userAvatar: string | null
  type: 'SUGGESTION' | 'ISSUE'
  description: string
  screenshots: string[]
  status: 'PENDING' | 'READ'
  createdAt: number
}

export interface PageResult<T> {
  content: T[]
  totalElements: number
  totalPages: number
  size: number
  number: number
}

export function useFeedback() {
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const request = useCallback(async <T>(url: string, options?: RequestInit): Promise<T> => {
    setLoading(true)
    setError(null)
    try {
      const res = await fetch(url, {
        ...options,
        headers: { ...getAuthHeaders(), ...options?.headers },
      })
      const data = await res.json()
      if (!res.ok) {
        throw new Error(data.message || '请求失败')
      }
      return data as T
    } catch (err: any) {
      setError(err.message)
      throw err
    } finally {
      setLoading(false)
    }
  }, [])

  const fetchFeedbackList = useCallback((page: number, size: number, type?: string, status?: string) => {
    const params = new URLSearchParams({ page: String(page), size: String(size) })
    if (type) params.set('type', type)
    if (status) params.set('status', status)
    return request<PageResult<FeedbackListItem>>(`${API_BASE}?${params}`)
  }, [request])

  const fetchFeedbackDetail = useCallback((id: number) => {
    return request<FeedbackDetail>(`${API_BASE}/${id}`)
  }, [request])

  const markAsRead = useCallback((id: number) => {
    return request<{ message: string }>(`${API_BASE}/${id}/read`, {
      method: 'PUT',
    })
  }, [request])

  return { loading, error, fetchFeedbackList, fetchFeedbackDetail, markAsRead }
}
```

- [ ] **Step 2: 提交git**

```bash
git add admin/app/dashboard/content/feedback/hooks/use-feedback.ts
git commit -m "feat: 创建use-feedback钩子"
```

---

## 任务12: 创建AdminWeb前端FeedbackList组件

**Files:**
- Create: `admin/app/dashboard/content/feedback/components/feedback-list.tsx`

- [ ] **Step 1: 创建feedback-list组件**

```typescript
'use client'

import { FeedbackListItem } from '../hooks/use-feedback'

interface FeedbackListProps {
  items: FeedbackListItem[]
  onSelect: (item: FeedbackListItem) => void
  selectedId: number | null
}

const typeLabels: Record<string, string> = {
  SUGGESTION: '功能建议',
  ISSUE: '问题反馈',
}

const statusLabels: Record<string, string> = {
  PENDING: '待处理',
  READ: '已读',
}

const statusColors: Record<string, string> = {
  PENDING: 'var(--warning)',
  READ: 'var(--on-surface-variant)',
}

export function FeedbackList({ items, onSelect, selectedId }: FeedbackListProps) {
  return (
    <div className="overflow-x-auto">
      <table className="w-full">
        <thead>
          <tr style={{ borderBottom: '1px solid var(--outline-variant)' }}>
            <th className="text-left p-3 text-sm font-medium text-[var(--on-surface-variant)]">ID</th>
            <th className="text-left p-3 text-sm font-medium text-[var(--on-surface-variant)]">用户</th>
            <th className="text-left p-3 text-sm font-medium text-[var(--on-surface-variant)]">类型</th>
            <th className="text-left p-3 text-sm font-medium text-[var(--on-surface-variant)]">状态</th>
            <th className="text-left p-3 text-sm font-medium text-[var(--on-surface-variant)]">描述</th>
            <th className="text-left p-3 text-sm font-medium text-[var(--on-surface-variant)]">提交时间</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item) => (
            <tr
              key={item.id}
              onClick={() => onSelect(item)}
              className={`cursor-pointer transition-colors hover:bg-[var(--surface-variant)] ${
                selectedId === item.id ? 'bg-[var(--surface-variant)]' : ''
              }`}
              style={{ borderBottom: '1px solid var(--outline-variant)' }}
            >
              <td className="p-3 text-sm text-[var(--on-surface)]">{item.id}</td>
              <td className="p-3 text-sm text-[var(--on-surface)]">
                {item.userNickname || `用户${item.userId}`}
              </td>
              <td className="p-3 text-sm text-[var(--on-surface)]">
                {typeLabels[item.type] || item.type}
              </td>
              <td className="p-3 text-sm">
                <span style={{ color: statusColors[item.status] }}>
                  {statusLabels[item.status] || item.status}
                </span>
              </td>
              <td className="p-3 text-sm text-[var(--on-surface)] max-w-xs truncate">
                {item.description}
              </td>
              <td className="p-3 text-sm text-[var(--on-surface-variant)]">
                {new Date(item.createdAt).toLocaleString('zh-CN')}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
```

- [ ] **Step 2: 提交git**

```bash
git add admin/app/dashboard/content/feedback/components/feedback-list.tsx
git commit -m "feat: 创建FeedbackList组件"
```

---

## 任务13: 创建AdminWeb前端FeedbackDetail组件

**Files:**
- Create: `admin/app/dashboard/content/feedback/components/feedback-detail.tsx`

- [ ] **Step 1: 创建feedback-detail组件**

```typescript
'use client'

import { FeedbackDetail as FeedbackDetailType } from '../hooks/use-feedback'

interface FeedbackDetailProps {
  detail: FeedbackDetailType
  onMarkAsRead: () => void
  onClose: () => void
  isMarkingAsRead: boolean
}

const typeLabels: Record<string, string> = {
  SUGGESTION: '功能建议',
  ISSUE: '问题反馈',
}

const statusLabels: Record<string, string> = {
  PENDING: '待处理',
  READ: '已读',
}

const statusColors: Record<string, string> = {
  PENDING: 'var(--warning)',
  READ: 'var(--on-surface-variant)',
}

export function FeedbackDetail({ detail, onMarkAsRead, onClose, isMarkingAsRead }: FeedbackDetailProps) {
  return (
    <div className="fixed inset-0 z-50 flex">
      <div
        className="absolute inset-0 bg-black/50"
        onClick={onClose}
      />
      <div className="relative ml-auto w-full max-w-lg bg-[var(--surface)] h-full shadow-xl overflow-y-auto">
        <div className="p-6">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-lg font-medium text-[var(--on-surface)]">反馈详情</h2>
            <button
              onClick={onClose}
              className="p-2 hover:bg-[var(--surface-variant)] rounded-full transition-colors"
            >
              <span className="material-icons-round text-[var(--on-surface-variant)]">close</span>
            </button>
          </div>

          <div className="space-y-6">
            <div className="flex items-center gap-3">
              {detail.userAvatar ? (
                <img
                  src={detail.userAvatar}
                  alt="avatar"
                  className="w-12 h-12 rounded-full object-cover"
                />
              ) : (
                <div className="w-12 h-12 rounded-full bg-[var(--surface-variant)] flex items-center justify-center">
                  <span className="material-icons-round text-[var(--on-surface-variant)]">person</span>
                </div>
              )}
              <div>
                <p className="font-medium text-[var(--on-surface)]">
                  {detail.userNickname || `用户${detail.userId}`}
                </p>
                <p className="text-sm text-[var(--on-surface-variant)]">
                  用户ID: {detail.userId}
                </p>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-sm text-[var(--on-surface-variant)] mb-1">类型</p>
                <p className="text-[var(--on-surface)]">{typeLabels[detail.type] || detail.type}</p>
              </div>
              <div>
                <p className="text-sm text-[var(--on-surface-variant)] mb-1">状态</p>
                <span style={{ color: statusColors[detail.status] }}>
                  {statusLabels[detail.status] || detail.status}
                </span>
              </div>
            </div>

            <div>
              <p className="text-sm text-[var(--on-surface-variant)] mb-2">描述</p>
              <p className="text-[var(--on-surface)] whitespace-pre-wrap">{detail.description}</p>
            </div>

            {detail.screenshots.length > 0 && (
              <div>
                <p className="text-sm text-[var(--on-surface-variant)] mb-2">
                  截图 ({detail.screenshots.length})
                </p>
                <div className="grid grid-cols-3 gap-2">
                  {detail.screenshots.map((url, index) => (
                    <a
                      key={index}
                      href={url}
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      <img
                        src={url}
                        alt={`截图${index + 1}`}
                        className="w-full aspect-square object-cover rounded-lg border border-[var(--outline-variant)]"
                      />
                    </a>
                  ))}
                </div>
              </div>
            )}

            <div>
              <p className="text-sm text-[var(--on-surface-variant)] mb-1">提交时间</p>
              <p className="text-[var(--on-surface)]">
                {new Date(detail.createdAt).toLocaleString('zh-CN')}
              </p>
            </div>

            {detail.status === 'PENDING' && (
              <button
                onClick={onMarkAsRead}
                disabled={isMarkingAsRead}
                className="w-full py-3 rounded-lg font-medium text-white transition-colors disabled:opacity-50"
                style={{ backgroundColor: 'var(--primary)' }}
              >
                {isMarkingAsRead ? '处理中...' : '标记已读'}
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
```

- [ ] **Step 2: 提交git**

```bash
git add admin/app/dashboard/content/feedback/components/feedback-detail.tsx
git commit -m "feat: 创建FeedbackDetail组件"
```

---

## 任务14: 创建AdminWeb前端主页面

**Files:**
- Create: `admin/app/dashboard/content/feedback/page.tsx`

- [ ] **Step 1: 创建主页面**

```typescript
'use client'

import { useState, useEffect, useCallback } from 'react'
import { useFeedback, FeedbackListItem, FeedbackDetail as FeedbackDetailType } from './hooks/use-feedback'
import { FeedbackList } from './components/feedback-list'
import { FeedbackDetail } from './components/feedback-detail'

export default function FeedbackPage() {
  const { fetchFeedbackList, fetchFeedbackDetail, markAsRead, loading } = useFeedback()
  const [items, setItems] = useState<FeedbackListItem[]>([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [size] = useState(20)
  const [typeFilter, setTypeFilter] = useState<string>('')
  const [statusFilter, setStatusFilter] = useState<string>('')
  const [selectedItem, setSelectedItem] = useState<FeedbackListItem | null>(null)
  const [detail, setDetail] = useState<FeedbackDetailType | null>(null)
  const [isMarkingAsRead, setIsMarkingAsRead] = useState(false)

  const loadList = useCallback(() => {
    fetchFeedbackList(page, size, typeFilter || undefined, statusFilter || undefined)
      .then((result) => {
        setItems(result.content)
        setTotal(result.totalElements)
      })
      .catch(() => {})
  }, [page, size, typeFilter, statusFilter, fetchFeedbackList])

  useEffect(() => {
    loadList()
  }, [loadList])

  const handleSelect = useCallback((item: FeedbackListItem) => {
    setSelectedItem(item)
    fetchFeedbackDetail(item.id)
      .then(setDetail)
      .catch(() => {})
  }, [fetchFeedbackDetail])

  const handleMarkAsRead = useCallback(async () => {
    if (!selectedItem) return
    setIsMarkingAsRead(true)
    try {
      await markAsRead(selectedItem.id)
      await loadList()
      if (detail) {
        setDetail({ ...detail, status: 'READ' })
      }
    } finally {
      setIsMarkingAsRead(false)
    }
  }, [selectedItem, detail, markAsRead, loadList])

  const handleCloseDetail = useCallback(() => {
    setSelectedItem(null)
    setDetail(null)
  }, [])

  const totalPages = Math.ceil(total / size)

  return (
    <div className="h-full flex flex-col -m-6">
      <div className="p-6 border-b border-[var(--outline-variant)]">
        <div className="flex items-center justify-between mb-4">
          <h1 className="text-xl font-medium text-[var(--on-surface)]">反馈管理</h1>
          <button
            onClick={loadList}
            className="flex items-center gap-2 px-4 py-2 text-sm rounded-lg transition-colors hover:bg-[var(--surface-variant)]"
          >
            <span className="material-icons-round text-[var(--on-surface-variant)]" style={{ fontSize: 18 }}>
              refresh
            </span>
            刷新
          </button>
        </div>

        <div className="flex items-center gap-4">
          <select
            value={typeFilter}
            onChange={(e) => { setTypeFilter(e.target.value); setPage(1) }}
            className="px-3 py-2 rounded-lg text-sm border border-[var(--outline)] bg-[var(--surface)] text-[var(--on-surface)]"
          >
            <option value="">全部类型</option>
            <option value="SUGGESTION">功能建议</option>
            <option value="ISSUE">问题反馈</option>
          </select>

          <select
            value={statusFilter}
            onChange={(e) => { setStatusFilter(e.target.value); setPage(1) }}
            className="px-3 py-2 rounded-lg text-sm border border-[var(--outline)] bg-[var(--surface)] text-[var(--on-surface)]"
          >
            <option value="">全部状态</option>
            <option value="PENDING">待处理</option>
            <option value="READ">已读</option>
          </select>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-6">
        {loading && !items.length ? (
          <div className="flex items-center justify-center h-full">
            <p className="text-[var(--on-surface-variant)]">加载中...</p>
          </div>
        ) : (
          <>
            <FeedbackList
              items={items}
              onSelect={handleSelect}
              selectedId={selectedItem?.id || null}
            />

            {totalPages > 1 && (
              <div className="flex items-center justify-center gap-2 mt-6">
                <button
                  onClick={() => setPage(Math.max(1, page - 1))}
                  disabled={page === 1}
                  className="p-2 rounded-lg hover:bg-[var(--surface-variant)] disabled:opacity-50"
                >
                  <span className="material-icons-round">chevron_left</span>
                </button>

                {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
                  let pageNum = i + 1
                  if (totalPages > 5) {
                    if (page <= 3) {
                      pageNum = i + 1
                    } else if (page >= totalPages - 2) {
                      pageNum = totalPages - 4 + i
                    } else {
                      pageNum = page - 2 + i
                    }
                  }
                  return (
                    <button
                      key={pageNum}
                      onClick={() => setPage(pageNum)}
                      className={`w-10 h-10 rounded-lg text-sm transition-colors ${
                        page === pageNum
                          ? 'text-white'
                          : 'hover:bg-[var(--surface-variant)] text-[var(--on-surface)]'
                      }`}
                      style={page === pageNum ? { backgroundColor: 'var(--primary)' } : {}}
                    >
                      {pageNum}
                    </button>
                  )
                })}

                <button
                  onClick={() => setPage(Math.min(totalPages, page + 1))}
                  disabled={page === totalPages}
                  className="p-2 rounded-lg hover:bg-[var(--surface-variant)] disabled:opacity-50"
                >
                  <span className="material-icons-round">chevron_right</span>
                </button>
              </div>
            )}
          </>
        )}
      </div>

      {selectedItem && detail && (
        <FeedbackDetail
          detail={detail}
          onMarkAsRead={handleMarkAsRead}
          onClose={handleCloseDetail}
          isMarkingAsRead={isMarkingAsRead}
        />
      )}
    </div>
  )
}
```

- [ ] **Step 2: 提交git**

```bash
git add admin/app/dashboard/content/feedback/page.tsx
git commit -m "feat: 创建反馈管理主页面"
```

---

## 任务15: 更新AdminWeb菜单配置

**Files:**
- Modify: `admin/lib/menu-config.ts`

- [ ] **Step 1: 更新menu-config.ts**

找到内容管理的children部分，添加反馈管理菜单项：

```typescript
export const menuItems: MenuItem[] = [
  // ... 其他菜单项
  {
    label: '内容管理',
    icon: 'article',
    children: [
      { label: '树洞审核', href: '/dashboard/content/treehole' },
      { label: '反馈管理', href: '/dashboard/content/feedback' },
      { label: '举报处理', href: '/dashboard/content/reports' },
    ],
  },
  // ... 其他菜单项
]
```

完整更新后的文件：

```typescript
export interface MenuItem {
  label: string
  icon: string
  href?: string
  children?: { label: string; href: string }[]
}

export const menuItems: MenuItem[] = [
  { label: '首页', icon: 'dashboard', href: '/dashboard' },
  {
    label: '用户管理',
    icon: 'people',
    children: [
      { label: 'APP 用户', href: '/dashboard/users/app' },
      { label: '管理员', href: '/dashboard/users/admin' },
    ],
  },
  {
    label: '内容管理',
    icon: 'article',
    children: [
      { label: '树洞审核', href: '/dashboard/content/treehole' },
      { label: '反馈管理', href: '/dashboard/content/feedback' },
      { label: '举报处理', href: '/dashboard/content/reports' },
    ],
  },
  {
    label: '支付管理',
    icon: 'payment',
    children: [
      { label: '交易记录', href: '/dashboard/payments/transactions' },
      { label: '支付宝配置', href: '/dashboard/payments/alipay' },
    ],
  },
  {
    label: '运维',
    icon: 'monitor_heart',
    children: [
      { label: '监控', href: '/dashboard/ops/monitor' },
      { label: '日志', href: '/dashboard/ops/logs' },
    ],
  },
  {
    label: '工具',
    icon: 'build',
    children: [
      { label: '文件上传', href: '/dashboard/tools/upload' },
      { label: '数据库管理', href: '/dashboard/tools/database' },
      { label: '存储管理', href: '/dashboard/tools/storage' },
      { label: '缓存管理', href: '/dashboard/tools/cache' },
    ],
  },
  { label: '系统设置', icon: 'tune', href: '/dashboard/settings' },
  { label: 'API 文档', icon: 'api', href: '/dashboard/api-docs' },
]
```

- [ ] **Step 2: 提交git**

```bash
git add admin/lib/menu-config.ts
git commit -m "feat: 添加反馈管理菜单"
```

---

## 计划完成

所有任务已创建完成！现在可以开始实施。

### 总结

已创建的完整实现计划包括：
1. 数据库SQL脚本
2. grid-app后端完整实现（枚举、实体、Repository、Service、Controller）
3. grid-admin后端完整实现（DTO、Service、Controller）
4. admin前端完整实现（钩子、列表组件、详情组件、主页面、菜单）

每个任务都是独立可测试的单元，并有对应的git提交步骤。

**执行方式选择：**
- **选项A（推荐）:** 使用 superpowers:subagent-driven-development 逐个任务执行
- **选项B:** 使用 superpowers:executing-plans 批量执行
