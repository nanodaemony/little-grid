# 足迹地图功能实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-step.

**Goal:** 实现足迹地图功能，让登录用户可以在地图上标记自己去过的城市，支持点击地图选点和搜索城市两种方式，并在地图上高亮显示已标记的城市，同时提供时间线列表按访问日期倒序排列。

**Architecture:** 后端使用 Spring Boot + JPA，采用项目现有的分层架构（Controller -> Service -> Repository），数据通过 MapStruct 转换。前端使用 Flutter + Provider 状态管理，集成高德地图 SDK。

**Tech Stack:** Spring Boot 3.2.5, JPA, MapStruct, Flutter, AMap SDK

---

## Phase 1: 后端实现

### Task 1: 创建 Footprint 实体类

**Files:**
- Create: `backend/eladmin-system/src/main/java/me/zhengjie/modules/footprint/domain/Footprint.java`

- [ ] **Step 1: 创建 Footprint 实体类文件**

```java
/*
 *  Copyright 2019-2025 Zheng Jie
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package com.littlegrid.modules.footprint.domain;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;
import lombok.Setter;
import com.littlegrid.base.BaseEntity;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.io.Serializable;

/**
 * @author System Generated
 * @date 2026-04-01
 */
@Entity
@Getter
@Setter
@Table(name = "footprint")
public class Footprint extends BaseEntity implements Serializable {

    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Schema(description = "用户ID")
    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Schema(description = "城市名称，如'上海市'")
    @NotBlank
    @Column(name = "city_name", length = 100, nullable = false)
    private String cityName;

    @Schema(description = "省份名称，如'上海'")
    @Column(name = "province_name", length = 50)
    private String provinceName;

    @Schema(description = "纬度")
    @NotNull
    @Column(name = "latitude", precision = 10, scale = 7, nullable = false)
    private Double latitude;

    @Schema(description = "经度")
    @NotNull
    @Column(name = "longitude", precision = 10, scale = 7, nullable = false)
    private Double longitude;

    @Schema(description = "访问日期")
    @NotNull
    @Column(name = "visit_date", nullable = false)
    private LocalDate visitDate;
}
```

- [ ] **Step 2: Git commit**

```bash
git add backend/eladmin-system/src/main/java/me/zhengjie/modules/footprint/domain/Footprint.java
git commit -m "feat(footprint): add Footprint entity class"
```

---

### Task 2: 创建 FootprintRepository

**Files:**
- Create: `backend/eladmin-system/src/main/java/me/zhengjie/modules/footprint/repository/FootprintRepository.java`

- [ ] **Step 1: 创建 Repository 接口**

```java
/*
 *   Copyright 2019-2025 Zheng Jie
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package com.littlegrid.modules.footprint.repository;

import com.littlegrid.modules.footprint.domain.Footprint;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

/**
 * @author System Generated
 * @date 2026-04-01
 */
public interface FootprintRepository extends JpaRepository<Footprint, Long>, JpaSpecificationExecutor<Footprint> {

    /**
     * 根据用户ID查询所有足迹
     * @param userId 用户ID
     * @return 足迹列表
     */
    java.util.List<Footprint> findByUserId(Long userId);
}
```

- [ ] **Step 2: Git commit**

```bash
git add backend/eladmin-system/src/main/java/me/zhengjie/modules/footprint/repository/FootprintRepository.java
git commit -m "feat(footprint): add FootprintRepository"
```

---

### Task 3: 创建 DTO 类

**Files:**
- Create: `backend/eladmin-system/src/main/java/me/zhengjie/modules/footprint/service/dto/FootprintDTO.java`
- Create: `backend/eladmin-system/src/main/java/me/zhengjie/modules/footprint/service/dto/FootprintCreateDTO.java`
- Create: `backend/eladmin-system/src/main/java/me/zhengjie/modules/footprint/service/dto/FootprintUpdateDTO.java`

- [ ] **Step 1: 创建 FootprintDTO**

```java
/*
 *  Copyright 2019-2025 Zheng Jie
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package com.littlegrid.modules.footprint.service.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;
import lombok.Setter;
import com.littlegrid.base.BaseDTO;
import java.io.Serializable;

/**
 * @author System Generated
 * @date 2026-04-01
 */
@Getter
@Setter
public class FootprintDTO extends BaseDTO implements Serializable {

    @Schema(description = "ID")
    private Long id;

    @Schema(description = "城市名称")
    private String cityName;

    @Schema(description = "省份名称")
    private String provinceName;

    @Schema(description = "纬度")
    private Double latitude;

    @Schema(description = "经度")
    private Double longitude;

    @Schema(description = "访问日期 (ISO 8601 格式)")
    private String visitDate;
}
```

