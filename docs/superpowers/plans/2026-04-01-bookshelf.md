# 书架功能实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**目标**: 为用户提供书架功能，记录和管理看过的书、电影、电视剧、番剧、游戏等内容，支持分类、评分、标签等功能。

**架构**: 后端集成到 eladmin-tools 模块，前端作为独立工具模块添加到 Flutter 应用。后端使用 JPA 进行数据持久化，前端使用 Provider 进行状态管理。

**技术栈**: Spring Boot 3.2.5, JPA, Flutter, Provider, MySQL

---

## 后端实现

### Task 1: 创建 BookshelfCategory 实体类

**文件:**
- 创建: `backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/domain/BookshelfCategory.java`

- [ ] **Step 1: 创建 BookshelfCategory 实体类**

```java
package com.littlegrid.modules.bookshelf.domain;

import com.littlegrid.base.BaseEntity;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.io.Serializable;
import java.util.Objects;

@Entity
@Getter
@Setter
@Table(name = "bookshelf_category")
@Schema(description = "书架分类实体")
public class BookshelfCategory extends BaseEntity implements Serializable {

    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Schema(description = "分类ID")
    private Long id;

    @NotBlank
    @Size(max = 50)
    @Column(name = "name", nullable = false, length = 50)
    @Schema(description = "分类名称")
    private String name;

    @Column(name = "sort")
    @Schema(description = "排序")
    private Integer sort = 0;

    @Column(name = "created_by", nullable = false)
    @Schema(description = "创建用户ID")
    private Long createdBy;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        BookshelfCategory that = (BookshelfCategory) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
```

- [ ] **Step 2: 提交**

```bash
git add backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/domain/BookshelfCategory.java
git commit -m "feat(bookshelf): add BookshelfCategory entity"
```

---

### Task 2: 创建 BookshelfItem 实体类

**文件:**
- 创建: `backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/domain/BookshelfItem.java`

- [ ] **Step 1: 创建 BookshelfItem 实体类**

```java
package com.littlegrid.modules.bookshelf.domain;

import com.littlegrid.base.BaseEntity;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.io.Serializable;
import java.time.LocalDate;
import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

@Entity
@Getter
@Setter
@Table(name = "bookshelf_item")
@Schema(description = "书架条目实体")
public class BookshelfItem extends BaseEntity implements Serializable {

    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Schema(description = "条目ID")
    private Long id;

    @NotNull
    @Column(name = "category_id", nullable = false)
    @Schema(description = "分类ID")
    private Long categoryId;

    @NotBlank
    @Size(max = 100)
    @Column(name = "title", nullable = false, length = 100)
    @Schema(description = "标题")
    private String title;

    @NotBlank
    @Size(max = 500)
    @Column(name = "cover_url", nullable = false, length = 500)
    @Schema(description = "封面图片URL")
    private String coverUrl;

    @Size(max = 200)
    @Column(name = "summary", length = 200)
    @Schema(description = "一句话简介")
    private String summary;

    @Column(name = "start_date")
    @Schema(description = "开始观看日期")
    private LocalDate startDate;

    @Column(name = "end_date")
    @Schema(description = "结束观看日期")
    private LocalDate endDate endDate;

    @Column(name = "finish_date")
    @Schema(description = "完成日期")
    private LocalDate finishDate;

    @Size(max = 100)
    @Column(name = "author", length = 100)
    @Schema(description = "作者/导演")
    private String author;

    @Column(name = "rating")
    @Schema(description = "评分 1-10")
    private Integer rating;

    @Column(name = "review", columnDefinition = "TEXT")
    @Schema(description = "详细评价")
    private String review;

    @Size(max = 50)
    @Column(name = "progress", length = 50)
    @Schema(description = "观看进度")
    private String progress;

    @Column(name = "is_recommended")
    @Schema(description = "是否推荐")
    private Boolean isRecommended = false;

    @Column(name = "created_by", nullable = false)
    @Schema(description = "创建用户ID")
    private Long createdBy;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "bookshelf_item_tag",
        joinColumns = @JoinColumn(name = "item_id"),
        inverseJoinColumns = @JoinColumn(name = "tag_id")
    )
    @Schema(description = "标签")
    private Set<BookshelfTag> tags = new HashSet<>();

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        BookshelfItem that = (BookshelfItem) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
```

- [ ] **Step 2: 提交**

```bash
git add backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/domain/BookshelfItem.java
git commit -m "feat(bookshelf): add BookshelfItem entity"
```

---

### Task 3: 创建 BookshelfTag 实体类

**文件:**
- 创建: `backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/domain/BookshelfTag.java`

- [ ] **Step 1: 创建 BookshelfTag 实体类**

```java
package com.littlegrid.modules.bookshelf.domain;

import com.littlegrid.base.BaseEntity;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.io.Serializable;
import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

@Entity
@Getter
@Setter
@Table(name = "bookshelf_tag", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"name", "created_by"})
})
@Schema(description = "书架标签实体")
public class BookshelfTag extends BaseEntity implements Serializable {

    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Schema(description = "标签ID")
    private Long id;

    @NotBlank
    @Size(max = 30)
    @Column(name = "name", nullable = false, length = 30)
    @Schema(description = "标签名称")
    private String name;

    @Column(name = "created_by", nullable = false)
    @Schema(description = "创建用户ID")
    private Long createdBy;

    @ManyToMany(mappedBy = "tags", fetch = FetchType.LAZY)
    @Schema(description = "条目")
    private Set<BookshelfItem> items = new HashSet<>();

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        BookshelfTag that = (BookshelfTag) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
```

- [ ] **Step 2: 提交**

```bash
git add backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/domain/BookshelfTag.java
git commit -m "feat(bookshelf): add BookshelfTag entity"
```

---

### Task 4: 创建 Repository 接口

**文件:**
- 创建: `backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/repository/BookshelfCategoryRepository.java`
- 创建: `backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/repository/BookshelfItemRepository.java`
- 创建: `backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/repository/BookshelfTagRepository.java`

- [ ] **Step 1: 创建 BookshelfCategoryRepository**

```java
package com.littlegrid.modules.bookshelf.repository;

import com.littlegrid.modules.bookshelf.domain.BookshelfCategory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BookshelfCategoryRepository extends JpaRepository<BookshelfCategory, Long> {

    /**
     * 根据用户ID查询分类
     */
    List<BookshelfCategory> findByCreatedByOrderBySortAsc(Long createdBy);

    /**
     * 根据用户ID和名称查询分类
     */
    List<BookshelfCategory> findByCreatedByAndName(Long createdBy, String name);
}
```

- [ ] **Step 2: 创建 BookshelfItemRepository**

```java
package com.littlegrid.modules.bookshelf.repository;

import com.littlegrid.modules.bookshelf.domain.BookshelfItem;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BookshelfItemRepository extends JpaRepository<BookshelfItem, Long> {

    /**
     * 根据分类ID和用户ID查询条目（分页）
     */
    Page<BookshelfItem> findByCategoryIdAndCreatedByOrderByCreateTimeDesc(Long categoryId, Long createdBy, Pageable pageable);

    /**
     * 根据ID和用户ID查询条目
     */
    List<BookshelfItem> findByIdAndCreatedBy(Long id, Long createdBy);

    /**
     * 根据分类ID和用户ID统计条目数量
     */
    Long countByCategoryIdAndCreatedBy(Long categoryId, Long createdBy);
}
```

- [ ] **Step 3: 创建 BookshelfTagRepository**

```java
package com.littlegrid.modules.bookshelf.repository;

import com.littlegrid.modules.bookshelf.domain.BookshelfTag;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BookshelfTagRepository extends JpaRepository<BookshelfTag, Long> {

    /**
     * 根据用户ID查询标签
     */
    List<BookshelfTag> findByCreatedByOrderByCreateTimeDesc(Long createdBy);

    /**
     * 根据用户ID和名称查询标签
     */
    List<BookshelfTag> findByCreatedByAndName(Long createdBy, String name);
}
```

- [ ] **Step 4: 提交**

```bash
git add backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/repository/
git commit -m "feat(bookshelf): add repository interfaces"
```

---

### Task 5: 创建 DTO 类

**文件:**
- 创建: `backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/service/dto/BookshelfCategoryDTO.java`
- 创建: `backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/service/dto/CreateBookshelfCategoryDTO.java`
- 创建: `backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/service/dto/UpdateBookshelfCategoryDTO.java`
- 创建: `backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/service/dto/BookshelfItemDTO.java`
- 创建: `backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/service/dto/CreateBookshelfItemDTO.java`
- 创建: `backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/service/dto/UpdateBookshelfItemDTO.java`
- 创建: `backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/service/dto/BookshelfTagDTO.java`
- 创建: `backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/service/dto/CreateBookshelfTagDTO.java`

- [ ] **Step 1: 创建 BookshelfCategoryDTO**

```java
package com.littlegrid.modules.bookshelf.service.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Schema(description = "书架分类DTO")
public class BookshelfCategoryDTO {

    @Schema(description = "分类ID")
    private Long id;

    @Schema(description = "分类名称")
    private String name;

    @Schema(description = "排序")
    private Integer sort;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Schema(description = "更新时间")
    private LocalDateTime updateTime;
}
```

- [ ] **Step 2: 创建 CreateBookshelfCategoryDTO**

```java
package com.littlegrid.modules.bookshelf.service.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
@Schema(description = "创建书架分类DTO")
public class CreateBookshelfCategoryDTO {

    @NotBlank
    @Size(max = 50)
    @Schema(description = "分类名称", required = true)
    private String name;

    @Schema(description = "排序")
    private Integer sort;
}
```

- [ ] **Step 3: 创建 UpdateBookshelfCategoryDTO**

```java
package com.littlegrid.modules.bookshelf.service.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
@Schema(description = "更新书架分类DTO")
public class UpdateBookshelfCategoryDTO {

    @NotBlank
    @Size(max = 50)
    @Schema(description = "分类名称", required = true)
    private String name;

    @Schema(description = "排序")
    private Integer sort;
}
```

- [ ] **Step 4: 创建 BookshelfItemDTO**

