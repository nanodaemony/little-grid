# 用户图片上传接口实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为用户端提供图片上传接口，支持多种业务类型（头像、动态、通用等），使用现有的 S3 配置和 JWT 鉴权。

**Architecture:** 在 eladmin-app 模块中创建 ImageUploadController 和 ImageUploadService，复用 eladmin-tools 模块的 S3 配置，使用现有的 JWT 鉴权机制。

**Tech Stack:** Spring Boot, AWS S3 SDK, Lombok, JWT

---

## File Structure

```
backend/eladmin-app/src/main/java/com/littlegrid/modules/app/
├── rest/
│   └── ImageUploadController.java  [新建]
├── service/
│   ├── ImageUploadService.java  [新建]
│   └── dto/
│       ├── UploadDTO.java  [新建]
│       └── UploadResultDTO.java  [新建]
```

---

### Task 1: 创建 UploadDTO.java

**Files:**
- Create: `backend/eladmin-app/src/main/java/com/littlegrid/modules/app/service/dto/UploadDTO.java`

- [ ] **Step 1: 创建 UploadDTO 类**

```java
package com.littlegrid.modules.app.service.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
@Schema(description = "图片上传请求参数")
public class UploadDTO {

    @NotNull(message = "文件不能为空")
    @Schema(description = "上传的文件")
    private MultipartFile file;

    @NotBlank(message = "业务类型不能为空")
    @Schema(description = "业务类型：avatar|post|dynamic|temp")
    private String businessType;
}
```

- [ ] **Step 2: 保存修改**

```bash
git add backend/eladmin-app/src/main/java/com/littlegrid/modules/app/service/dto/UploadDTO.java
git commit -m "feat: add UploadDTO for image upload request"
```

---

### Task 2: 创建 UploadResultDTO.java

**Files:**
- Create: `backend/eladmin-app/src/main/java/com/littlegrid/modules/app/service/dto/UploadResultDTO.java`

- [ ] **Step 1: 创建 UploadResultDTO 类**

```java
package com.littlegrid.modules.app.service.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "图片上传响应结果")
public class UploadResultDTO {

    @Schema(description = "文件完整 URL")
    private String url;

    @Schema(description = "原始文件名")
    private String fileName;

    @Schema(description = "文件大小（字节）")
    private Long fileSize;

    @Schema(description = "文件类型")
    private String fileType;
}
```

- [ ] **Step 2: 保存修改**

```bash
git add backend/eladmin-app/src/main/java/com/littlegrid/modules/app/service/dto/UploadResultDTO.java
git commit -m "feat: add UploadResultDTO for image upload response"
```

---

### Task 3: 创建 BusinessType 枚举类

**Files:**
- Create: `backend/eladmin-app/src/main/java/com/littlegrid/modules/app/enums/BusinessType.java`

- [ ] **Step 1: 创建 BusinessType 枚举**

```java
package com.littlegrid.modules.app.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum BusinessType {

    AVATAR("avatar", "用户头像"),
    POST("post", "用户动态图片"),
    DYNAMIC("dynamic", "通用动态内容"),
    TEMP("temp", "临时文件");

    private final String code;
    private final String description;

    /**
     * 根据 code 获取枚举
     */
    public static BusinessType fromCode(String code) {
        for (BusinessType type : values()) {
            if (type.code.equals(code)) {
                return type;
            }
        }
        return null;
    }
}
```

- [ ] **Step 2: 保存修改**

```bash
git add backend/eladmin-app/src/main/java/com/littlegrid/modules/app/enums/BusinessType.java
git commit -m "feat: add BusinessType enum for upload business types"
```

---

### Task 4: 创建 ImageUploadService.java

**Files:**
- Create: `backend/eladmin-app/src/main/java/com/littlegrid/modules/app/service/ImageUploadService.java`

- [ ] **Step 1: 创建 ImageUploadService 类**