- [ ] **Step 2: 创建 FootprintCreateDTO**

```java
/*
 *  Copyright 2019-2025 Zheng Jie
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package com.littlegrid.modules.footprint.service.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;
import java.io.Serializable;

/**
 * @author System Generated
 * @date 2026-04-01
 */
@Getter
@Setter
public class FootprintCreateDTO implements Serializable {

    @NotBlank(message = "城市名称不能为空")
    @Schema(description = "城市名称")
    private String cityName;

    @NotBlank(message = "省份名称不能为空")
    @Schema(description = "省份名称")
    private String provinceName;

    @NotNull(message = "经度不能为空")
    @Schema(description = "经度")
    private Double longitude;

    @NotNull(message = "纬度不能为空")
    @Schema(description = "纬度")
    private Double latitude;

    @NotBlank(message = "访问日期不能为空")
    @Schema(description = "访问日期 (ISO 8601 格式: yyyy-MM-dd)")
    private String visitDate;
}
```

- [ ] **Step 3: 创建 FootprintUpdateDTO**

```java
/*
 *  Copyright 2019-2025 Zheng Jie
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package com.littlegrid.modules.footprint.service.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;
import java.io.Serializable;

/**
 * @author System Generated
 * @date 2026-04-01
 */
@Getter
@Setter
public class FootprintUpdateDTO implements Serializable {

    @NotNull(message = "ID不能为空")
    @Schema(description = "足迹ID")
    private Long id;

    @Schema(description = "城市名称")
    private String cityName;

    @Schema(description = "省份名称")
    private String provinceName;

    @Schema(description = "经度")
    private Double longitude;

    @Schema(description = "纬度")
    private Double latitude;

    @Schema(description = "访问日期 (ISO 8601 格式: yyyy-MM-dd)")
    private String visitDate;
}
```

- [ ] **Step 4: Git commit**

```bash
git add backend/eladmin-system/src/main/java/me/zhengjie/modules/footprint/service/dto/
git commit -m "feat(footprint): add DTO classes (FootprintDTO, FootprintCreateDTO, FootprintUpdateDTO)"
```

---

### Task 4: 创建 MapStruct Mapper

**Files:**
- Create: `backend/eladmin-system/src/main/java/me/zhengjie/modules/footprint/service/mapstruct/FootprintMapper.java`

- [ ] **Step 1: 创建 FootprintMapper**

```java
/*
 *  Copyright 2019-2025 Zheng Jie
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package com.littlegrid.modules.footprint.service.mapstruct;

import com.littlegrid.base.BaseMapper;
import com.littlegrid.modules.footprint.domain.Footprint;
import com.littlegrid.modules.footprint.service.dto.FootprintDTO;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.ReportingPolicy;

/**
 * @author System Generated
 * @date 2026-04-01
 */
@Mapper(componentModel = "spring", uses = {}, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface FootprintMapper extends BaseMapper<FootprintDTO, Footprint> {

    @Mapping(source = "visitDate", target = "visitDate", dateFormat = "yyyy-MM-dd")
    Footprint toEntity(FootprintDTO dto);

    @Mapping(source = "visitDate", target = "visitDate", dateFormat = "yyyy-MM-dd")
    FootprintDTO toDto(Footprint entity);
}
```

- [ ] **Step 2: Git commit**

```bash
git add backend/eladmin-system/src/main/java/me/zhengjie/modules/footprint/service/mapstruct/FootprintMapper.java
git commit -m "feat(footprint): add FootprintMapper for entity-DTO conversion"
```

---

### Task 5: 创建 FootprintService 接口

**Files:**
- Create: `backend/eladmin-system/src/main/java/me/zhengjie/modules/footprint/service/FootprintService.java`

- [ ] **Step 1: 创建 Service 接口**