```java
package com.littlegrid.modules.bookshelf.service.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Schema(description = "书架条目DTO")
public class BookshelfItemDTO {

    @Schema(description = "条目ID")
    private Long id;

    @Schema(description = "分类ID")
    private Long categoryId;

    @Schema(description = "标题")
    private String title;

    @Schema(description = "封面图片URL")
    private String coverUrl;

    @Schema(description = "一句话简介")
    private String summary;

    @JsonFormat(pattern = "yyyy-MM-dd")
    @Schema(description = "开始观看日期")
    private LocalDate startDate;

    @JsonFormat(pattern = "yyyy-MM-dd")
    @Schema(description = "结束观看日期")
    private LocalDate endDate;

    @JsonFormat(pattern = "yyyy-MM-dd")
    @Schema(description = "完成日期")
    private LocalDate finishDate;

    @Schema(description = "作者/导演")
    private String author;

    @Schema(description = "评分")
    private Integer rating;

    @Schema(description = "详细评价")
    private String review;

    @Schema(description = "观看进度")
    private String progress;

    @Schema(description = "是否推荐")
    private Boolean isRecommended;

    @Schema(description = "标签")
    private List<String> tags;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Schema(description = "更新时间")
    private LocalDateTime updateTime;
}
```

- [ ] **Step 5: 创建 CreateBookshelfItemDTO**

```java
package com.littlegrid.modules.bookshelf.service.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
@Schema(description = "创建书架条目DTO")
public class CreateBookshelfItemDTO {

    @NotNull
    @Schema(description = "分类ID", required = true)
    private Long categoryId;

    @NotBlank
    @Size(max = 100)
    @Schema(description = "标题", required = true)
    private String title;

    @NotBlank
    @Size(max = 500)
    @Schema(description = "封面图片URL", required = true)
    private String coverUrl;

    @Size(max = 200)
    @Schema(description = "一句话简介")
    private String summary;

    @JsonFormat(pattern = "yyyy-MM-dd")
    @Schema(description = "开始观看日期")
    private LocalDate startDate;

    @JsonFormat(pattern = "yyyy-MM-dd")
    @Schema(description = "结束观看日期")
    private LocalDate endDate;

    @JsonFormat(pattern = "yyyy-MM-dd")
    @Schema(description = "完成日期")
    private LocalDate finishDate;

    @Size(max = 100)
    @Schema(description = "作者/导演")
    private String author;

    @Schema(description = "评分 1-10")
    private Integer rating;

    @Schema(description = "详细评价")
    private String review;

    @Size(max = 50)
    @Schema(description = "观看进度")
    private String progress;

    @Schema(description = "是否推荐")
    private Boolean isRecommended;

    @Schema(description = "标签")
    private List<String> tags;
}
```

- [ ] **Step 6: 创建 UpdateBookshelfItemDTO**

```java
package com.littlegrid.modules.bookshelf.service.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
@Schema(description = "更新书架条目DTO")
public class UpdateBookshelfItemDTO extends CreateBookshelfItemDTO {
    // 继承所有字段
}
```

- [ ] **Step 7: 创建 BookshelfTagDTO**

```java
package com.littlegrid.modules.bookshelf.service.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Schema(description = "书架标签DTO")
public class BookshelfTagDTO {

    @Schema(description = "标签ID")
    private Long id;

    @Schema(description = "标签名称")
    private String name;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Schema(description = "更新时间")
    private LocalDateTime updateTime;
}
```

- [ ] **Step 8: 创建 CreateBookshelfTagDTO**

```java
package com.littlegrid.modules.bookshelf.service.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
@Schema(description = "创建书架标签DTO")
public class CreateBookshelfTagDTO {

    @NotBlank
    @Size(max = 30)
    @Schema(description = "标签名称", required = true)
    private String name;
}
```

- [ ] **Step 9: 提交**

```bash
git add backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/service/dto/
git commit -m "feat(bookshelf): add DTO classes"
```

---

### Task 6: 创建 BookshelfService

**文件:**
- 创建: `backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/service/BookshelfService.java`

- [ ] **Step 1: 创建 BookshelfService**

```java
package com.littlegrid.modules.bookshelf.service;

import com.littlegrid.exception.BadRequestException;
import com.littlegrid.exception.EntityNotFoundException;
import com.littlegrid.modules.bookshelf.domain.*;
import com.littlegrid.modules.bookshelf.repository.*;
import com.littlegrid.modules.bookshelf.service.dto.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class BookshelfService {

    private final BookshelfCategoryRepository categoryRepository;
    private final BookshelfItemRepository itemRepository;
    private final BookshelfTagRepository tagRepository;

    // ========== 分类管理 ==========

    /**
     * 获取用户的所有分类
     */
    public List<BookshelfCategoryDTO> getCategories(Long userId) {
        List<BookshelfCategory> categories = categoryRepository.findByCreatedByOrderBySortAsc(userId);
        return categories.stream().map(this::toCategoryDTO).collect(Collectors.toList());
    }

    /**
     * 创建分类
     */
    public BookshelfCategoryDTO createCategory(Long userId, CreateBookshelfCategoryDTO dto) {
        // 检查分类名称是否已存在
        List<BookshelfCategory> existing = categoryRepository.findByCreatedByAndName(userId, dto.getName());
        if (!existing.isEmpty()) {
            throw new BadRequestException("该分类名称已存在");
        }

        BookshelfCategory category = new BookshelfCategory();
        category.setName(dto.getName());
        category.setSort(dto.getSort() != null ? dto.getSort() : 0);
        category.setCreatedBy(userId);

        BookshelfCategory saved = categoryRepository.save(category);
        return toCategoryDTO(saved);
    }

    /**
     * 更新分类
     */
    public BookshelfCategoryDTO updateCategory(Long userId, Long id, UpdateBookshelfCategoryDTO dto) {
        BookshelfCategory category = categoryRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException(BookshelfCategory.class, "id", String.valueOf(id)));

        // 检查权限
        if (!category.getCreatedBy().equals(userId)) {
            throw new BadRequestException("无权操作此分类");
        }

        // 检查分类名称是否已存在（排除当前分类）
        List<BookshelfCategory> existing = categoryRepository.findByCreatedByAndName(userId, dto.getName());
        if (!existing.isEmpty() && !existing.get(0).getId().equals(id)) {
            throw new BadRequestException("该分类名称已存在");
        }

        category.setName(dto.getName());
        category.setSort(dto.getSort() != null ? dto.getSort() : 0);

        BookshelfCategory saved = categoryRepository.save(category);
        return toCategoryDTO(saved);
    }

    /**
     * 删除分类
     */
    public void deleteCategory(Long userId, Long id) {
        BookshelfCategory category = categoryRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException(BookshelfCategory.class, "id", String.valueOf(id)));

        // 检查权限
        if (!category.getCreatedBy().equals(userId)) {
            throw new BadRequestException("无权操作此分类");
        }

        // 检查是否有条目依赖
        Long itemCount = itemRepository.countByCategoryIdAndCreatedBy(id, userId);
        if (itemCount > 0) {
            throw new BadRequestException("该分类下有 " + itemCount + " 个条目，无法删除");
        }

        categoryRepository.delete(category);
    }

    /**
     * 初始化默认分类
     */
    public void initDefaultCategories(Long userId) {
        List<BookshelfCategory> existing = categoryRepository.findByCreatedByOrderBySortAsc(userId);
        if (!existing.isEmpty()) return;

        String[][] defaultCategories = {
                {"书", "1"},
                {"电影", "2"},
                {"电视剧", "3"},
                {"番剧", "4"},
                {"游戏", "5"}
        };

        for (String[] cat : defaultCategories) {
            BookshelfCategory category = new BookshelfCategory();
            category.setName(cat[0]);
            category.setSort(Integer.parseInt(cat[1]));
            category.setCreatedBy(userId);
            categoryRepository.save(category);
        }
    }

    // ========== 条目管理 ==========

    /**
     * 获取分类下的条目列表（分页）
     */
    public Page<BookshelfItemDTO> getItems(Long userId, Long categoryId, Pageable pageable) {
        Page<BookshelfItem> items = itemRepository.findByCategoryIdAndCreatedByOrderByCreateTimeDesc(categoryId, userId, pageable);
        return items.map(this::toItemDTO);
    }

    /**
     * 获取条目详情
     */
    public BookshelfItemDTO getItem(Long userId, Long id) {
        List<BookshelfItem> items = itemRepository.findByIdAndCreatedBy(id, userId);
        if (items.isEmpty()) {
            throw new EntityNotFoundException(BookshelfItem.class, "id", String.valueOf(id));
        }
        return toItemDTO(items.get(0));
    }

    /**
     * 创建条目
     */
    public BookshelfItemDTO createItem(Long userId, CreateBookshelfItemDTO dto) {
        BookshelfItem item = new BookshelfItem();
        item.setCategoryId(dto.getCategoryId());
        item.setTitle(dto.getTitle());
        item.setCoverUrl(dto.getCoverUrl());
        item.setSummary(dto.getSummary());
        item.setStartDate(dto.getStartDate());
        item.setEndDate(dto.getEndDate());
        item.setFinishDate(dto.getFinishDate());
        item.setAuthor(dto.getAuthor());
        item.setRating(dto.getRating());
        item.setReview(dto.getReview());
        item.setProgress(dto.getProgress());
        item.setIsRecommended(dto.getIsRecommended() != null ? dto.getIsRecommended() : false);
        item.setCreatedBy(userId);

        // 处理标签
        if (dto.getTags() != null && !dto.getTags().isEmpty()) {
            Set<BookshelfTag> tags = new HashSet<>();
            for (String tagName : dto.getTags()) {
                BookshelfTag tag = findOrCreateTag(userId, tagName);
                tags.add(tag);
            }
            item.setTags(tags);
        }

        BookshelfItem saved = itemRepository.save(item);
        return toItemDTO(saved);
    }

    /**
     * 更新条目
     */
    public BookshelfItemDTO updateItem(Long userId, Long id, UpdateBookshelfItemDTO dto) {
        List<BookshelfItem> items = itemRepository.findByIdAndCreatedBy(id, userId);
        if (items.isEmpty()) {
            throw new EntityNotFoundException(BookshelfItem.class, "id", String.valueOf(id));
        }

        BookshelfItem item = items.get(0);
        item.setCategoryId(dto.getCategoryId());
        item.setTitle(dto.getTitle());
        item.setCoverUrl(dto.getCoverUrl());
        item.setSummary(dto.getSummary());
        item.setStartDate(dto.getStartDate());
        item.setEndDate(dto.getEndDate());
        item.setFinishDate(dto.getFinishDate());
        item.setAuthor(dto.getAuthor());
        item.setRating(dto.getRating());
        item.setReview(dto.getReview());
        item.setProgress(dto.getProgress());
        item.setIsRecommended(dto.getIsRecommended() != null ? dto.getIsRecommended() : false);

        // 处理标签
        if (dto.getTags() != null) {
            Set<BookshelfTag> tags = new HashSet<>();
            for (String tagName : dto.getTags()) {
                BookshelfTag tag = findOrCreateTag(userId, tagName);
                tags.add(tag);
            }
            item.setTags(tags);
        }

        BookshelfItem saved = itemRepository.save(item);
        return toItemDTO(saved);
    }

    /**
     * 删除条目
     */
    public void deleteItem(Long userId, Long id) {
        List<BookshelfItem> items = itemRepository.findByIdAndCreatedBy(id, userId);
        if (items.isEmpty()) {
            throw new EntityNotFoundException(BookshelfItem.class, "id", String.valueOf(id));
        }
        itemRepository.delete(items.get(0));
    }

    // ========== 标签管理 ==========

    /**
     * 获取用户的所有标签
     */
    public List<BookshelfTagDTO> getTags(Long userId) {
        List<BookshelfTag> tags = tagRepository.findByCreatedByOrderByCreateTimeCreateTimeDesc(userId);
        return tags.stream().map(this::toTagDTO).collect(Collectors.toList());
    }

    /**
     * 创建标签
     */
    public BookshelfTagDTO createTag(Long userId, CreateBookshelfTagDTO dto) {
        // 检查标签名称是否已存在
        List<BookshelfTag> existing = tagRepository.findByCreatedByAndName(userId, dto.getName());
        if (!existing.isEmpty()) {
            throw new BadRequestException("该标签名称已存在");
        }

        BookshelfTag tag = new BookshelfTag();
        tag.setName(dto.getName());
        tag.setCreatedBy(userId);

        BookshelfTag saved = tagRepository.save(tag);
        return toTagDTO(saved);
    }

    /**
     * 查找或创建标签
     */
    private BookshelfTag findOrCreateTag(Long userId, String tagName) {
        List<BookshelfTag> existing = tagRepository.findByCreatedByAndName(userId, tagName);
        if (!existing.isEmpty()) {
            return existing.get(0);
        }

        BookshelfTag tag = new BookshelfTag();
        tag.setName(tagName);
        tag.setCreatedBy(userId);
        return tagRepository.save(tag);
    }

    // ========== DTO 转换 ==========

    private BookshelfCategoryDTO toCategoryDTO(BookshelfCategory category) {
        BookshelfCategoryDTO dto = new BookshelfCategoryDTO();
        dto.setId(category.getId());
        dto.setName(category.getName());
        dto.setSort(category.getSort());
        dto.setCreateTime(category.getCreateTime() != null ? category.getCreateTime().toLocalDateTime() : null);
        dto.setUpdateTime(category.getUpdateTime() != null ? category.getUpdateTime().toLocalDateTime() : null);
        return dto;
    }

    private BookshelfItemDTO toItemDTO(BookshelfItem item) {
        BookshelfItemDTO dto = new BookshelfItemDTO();
        dto.setId(item.getId());
        dto.setCategoryId(item.getCategoryId());
        dto.setTitle(item.getTitle());
        dto.setCoverUrl(item.getCoverUrl());
        dto.setSummary(item.getSummary());
        dto.setStartDate(item.getStartDate());
        dto.setEndDate(item.getEndDate());
        dto.setFinishDate(item.getFinishDate());
        dto.setAuthor(item.getAuthor());
        dto.setRating(item.getRating());
        dto.setReview(item.getReview());
        dto.setProgress(item.getProgress());
        dto.setIsRecommended(item.getIsRecommended());

        // 转换标签
        if (item.getTags() != null) {
            List<String> tagNames = item.getTags().stream()
                    .map(BookshelfTag::getName)
                    .collect(Collectors.toList());
            dto.setTags(tagNames);
        }

        dto.setCreateTime(item.getCreateTime() != null ? item.getCreateTime().toLocalDateTime() : null);
        dto.setUpdateTime(item.getUpdateTime() != null ? item.getUpdateTime().toLocalDateTime() : null);
        return dto;
    }

    private BookshelfTagDTO toTagDTO(BookshelfTag tag) {
        BookshelfTagDTO dto = new BookshelfTagDTO();
        dto.setId(tag.getId());
        dto(tag.getName());
        dto.setCreateTime(tag.getCreateTime() != null ? tag.getCreateTime().toLocalDateTime() : null);
        dto.setUpdateTime(tag.getUpdateTime() != null ? tag.getUpdateTime().toLocalDateTime() : null);
        return dto;
    }
}
```