```java
package com.littlegrid.modules.app.service;

import cn.hutool.core.util.IdUtil;
import cn.hutool.core.util.StrUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import com.littlegrid.exception.BadRequestException;
import com.littlegrid.modules.app.enums.BusinessType;
import com.littlegrid.modules.app.service.dto.UploadResultDTO;
import com.littlegrid.modules.app.utils.AppSecurityUtils;

@Slf4j
@Service
@RequiredArgsConstructor
public class ImageUploadService {

    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
    private static final String[] ALLOWED_IMAGE_TYPES = {"jpg", "jpeg", "png", "gif", "webp"};

    private final S3Client s3Client;

    /**
     * 上传图片到 OSS
     *
     * @param file 上传的文件
     * @param businessType 业务类型
     * @return 上传结果
     */
    public UploadResultDTO uploadImage(MultipartFile file, String businessType) {
        // 1. 验证业务类型
        BusinessType type = BusinessType.fromCode(businessType);
        if (type == null) {
            throw new BadRequestException("无效的业务类型");
        }

        // 2. 验证文件
        validateFile(file);

        // 3. 生成文件名
        String originalFileName = file.getOriginalFilename();
        String fileExtension = StrUtil.subAfter(originalFileName, ".");
        String uniqueFileName = IdUtil.simpleUUID() + "." + fileExtension;

        // 4. 构建上传路径（业务类型/文件名）
        String uploadPath = type.getCode() + "/" + uniqueFileName;

        try {
            // 5. 上传到 OSS
            PutObjectRequest putRequest = PutObjectRequest.builder()
                    .bucket("nano-little-grid")
                    .key(uploadPath)
                    .build();

            s3Client.putObject(putRequest, RequestBody.fromInputStream(file.getInputStream(), file.getSize()));

            // 6. 构建返回结果
            String fileUrl = "https://nano-little-grid.oss-cn-chengdu.aliyuncs.com/" + uploadPath;

            return new UploadResultDTO(
                    fileUrl,
                    originalFileName,
                    file.getSize(),
                    fileExtension
            );

        } catch (Exception e) {
            log.error("图片上传失败", e);
            throw new BadRequestException("图片上传失败：" + e.getMessage());
        }
    }

    /**
     * 验证文件
是否为有效的图片类型且大小符合要求
     *
     * @param file 上传的文件
     * @throws BadRequestException 验证失败时抛出异常
     */
    private void validateFile(MultipartFile file) {
        // 验证文件不为空
        if (file.isEmpty()) {
            throw new BadRequestException("文件不能为空");
        }

        // 验证文件大小
        long fileSize = file.getSize();
        if (fileSize > MAX_FILE_SIZE) {
            throw new BadRequestException("文件大小不能超过 10MB");
        }

        // 验证文件类型
        String originalFileName = file.getOriginalFilename();
        String fileExtension = StrUtil.subAfter(originalFileName, ".").toLowerCase();

        boolean isValidType = false;
        for (String allowedType : ALLOWED_IMAGE_TYPES) {
            if (allowedType.equalsIgnoreCase(fileExtension)) {
                isValidType = true;
                break;
            }
        }

        if (!isValidType) {
            throw new BadRequestException("只支持图片格式：jpg, jpeg, png, gif, webp");
        }

        // 验证 MIME 类型
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new BadRequestException("文件类型不正确");
        }
    }
}
```

- [ ] **Step 2: 保存修改**

```bash
git add backend/eladmin-app/src/main/java/com/littlegrid/modules/app/service/ImageUploadService.java
git commit -m "feat: add ImageUploadService with OSS upload logic"
```

---

### Task 5: 创建 ImageUploadController.java

**Files:**
- Create: `backend/eladmin-app/src/main/java/com/littlegrid/modules/app/rest/ImageUploadController.java`

- [ ] **Step 1: 创建 ImageUploadController 类**