```java
/*
 *  Copyright 2019-2025 Zheng Jie
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package com.littlegrid.modules.footprint.service;

import com.littlegrid.modules.footprint.domain.Footprint;
import com.littlegrid.modules.footprint.service.dto.FootprintDTO;
import com.littlegrid.modules.footprint.service.dto.FootprintCreateDTO;
import com.littlegrid.modules.footprint.service.dto.FootprintUpdateDTO;
import java.util.List;

/**
 * @author System Generated
 * @date 2026-04-01
 */
public interface FootprintService {

    /**
     * 获取当前用户的所有足迹
     * @param userId 用户ID
     * @return 足迹列表
     */
    List<FootprintDTO> findByUserId(Long userId);

    /**
     * 根据ID查询足迹
     * @param id 足迹ID
     * @param userId userId 用户ID（用于权限验证）
     * @return 足迹DTO
     */
    FootprintDTO findById(Long id, Long userId);

    /**
     * 创建足迹
     * @param dto 创建DTO
     * @param userId 用户ID
     * @return 创建的足迹
     */
    Footprint create(FootprintCreateDTO dto, Long userId);

    /**
     * 更新足迹
     * @param dto 更新DTO
     * @param userId 用户ID（用于权限验证）
     */
    void update(FootprintUpdateDTO dto, Long userId);

    /**
     * 删除足迹
     * @param id 足迹ID
     * @param userId 用户ID（用于权限验证）
     */
    void delete(Long id, Long userId);
}
```

- [ ] **Step 2: Git commit**

```bash
git add backend/eladmin-system/src/main/java/me/zhengjie/modules/footprint/service/FootprintService.java
git commit -m "feat(footprint): add FootprintService interface"
```

---

### Task 6: 创建 FootprintServiceImpl

**Files:**
- Create: `backend/eladmin-system/src/main/java/me/zhengjie/modules/footprint/service/impl/FootprintServiceImpl.java`

- [ ] **Step 1: 创建 Service 实现类**

```java
/*
 *  Copyright 2019-2025 Zheng Jie
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package com.littlegrid.modules.footprint.service.impl;

import com.littlegrid.exception.EntityNotFoundException;
import com.littlegrid.modules.footprint.domain.Footprint;
import com.littlegrid.modules.footprint.repository.FootprintRepository;
import com.littlegrid.modules.footprint.service.FootprintService;
import com.littlegrid.modules.footprint.service.dto.FootprintDTO;
import com.littlegrid.modules.footprint.service.dto.FootprintCreateDTO;
import com.littlegrid.modules.footprint.service.dto.FootprintUpdateDTO;
import com.littlegrid.modules.footprint.service.mapstruct.FootprintMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

/**
 * @author System Generated
 * @date 2026-04-01
 */
@Service
@RequiredArgsConstructor
public class FootprintServiceImpl implements FootprintService {

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    private final FootprintRepository repository;
    private final FootprintMapper mapper;

    @Override
    public List<FootprintDTO> findByUserId(Long userId) {
        List<Footprint> footprints = repository.findByUserId(userId);
        return footprints.stream()
                .map(mapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public FootprintDTO findById(Long id, Long userId) {
        Footprint footprint = repository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException(Footprint.class, id));

        // 权限验证：只能查询自己的足迹
        if (!footprint.getUserId().equals(userId)) {
            throw new RuntimeException("无权访问此数据");
        }

        return mapper.toDto(footprint);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Footprint create(FootprintCreateDTO dto, Long userId) {
        Footprint footprint = new Footprint();
        footprint.setUserId(userId);
        footprint.setCityName(dto.getCityName());
        footprint.setProvinceName(dto.getProvinceName());
        footprint.setLongitude(dto.getLongitude());
        footprint.setLatitude(dto.getLatitude());
        footprint.setVisitDate(LocalDate.parse(dto.getVisitDate(), DATE_FORMATTER));

        return repository.save(footprint);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void update(FootprintUpdateDTO dto, Long userId) {
        Footprint footprint = repository.findById(dto.getId())
                .orElseThrow(() -> new EntityNotFoundException(Footprint.class, dto.getId()));

        // 权限验证：只能更新自己的足迹
        if (!footprint.getUserId().equals(userId)) {
            throw new RuntimeException("无权访问此数据");
        }

        if (dto.getCityName() != null) {
            footprint.setCityName(dto.getCityName());
        }
        if (dto.getProvinceName() != null) {
            footprint.setProvinceName(dto.getProvinceName());
        }
        if (dto.getLongitude() != null) {
            footprint.setLongitude(dto.getLongitude());
        }
        if (dto.getLatitude() != null) {
            footprint.setLatitude(dto.getLatitude());
        }
        if (dto.getVisitDate() != null) {
            footprint.setVisitDate(LocalDate.parse(dto.getVisitDate(), DATE_FORMATTER));
        }

        repository.save(footprint);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id, Long userId) {
        Footprint footprint = repository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException(Footprint.class, id));

        // 权限验证：只能删除自己的足迹
        if (!footprint.getUserId().equals(userId)) {
            throw new RuntimeException("无权访问此数据");
        }

        repository.deleteById(id);
    }
}
```