- [ ] **Step 2: 提交**

```bash
git add backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/service/BookshelfService.java
git commit -m "feat(bookshelf): add BookshelfService"
```

---

### Task 7: 创建 BookshelfController

**文件:**
- 创建: `backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/rest/BookshelfController.java`

- [ ] **Step 1: 创建 BookshelfController**

```java
package com.littlegrid.modules.bookshelf.rest;

import com.littlegrid.modules.bookshelf.service.BookshelfService;
import com.littlegrid.modules.bookshelf.service.dto.*;
import com.littlegrid.utils.SecurityUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tools/bookshelf")
@RequiredArgsConstructor
@Tag(name = "书架管理")
public class BookshelfController {

    private final BookshelfService bookshelfService;

    // ========== 分类管理 ==========

    @Operation(summary = "获取分类列表")
    @GetMapping("/categories")
    public ResponseEntity<List<BookshelfCategoryDTO>> getCategories() {
        Long userId = SecurityUtils.getCurrentUserId();
        List<BookshelfCategoryDTO> result = bookshelfService.getCategories(userId);
        return ResponseEntity.ok(result);
    }

    @Operation(summary = "创建分类")
    @PostMapping("/categories")
    public ResponseEntity<BookshelfCategoryDTO> createCategory(@Valid @RequestBody CreateBookshelfCategoryDTO dto) {
        Long userId = SecurityUtils.getCurrentUserId();
        BookshelfCategoryDTO result = bookshelfService.createCategory(userId, dto);
        return ResponseEntity.ok(result);
    }

    @Operation(summary = "更新分类")
    @PutMapping("/categories/{id}")
    public ResponseEntity<BookshelfCategoryDTO> updateCategory(
            @PathVariable Long id,
            @Valid @RequestBody UpdateBookshelfCategoryDTO dto) {
        Long userId = SecurityUtils.getCurrentUserId();
        BookshelfCategoryDTO result = bookshelfService.updateCategory(userId, id, dto);
        return ResponseEntity.ok(result);
    }

    @Operation(summary = "删除分类")
    @DeleteMapping("/categories/{id}")
    public ResponseEntity<Void> deleteCategory(@PathVariable Long id) {
        Long userId = SecurityUtils.getCurrentUserId();
        bookshelfService.deleteCategory(userId, id);
        return ResponseEntity.ok().build();
    }

    // ========== 条目管理 ==========

    @Operation(summary = "获取分类下的条目列表")
    @GetMapping("/items")
    public ResponseEntity<Page<BookshelfItemDTO>> getItems(
            @RequestParam Long categoryId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Long userId = SecurityUtils.getCurrentUserId();
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createTime"));
        Page<BookshelfItemDTO> result = bookshelfService.getItems(userId, categoryId, pageable);
        return ResponseEntity.ok(result);
    }

    @Operation(summary = "获取条目详情")
    @GetMapping("/items/{id}")
    public ResponseEntity<BookshelfItemDTO> getItem(@PathVariable Long id) {
        Long userId = SecurityUtils.getCurrentUserId();
        BookshelfItemDTO result = bookshelfService.getItem(userId, id);
        return ResponseEntity.ok(result);
    }

    @Operation(summary = "创建条目")
    @PostMapping("/items")
    public ResponseEntity<BookshelfItemDTO> createItem(@Valid @RequestBody CreateBookshelfItemDTO dto) {
        Long userId = SecurityUtils.getCurrentUserId();
        BookshelfItemDTO result = bookshelfService.createItem(userId, dto);
        return ResponseEntity.ok(result);
    }

    @Operation(summary = "更新条目")
    @PutMapping("/items/{id}")
    public ResponseEntity<BookshelfItemDTO> updateItem(
            @PathVariable Long id,
            @Valid @RequestBody UpdateBookshelfItemDTO dto) {
        Long userId = SecurityUtils.getCurrentUserId();
        BookshelfItemDTO result = bookshelfService.updateItem(userId, id, dto);
        return ResponseEntity.ok(result);
    }

    @Operation(summary = "删除条目")
    @DeleteMapping("/items/{id}")
    public ResponseEntity<Void> deleteItem(@PathVariable Long id) {
        Long userId = SecurityUtils.getCurrentUserId();
        bookshelfService.deleteItem(userId, id);
        return ResponseEntity.ok().build();
    }

    // ========== 标签管理 ==========

    @Operation(summary = "获取标签列表")
    @GetMapping("/tags")
    public ResponseEntity<List<BookshelfTagDTO>> getTags() {
        Long userId = SecurityUtils.getCurrentUserId();
        List<BookshelfTagDTO> result = bookshelfService.getTags(userId);
        return ResponseEntity.ok(result);
    }

    @Operation(summary = "创建标签")
    @PostMapping("/tags")
    public ResponseEntity<BookshelfTagDTO> createTag(@Valid @RequestBody CreateBookshelfTagDTO dto) {
        Long userId = SecurityUtils.getCurrentUserId();
        BookshelfTagDTO result = bookshelfService.createTag(userId, dto);
        return ResponseEntity.ok(result);
    }
}
```

- [ ] **Step 2: 提交**

```bash
git add backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/rest/BookshelfController.java
git commit -m "feat(bookshelf): add BookshelfController"
```

---

### Task 8: 创建数据库迁移 SQL

**文件:**
- 创建: `backend/sql/bookshelf_tables.sql`