```java
package com.littlegrid.modules.app.rest;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import com.littlegrid.exception.BadRequestException;
import com.littlegrid.modules.app.service.ImageUploadService;
import com.littlegrid.modules.app.service.dto.UploadDTO;
import com.littlegrid.modules.app.service.dto.UploadResultDTO;
import com.littlegrid.modules.app.utils.AppSecurityUtils;
import com.littlegrid.utils.Result;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/app/upload")
@Tag(name = "APP: 用户图片上传")
public class ImageUploadController {

    private final ImageUploadService imageUploadService;

    @Operation(summary = "上传单张图片")
    @PostMapping("/image")
    public ResponseEntity<Result<UploadResultDTO>> uploadImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam("businessType") String businessType) {

        try {
            UploadDTO dto = new UploadDTO();
            dto.setFile(file);
            dto.setBusinessType(businessType);

            UploadResultDTO result = imageUploadService.uploadImage(file, businessType);
            return ResponseEntity.ok(Result.success(result));
        } catch (BadRequestException e) {
            return ResponseEntity.badRequest().body(Result.error(e.getMessage()));
        } catch (Exception e) {
            log.error("上传失败", e);
            return ResponseEntity.internalServerError().body(Result.error("上传失败，请稍后重试"));
        }
    }
}
```

- [ ] **Step 2: 保存修改**

```bash
git add backend/eladmin-app/src/main/java/com/littlegrid/modules/app/rest/ImageUploadController.java
git commit -m "feat: add ImageUploadController for user image upload API"
```

---

### Task 6: 更新 eladmin-app pom.xml 添加 S3 依赖

**Files:**
- Modify: `backend/eladmin-app/pom.xml`

- [ ] **Step 1: 添加 S3 SDK 依赖**

在 pom.xml 中添加：
```xml
<!-- amazon s3 依赖 -->
<dependency>
    <groupId>software.amazon.awssdk</groupId>
    <artifactId>s3</artifactId>
    <version>2.30.13</version>
    <scope>compile</scope>
</dependency>
```

- [ ] **Step 2: 保存修改**

```bash
git add backend/eladmin-app/pom.xml
git commit -m "feat: add AWS S3 SDK dependency to eladmin-app"
```

---

### Task 7: 配置 S3 Client Bean

**Files:**
- Create: `backend/eladmin-app/src/main/java/com/littlegrid/modules/app/config/S3Config.java`

- [ ] **Step 1: 创建 S3Config 配置类**

```java
package com.littlegrid.modules.app.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import org.springframework.beans.factory.annotation.Value;

@Data
@Configuration
@ConfigurationProperties(prefix = "amz.s3")
public class S3Config {

    @Value("${amz.s3.region:}")
    private String region;

    @Value("${amz.s3.endpoint:}")
    private String endPoint;

    @Value("${amz.s3.domain:}")
    private String domain;

    @Value("${amz.s3.access-key:}")
    private String accessKey;

    @Value("${amz.s3.secret-key:}")
    private String secretKey;

    @Value("${amz.s3.default-bucket:}")
    private String defaultBucket;

    @Value("${amz.s3.timeformat:yyyy-MM}")
    private String timeformat;

    @Bean
    public S3Client s3Client() {
        return S3Client.builder()
                .region(Region.of(region))
                .endpointOverride(URI.create(endPoint))
                .credentialsProvider(StaticCredentialsProvider.create(
                        AwsBasicCredentials.create(accessKey, secretKey)))
                .build();
    }
}
```

- [ ] **Step 2: 保存修改**

```bash
git add backend/eladmin-app/src/main/java/com/littlegrid/modules/app/config/S3Config.java
git commit -m "feat: add S3Config for Aliyun OSS connection"
```

---

## Testing

### Test 1: 鉴权测试

1. 不携带 token 访问 `/api/app/upload/image`
2. 预期返回 401 错误

### Test 2: 业务类型测试

1. 上传 avatar 类型图片
2. 预期 URL 路径包含 `avatar/` 前缀
3. 上传 post 类型图片
4. 预期 URL 路径包含 `post/` 前缀

### Test 3: 文件类型测试

1. 上传 jpg、png 图片 → 成功
2. 上传其他类型文件 → 返回错误

### Test 4: 文件大小测试

1. 上传小于 10MB 图片 → 成功
2. 上传大于 10MB 文件 → 返回错误

### Test 5: URL 访问测试

1. 上传成功后获取 URL
2. 验证 URL 可以正常访问图片