- [ ] **Step 2: Git commit**

```bash
git add backend/eladmin-system/src/main/java/me/zhengjie/modules/footprint/service/impl/FootprintServiceImpl.java
git commit -m "feat(footprint): add FootprintServiceImpl with authorization checks"
```

`---

### Task 7: 创建 FootprintController

**Files:**
- Create: `backend/eladmin-system/src/main/java/me/zhengjie/modules/footprint/rest/FootprintController.java`

- [ ] **Step 1: 创建 REST Controller**

```java
/*
 *  Copyright 2019-2025 Zheng Jie
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package com.littlegrid.modules.footprint.rest;

import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import com.littlegrid.annotation.Log;
import com.littlegrid.modules.footprint.service.FootprintService;
import com.littlegrid.modules.footprint.service.dto.FootprintDTO;
import com.littlegrid.modules.footprint.service.dto.FootprintCreateDTO;
import com.littlegrid.modules.footprint.service.dto.FootprintUpdateDTO;
import com.littlegrid.utils.SecurityUtils;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * @author System Generated
 * @date 2026-04-01
 */
@RestController
@RequiredArgsConstructor
@Tag(name = "足迹地图：足迹管理")
@RequestMapping("/api/footprints")
public class FootprintController {

    private final FootprintService footprintService;

    @Operation(summary = "获取当前用户的所有足迹")
    @GetMapping
    public ResponseEntity<List<FootprintDTO>> findUserFootprints() {
        Long userId = SecurityUtils.getCurrentUserId();
        List<FootprintDTO> footprints = footprintService.findByUserId(userId);
        return new ResponseEntity<>(footprints, HttpStatus.OK);
    }

    @Operation(summary = "获取单个足迹详情")
    @GetMapping(value = "/{id}")
    public ResponseEntity<FootprintDTO> findById(@PathVariable Long id) {
        Long userId = SecurityUtils.getCurrentUserId();
        FootprintDTO dto = footprintService.findById(id, userId);
        return new ResponseEntity<>(dto, HttpStatus.OK);
    }

    @Log("添加足迹")
    @Operation(summary = "添加新足迹")
    @PostMapping
    public ResponseEntity<FootprintDTO> create(@Validated @RequestBody FootprintCreateDTO dto) {
        Long userId = SecurityUtils.getCurrentUserId();
        footprintService.create(dto, userId);
        return new ResponseEntity<>(HttpStatus.CREATED);
    }

    @Log("修改足迹")
    @Operation(summary = "更新足迹信息")
    @PutMapping
    public ResponseEntity<Object> update(@Validated @RequestBody FootprintUpdateDTO dto) {
        Long userId = SecurityUtils.getCurrentUserId();
        footprintService.update(dto, userId);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    @Log("删除足迹")
    @Operation(summary = "删除足迹")
    @DeleteMapping(value = "/{id}")
    public ResponseEntity<Object> delete(@PathVariable Long id) {
        Long userId = SecurityUtils.getCurrentUserId();
        footprintService.delete(id, userId);
        return new ResponseEntity<>(HttpStatus.OK);
    }
}
```

- [ ] **Step 2: Git commit**

```bash
git add backend/eladmin-system/src/main/java/me/zhengjie/modules/footprint/rest/FootprintController.java
git commit -m "feat(footprint): add FootprintController with REST endpoints"
```

---

## Phase 2: 前端实现

### Task 8: 添加高德地图依赖

**Files:**
- Modify: `app/pubspec.yaml`

- [ ] **Step 1: 在 pubspec.yaml 中添加依赖**

在 `dependencies:` 部分添加：
```yaml
  amap_flutter_map: ^3.0.0
  amap_flutter_base: ^3.0.0
```

- [ ] **Step 2: Git commit**

```bash
git add app/pubspec.yaml
git commit -m "chore: add amap_flutter dependencies"
```

---

### Task 9: 创建 Footprint 数据模型

**Files:**
- Create: `app/lib/models/footprint.dart`

- [ ] **Step 1: 创建 Footprint 模型**

```dart
class Footprint {
  final int id;
  final String cityName;
  final String? provinceName;
  final double latitude;
  final double longitude;
  final DateTime visitDate;
  final DateTime? createTime;