- [ ] **Step 1: 创建数据库迁移文件**

```sql
-- 书架分类表
CREATE TABLE IF NOT EXISTS `bookshelf_category` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    `name` VARCHAR(50) NOT NULL COMMENT '分类名称',
    `sort` INT DEFAULT 0 COMMENT '排序',
    `created_by` VARCHAR(255) NOT NULL COMMENT '创建人',
    `create_by` VARCHAR(255) DEFAULT NULL COMMENT '创建人(兼容字段)',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(255) DEFAULT NULL COMMENT '更新人',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_sort` (`created_by`, `sort`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='书架分类表';

-- 书架标签表
CREATE TABLE IF NOT EXISTS `bookshelf_tag` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    `name` VARCHAR(30) NOT NULL COMMENT '标签名称',
    `created_by` BIGINT NOT NULL COMMENT '创建用户ID',
    `create_by` VARCHAR(255) DEFAULT NULL COMMENT '创建人(兼容字段)',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(255) DEFAULT NULL COMMENT '更新人',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_name_user` (`name`, `created_by`),
    KEY `idx_user` (`created_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='书架标签表';

-- 书架条目表
CREATE TABLE IF NOT EXISTS `bookshelf_item` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    `category_id` BIGINT NOT NULL COMMENT '分类ID',
    `title` VARCHAR(100) NOT NULL COMMENT '标题',
    `cover_url` VARCHAR(500) NOT NULL COMMENT '封面图片URL',
    `summary` VARCHAR(200) DEFAULT NULL COMMENT '一句话简介',
    `start_date` DATE DEFAULT NULL COMMENT '开始观看日期',
    `end_date` DATE DEFAULT NULL COMMENT '结束观看日期',
    `finish_date` DATE DEFAULT NULL COMMENT '完成日期',
    `author` VARCHAR(100) DEFAULT NULL COMMENT '作者/导演',
    `rating` INT DEFAULT NULL COMMENT '评分 1-10',
    `review` TEXT DEFAULT NULL COMMENT '详细评价',
    `progress` VARCHAR(50) DEFAULT NULL COMMENT '观看进度',
    `is_recommended` TINYINT(1) DEFAULT 0 COMMENT '是否推荐',
    `created_by` BIGINT NOT NULL COMMENT '创建用户ID',
    `create_by` VARCHAR(255) DEFAULT NULL COMMENT '创建人(兼容字段)',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(255) DEFAULT NULL COMMENT '更新人',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_category_user` (`category_id`, `created_by`),
    KEY `idx_create_time` (`create_time` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='书架条目表';

-- 条目标签关联表
CREATE TABLE IF NOT EXISTS `bookshelf_item_tag` (
    `item_id` BIGINT NOT NULL COMMENT '条目ID',
    `tag_id` BIGINT NOT NULL COMMENT '标签ID',
    UNIQUE KEY `uk_item_tag` (`item_id`, `tag_id`),
    KEY `idx_item` (`item_id`),
    KEY `idx_tag` (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='条目标签关联表';
```

- [ ] **Step 2: 提交**

```bash
git add backend/sql/bookshelf_tables.sql
git commit -m "feat(bookshelf): add database migration SQL"
```

---

## 前端实现

### Task 9: 创建数据模型类

**文件:**
- 创建: `app/lib/tools/bookshelf/models/category.dart`
- 创建: `app/lib/tools/bookshelf/models/item.dart`
- 创建: `app/lib/tools/bookshelf/models/tag.dart`

- [ ] **Step 1: 创建 Category 模型**

```dart
// app/lib/tools/bookshelf/models/category.dart

class Category {
  final int id;
  final String name;
  final int? sort;
  final DateTime? createTime;
  final DateTime? updateTime;

  Category({
    required this.id,
    required this.name,
    this.sort,
    this.createTime,
   这个.updateTime,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      sort: json['sort'] as int?,
      createTime: json['createTime'] != null
          ? DateTime.parse(json['createTime'])
          : null,
      updateTime: json['updateTime'] != null
          ? DateTime.parse(json['updateTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (sort != null) 'sort': sort,
      if (createTime != null) 'createTime': createTime!.toIso8601String(),
      if (updateTime != null) 'updateTime': updateTime!.toIso8601String(),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    int? sort,
    DateTime? createTime,
    DateTime? updateTime,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      sort: sort ?? this.sort,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }
}
```

- [ ] **Step 2: 创建 Item 模型**

```dart
// app/lib/tools/bookshelf/models/item.dart

class Item {
  final int id;
  final int categoryId;
  final String title;
  final String coverUrl;
  final String? summary;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? finishDate;
  final String? author;
  final int? rating;
  final String? review;
  final String? progress;
  final bool? isRecommended;
  final List<String>? tags;
  final DateTime? createTime;
  final DateTime? updateTime;

  Item({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.coverUrl,
    this.summary,
    this.startDate,
    this.endDate,
    this.finishDate,
    this.author,
    this.rating,
    this.review,
    this.progress,
    this.isRecommended,
    this.tags,
    this.createTime,
    this.updateTime,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as int,
      categoryId: json['categoryId'] as int,
      title: json['title'] as String,
      coverUrl: json['coverUrl'] as String,
      summary: json['summary'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : null,
      finishDate: json['finishDate'] != null
          ? DateTime.parse(json['finishDate'])
          : null,
      author: json['author'] as String?,
      rating: json['rating'] as int?,
      review: json['review'] as String?,
      progress: json['progress'] as String?,
      isRecommended: json['isRecommended'] as bool?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'])
          : null,
      createTime: json['createTime'] != null
          ? DateTime.parse(json['createTime'])
          : null,
      updateTime: json['updateTime'] != null
          ? DateTime.parse(json['updateTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'title': title,
      'coverUrl': coverUrl,
      if (summary != null) 'summary': summary,
      if (startDate != null) 'startDate': startDate!.toIso8601String().substring(0, 10),
      if (endDate != null) 'endDate': endDate!.toIso8601String().substring(0, 10),
      if (finishDate != null) 'finishDate': finishDate!.toIso8601String().substring(0, 10),
      if (author != null) 'author': author,
      if (rating != null) 'rating': rating,
      if (review != null) 'review': review,
      if (progress != null) 'progress': progress,
      if (isRecommended != null) 'isRecommended': isRecommended,
      if (tags != null) 'tags': tags,
    };
  }

  Item copyWith({
    int? id,
    int? categoryId,
    String? title,
    String? coverUrl,
    String? summary,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? finishDate,
    String? author,
    int? rating,
    String? review,
    String? progress,
    bool? isRecommended,
    List<String>? tags,
    DateTime? createTime,
    DateTime? updateTime,
  }) {
    return Item(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      summary: summary ?? this.summary,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      finishDate: finishDate ?? this.finishDate,
      author: author ?? this.author,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      progress: progress ?? this.progress,
      isRecommended: isRecommended ?? this.isRecommended,
      tags: tags ?? this.tags,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }
}
```

- [ ] **Step 3: 创建 Tag 模型**

```dart
// app/lib/tools/bookshelf/models/tag.dart

class Tag {
  final int id;
  final String name;
  final DateTime? createTime;
  final DateTime? updateTime;

  Tag({
    required this.id,
    required this.name,
    this.createTime,
    this.updateTime,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as int,
      name: json['name'] as String,
      createTime: json['createTime'] != null
          ? DateTime.parse(json['createTime'])
          : null,
      updateTime: json['updateTime'] != null
          ? DateTime.parse(json['updateTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
```

- [ ] **Step 4: 提交**

```bash
git add app/lib/tools/bookshelf/models/
git commit -m "feat(bookshelf): add data models"
```

---

### Task 10: 创建 API 服务类

**文件:**
- 创建: `app/lib/tools/bookshelf/services/bookshelf_api.dart`

- [ ] **Step 1: 创建 BookshelfApi 服务**

```dart
// app/lib/tools/bookshelf/services/bookshelf_api.dart

import 'dart:async';
import 'package:http/http.dart';
import '../../../core/services/auth_service.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../models/tag.dart';

class BookshelfApi {
  final AuthService _authService;

  BookshelfApi(this._authService);

  Future<String> get _baseUrl async {
    final config = await _authService.getApiConfig();
    return '${config['baseUrl']}/api/tools/bookshelf';
  }

  Future<String> get _token async {
    return await _authService.getToken();
  }

  Future<Map<String, String>> get _headers async {
    final token = await _token;
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // ========== 分类管理 ==========

  Future<List<Category>> getCategories() async {
    final baseUrl = await _baseUrl;
    final headers = await _headers;

    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = _parseResponse(response.body)['data'] as List;
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('获取分类列表失败: ${response.statusCode}');
    }
  }

  Future<Category> createCategory(String name, {int? sort}) async {
    final baseUrl = await _baseUrl;
    final headers = await _headers;

    final response = await http.post(
      Uri.parse('$baseUrl/categories'),
      headers: headers,
      body: _encodeBody({'name': name, if (sort != null) 'sort': sort}),
    );

    if (response.statusCode == 200) {
      return Category.fromJson(_parseResponse(response.body)['data']);
    } else {
      throw Exception('创建分类失败: ${response.statusCode}');
    }
  }

  Future<Category> updateCategory(int id, String name, {int? sort}) async {
    final baseUrl = await _baseUrl;
    final headers = await _headers;

    final response = await http.put(
      Uri.parse('$baseUrl/categories/$id'),
      headers: headers,
      body: _encodeBody({'name': name, if (sort != null) 'sort': sort}),
    );

    if (response.statusCode == 200) {
      return Category.fromJson(_parseResponse(response.body)['data']);
    } else {
      throw Exception('更新分类失败: ${response.statusCode}');
    }
  }

  Future<void> deleteCategory(int id) async {
    final baseUrl = await _baseUrl;
    final headers = await _headers;

    final response = await http.delete(
      Uri.parse('$baseUrl/categories/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('删除分类失败: ${response.statusCode}');
    }
  }

  // ========== 条目管理 ==========

  Future<Map<String, dynamic>> getItems(int categoryId, {int page = 0, int size = 20}) async {
    final = await _baseUrl;
    final headers = await _headers;

    final response = await http.get(
      Uri.parse('$baseUrl/items?categoryId=$categoryId&page=$page&size=$size'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return _parseResponse(response.body)['data'] as Map<String, dynamic>;
    } else {
      throw Exception('获取条目列表失败: ${response.statusCode}');
    }
  }

  Future<Item> getItem(int id) async {
    final baseUrl = await _baseUrl;
    final headers = await _headers;

    final response = await http.get(
      Uri.parse('$baseUrl/items/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Item.fromJson(_parseResponse(response.body)['data']);
    } else {
      throw Exception('获取条目详情失败: ${response.statusCode}');
    }
  }

  Future<Item> createItem(Map<String, dynamic> data) async {
    final baseUrl = await _baseUrl;
    final headers = await _headers;

    final response = await http.post(
      Uri.parse('$baseUrl/items'),
      headers: headers,
      body: _encodeBody(data),
    );

    if (response.statusCode == 200) {
      return Item.fromJson(_parseResponse(response.body)['data']);
    } else {
      throw Exception('创建条目失败: ${response.statusCode}');
    }
  }

  Future<Item> updateItem(int id, Map<String, dynamic> data) async {
    final baseUrl = await _baseUrl;
    final headers = await _headers;

    final response = await http.put(
      Uri.parse('$baseUrl/items/$id'),
      headers: headers,
      body: _encodeBody(data),
    );

    if (response.statusCode == 200) {
      return Item.fromJson(_parseResponse(response.body)['data']);
    } else {
      throw Exception('更新条目失败: ${response.statusCode}');
    }
  }

  Future<void> deleteItem(int id) async {
    final baseUrl = await _baseUrl;
    final headers = await _headers;

    final response = await http.delete(
      Uri.parse('$baseUrl/items/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('删除条目失败: ${response.statusCode}');
    }
  }

  // ========== 标签管理 ==========

  Future<List<Tag>> getTags() async {
    final baseUrl = await _baseUrl;
    final headers = await _headers;

    final response = await http.get(
      Uri.parse('$baseUrl/tags'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = _parseResponse(response.body)['data'] as List;
      return data.map((json) => Tag.fromJson(json)).toList();
    } else {
      throw Exception('获取标签列表失败: ${response.statusCode}');
    }
  }

  Future<Tag> createTag(String name) async {
    final baseUrl = await _baseUrl;
    final headers = await _headers;

    final response = await http.post(
      Uri.parse('$baseUrl/tags'),
      headers: headers,
      body: _encodeBody({'name': name}),
    );

    if (response.statusCode == 200) {
      return Tag.fromJson(_parseResponse(response.body)['data']);
    } else {
      else {
        throw Exception('创建标签失败: ${response.statusCode}');
      }
    }
  }

  // ========== 辅助方法 ==========

  Map<String, dynamic> _parseResponse(String body) {
    // 假设响应格式为 {"code": 200, "data": ...}
    // 实际根据后端响应格式调整可能需要使用 fastjson2
    import 'dart:convert';
    return jsonDecode(body);
  }

  String _encodeBody(Map<String, dynamic> data) {
    import 'dart:convert';
    return jsonEncode(data);
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/bookshelf/services/bookshelf_api.dart
git commit -m "feat(bookshelf): add BookshelfApi service"
```

---

### Task 11: 创建 BookshelfProvider

**文件:**
- 创建: `app/lib/tools/bookshelf/providers/bookshelf_provider.dart`

- [ ] **Step 1: 创建 BookshelfProvider**

```dart
// app/lib/tools/bookshelf/providers/bookshelf_provider.dart

import 'package:flutter/foundation.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../models/tag.dart';

class BookshelfProvider extends ChangeNotifier {
  // ========== 分类状态 ==========

  List<Category> _categories = [];
  List<Category> get categories => _categories;
  Category? _selectedCategory;
  Category? get selectedCategory => _selectedCategory;

  void setCategories(List<Category> categories) {
    _categories = categories;
    if (_categories.isNotEmpty && _selectedCategory == null) {
      _selectedCategory = _categories.first;
    }
    notifyListeners();
  }

  void selectCategory(Category category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void addCategory(Category category) {
    _categories.add(category);
    notifyListeners();
  }

  void updateCategory(Category category) {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      notifyListeners();
    }
  }

  void removeCategory(int categoryId) {
    _categories.removeWhere((c) => c.id == categoryId);
    if (_selectedCategory?.id == categoryId && _categories.isNotEmpty) {
      _selectedCategory = _categories.first;
    }
    notifyListeners();
  }

  // ========== 条目状态 ==========

  List<Item> _items = [];
  List<Item> get items => _items;
  bool _loadingItems = false;
  bool get loadingItems => _loadingItems;

  void setItems(List<Item> items) {
    _items = items;
    _loadingItems = false;
    notifyListeners();
  }

  void setLoadingItems(bool loading) {
    _loadingItems = loading;
    notifyListeners();
  }

  void addItem(Item item) {
    _items.insert(0, item);
    notifyListeners();
  }

  void updateItem(Item item) {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
      notifyListeners();
    }
  }

  void removeItem(int itemId) {
    _items.removeWhere((i) => i.id == itemId);
    notifyListeners();
  }

  // ========== 标签状态 ==========

  List<Tag> _tags = [];
  List<Tag> get tags => _tags;

  void setTags(List<Tag> tags) {
    _tags = tags;
    notifyListeners();
  }

  void addTag(Tag tag) {
    _tags.add(tag);
    notifyListeners();
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/bookshelf/providers/bookshelf_provider.dart
git commit -m "feat(bookshelf): add BookshelfProvider"
```

---

### Task 12: 创建 CategoryTab 组件

**文件:**
- 创建: `app/lib/tools/bookshelf/widgets/category_tab.dart`

- [ ] **Step 1: 创建 CategoryTab 组件**

```dart
// app/lib/tools/bookshelf/widgets/category_tab.dart

import 'package:flutter/material.dart';
import '../models/category.dart';
import '../providers/bookshelf_provider.dart';

class CategoryTab extends StatelessWidget {
  final List<Category> categories;
  final Category? selectedCategory;
  final Function(Category) onCategoryTap;

  const CategoryTab({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory?.id == category.id;
          return _buildCategoryChip(context, category, isSelected);
        },
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, Category category, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => onCategoryTap(category),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            category.name,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/bookshelf/widgets/category_tab.dart
git commit -m "feat(bookshelf): add CategoryTab widget"
```

---

### Task 13: 创建 ItemCard 组件

**文件:**
- 创建: `app/lib/tools/bookshelf/widgets/item_card.dart`

- [ ] **Step 1: 创建 ItemCard 组件**

```dart
// app/lib/tools/bookshelf/widgets/item_card.dart

import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final Function() onTap;
  final Function() onDelete;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onDelete();
      },
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('确认删除'),
            content: const Text('确定要删除这个条目吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('删除'),
              ),
            ],
          ),
        ) ?? false;
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        child: const Padding(
          padding: EdgeInsets.only(right: 20),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 封面图片
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child: Image.network(
                      item.coverUrl,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 120,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported, size: 40),
                        );
                      },
                    ),
                  ),
                  // 评分徽章
                  if (item.rating != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${item.rating}分',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // 标题
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/bookshelf/widgets/item_card.dart
git commit -m "feat(bookshelf): add ItemCardCard widget"
```

---

### Task 14: 创建 RatingWidget 组件

**文件:**
- 创建: `app/lib/tools/bookshelf/widgets/rating_widget.dart`

- [ ] **Step 1: 创建 RatingWidget 组件**

```dart
// app/lib/tools/bookshelf/widgets/rating_widget.dart

import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final int? rating;
  final bool editable;
  final Function(int)? onRatingTap;

  const RatingWidget({
    super.key,
    this.rating,
    this.editable = false,
    this.onRatingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: List.generate(10, (index) {
        final starValue = index + 1;
        final isActive = rating != null && starValue <= rating!;
        return _buildStar(context, starValue, isActive);
      }),
    );
  }

  Widget _buildStar(BuildContext context, int starValue, bool isActive) {
    return GestureDetector(
      onTap: editable ? () => onRatingTap?.call(starValue) : null,
      child: Icon(
        Icons.star,
        color: isActive ? Colors.yellow : Colors.grey.shade300,
        size: 24,
      ),
    );
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/bookshelf/widgets/rating_widget.dart
git commit -m "feat(bookshelf): add RatingWidget widget"
```

---

### Task 15: 创建 TagSelector 组件

**文件:**
- 创建: `app/lib/tools/bookshelf/widgets/tag_selector.dart`

- [ ] **Step 1: 创建 TagSelector 组件**

```dart
// app/lib/tools/bookshelf/widgets/tag_selector.dart

import 'package:flutter:flutter.dart';
import '../models/tag.dart';

class TagSelector extends StatefulWidget {
  final List<Tag> allTags;
  final List<String> selectedTags;
  final Function(List<String>) onTagsChanged;
  final Function(String) onCreateTag;

  const TagSelector({
    super.key,
    required this.allTags,
    required this.selectedTags,
    required this.onTagsChanged,
    required this.onCreateTag,
  });

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  late List<String> _selectedTags;
  final TextEditingController _newTagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.selectedTags);
  }

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签列表
        Wrap(
          spacing: 8,
          children: widget.allTags.map((tag) {
            final isSelected = _selectedTags.contains(tag.name);
            return _buildTagChip(tag, isSelected);
          }).toList(),
        ),
        // 新建标签输入框
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newTagController,
                decoration: InputDecoration(
                  hintText: '新建标签',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final tagName = _newTagController.text.trim();
                if (tagName.isNotEmpty) {
                  widget.onCreateTag(tagName);
                  _newTagController.clear();
                }
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagChip(Tag tag, bool isSelected) {
    return FilterChip(
      label: Text(tag.name),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedTags.add(tag.name);
          } else {
            _selectedTags.remove(tag.name);
          }
          widget.onTagsChanged(_selectedTags);
        });
      },
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue,
    );
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/bookshelf/widgets/tag_selector.dart
git commit -m "feat(bookshelf): add TagSelector widget"
```

---

### Task 16: 创建 DatePickerField 组件

**文件:**
- 创建: `app/lib/tools/bookshelf/widgets/date_picker_field.dart`

- [ ] **Step 1: 创建 DatePickerField 组件**

```dart
// app/lib/tools/bookshelf/widgets/date_picker_field.dart

import 'package:flutter/material.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final Function(DateTime?) onDateChanged;

  const DatePickerField({
    super.key,
    required this.label,
    this.date,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const Spacer(),
            Text(
              date != null ? _formatDate(date!) : '未设置',
              style: TextStyle(
                color: date != null ? Colors.black87 : Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.calendar_today, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDateChanged(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/bookshelf/widgets/date_picker_field.dart
git commit -m "feat(bookshelf): add DatePickerField widget"
```

---

### Task 17: 创建 CategoryPage 分类管理页

**文件:**
- 创建: `app/lib/tools/bookshelf/pages/category_page.dart`

- [ ] **Step 1: 创建 CategoryPage**

```dart
// app/lib/tools/bookshelf/pages/category_page.dart

import 'package:flutter/material.dart';
import '../../core/services/image_upload_service.dart';
import '../models/category.dart';
import '../providers/bookshelf_provider.dart';
import '../services/bookshelf_api.dart';

class CategoryPage extends StatefulWidget {
  final BookshelfProvider provider;
  final BookshelfApi api;

  const CategoryPage({
    super.key,
    required this.provider,
    required this.api,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late List<Category> _categories;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.provider.categories);
    _loading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分类管理'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return _buildCategoryItem(context, category, index);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, Category category, int index) {
    return Dismissible(
      key: Key(category(category.id.toString())),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _deleteCategory(category.id),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmDialog(context);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        child: const Padding(
          padding: EdgeInsets.only(right: 20),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      child: ListTile(
        title: Text(category.name),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _showEditCategoryDialog(context, category),
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个分类吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showAddCategoryDialog(BuildContext context) {
    _showCategoryDialog(context, null, '添加分类');
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    _showCategoryDialog(context, category, '编辑分类');
  }

  void _showCategoryDialog(BuildContext context, Category? category, String title) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final sortController = TextEditingController(text: category?.sort?.toString() ?? '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '分类名称',
                hintText: '请输入分类名称',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: sortController,
              decoration: const InputDecoration(
                labelText: '排序',
                hintText: '请输入排序值',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => _saveCategory(context, category, nameController.text, sortController.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCategory(
    BuildContext context,
    Category? category,
    String name,
    String sortText,
  ) async {
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入分类名称')),
      );
      return;
    }

    try {
      final sort = int.tryParse(sortText) ?? 0;
      if (category != null) {
        // 更新
        final updated = await widget.api.updateCategory(category!.id, name, sort: sort);
        widget.provider.updateCategory(updated);
      } else {
        // 新建
        final created = await widget.api.createCategory(name, sort: sort);
        widget.provider.addCategory(created);
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    }
  }

  Future<void> _deleteCategory(int categoryId) async {
    try {
      await widget.api.deleteCategory(categoryId);
      widget.provider.removeCategory(categoryId);
      setState(() {
        _categories.removeWhere((c) => c.id == categoryId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败: $e')),
      );
    }
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/bookshelf/pages/category_page.dart
git commit -m "feat(bookshelf): add CategoryPage"
```

---

### Task 18: 创建 ItemDetailPage 详情页

**文件:**
- 创建: `app/lib/tools/bookshelf/pages/item_detail_page.dart`

- [ ] **Step 1: 创建 ItemDetailPage**

```dart
// app/lib/tools/bookshelf/pages/item_detail_page.dart

import 'package:flutter/material.dart';
import '../../core/services/image_upload_service.dart';
import '../models/item.dart';
import '../models/category.dart';
import '../models/tag.dart';
import '../providers/bookshelf_provider.dart';
import '../services/bookshelf_api.dart';
import '../widgets/rating_widget.dart';
import '../widgets/tag_selector.dart';
import '../widgets/date_picker_field.dart';

class ItemDetailPage extends StatefulWidget {
  final int itemId;
  final BookshelfProvider provider;
  final BookshelfApi api;
  final List<Category> categories;

  const ItemDetailPage({
    super.key,
    required this.itemId,
    required this.provider,
    required this.api,
    required this.categories,
  });

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  Item? _item;
  bool _loading = true;
  bool _isEditMode = false;
  bool _saving = false;

  // 编辑表单字段
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _progressController = TextEditingController();

  Category? _selectedCategory;
  int? _rating;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _finishDate;
  bool? _isRecommended;
  List<String> _selectedTags = [];
  String _coverUrl = '';

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _authorController.dispose();
    _reviewController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _loadItem() async {
    try {
      final item = await widget.api.getItem(widget.itemId);
      setState(() {
        _item = item;
        _loading = false;
        _coverUrl = item.coverUrl;
        _titleController.text = item.title;
        _summaryController.text = item.summary ?? '';
        _authorController.text = item.author ?? '';
        _reviewController.text = item.review ?? '';
        _progressController.text = item.progress ?? '';
        _selectedCategory = widget.categories.firstWhere(
          (c) => c.id == item.categoryId,
          orElse: () => widget.categories.first,
        );
        _rating = item.rating;
        _startDate = item.startDate;
        _endDate = item.endDate;
        _finishDate = item.finishDate;
        _isRecommended = item.isRecommended;
        _selectedTags = item.tags ?? [];
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '编辑条目' : '条目详情'),
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditMode = true),
            ),
        ],
      ),
      body: _isEditMode ? _buildEditMode() : _buildViewMode(),
    );
  }

  Widget _buildViewMode() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面大图
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _coverUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported, size: 60),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // 标题
          Text(
            _item!.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // 分类标签
          if (_selectedCategory != null)
            Chip(
              label: Text(_selectedCategory!.name),
              backgroundColor: Colors.blue.shade100,
            ),
          const SizedBox(height: 16),
          // 评分
          if (_rating != null)
            Row(
              children: [
                const Text('评分：', style: TextStyle(fontSize: 16)),
                RatingWidget(rating: _rating),
              ],
            ),
          const SizedBox(height: 8),
          // 作者
          if (_item!.author != null && _item!.author!.isNotEmpty) ...[
            Text('作者：${_item!.author}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
          ],
          // 日期信息
          if (_item!.startDate != null)
            Text('开始时间：${_formatDate(_item!.startDate!)}', style: const TextStyle(fontSize: 14)),
          if (_item!.endDate != null)
            Text('结束时间：${_formatDate(_item!.endDate!)}', style: const TextStyle(fontSize: 14)),
          if (_item!.finishDate != null)
            Text('完成时间：${_formatDate(_item!.finishDate!)}', style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          // 一句话简介
          if (_item!.summary != null && _item!.summary!.isNotEmpty) ...[
            Text(_item!.summary!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
          ],
          // 标签
          if (_item!.tags != null && _item!.tags!.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              children: _item!.tags!.map((tag) {
                return Chip(label: Text(tag));
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          // 观看进度
          if (_item!.progress != null && _item!.progress!.isNotEmpty) ...[
            Text('进度：${_item!.progress}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
          ],
          // 推荐标记
          if (_item!.isRecommended == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('推荐', style: TextStyle(color: Colors.white)),
            ),
          const SizedBox(height: 16),
          // 详细评价
          if (_item!.review != null && _item!.review(review.isNotEmpty))
            Text(
              '评价',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 8),
          Text(_item!.review!, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildEditMode() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面上传
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => _uploadCover(),
              child: Stack(
                children: [
                  if (_coverUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _coverUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload, size: 48, color: Colors.grey.shade400),
                          SizedBox(height: 8),
                          Text('点击上传封面', style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  const Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 标题输入
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '标题 *',
              hintText: '请输入标题',
            ),
          ),
          const SizedBox(height: 16),
          // 分类选择
          DropdownButtonFormField<Category>(
            value: _selectedCategory,
            decoration: const InputDecoration(labelText: '分类 *'),
            items: widget.categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (category) {
              setState(() => _selectedCategory = category);
            },
          ),
          const SizedBox(height: 16),
          // 一句话简介
          TextField(
            controller: _summaryController,
            decoration: const InputDecoration(
              labelText: '一句话简介',
              hintText: '简单描述一下',
            ),
          ),
          const SizedBox(height: 16),
          // 作者输入
          TextField(
            controller: _authorController,
            decoration: const InputDecoration(
              labelText: '作者/导演',
              hintText: '请输入作者或导演',
            ),
          ),
          const SizedBox(height: 16),
          // 评分
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('评分', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              RatingWidget(
                rating: _rating,
                editable: true,
                onRatingTap: (value) {
                  setState(() => _rating = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 日期选择
          DatePickerField(
            label: '开始时间',
            date: _startDate,
            onDateChanged: (date) {
              setState(() => _startDate = date);
            },
          ),
          const SizedBox(height: 16),
          DatePickerField(
            label: '结束时间',
            date: _endDate,
            onDateChanged: (date) {
              setState(() => _endDate = date);
            },
          ),
          const SizedBox(height: 16),
          DatePickerField(
            label: '完成时间',
            date: _finishDate,
            onDateChanged: (date) {
              setState(() => _finishDate = date);
            },
          ),
          const SizedBox(height: 16),
          // 标签选择
          Text('标签', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          TagSelector(
            allTags: widget.provider.tags.map((t) => Tag(id: t.id, name: t.name)).toList(),
            selectedTags: _selectedTags,
            onTagsChanged: (tags) {
              setState(() => _selectedTags = tags);
            },
            onCreateTag: (tagName) {
              _createNewTag(tagName);
            },
          ),
          const SizedBox(height: 16),
          // 观看进度
          TextField(
            controller: _progressController,
            decoration: const InputDecoration(
              labelText: '观看进度',
              hintText: '如：看了3集',
            ),
          ),
          const SizedBox(height: 16),
          // 推荐标记
          SwitchListTile(
            title: const Text('推荐'),
            value: _isRecommended ?? false,
            onChanged: (value) {
              setState(() => _isRecommended = value);
            },
          ),
          const SizedBox(height: 16),
          // 详细评价
          TextField(
            controller: _reviewController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: '详细评价',
              hintText: '写下你的评价...',
            ),
          ),
          const SizedBox(height: 32),
          // 保存/取消按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _isEditMode = false),
                  child: const Text('取消'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveItem,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('保存'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _uploadCover() async {
    try {
      final imageUploadService = ImageUploadService();
      final url = await imageUploadService.uploadImage('bookshelf');
      if (url != null) {
        setState(() => _coverUrl = url!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('上传失败: $e')),
        );
      }
    }
  }

  Future<void> _createNewTag(String tagName) async {
    try {
      final imageUploadService = ImageUploadService();
      // 注意：这里需要调用 tag 创建 API，暂时使用模拟
      setState(() {
        _selectedTags.add(tagName);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建标签失败: $e')),
        );
      }
    }
  }

  Future<void> _saveItem() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入标题')),
      );
      return;
    }

    if (_coverUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请上传封面图片')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择分类')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final data = {
        'categoryId': _selectedCategory!.id,
        'title': _titleController.text,
        'coverUrl': _coverUrl,
        'summary': _summaryController.text.isEmpty ? null : _summaryController.text,
        'author': _authorController.text.isEmpty ? null : _authorController.text,
        'rating': _rating,
        'startDate': _startDate?.toIso8601String().substring(0, 10),
        'endDate': _endDate?.toIso8601String().substring(0, 10),
        'finishDate': _finishDate?.toIso8601String().substring(0, 10),
        'review': _reviewController.text.isEmpty ? null : _reviewController.text,
        'progress': _progressController.text.isEmpty ? null : _progressController.text,
        'isRecommended': _isRecommended,
        'tags': _selectedTags,
      };

      final updated = await widget.api.updateItem(widget.itemId, data);
      widget.provider.updateItem(updated);

      setState(() {
        _item = updated;
        _isEditMode = false;
        _saving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存成功')),
        );
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
`````

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/bookshelf/pages/item_detail_page.dart
git commit -m "feat(bookshelf): add ItemDetailPage"
```

---

### Task 19: 创建 AddItemDialog 添加条目弹窗

**文件:**
- 创建: `app/lib/tools/bookshelf/pages/add_item_dialog.dart`

- [ ] **Step 1: 创建 AddItemDialog**

```dart
// app/lib/tools/bookshelf/pages/add_item_dialog.dart

import 'package:flutter/material.dart';
import '../../core/services/image_upload_service.dart';
import '../models/item.dart';
import '../models/category.dart';
import '../providers/bookshelf_provider.dart';
import '../services/bookshelf_api.dart';
import '../widgets/rating_widget.dart';
import '../widgets/tag_selector.dart';
import '../widgets/date_picker_field.dart';

class AddItemDialog extends StatefulWidget {
  final Category? defaultCategory;
  final BookshelfProvider provider;
  final BookshelfApi api;
  final List<Category> categories;

  const AddItemDialog({
    super.key,
    this.defaultCategory,
    required this.provider,
    required this.api,
    required this.categories,
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  bool _saving = false;

  // 表单字段
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _progressController = TextEditingController();

  Category? _selectedCategory;
  int? _rating;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _finishDate;
  bool? _isRecommended;
  List<String> _selectedTags = [];
  String _coverUrl = '';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.defaultCategory;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _authorController.dispose();
    _reviewController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.max(500, MediaQuery.of(context).size.width * 0.9),
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  const Text('添加条目', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // 表单内容
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 封面上传
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () => _uploadCover(),
                        child: Stack(
                          children: [
                            if (_coverUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _coverUrl,
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cloud_upload, size: 40, color: Colors.grey.shade400),
                                    SizedBox(height: 8),
                                    Text('点击上传封面 *', style: TextStyle(color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 标题输入
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: '标题 *',
                        hintText: '请输入标题',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 分类选择
                    DropdownButtonFormField<Category>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: '分类 *'),
                      items: widget.categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (category) {
                        setState(() => _selectedCategory = category);
                      },
                    ),
                    const SizedBox(height: 16),
                    // 一句话简介
                    TextField(
                      controller: _summaryController,
                      decoration: const InputDecoration(
                        labelText: '一句话简介',
                        hintText: '简单描述一下',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 作者输入
                    TextField(
                      controller: _authorController,
                      decoration: const InputDecoration(
                        labelText: '作者/导演',
                        hintText: '请输入作者或导演',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 评分
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('评分', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        RatingWidget(
                          rating: _rating,
                          editable: true,
                          onRatingTap: (value) {
                            setState(() => _rating = value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 日期选择
                    DatePickerField(
                      label: '开始时间',
                      date: _startDate,
                      onDateChanged: (date) {
                        setState(() => _startDate = date);
                      },
                    ),
                    const SizedBox(height: 8),
                    DatePickerField(
                      label: '结束时间',
                      date: _endDate,
                      onDateChanged: (date) {
                        setState(() => _endDate = date);
                      },
                    ),
                    const SizedBox(height: 8),
                    DatePickerField(
                      label: '完成时间',
                      date: _finishDate,
                      onDateChanged: (date) {
                        setState(() => _finishDate = date);
                      },
                    ),
                    const SizedBox(height: 16),
                    // 标签选择
                    Text('标签', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    TagSelector(
                      allTags: widget.provider.tags.map((t) => Tag(id: t.id, name: t.name)).toList(),
                      selectedTags: _selectedTags,
                      onTagsChanged: (tags) {
                        setState(() => _selectedTags = tags);
                      },
                      onCreateTag: (tagName) {
                        _createNewTag(tagName);
                      },
                    ),
                    const SizedBox(height: 16),
                    // 观看进度
                    TextField(
                      controller: _progressController,
                      decoration: const InputDecoration(
                        labelText: '观看进度',
                        hintText: '如：看了3集',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 推荐标记
                    SwitchListTile(
                      title: const Text('推荐'),
                      value: _isRecommended ?? false,
                      onChanged: (value) {
                        setState(() => _isRecommended = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    // 详细评价
                    TextField(
                      controller: _reviewController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: '详细评价',
                        hintText: '写下你的评价...',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 底部按钮
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shadeares)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveItem,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('添加'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadCover() async {
    try {
      final imageUploadService = ImageUploadService();
      final url = await imageUploadService.uploadImage('bookshelf');
      if (url != null) {
        setState(() => _coverUrl = url!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('上传失败: $e')),
        );
      }
    }
  }

  Future<void> _createNewTag(String tagName) async {
    try {
      final imageUploadService = ImageUploadService();
      // 注意：这里需要调用 tag 创建 API，暂时使用模拟
      setState(() {
        _selectedTags.add(tagName);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建标签失败: $e')),
        );
      }
    }
  }

  Future<void> _saveItem() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入标题')),
      );
      return;
    }

    if (_coverUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请上传封面图片')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择分类')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final data = {
        'categoryId': _selectedCategory!.id,
        'title': _titleController.text,
        'coverUrl': _coverUrl,
        'summary': _summaryController.text.isEmpty ? null : _summaryController.text,
        'author': _authorController.text.isEmpty ? null : _authorController.text,
        'rating': _rating,
        'startDate': _startDate?.toIso8601String().substring(0, 10),
        'endDate': _endDate?.toIso8601String().substring(0, 10),
        'finishDate': _finishDate?.toIso8601String().substring(0, 10),
        'review': _reviewController.text.isEmpty ? null : _reviewController.text,
        'progress': _progressController.text.isEmpty ? null : _progressController.text,
        'isRecommended': _isRecommended,
        'tags': _selectedTags,
      };

      final created = await widget.api.createItem(data);
      widget.provider.addItem(created);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('添加成功')),
        );
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加失败: $e')),
        );
      }
    }
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/bookshelf/pages/add_item_dialog.dart
git commit -m "feat(bookshelf): add AddItemDialog"
```

---

### Task 20: 创建 BookshelfPage 主页面

**文件:**
- 创建: `app/lib/tools/bookshelf/pages/bookshelf_page.dart`

- [ ] **Step 1: 创建 BookshelfPage**

```dart
// app/lib/tools/bookshelf/pages/bookshelf_page.dart

import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/providers/app_provider.dart';
import '../../core/services/tool_registry.dart';
import '../models/category.dart';
import '../providers/bookshelf_provider.dart';
import '../services/bookshelf_api.dart';
import '../widgets/category_tab.dart';
import '../widgets/item_card.dart';
import './category_page.dart';
import './item_detail_page.dart';
import './add_item_dialog.dart';

class BookshelfPage extends StatefulWidget {
  const BookshelfPage({super.key});

  @override
  State<BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends State<BookshelfPage> {
  late BookshelfProvider _provider;
  late BookshelfApi _api;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _provider = BookshelfProvider();
    _initialize();
  }

  Future<void> _initialize() async {
    final authService = AuthService();
    _api = BookshelfApi(authService);

    // 加载分类列表
    await _loadCategories();
    // 加载标签列表
    await _loadTags();
    // 加载当前分类的条目
    if (_provider.selectedCategory != null) {
      await _loadItems(_provider.selectedCategory!.id);
    }

    setState(() => _initialized = true);
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _api.getCategories();
      _provider.setCategories(categories);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载分类失败: $e')),
        );
      }
    }
  }

  Future<void> _loadTags() async {
    try {
      final tags = await _api.getTags();
      _provider.setTags(tags);
    } catch (e) {
      // 标签加载失败不影响使用
    }
  }

  Future<void> _loadItems(int categoryId) async {
    _provider.setLoadingItems(true);
    try {
      final result = await _api.getItems(categoryId);
      final List<dynamic> content = result['content'] as List;
      final items = content.map((json) => Item.fromJson(json)).toList();
      _provider.setItems(items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载条目失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ChangeNotifierProvider<BookshelfProvider>(
      create: (_) => _provider,
      child: Consumer<BookshelfProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('书架'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => _showCategoryPage(context),
                ),
              ],
            ),
            body: Column(
              children: [
                // 分类切换
                CategoryTab(
                  categories: provider.categories,
                  selectedCategory: provider.selectedCategory,
                  onCategoryTap: (category) {
                    provider.selectCategory(category);
                    _loadItems(category.id);
                  },
                ),
                // 条目列表
                Expanded(
                  child: _buildItemsGrid(context, provider),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddItemDialog(context),
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemsGrid(BuildContext context, BookshelfProvider provider) {
    if (provider.loadingItems) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              '还没有条目',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              '点击右下角按钮添加',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: provider.items.length,
      itemBuilder: (context, index) {
        final item = provider.items[index];
        return ItemCard(
          item: item,
          onTap: () => _showItemDetail(context, item.id),
          onDelete: () => _deleteItem(item.id),
        );
      },
    );
  }

  void _showCategoryPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryPage(
          provider: _provider,
          api: _api,
        ),
      ),
    );
  }

  void _showItemDetail(BuildContext context, int itemId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ItemDetailPage(
          itemId: itemId,
          provider: _provider,
          api: _api,
          categories: _provider.categories,
        ),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(
        defaultCategory: _provider.selectedCategory,
        provider: _provider,
        api: _api,
        categories: _provider.categories,
      ),
    );
  }

  Future<void> _deleteItem(int itemId) async {
    try {
      await _api.deleteItem(itemId);
      _provider.removeItem(itemId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/bookshelf/pages/bookshelf_page.dart
git commit -m "feat(bookshelf): add BookshelfPage"
```

---

### Task 21: 创建 BookshelfTool 工具模块

**文件:**
- 创建: `app/lib/tools/bookshelf/bookshelf_tool.dart`

- [ ] **Step 1: 创建 BookshelfTool**

```dart
// app/lib/tools/bookshelf/bookshelf_tool.dart

import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import '../../core/services/auth_service.dart';
import '../bookshelf_page.dart';

class BookshelfTool implements ToolModule {
  @override
  String get id => 'bookshelf';

  @override
  String get name => '书架';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.menu_book;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const BookshelfPage();
  }

  @override
  ToolSettings? get settings => null;

  @override
  Future<void> onInit() async {
    // 首次初始化逻辑，可以在这里检查并创建默认分类
    // 这部分逻辑可以移到 BookshelfPage 中
  }

  @override
  Future<void> onDispose() async {}

  @override
  void onEnter() {}

  @override
  void onExit() {}
}
```

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/bookshelf/bookshelf_tool.dart
git commit -m "feat(bookshelf): add BookshelfTool"
```

---

### Task 22: 注册 BookshelfTool 到 ToolRegistry

**文件:**
- 修改: `app/lib/main.dart`

- [ ] **Step 1: 在 main.dart 中注册 BookshelfTool**

找到 `ToolRegistry.register(...)` 部分并添加 BookshelfTool

```dart
import 'tools/bookshelf/bookshelf_tool.dart';

void main() {
  // ... 其他代码

  // 注册书架工具
  ToolRegistry.register(BookshelfTool());

  // ... 其他代码
}
```

- [ ] **Step 2: 提交**

```bash
git add app/lib/main.dart
git commit -m "feat(bookshelf): register BookshelfTool in main.dart"
```

---

## 测试

### Task 23: 后端单元测试

**文件:**
- 创建: `backend/eladmin-tools/src/test/java/com/littlegrid/modules/bookshelf/service/BookshelfServiceTest.java`

- [ ] **Step 1: 创建 BookshelfServiceTest**

```java
package com.littlegrid.modules.bookshelf.service;

import com.littlegrid.modules.bookshelf.domain.*;
import com.littlegrid.modules.bookshelf.repository.*;
import com.littlegrid.modules.bookshelf.service.dto.*;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@SpringBootTest
@ExtendWith(MockitoExtension.class)
class BookshelfServiceTest {

    @Mock
    private BookshelfCategoryRepository categoryRepository;

    @Mock
    private BookshelfItemRepository itemRepository;

    @Mock
    private BookshelfTagRepository tagRepository;

    @InjectMocks
    private BookshelfService bookshelfService;

    @Test
    void shouldCreateCategory() {
        // Given
        Long userId = 1L;
        CreateBookshelfCategoryDTO dto = new CreateBookshelfCategoryDTO();
        dto.setName("测试分类");
        dto.setSort(1);

        BookshelfCategory savedCategory = new BookshelfCategory();
        savedCategory.setId(1L);
        savedCategory.setName("测试分类");
        savedCategory.setSort(1);
        savedCategory.setCreatedBy(userId);

        when(categoryRepository.findByCreatedByAndName(userId, "测试分类"))
                .thenReturn(List.of());
        when(categoryRepository.save(any(BookshelfCategory.class)))
                .thenReturn(savedCategory);

        // When
        BookshelfCategoryDTO result = bookshelfService.createCategory(userId, dto);

        // Then
        assertNotNull(result);
        assertEquals("测试分类", result.getName());
        assertEquals(1, result.getSort());
    }

    @Test
    void shouldThrowExceptionWhenCategoryNameExists() {
        // Given
        Long userId = 1L;
        CreateBookshelfCategoryDTO dto = new CreateBookshelfCategoryDTO();
        dto.setName("已存在分类");

        BookshelfCategory existing = new BookshelfCategory();
        existing.setId(1L);
        existing.setName("已存在分类");

        when(categoryRepository.findByCreatedByAndName(userId, "已存在分类"))
                .thenReturn(List.of(existing));

        // When & Then
        assertThrows(BadRequestException.class, () -> {
            bookshelfService.createCategory(userId, dto);
        });
    }
}
```

- [ ] **Step 2: 运行测试**

```bash
cd backend/eladmin-tools
mvn test -Dtest=BookshelfServiceTest
```

Expected: PASS

- [ ] **Step 3: 提交**

```bash
git add backend/eladmin-tools/src/test/java/com/littlegrid/modules/bookshelf/service/BookshelfServiceTest.java
git commit -m "test(bookshelf): add BookshelfServiceTest"
```

---

### Task 24: 前端 Widget 测试

**文件:**
- 创建: `app/lib/tools/bookshelf/widgets/category_tab_test.dart`
- 创建: `app/lib/tools/bookshelf/widgets/item_card_test.dart`

- [ ] **Step 1: 创建 CategoryTab 测试**

```dart
// app/lib/tools/bookshelf/widgets/category_tab_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart' as mockito;
import '../models/category.dart';
import '../providers/bookshelf_provider.dart';
import 'category_tab.dart';

void main() {
  testWidgets('CategoryTab renders correctly', (tester) async {
    final categories = [
      Category(id: 1, name: '书'),
      Category(id: 2, name: '电影'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryTab(
            categories: categories,
            selectedCategory: categories[0],
            onCategoryTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('书'), findsOneWidget);
    expect(find.text('电影'), findsOneWidget);
  });

  testWidgets('CategoryTab calls onCategoryTap when tapped', (tester) async {
    Category? tappedCategory;
    final categories = [
      Category(id: 1, name: '书'),
      Category(id: 2, name: '电影'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryTab(
            categories: categories,
            selectedCategory: categories[0],
            onCategoryTap: (category) {
              tappedCategory = category;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('电影'));
    expect(tappedCategory?.name, '电影');
  });
}
```

- [ ] **Step 2: 创建 ItemCard 测试**

```dart
// app/lib/tools/bookshelf/widgets/item_card_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../models/item.dart';
import 'item_card.dart';

void main() {
  testWidgets('ItemCard renders correctly', (tester) async {
    final item = Item(
      id: 1,
      categoryId: 1,
      title: '三体',
      coverUrl: 'https://example.com/cover.jpg',
      rating: 9,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemCard(
            item: item,
            onTap: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('三体'), findsOneWidget);
    expect(find.text('9分'), findsOneWidget);
  });

  testWidgets('ItemCard calls onTap when tapped', (tester) async {
    bool tapped = false;
    final item = Item(
      id: 1,
      categoryId: 1,
      title: '测试',
      coverUrl: 'https://example.com/cover.jpg',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemCard(
            item: item,
            onTap: () {
              tapped = true;
            },
            onDelete: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('测试'));
    expect(tapped, true);
  });
}
```

- [ ] **Step 3: 运行测试**

```bash
cd app
flutter test test/tools/bookshelf/widgets/category_tab_test.dart
flutter test test/tools/bookshelf/widgets/item_card_test.dart
```

Expected: PASS

- [ ] **Step 4: 提交**

```bash
git add app/lib/tools/bookshelf/widgets/category_tab_test.dart
git add app/lib/tools/bookshelf/widgets/item_card_test.dart
git commit -m "test(bookshelf): add widget tests"
```

---

## 文档

### Task 25: 创建 README 文档

**文件:**
- 创建: `app/lib/tools/bookshelf/README.md`

- [ ] **Step 1: 创建 README**

```markdown
# 书架功能

## 功能概述

书架功能允许用户记录和管理看过的各种内容，包括书、电影、电视剧、番剧、游戏等。

## 核心特性

- 分类管理：默认5个分类，支持用户自定义
- 条目管理：卡片展示，支持增删改查
- 详情页：查看完整信息，支持编辑
- 图片上传：使用服务器存储
- 评分系统：1-10分评价
- 标签系统：支持多标签分类
- 观看进度：记录观看进度
- 推荐标记：标记为可推荐

## 技术栈

- Flutter
- Provider (状态管理)
- http (网络请求)

## 使用说明

1. 在主网格页面找到"书架"工具格子
2. 点击进入书架页面
3. 顶部可以切换不同分类
4. 点击右下角"+"按钮添加新条目
5. 点击条目卡片查看详情
6. 左滑卡片可以删除条目
7. 点击右上角设置图标管理分类

## API 接口

所有接口位于 `/api/tools/bookshelf` 路径下：

- `GET /categories` - 获取分类列表
- `POST /categories` - 创建分类
- `PUT /categories/{id}` - 更新分类
- `DELETE /categories/{id}` - 删除分类
- `GET /items` - 获取条目列表
- `GET /items/{id}` - 获取条目详情
- `POST /items` - 创建条目
- `PUT /items/{id}` - 更新条目
- `DELETE /items/{id}` - 删除条目
- `GET /tags` - 获取标签列表
- `POST /tags` - 创建标签
```

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/bookshelf/README.md
git commit -m "docs(bookshelf): add README documentation"
```

---

## 完成

### Task 26: 最终提交和合并准备

**文件:**
- 提交所有更改

- [ ] **Step 1: 检查所有更改**

```bash
git status
```

- [ ] **Step 2: 添加所有更改并提交**

```bash
git add .
git commit -m "feat(bookshelf): complete bookshelf feature implementation"
```

- [ ] **Step 3: 查看提交历史**

```bash
git log --oneline -10
```

Expected: 看到所有 bookshelf 相关的提交记录