  Footprint({
    required this.id,
    required this.cityName,
    this.provinceName,
    required this.latitude,
    required this.longitude,
    required this.visitDate,
    this.createTime,
  });

  factory Footprint.fromJson(Map<String, dynamic> json) {
    return Footprint(
      id: json['id'] as int,
      cityName: json['cityName'] as String,
      provinceName: json['provinceName'] as String?,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      visitDate: DateTime.parse(json['visitDate'] as String),
      createTime: json['createTime'] != null
          ? DateTime.parse(json['createTime'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cityName': cityName,
      'provinceName': provinceName,
      'latitude': latitude,
      'longitude': longitude,
      'visitDate': visitDate.toIso8601String().split('T')[0],
    };
  }
}
```

- [ ] **Step 2: Git commit**

```bash
git add app/lib/models/footprint.dart
git commit -m "feat(footprint): add Footprint data model"
```

---

### Task 10: 创建 FootprintService

**Files:**
- Create: `app/lib/core/services/footprint_service.dart`

- [ ] **Step 1: 创建 FootprintService**

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/footprint.dart';
import 'secure_storage.dart';

class FootprintService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://8.137.39.155:8000/api',
  );

  static Future<List<Footprint>> getFootprints() async {
    final token = await SecureStorage.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/footprints'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => Footprint.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('请先登录');
    } else {
      throw Exception('获取足迹失败: ${response.statusCode}');
    }
  }

  static Future<void> createFootprint(Footprint footprint) async {
    final token = await SecureStorage.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/footprints'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(footprint.toJson()),
    );

    if (response.statusCode == 201) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('请先登录');
    } else {
      throw Exception('添加足迹失败: ${response.statusCode}');
    }
  }

  static Future<void> updateFootprint(Footprint footprint) async {
    final token = await SecureStorage.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/footprints'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(footprint.toJson()),
    );

    if (response.statusCode == 204) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('请先登录');
    } else if (response.statusCode == 403) {
      throw Exception('无权访问此数据');
    } else {
      throw Exception('更新足迹失败: ${response.statusCode}');
    }
  }

  static Future<void> deleteFootprint(int id) async {
    final token = await SecureStorage.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/footprints/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('请先登录');
    } else if (response.statusCode == 403) {
      throw Exception('无权访问此数据');
    } else {
      throw Exception('删除足迹失败: ${response.statusCode}');
    }
  }
}
```

- [ ] **Step 2: Git commit**

```bash
git add app/lib/core/services/footprint_service.dart
git commit -m "feat(footprint): add FootprintService for API calls"
```

---

### Task 11: 创建 FootprintProvider

**Files:**
- Create: `app/lib/providers/footprint_provider.dart`

- [ ] **Step 1: 创建 FootprintProvider**

```dart
import 'package:flutter/foundation.dart';
import '../models/footprint.dart';
import '../core/services/footprint_service.dart';

class FootprintProvider extends ChangeNotifier {
  List<Footprint> _footprints = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Footprint> get footprints => _footprints;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadFootprints() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _footprints = await FootprintService.getFootprints();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addFootprint(Footprint footprint) async {
    try {
      await FootprintService.createFootprint(footprint);
      _footprints.add(footprint);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateFootprint(Footprint footprint) async {
    try {
      await FootprintService.updateFootprint(footprint);
      final index = _footprints.indexWhere((f) => f.id == footprint.id);
      if (index != -1) {
        _footprints[index] = footprint;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteFootprint(int id) async {
    try {
      await FootprintService.deleteFootprint(id);
      _footprints.removeWhere((f) => f.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
```

- [ ] **Step 2: Git commit**

```bash
git add app/lib/providers/footprint_provider.dart
git commit -m "feat(footprint): add FootprintProvider for state management"
```

---

### Task 12: 创建 FootprintPage 主页面

**Files:**
- Create: `app/lib/pages/footprint_page.dart`

- [ ] **Step 1: 创建 FootprintPage**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/footprint_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/footprint_map_view.dart';
import '../widgets/footprint_timeline_view.dart';

class FootprintPage extends StatefulWidget {
  const FootprintPage({super.key});

  @override
  State<FootprintPage> createState() => _FootprintPageState();
}

class _FootprintPageState extends State<FootprintPage> {
  @override
  void initState() {
    super.initState();
    // 延迟加载数据，确保 Provider 已初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      _showLoginPrompt();
      return;
    }
    await Provider.of<FootprintProvider>(context, listen: false)
        .loadFootprints();
  }

  void _showLoginPrompt() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('请先登录')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('足迹地图'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showCitySearch(),
          ),
        ],
      ),
      body: Consumer<FootprintProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.errorMessage!),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      _loadData();
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          if (provider.footprints.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              Expanded(
                flex: 2,
                child: FootprintMapView(
                  footprints: provider.footprints,
                  onMapTap: _handleMapTap,
                ),
              ),
              Expanded(
                flex: 1,
                child: FootprintTimelineView(
                  footprints: provider.footprints,
                  onEdit: _handleEdit,
                  onDelete: _handleDelete,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            '还没有足迹记录',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '点击地图或搜索按钮添加足迹',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _handleMapTap(double latitude, double longitude) {
    // TODO: 实现地图点击处理，调用高德逆地理编码
    _showAddDialog();
  }

  void _handleEdit(Footprint footprint) {
    // TODO: 实现编辑对话框
  }

  void _handleDelete(Footprint footprint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除足迹'),
        content: Text('确定删除 ${footprint.cityName} 的足迹吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final success = await Provider.of<FootprintProvider>(
                context,
                listen: false,
              ).deleteFootprint(footprint.id);
              Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('删除成功')),
                );
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    // TODO: 实现添加足迹对话框
  }

  void _showCitySearch() {
    // TODO: 实现城市搜索对话框
  }
}
```

- [ ] **Step 2: Git commit**

```bash
git add app/lib/pages/footprint_page.dart
git commit -m "feat(footprint): add FootprintPage main structure"
```

---

### Task 13: 创建 FootprintMapView 地图组件

**Files:**
- Create: `app/lib/widgets/footprint_map_view.dart`

- [ ] **Step 1: 创建地图视图组件**

```dart
import 'package:flutter/material.dart';
import '../models/footprint.dart';

// 注意：这里使用占位符实现，实际需要集成 amap_flutter_map
class FootprintMapView extends StatelessWidget {
  final List<Footprint> footprints;
  final Function(double, double)? onMapTap;

  const FootprintMapView({
    super.key,
    required this.footprints,
    this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Stack(
        children: [
          // 占位符地图背景
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade50, Colors.green.shade50],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      '地图组件（待集成高德地图）',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 足迹标记点
          ..._buildMarkers(),
        ],
      ),
    );
  }

  List<Widget> _buildMarkers() {
    return footprints.map((footprint) {
      // 占位符实现，实际需要使用 AMapMarker
      return Positioned(
        left: (footprint.longitude + 180) / 360 * MediaQuery.of(context).size.width,
        top: (90 - footprint.latitude) / 180 * MediaQuery.of(context).size.height / 2,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      );
    }).toList();
  }
}
```

- [ ] **Step 2: Git commit**

```bash
git add app/lib/widgets/footprint_map_view.dart
git commit -m "feat(footprint): add FootprintMapView with placeholder implementation"
```

---

### Task 14: 创建 FootprintTimelineView 时间线组件

**Files:**
- Create: `app/lib/widgets/footprint_timeline_view.dart`

- [ ] **Step 1: 创建时间线视图组件**

```dart
import 'package:flutter/material.dart';
import '../models/footprint.dart';

class FootprintTimelineView extends StatelessWidget {
  final List<Footprint> footprints;
  final Function(Footprint)? onEdit;
  final Function(Footprint)? onDelete;

  const FootprintTimelineView({
    super.key,
    required this.footprints,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 按日期倒序排列
    final sortedFootprints = List<Footprint>.from(footprints);
    sortedFootprints.sort((a, b) => b.visitDate.compareTo(a.visitDate));

    if (sortedFootprints.isEmpty) {
      return Center(
        child: Text(
          '暂无足迹记录',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedFootprints.length,
        itemBuilder: (context, index) {
          return _buildTimelineCard(sortedFootprints[index]);
        },
      ),
    );
  }

  Widget _buildTimelineCard(Footprint footprint) {
    final dateStr = '${footprint.visitDate.year}年'
        '${footprint.visitDate.month.toString().padLeft(2, '0')}月'
        '${footprint.visitDate.day.toString().padLeft(2, '0')}日';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: Text(
            '${footprint.visitDate.day}',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
Row footprint.cityName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (footprint.provinceName != null)
              Text(footprint.provinceName!),
            Text(
              dateStr,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => onEdit!(footprint),
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                onPressed: () => onDelete!(footprint),
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Git commit**

```bash
git add app/lib/widgets/footprint_timeline_view.dart
git commit -m "feat(footprint): add FootprintTimelineView component"
```

---

### Task 15: 注册足迹地图工具

**Files:**
- Create: `app/lib/tools/footprint/footprint_tool.dart`
- Modify: `app/lib/main.dart`

- [ ] **Step 1: 创建 FootprintTool**

```dart
import 'package:flutter/material.dart';
import '../../pages/footprint_page.dart';

class FootprintTool {
  String get name => '足迹地图';
  String get icon => 'assets/icons/footprint.png';
  String get description => '在地图上标记你去过的城市';

  Widget get page => const FootprintPage();
}
```

- [ ] **Step 2: 在 main.dart 中注册工具**

在 main.dart 的 import 部分添加：
```dart
import 'tools/footprint/footprint_tool.dart';
```

在 main() 函数中添加注册：
```dart
  ToolRegistry.register(FootprintTool());
```

- [ ] **Step 3: Git commit**

```bash
git add app/lib/tools/footprint/footprint_tool.dart app/lib/main.dart
git commit -m "feat(footprint): register FootprintTool in main.dart"
```

---

## Phase 3: 数据库迁移

### Task 16: 创建数据库迁移 SQL

**Files:**
- Create: `backend/eladmin-system/src/main/resources/db/migration/V2__create_footprint_table.sql`

- [ ] **Step 1: 创建迁移 SQL 文件**

```sql
-- 创建足迹表
CREATE TABLE footprint (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  city_name VARCHAR(100) NOT NULL,
  province_name VARCHAR(50),
  latitude DECIMAL(10,7) NOT NULL,
  longitude DECIMAL(10,7) NOT NULL,
  visit_date DATE NOT NULL,
  create_by VARCHAR(50),
  update_by VARCHAR(50),
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='足迹表';
```

- [ ] **Step 2: Git commit**

```bash
git add backend/eladmin-system/src/main/resources/db/migration/V2__create_footprint_table.sql
git commit -m "chore: add database migration for footprint table"
```

---

## 验证步骤

### Task 17: 后端集成验证

- [ ] **Step 1: 启动后端服务**

```bash
cd backend
./mvnw clean package -DskipTests
java -jar eladmin-app/target/eladmin-app-2.7.jar
```

- [ ] **Step 2: 测试 API 端点**

使用 Swagger UI 或 curl 测试：
- GET `/api/footprints` (需要登录)
- POST `/api/footprints`
- PUT `/api/footprints`
- DELETE `/api/footprints/{id}`

### Task 18: 前端集成验证

- [ ] **Step 1: 安装依赖**

```bash
cd app
flutter pub get
```

- [ ] **Step 2: 运行应用**

```bash
flutter run
```

- [ ] **Step 3: 手动测试流程**
1. 登录系统
2. 进入足迹地图页面
3. 测试添加足迹功能
4. 验证地图显示和时间线列表
5. 测试编辑和删除功能

---

## 总结

本计划完成了足迹地图功能的完整实现：

1. **后端部分**: 实体、Repository、DTO、Mapper、Service、Controller
2. **前端部分**: 模型、服务、Provider、页面组件、工具注册
3. **数据库**: 创建足迹表的迁移脚本

**注意事项**:
- 高德地图 SDK 需要申请 API Key 并配置
- 地图点击逆地理编码功能需要进一步实现高德 API 调用
- 城市搜索功能需要实现高德 POI 搜索 API 调用
