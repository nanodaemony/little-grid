# 树洞匿名墙 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在小方格应用中新增"树洞匿名墙"功能格子,支持发布秘密/烦恼、随机浏览、回复互动、我的树洞管理。

**Architecture:** 后端 Spring Boot (grid-app 模块) + 前端 Flutter (按工具规范实现) + MySQL 数据库 (Flyway 迁移)

**Tech Stack:** Spring Boot JPA, Flutter, MySQL, Flyway

---

## 变更文件总览

### 后端 (backend/grid-app)
- 创建: `src/main/resources/db/migration/V3__Create_treehole_tables.sql`
- 创建: `src/main/java/com/naon/grid/modules/app/treehole/domain/TreeholePost.java`
- 创建: `src/main/java/com/naon/grid/modules/app/treehole/domain/TreeholeReply.java`
- 创建: `src/main/java/com/naon/grid/modules/app/treehole/domain/TreeholeReplyLike.java`
- 创建: `src/main/java/com/naon/grid/modules/app/treehole/domain/TreeholeViewHistory.java`
- 创建: `src/main/java/com/naon/grid/modules/app/treehole/repository/TreeholePostRepository.java`
- 创建: `src/main/java/com/naon/grid/modules/app/treehole/repository/TreeholeReplyRepository.java`
- 创建: `src/main/java/com/naon/grid/modules/app/treehole/repository/TreeholeReplyLikeRepository.java`
- 创建: `src/main/java/com/naon/grid/modules/app/treehole/repository/TreeholeViewHistoryRepository.java`
- 创建: `src/main/java/com/naon/grid/modules/app/treehole/service/dto/CreatePostDTO.java`
- 创建: `src/main/java/com/naon/grid/modules/app/treehole/service/dto/CreateReplyDTO.java`
- 创建: `src/main/java/com/naon/grid/modules/app/treehole/service/dto/PostDTO.java`
- 创建: `src/main/java/com/naon/grid/modules/app/treehole/service/dto/PostDetailDTO.java`
- 创建: `src/main/java/com/naon/grid/modules/app/treehole/service/dto/ReplyDTO.java`
- 创建: `src/main/java/com/naon/grid/modules/app/treehole/service/TreeholeService.java`
- 创建: `src/main/java/com/naon/grid/modules/app/treehole/service/impl/TreeholeServiceImpl.java`
- 创建: `src/main/java/com/naon/grid/modules/app/treehole/rest/TreeholeController.java`

### 前端 (app)
- 创建: `lib/tools/treehole/treehole_tool.dart`
- 创建: `lib/tools/treehole/treehole_models.dart`
- 创建: `lib/tools/treehole/treehole_service.dart`
- 创建: `lib/tools/treehole/widgets/treehole_card.dart`
- 创建: `lib/tools/treehole/widgets/reply_item.dart`
- 创建: `lib/tools/treehole/treehole_page.dart`
- 创建: `lib/tools/treehole/treehole_post_page.dart`
- 创建: `lib/tools/treehole/treehole_detail_page.dart`
- 创建: `lib/tools/treehole/treehole_mine_page.dart`
- 修改: `lib/core/constants/api_constants.dart` - 添加树洞API常量
- 修改: `lib/main.dart` - 注册树洞工具

---

## Task 1: 数据库表创建 (Flyway 迁移)

**Files:**
- Create: `backend/grid-app/src/main/resources/db/migration/V3__Create_treehole_tables.sql`

- [ ] **Step 1: 创建 Flyway 迁移脚本**

```sql
-- 树洞帖子表
CREATE TABLE IF NOT EXISTS `treehole_post` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '发布者ID',
    `content` VARCHAR(500) NOT NULL COMMENT '内容',
    `tag` VARCHAR(20) NOT NULL COMMENT '标签',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_tag` (`tag`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='树洞帖子表';

-- 树洞回复表
CREATE TABLE IF NOT EXISTS `treehole_reply` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `post_id` BIGINT NOT NULL COMMENT '帖子ID',
    `user_id` BIGINT NOT NULL COMMENT '回复者ID',
    `parent_id` BIGINT DEFAULT NULL COMMENT '父回复ID(二级回复)',
    `content` VARCHAR(300) NOT NULL COMMENT '内容',
    `like_count` INT NOT NULL DEFAULT 0 COMMENT '点赞数',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_post_id` (`post_id`),
    KEY `idx_parent_id` (`parent_id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='树洞回复表';

-- 回复点赞表
CREATE TABLE IF NOT EXISTS `treehole_reply_like` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `reply_id` BIGINT NOT NULL COMMENT '回复ID',
    `user_id` BIGINT NOT NULL COMMENT '点赞者ID',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_reply_user` (`reply_id`, `user_id`),
    KEY `idx_reply_id` (`reply_id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='回复点赞表';

-- 浏览历史表
CREATE TABLE IF NOT EXISTS `treehole_view_history` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `post_id` BIGINT NOT NULL COMMENT '帖子ID',
    `view_date` DATE NOT NULL COMMENT '浏览日期',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_post_date` (`user_id`, `post_id`, `view_date`),
    KEY `idx_user_date` (`user_id`, `view_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='树洞浏览历史表';
```

- [ ] **Step 2: 验证迁移脚本格式**

确认:
- 表名使用下划线命名
- 使用 `IF NOT EXISTS`
- 有适当的索引
- 字符集为 utf8mb4

- [ ] **Step 3: Commit**

```bash
cd /home/nano/little-grid2
git add backend/grid-app/src/main/resources/db/migration/V3__Create_treehole_tables.sql
git commit -m "feat: add treehole database tables

- Create treehole_post table for posts
- Create treehole_reply table for replies with nested support
- Create treehole_reply_like table for likes
- Create treehole_view_history table for view tracking

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

## Task 2: 后端实体类创建

**Files:**
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/domain/TreeholePost.java`
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/domain/TreeholeReply.java`
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/domain/TreeholeReplyLike.java`
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/domain/TreeholeViewHistory.java`

- [ ] **Step 1: 创建 TreeholePost.java**

```java
package com.naon.grid.modules.app.treehole.domain;

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
@Table(name = "treehole_post")
public class TreeholePost implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @Column(name = "user_id", nullable = false)
    private Long userId;

    @NotBlank(message = "内容不能为空")
    @Size(max = 500, message = "内容最多500字")
    @Column(name = "content", nullable = false, length = 500)
    private String content;

    @NotBlank(message = "标签不能为空")
    @Size(max = 20, message = "标签最多20字")
    @Column(name = "tag", nullable = false, length = 20)
    private String tag;

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

- [ ] **Step 2: 创建 TreeholeReply.java**

```java
package com.naon.grid.modules.app.treehole.domain;

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
@Table(name = "treehole_reply")
public class TreeholeReply implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @Column(name = "post_id", nullable = false)
    private Long postId;

    @NotNull
    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "parent_id")
    private Long parentId;

    @NotBlank(message = "内容不能为空")
    @Size(max = 300, message = "内容最多300字")
    @Column(name = "content", nullable = false, length = 300)
    private String content;

    @Column(name = "like_count", nullable = false)
    private Integer likeCount = 0;

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

- [ ] **Step 3: 创建 TreeholeReplyLike.java**

```java
package com.naon.grid.modules.app.treehole.domain;

import lombok.Getter;
import lombok.Setter;

import javax.persistence.*;
import javax.validation.constraints.NotNull;
import java.io.Serializable;
import java.util.Date;

@Entity
@Getter
@Setter
@Table(name = "treehole_reply_like")
public class TreeholeReplyLike implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @Column(name = "reply_id", nullable = false)
    private Long replyId;

    @NotNull
    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "created_at")
    private Date createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = new Date();
    }
}
```

- [ ] **Step 4: 创建 TreeholeViewHistory.java**

```java
package com.naon.grid.modules.app.treehole.domain;

import lombok.Getter;
import lombok.Setter;

import javax.persistence.*;
import javax.validation.constraints.NotNull;
import java.io.Serializable;
import java.sql.Date;
import java.util.Date as UtilDate;

@Entity
@Getter
@Setter
@Table(name = "treehole_view_history")
public class TreeholeViewHistory implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @Column(name = "user_id", nullable = false)
    private Long userId;

    @NotNull
    @Column(name = "post_id", nullable = false)
    private Long postId;

    @NotNull
    @Column(name = "view_date", nullable = false)
    private Date viewDate;

    @Column(name = "created_at")
    private UtilDate createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = new UtilDate();
        if (viewDate == null) {
            viewDate = new Date(System.currentTimeMillis());
        }
    }
}
```

- [ ] **Step 5: Commit**

```bash
cd /home/nano/little-grid2
git add backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/domain/*.java
git commit -m "feat: add treehole domain entities

- Add TreeholePost entity
- Add TreeholeReply entity with nested reply support
- Add TreeholeReplyLike entity
- Add TreeholeViewHistory entity

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

## Task 3: 后端 Repository 层创建

**Files:**
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/repository/TreeholePostRepository.java`
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/repository/TreeholeReplyRepository.java`
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/repository/TreeholeReplyLikeRepository.java`
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/repository/TreeholeViewHistoryRepository.java`

- [ ] **Step 1: 创建 TreeholePostRepository.java**

```java
package com.naon.grid.modules.app.treehole.repository;

import com.naon.grid.modules.app.treehole.domain.TreeholePost;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TreeholePostRepository extends JpaRepository<TreeholePost, Long>, JpaSpecificationExecutor<TreeholePost> {

    /**
     * 查询用户发布的帖子
     */
    Page<TreeholePost> findByUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);

    /**
     * 随机获取帖子(排除自己的和已浏览的)
     */
    @Query(value = "SELECT p FROM TreeholePost p WHERE p.userId != :userId " +
           "AND p.id NOT IN :viewedPostIds " +
           "AND (:tag IS NULL OR p.tag = :tag) " +
           "ORDER BY FUNCTION('RAND')")
    List<TreeholePost> findRandomPosts(
            @Param("userId") Long userId,
            @Param("viewedPostIds") List<Long> viewedPostIds,
            @Param("tag") String tag,
            Pageable pageable);

    /**
     * 随机获取帖子(只排除自己的,没有浏览历史)
     */
    @Query(value = "SELECT p FROM TreeholePost p WHERE p.userId != :userId " +
           "AND (:tag IS NULL OR p.tag = :tag) " +
           "ORDER BY FUNCTION('RAND')")
    List<TreeholePost> findRandomPostsWithoutViewHistory(
            @Param("userId") Long userId,
            @Param("tag") String tag,
            Pageable pageable);

    /**
     * 统计帖子的回复数
     */
    @Query("SELECT COUNT(r) FROM TreeholeReply r WHERE r.postId = :postId")
    Long countRepliesByPostId(@Param("postId") Long postId);
}
```

- [ ] **Step 2: 创建 TreeholeReplyRepository.java**

```java
package com.naon.grid.modules.app.treehole.repository;

import com.naon.grid.modules.app.treehole.domain.TreeholeReply;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TreeholeReplyRepository extends JpaRepository<TreeholeReply, Long>, JpaSpecificationExecutor<TreeholeReply> {

    /**
     * 查询帖子的所有一级回复
     */
    List<TreeholeReply> findByPostIdAndParentIdIsNullOrderByCreatedAtDesc(Long postId);

    /**
     * 查询某个回复的子回复
     */
    List<TreeholeReply> findByParentIdOrderByCreatedAtAsc(Long parentId);

    /**
     * 删除帖子的所有回复
     */
    @Modifying
    @Query("DELETE FROM TreeholeReply r WHERE r.postId = :postId")
    void deleteByPostId(@Param("postId") Long postId);

    /**
     * 删除回复的所有子回复
     */
    @Modifying
    @Query("DELETE FROM TreeholeReply r WHERE r.parentId = :parentId")
    void deleteByParentId(@Param("parentId") Long parentId);

    /**
     * 增加点赞数
     */
    @Modifying
    @Query("UPDATE TreeholeReply r SET r.likeCount = r.likeCount + 1 WHERE r.id = :replyId")
    void incrementLikeCount(@Param("replyId") Long replyId);

    /**
     * 减少点赞数
     */
    @Modifying
    @Query("UPDATE TreeholeReply r SET r.likeCount = r.likeCount - 1 WHERE r.id = :replyId AND r.likeCount > 0")
    void decrementLikeCount(@Param("replyId") Long replyId);
}
```

- [ ] **Step 3: 创建 TreeholeReplyLikeRepository.java**

```java
package com.naon.grid.modules.app.treehole.repository;

import com.naon.grid.modules.app.treehole.domain.TreeholeReplyLike;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TreeholeReplyLikeRepository extends JpaRepository<TreeholeReplyLike, Long>, JpaSpecificationExecutor<TreeholeReplyLike> {

    /**
     * 检查是否已点赞
     */
    boolean existsByReplyIdAndUserId(Long replyId, Long userId);

    /**
     * 查询点赞记录
     */
    Optional<TreeholeReplyLike> findByReplyIdAndUserId(Long replyId, Long userId);

    /**
     * 查询用户对某批回复的点赞状态
     */
    @Query("SELECT l.replyId FROM TreeholeReplyLike l WHERE l.replyId IN :replyIds AND l.userId = :userId")
    List<Long> findLikedReplyIds(@Param("replyIds") List<Long> replyIds, @Param("userId") Long userId);

    /**
     * 删除某回复的所有点赞
     */
    @Modifying
    @Query("DELETE FROM TreeholeReplyLike l WHERE l.replyId = :replyId")
    void deleteByReplyId(@Param("replyId") Long replyId);

    /**
     * 删除某帖子所有回复的点赞(通过回复ID列表)
     */
    @Modifying
    @Query("DELETE FROM TreeholeReplyLike l WHERE l.replyId IN :replyIds")
    void deleteByReplyIds(@Param("replyIds") List<Long> replyIds);
}
```

- [ ] **Step 4: 创建 TreeholeViewHistoryRepository.java**

```java
package com.naon.grid.modules.app.treehole.repository;

import com.naon.grid.modules.app.treehole.domain.TreeholeViewHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.sql.Date;
import java.util.List;

@Repository
public interface TreeholeViewHistoryRepository extends JpaRepository<TreeholeViewHistory, Long>, JpaSpecificationExecutor<TreeholeViewHistory> {

    /**
     * 查询用户某天已浏览的帖子ID列表
     */
    @Query("SELECT h.postId FROM TreeholeViewHistory h WHERE h.userId = :userId AND h.viewDate = :viewDate")
    List<Long> findViewedPostIds(@Param("userId") Long userId, @Param("viewDate") Date viewDate);

    /**
     * 删除某帖子的浏览历史
     */
    @Modifying
    @Query("DELETE FROM TreeholeViewHistory h WHERE h.postId = :postId")
    void deleteByPostId(@Param("postId") Long postId);
}
```

- [ ] **Step 5: Commit**

```bash
cd /home/nano/little-grid2
git add backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/repository/*.java
git commit -m "feat: add treehole repository layer

- Add TreeholePostRepository with random query support
- Add TreeholeReplyRepository with nested reply queries
- Add TreeholeReplyLikeRepository for like tracking
- Add TreeholeViewHistoryRepository for view tracking

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

## Task 4: 后端 DTO 层创建

**Files:**
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/service/dto/CreatePostDTO.java`
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/service/dto/CreateReplyDTO.java`
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/service/dto/PostDTO.java`
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/service/dto/PostDetailDTO.java`
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/service/dto/ReplyDTO.java`

- [ ] **Step 1: 创建 CreatePostDTO.java**

```java
package com.naon.grid.modules.app.treehole.service.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

@Data
public class CreatePostDTO {

    @NotBlank(message = "内容不能为空")
    @Size(max = 500, message = "内容最多500字")
    private String content;

    @NotBlank(message = "标签不能为空")
    @Size(max = 20, message = "标签最多20字")
    private String tag;
}
```

- [ ] **Step 2: 创建 CreateReplyDTO.java**

```java
package com.naon.grid.modules.app.treehole.service.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

@Data
public class CreateReplyDTO {

    @NotBlank(message = "内容不能为空")
    @Size(max = 300, message = "内容最多300字")
    private String content;

    private Long parentId;
}
```

- [ ] **Step 3: 创建 PostDTO.java**

```java
package com.naon.grid.modules.app.treehole.service.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PostDTO {

    private Long id;
    private String content;
    private String tag;
    private Long createdAt;
    private Long replyCount;
}
```

- [ ] **Step 4: 创建 ReplyDTO.java**

```java
package com.naon.grid.modules.app.treehole.service.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReplyDTO {

    private Long id;
    private Long postId;
    private String content;
    private Long parentId;
    private Integer likeCount;
    private Boolean isLiked;
    private Long createdAt;
    private List<ReplyDTO> children;
}
```

- [ ] **Step 5: 创建 PostDetailDTO.java**

```java
package com.naon.grid.modules.app.treehole.service.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PostDetailDTO {

    private PostDTO post;
    private List<ReplyDTO> replies;
}
```

- [ ] **Step 6: Commit**

```bash
cd /home/nano/little-grid2
git add backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/service/dto/*.java
git commit -m "feat: add treehole DTOs

- Add CreatePostDTO for post creation
- Add CreateReplyDTO for reply creation
- Add PostDTO for post response
- Add ReplyDTO for reply response with nested children
- Add PostDetailDTO for post detail view

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

## Task 5: 后端 Service 接口和实现

**Files:**
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/service/TreeholeService.java`
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/service/impl/TreeholeServiceImpl.java`

- [ ] **Step 1: 创建 TreeholeService.java**

```java
package com.naon.grid.modules.app.treehole.service;

import com.naon.grid.modules.app.treehole.service.dto.*;
import com.naon.grid.utils.PageResult;
import org.springframework.data.domain.Pageable;

public interface TreeholeService {

    PostDTO createPost(Long userId, CreatePostDTO dto);

    PostDTO getRandomPost(Long userId, String tag);

    PageResult<PostDTO> getMyPosts(Long userId, Pageable pageable);

    PostDetailDTO getPostDetail(Long postId, Long userId);

    void deletePost(Long postId, Long userId);

    ReplyDTO createReply(Long postId, Long userId, CreateReplyDTO dto);

    LikeResultDTO likeReply(Long replyId, Long userId);

    LikeResultDTO unlikeReply(Long replyId, Long userId);

    @lombok.Data
    @lombok.Builder
    @lombok.AllArgsConstructor
    @lombok.NoArgsConstructor
    class LikeResultDTO {
        private Long id;
        private Integer likeCount;
    }
}
```

- [ ] **Step 2: 创建 TreeholeServiceImpl.java**

```java
package com.naon.grid.modules.app.treehole.service.impl;

import com.naon.grid.exception.BadRequestException;
import com.naon.grid.exception.EntityNotFoundException;
import com.naon.grid.modules.app.treehole.domain.TreeholePost;
import com.naon.grid.modules.app.treehole.domain.TreeholeReply;
import com.naon.grid.modules.app.treehole.domain.TreeholeReplyLike;
import com.naon.grid.modules.app.treehole.domain.TreeholeViewHistory;
import com.naon.grid.modules.app.treehole.repository.TreeholePostRepository;
import com.naon.grid.modules.app.treehole.repository.TreeholeReplyRepository;
import com.naon.grid.modules.app.treehole.repository.TreeholeReplyLikeRepository;
import com.naon.grid.modules.app.treehole.repository.TreeholeViewHistoryRepository;
import com.naon.grid.modules.app.treehole.service.TreeholeService;
import com.naon.grid.modules.app.treehole.service.dto.*;
import com.naon.grid.utils.PageResult;
import com.naon.grid.utils.PageUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Date;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class TreeholeServiceImpl implements TreeholeService {

    private final TreeholePostRepository postRepository;
    private final TreeholeReplyRepository replyRepository;
    private final TreeholeReplyLikeRepository replyLikeRepository;
    private final TreeholeViewHistoryRepository viewHistoryRepository;

    @Override
    @Transactional
    public PostDTO createPost(Long userId, CreatePostDTO dto) {
        TreeholePost post = new TreeholePost();
        post.setUserId(userId);
        post.setContent(dto.getContent());
        post.setTag(dto.getTag());
        post = postRepository.save(post);
        return toPostDTO(post, 0L);
    }

    @Override
    @Transactional
    public PostDTO getRandomPost(Long userId, String tag) {
        Date today = new Date(System.currentTimeMillis());
        List<Long> viewedPostIds = viewHistoryRepository.findViewedPostIds(userId, today);

        Pageable pageable = PageRequest.of(0, 1);
        List<TreeholePost> posts;

        if (viewedPostIds.isEmpty()) {
            posts = postRepository.findRandomPostsWithoutViewHistory(userId, tag, pageable);
        } else {
            posts = postRepository.findRandomPosts(userId, viewedPostIds, tag, pageable);
        }

        if (posts.isEmpty()) {
            return null;
        }

        TreeholePost post = posts.get(0);

        // 记录浏览历史
        try {
            TreeholeViewHistory history = new TreeholeViewHistory();
            history.setUserId(userId);
            history.setPostId(post.getId());
            history.setViewDate(today);
            viewHistoryRepository.save(history);
        } catch (Exception e) {
            // 唯一索引冲突,说明已经记录过了,忽略
            log.warn("View history already exists for user {} and post {}", userId, post.getId());
        }

        Long replyCount = postRepository.countRepliesByPostId(post.getId());
        return toPostDTO(post, replyCount);
    }

    @Override
    public PageResult<PostDTO> getMyPosts(Long userId, Pageable pageable) {
        Page<TreeholePost> postPage = postRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);
        List<PostDTO> dtoList = postPage.getContent().stream()
                .map(post -> {
                    Long replyCount = postRepository.countRepliesByPostId(post.getId());
                    return toPostDTO(post, replyCount);
                })
                .collect(Collectors.toList());
        return PageUtil.toPageResult(postPage, dtoList);
    }

    @Override
    public PostDetailDTO getPostDetail(Long postId, Long userId) {
        TreeholePost post = postRepository.findById(postId)
                .orElseThrow(() -> new EntityNotFoundException(TreeholePost.class, postId));

        Long replyCount = postRepository.countRepliesByPostId(postId);
        PostDTO postDTO = toPostDTO(post, replyCount);

        List<TreeholeReply> firstLevelReplies = replyRepository.findByPostIdAndParentIdIsNullOrderByCreatedAtDesc(postId);

        // 获取所有回复ID,查询点赞状态
        List<Long> allReplyIds = new ArrayList<>();
        for (TreeholeReply reply : firstLevelReplies) {
            allReplyIds.add(reply.getId());
        }
        // 获取二级回复ID
        for (TreeholeReply reply : firstLevelReplies) {
            List<TreeholeReply> children = replyRepository.findByParentIdOrderByCreatedAtAsc(reply.getId());
            for (TreeholeReply child : children) {
                allReplyIds.add(child.getId());
            }
        }

        // 查询用户点赞状态
        List<Long> likedReplyIds = allReplyIds.isEmpty() ? List.of() :
                replyLikeRepository.findLikedReplyIds(allReplyIds, userId);

        // 构建二级回复Map
        Map<Long, List<TreeholeReply>> childrenMap = firstLevelReplies.stream()
                .collect(Collectors.toMap(
                        TreeholeReply::getId,
                        reply -> replyRepository.findByParentIdOrderByCreatedAtAsc(reply.getId())
                ));

        List<ReplyDTO> replyDTOs = firstLevelReplies.stream()
                .map(reply -> toReplyDTO(reply, likedReplyIds, childrenMap))
                .collect(Collectors.toList());

        return PostDetailDTO.builder()
                .post(postDTO)
                .replies(replyDTOs)
                .build();
    }

    @Override
    @Transactional
    public void deletePost(Long postId, Long userId) {
        TreeholePost post = postRepository.findById(postId)
                .orElseThrow(() -> new EntityNotFoundException(TreeholePost.class, postId));

        if (!post.getUserId().equals(userId)) {
            throw new BadRequestException("只能删除自己的帖子");
        }

        // 先删除点赞: 获取所有回复ID,然后删除点赞
        List<TreeholeReply> allReplies = replyRepository.findAll();
        List<Long> replyIds = allReplies.stream()
                .filter(r -> r.getPostId().equals(postId))
                .map(TreeholeReply::getId)
                .collect(Collectors.toList());

        if (!replyIds.isEmpty()) {
            replyLikeRepository.deleteByReplyIds(replyIds);
        }

        // 删除回复
        replyRepository.deleteByPostId(postId);

        // 删除浏览历史
        viewHistoryRepository.deleteByPostId(postId);

        // 删除帖子
        postRepository.delete(post);
    }

    @Override
    @Transactional
    public ReplyDTO createReply(Long postId, Long userId, CreateReplyDTO dto) {
        // 验证帖子存在
        if (!postRepository.existsById(postId)) {
            throw new EntityNotFoundException(TreeholePost.class, postId);
        }

        // 如果有parentId,验证父回复存在且属于同一帖子
        if (dto.getParentId() != null) {
            TreeholeReply parent = replyRepository.findById(dto.getParentId())
                    .orElseThrow(() -> new EntityNotFoundException(TreeholeReply.class, dto.getParentId()));
            if (!parent.getPostId().equals(postId)) {
                throw new BadRequestException("父回复不属于该帖子");
            }
        }

        TreeholeReply reply = new TreeholeReply();
        reply.setPostId(postId);
        reply.setUserId(userId);
        reply.setParentId(dto.getParentId());
        reply.setContent(dto.getContent());
        reply = replyRepository.save(reply);

        return ReplyDTO.builder()
                .id(reply.getId())
                .postId(reply.getPostId())
                .content(reply.getContent())
                .parentId(reply.getParentId())
                .likeCount(reply.getLikeCount())
                .isLiked(false)
                .createdAt(reply.getCreatedAt().getTime())
                .children(List.of())
                .build();
    }

    @Override
    @Transactional
    public LikeResultDTO likeReply(Long replyId, Long userId) {
        TreeholeReply reply = replyRepository.findById(replyId)
                .orElseThrow(() -> new EntityNotFoundException(TreeholeReply.class, replyId));

        if (replyLikeRepository.existsByReplyIdAndUserId(replyId, userId)) {
            // 已经点赞过了,返回当前状态
            return LikeResultDTO.builder()
                    .id(replyId)
                    .likeCount(reply.getLikeCount())
                    .build();
        }

        TreeholeReplyLike like = new TreeholeReplyLike();
        like.setReplyId(replyId);
        like.setUserId(userId);
        replyLikeRepository.save(like);

        replyRepository.incrementLikeCount(replyId);
        reply.setLikeCount(reply.getLikeCount() + 1);

        return LikeResultDTO.builder()
                .id(replyId)
                .likeCount(reply.getLikeCount())
                .build();
    }

    @Override
    @Transactional
    public LikeResultDTO unlikeReply(Long replyId, Long userId) {
        TreeholeReply reply = replyRepository.findById(replyId)
                .orElseThrow(() -> new EntityNotFoundException(TreeholeReply.class, replyId));

        TreeholeReplyLike like = replyLikeRepository.findByReplyIdAndUserId(replyId, userId)
                .orElse(null);

        if (like == null) {
            // 没有点赞,返回当前状态
            return LikeResultDTO.builder()
                    .id(replyId)
                    .likeCount(reply.getLikeCount())
                    .build();
        }

        replyLikeRepository.delete(like);

        if (reply.getLikeCount() > 0) {
            replyRepository.decrementLikeCount(replyId);
            reply.setLikeCount(reply.getLikeCount() - 1);
        }

        return LikeResultDTO.builder()
                .id(replyId)
                .likeCount(reply.getLikeCount())
                .build();
    }

    private PostDTO toPostDTO(TreeholePost post, Long replyCount) {
        return PostDTO.builder()
                .id(post.getId())
                .content(post.getContent())
                .tag(post.getTag())
                .createdAt(post.getCreatedAt().getTime())
                .replyCount(replyCount)
                .build();
    }

    private ReplyDTO toReplyDTO(TreeholeReply reply, List<Long> likedReplyIds,
                                  Map<Long, List<TreeholeReply>> childrenMap) {
        List<ReplyDTO> children = childrenMap.getOrDefault(reply.getId(), List.of())
                .stream()
                .map(child -> toReplyDTO(child, likedReplyIds, Map.of()))
                .collect(Collectors.toList());

        return ReplyDTO.builder()
                .id(reply.getId())
                .postId(reply.getPostId())
                .content(reply.getContent())
                .parentId(reply.getParentId())
                .likeCount(reply.getLikeCount())
                .isLiked(likedReplyIds.contains(reply.getId()))
                .createdAt(reply.getCreatedAt().getTime())
                .children(children)
                .build();
    }
}
```

- [ ] **Step 3: Commit**

```bash
cd /home/nano/little-grid2
git add backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/service/TreeholeService.java
git add backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/service/impl/TreeholeServiceImpl.java
git commit -m "feat: add treehole service layer

- Add TreeholeService interface
- Add TreeholeServiceImpl with full business logic
- Implement random post selection with view history
- Implement reply nesting and like tracking
- Add cascading delete for posts

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

## Task 6: 后端 Controller 层创建

**Files:**
- Create: `backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/rest/TreeholeController.java`

- [ ] **Step 1: 创建 TreeholeController.java**

```java
package com.naon.grid.modules.app.treehole.rest;

import com.naon.grid.annotation.Log;
import com.naon.grid.modules.app.security.AppTokenProvider;
import com.naon.grid.modules.app.treehole.service.TreeholeService;
import com.naon.grid.modules.app.treehole.service.dto.*;
import com.naon.grid.modules.security.config.SecurityProperties;
import com.naon.grid.utils.PageResult;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/app/treehole")
@Api(tags = "APP：树洞接口")
public class TreeholeController {

    private final TreeholeService treeholeService;
    private final AppTokenProvider appTokenProvider;
    private final SecurityProperties securityProperties;

    @Log("发布树洞")
    @ApiOperation("发布树洞")
    @PostMapping("/posts")
    public ResponseEntity<PostDTO> createPost(
            @Validated @RequestBody CreatePostDTO dto,
            HttpServletRequest request) {
        Long userId = getUserIdFromRequest(request);
        PostDTO post = treeholeService.createPost(userId, dto);
        return ResponseEntity.ok(post);
    }

    @Log("随机获取树洞")
    @ApiOperation("随机获取一条树洞")
    @GetMapping("/posts/random")
    public ResponseEntity<PostDTO> getRandomPost(
            @RequestParam(required = false) String tag,
            HttpServletRequest request) {
        Long userId = getUserIdFromRequest(request);
        PostDTO post = treeholeService.getRandomPost(userId, tag);
        if (post == null) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(post);
    }

    @Log("获取我的树洞")
    @ApiOperation("获取我的树洞列表")
    @GetMapping("/posts/mine")
    public ResponseEntity<PageResult<PostDTO>> getMyPosts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            HttpServletRequest request) {
        Long userId = getUserIdFromRequest(request);
        Pageable pageable = PageRequest.of(page, size);
        PageResult<PostDTO> result = treeholeService.getMyPosts(userId, pageable);
        return ResponseEntity.ok(result);
    }

    @Log("获取树洞详情")
    @ApiOperation("获取树洞详情(含回复)")
    @GetMapping("/posts/{id}")
    public ResponseEntity<PostDetailDTO> getPostDetail(
            @PathVariable Long id,
            HttpServletRequest request) {
        Long userId = getUserIdFromRequest(request);
        PostDetailDTO detail = treeholeService.getPostDetail(id, userId);
        return ResponseEntity.ok(detail);
    }

    @Log("删除树洞")
    @ApiOperation("删除我的树洞")
    @DeleteMapping("/posts/{id}")
    public ResponseEntity<Void> deletePost(
            @PathVariable Long id,
            HttpServletRequest request) {
        Long userId = getUserIdFromRequest(request);
        treeholeService.deletePost(id, userId);
        return ResponseEntity.ok().build();
    }

    @Log("发表回复")
    @ApiOperation("发表回复")
    @PostMapping("/posts/{id}/replies")
    public ResponseEntity<ReplyDTO> createReply(
            @PathVariable Long id,
            @Validated @RequestBody CreateReplyDTO dto,
            HttpServletRequest request) {
        Long userId = getUserIdFromRequest(request);
        ReplyDTO reply = treeholeService.createReply(id, userId, dto);
        return ResponseEntity.ok(reply);
    }

    @Log("点赞回复")
    @ApiOperation("点赞回复")
    @PostMapping("/replies/{id}/like")
    public ResponseEntity<TreeholeService.LikeResultDTO> likeReply(
            @PathVariable Long id,
            HttpServletRequest request) {
        Long userId = getUserIdFromRequest(request);
        TreeholeService.LikeResultDTO result = treeholeService.likeReply(id, userId);
        return ResponseEntity.ok(result);
    }

    @Log("取消点赞")
    @ApiOperation("取消点赞")
    @DeleteMapping("/replies/{id}/like")
    public ResponseEntity<TreeholeService.LikeResultDTO> unlikeReply(
            @PathVariable Long id,
            HttpServletRequest request) {
        Long userId = getUserIdFromRequest(request);
        TreeholeService.LikeResultDTO result = treeholeService.unlikeReply(id, userId);
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

- [ ] **Step 2: Commit**

```bash
cd /home/nano/little-grid2
git add backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/rest/TreeholeController.java
git commit -m "feat: add treehole REST controller

- Add TreeholeController with all endpoints
- Implement token-based authentication
- Add API documentation with Swagger annotations
- Add logging with @Log annotation

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

## Task 7: 前端 API 常量和数据模型

**Files:**
- Modify: `app/lib/core/constants/api_constants.dart`
- Create: `app/lib/tools/treehole/treehole_models.dart`

- [ ] **Step 1: 修改 api_constants.dart**

读取现有文件:

```dart
// app/lib/core/constants/api_constants.dart

class ApiConstants {
  // 基础配置 - 根据环境修改
  // 开发环境使用本地地址，生产环境修改为服务器地址
  static const String baseUrl = 'http://192.168.74.11:8000';

  static const String apiPrefix = '/api';
  static const String appApiPrefix = '$apiPrefix/app';

  // 认证相关
  static const String register = '$appApiPrefix/auth/register';
  static const String login = '$appApiPrefix/auth/login';
  static const String logout = '$appApiPrefix/auth/logout';

  // 用户相关
  static const String userProfile = '$appApiPrefix/user/profile';

  // 树洞相关
  static const String treeholePosts = '$appApiPrefix/treehole/posts';
  static const String treeholeRandomPost = '$appApiPrefix/treehole/posts/random';
  static const String treeholeMyPosts = '$appApiPrefix/treehole/posts/mine';
  static String treeholePostDetail(int id) => '$appApiPrefix/treehole/posts/$id';
  static String treeholePostReplies(int id) => '$appApiPrefix/treehole/posts/$id/replies';
  static String treeholeReplyLike(int id) => '$appApiPrefix/treehole/replies/$id/like';

  // 超时配置
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
}
```

- [ ] **Step 2: 创建 treehole_models.dart**

```dart
class TreeholePost {
  final int id;
  final String content;
  final String tag;
  final int createdAt;
  final int? replyCount;

  TreeholePost({
    required this.id,
    required this.content,
    required this.tag,
    required this.createdAt,
    this.replyCount,
  });

  factory TreeholePost.fromJson(Map<String, dynamic> json) {
    return TreeholePost(
      id: json['id'] as int,
      content: json['content'] as String,
      tag: json['tag'] as String,
      createdAt: json['createdAt'] as int,
      replyCount: json['replyCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'tag': tag,
      'createdAt': createdAt,
      'replyCount': replyCount,
    };
  }

  TreeholePost copyWith({
    int? id,
    String? content,
    String? tag,
    int? createdAt,
    int? replyCount,
  }) {
    return TreeholePost(
      id: id ?? this.id,
      content: content ?? this.content,
      tag: tag ?? this.tag,
      createdAt: createdAt ?? this.createdAt,
      replyCount: replyCount ?? this.replyCount,
    );
  }
}

class TreeholeReply {
  final int id;
  final int postId;
  final String content;
  final int? parentId;
  final int likeCount;
  final bool isLiked;
  final int createdAt;
  final List<TreeholeReply>? children;

  TreeholeReply({
    required this.id,
    required this.postId,
    required this.content,
    this.parentId,
    required this.likeCount,
    required this.isLiked,
    required this.createdAt,
    this.children,
  });

  factory TreeholeReply.fromJson(Map<String, dynamic> json) {
    final childrenJson = json['children'] as List?;
    return TreeholeReply(
      id: json['id'] as int,
      postId: json['postId'] as int,
      content: json['content'] as String,
      parentId: json['parentId'] as int?,
      likeCount: json['likeCount'] as int,
      isLiked: json['isLiked'] as bool? ?? false,
      createdAt: json['createdAt'] as int,
      children: childrenJson
          ?.map((e) => TreeholeReply.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'content': content,
      'parentId': parentId,
      'likeCount': likeCount,
      'isLiked': isLiked,
      'createdAt': createdAt,
      'children': children?.map((e) => e.toJson()).toList(),
    };
  }

  TreeholeReply copyWith({
    int? id,
    int? postId,
    String? content,
    int? parentId,
    int? likeCount,
    bool? isLiked,
    int? createdAt,
    List<TreeholeReply>? children,
  }) {
    return TreeholeReply(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      children: children ?? this.children,
    );
  }
}

class PostDetail {
  final TreeholePost post;
  final List<TreeholeReply> replies;

  PostDetail({
    required this.post,
    required this.replies,
  });

  factory PostDetail.fromJson(Map<String, dynamic> json) {
    final repliesJson = json['replies'] as List?;
    return PostDetail(
      post: TreeholePost.fromJson(json['post'] as Map<String, dynamic>),
      replies: repliesJson
              ?.map((e) => TreeholeReply.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post': post.toJson(),
      'replies': replies.map((e) => e.toJson()).toList(),
    };
  }
}

class LikeResult {
  final int id;
  final int likeCount;

  LikeResult({
    required this.id,
    required this.likeCount,
  });

  factory LikeResult.fromJson(Map<String, dynamic> json) {
    return LikeResult(
      id: json['id'] as int,
      likeCount: json['likeCount'] as int,
    );
  }
}

/// 标签常量
class TreeholeTags {
  static const String all = '全部';
  static const String worry = '烦恼';
  static const String secret = '秘密';
  static const String help = '求助';
  static const String share = '分享';
  static const String other = '其他';

  static const List<String> allTags = [all, worry, secret, help, share, other];
  static const List<String> selectableTags = [worry, secret, help, share, other];
}
```

- [ ] **Step 3: Commit**

```bash
cd /home/nano/little-grid2
git add app/lib/core/constants/api_constants.dart
git add app/lib/tools/treehole/treehole_models.dart
git commit -m "feat: add treehole frontend models and API constants

- Add treehole API endpoints to ApiConstants
- Add TreeholePost, TreeholeReply, PostDetail models
- Add TreeholeTags constants

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

## Task 8: 前端 API Service

**Files:**
- Create: `app/lib/tools/treehole/treehole_service.dart`

- [ ] **Step 1: 创建 treehole_service.dart**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/services/http_client.dart';
import '../../core/utils/logger.dart';
import 'treehole_models.dart';

/// 树洞 API 服务
class TreeholeService {
  static const String module = 'Treehole';

  /// 随机获取一条树洞
  static Future<TreeholePost?> getRandomPost({String? tag}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.treeholeRandomPost}')
          .replace(queryParameters: tag != null && tag != TreeholeTags.all ? {'tag': tag} : null);
      final response = await HttpClient.get(uri, module: module);

      if (response.statusCode == 204) {
        return null;
      }
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return TreeholePost.fromJson(json);
      }
      throw Exception('获取树洞失败: ${response.statusCode}');
    } catch (e) {
      AppLogger.e('getRandomPost error: $e', module: module);
      rethrow;
    }
  }

  /// 发布树洞
  static Future<TreeholePost> createPost(String content, String tag) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.treeholePosts}');
      final response = await HttpClient.post(
        uri,
        body: {'content': content, 'tag': tag},
        module: module,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return TreeholePost.fromJson(json);
      }
      throw Exception('发布失败: ${response.statusCode}');
    } catch (e) {
      AppLogger.e('createPost error: $e', module: module);
      rethrow;
    }
  }

  /// 获取我的树洞列表
  static Future<List<TreeholePost>> getMyPosts({int page = 0, int size = 20}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.treeholeMyPosts}')
          .replace(queryParameters: {'page': '$page', 'size': '$size'});
      final response = await HttpClient.get(uri, module: module);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final content = json['content'] as List?;
        return content
                ?.map((e) => TreeholePost.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
      }
      throw Exception('获取失败: ${response.statusCode}');
    } catch (e) {
      AppLogger.e('getMyPosts error: $e', module: module);
      rethrow;
    }
  }

  /// 获取树洞详情
  static Future<PostDetail> getPostDetail(int id) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.treeholePostDetail(id)}');
      final response = await HttpClient.get(uri, module: module);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return PostDetail.fromJson(json);
      }
      throw Exception('获取详情失败: ${response.statusCode}');
    } catch (e) {
      AppLogger.e('getPostDetail error: $e', module: module);
      rethrow;
    }
  }

  /// 删除树洞
  static Future<void> deletePost(int id) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.treeholePostDetail(id)}');
      final response = await HttpClient.delete(uri, module: module);

      if (response.statusCode != 200) {
        throw Exception('删除失败: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.e('deletePost error: $e', module: module);
      rethrow;
    }
  }

  /// 发表回复
  static Future<TreeholeReply> createReply(int postId, String content, {int? parentId}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.treeholePostReplies(postId)}');
      final body = <String, dynamic>{'content': content};
      if (parentId != null) {
        body['parentId'] = parentId;
      }
      final response = await HttpClient.post(uri, body: body, module: module);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return TreeholeReply.fromJson(json);
      }
      throw Exception('回复失败: ${response.statusCode}');
    } catch (e) {
      AppLogger.e('createReply error: $e', module: module);
      rethrow;
    }
  }

  /// 点赞回复
  static Future<LikeResult> likeReply(int id) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.treeholeReplyLike(id)}');
      final response = await HttpClient.post(uri, module: module);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return LikeResult.fromJson(json);
      }
      throw Exception('点赞失败: ${response.statusCode}');
    } catch (e) {
      AppLogger.e('likeReply error: $e', module: module);
      rethrow;
    }
  }

  /// 取消点赞
  static Future<LikeResult> unlikeReply(int id) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.treeholeReplyLike(id)}');
      final response = await HttpClient.delete(uri, module: module);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return LikeResult.fromJson(json);
      }
      throw Exception('取消点赞失败: ${response.statusCode}');
    } catch (e) {
      AppLogger.e('unlikeReply error: $e', module: module);
      rethrow;
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd /home/nano/little-grid2
git add app/lib/tools/treehole/treehole_service.dart
git commit -m "feat: add treehole frontend API service

- Add TreeholeService with all API calls
- Implement random post, create post, get my posts
- Implement post detail, delete post
- Implement create reply, like/unlike reply

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

## Task 9: 前端 Widget 组件

**Files:**
- Create: `app/lib/tools/treehole/widgets/treehole_card.dart`
- Create: `app/lib/tools/treehole/widgets/reply_item.dart`

- [ ] **Step 1: 创建 treehole_card.dart**

```dart
import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../treehole_models.dart';

/// 树洞卡片组件
class TreeholeCard extends StatelessWidget {
  final TreeholePost post;
  final VoidCallback? onTap;
  final bool showReplyCount;

  const TreeholeCard({
    super.key,
    required this.post,
    this.onTap,
    this.showReplyCount = true,
  });

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays}天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      post.tag,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(post.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post.content,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
              if (showReplyCount && post.replyCount != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.replyCount}条回复',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 创建 reply_item.dart**

```dart
import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../treehole_models.dart';

/// 回复项组件
class ReplyItem extends StatelessWidget {
  final TreeholeReply reply;
  final VoidCallback? onLike;
  final VoidCallback? onUnlike;
  final VoidCallback? onReply;
  final bool isNested;

  const ReplyItem({
    super.key,
    required this.reply,
    this.onLike,
    this.onUnlike,
    this.onReply,
    this.isNested = false,
  });

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: isNested ? 24 : 0, bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: isNested
            ? Border(
                left: BorderSide(
                  color: AppColors.primaryLight,
                  width: 2,
                ),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: isNested ? 12 : 0),
            child: Text(
              reply.content,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.only(left: isNested ? 12 : 0),
            child: Row(
              children: [
                Text(
                  _formatTime(reply.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: 16),
                if (!isNested)
                  InkWell(
                    onTap: onReply,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.reply,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '回复',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (!isNested) const SizedBox(width: 16),
                InkWell(
                  onTap: reply.isLiked ? onUnlike : onLike,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        reply.isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: reply.isLiked ? AppColors.error : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reply.likeCount.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: reply.isLiked ? AppColors.error : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (reply.children != null && reply.children!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: reply.children!.map((child) {
                  return ReplyItem(
                    reply: child,
                    onLike: onLike,
                    onUnlike: onUnlike,
                    isNested: true,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
cd /home/nano/little-grid2
git add app/lib/tools/treehole/widgets/treehole_card.dart
git add app/lib/tools/treehole/widgets/reply_item.dart
git commit -m "feat: add treehole frontend widgets

- Add TreeholeCard for post display
- Add ReplyItem for nested replies with like/reply actions
- Use AppColors for consistent styling

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

## Task 10: 前端页面 - 浏览页

**Files:**
- Create: `app/lib/tools/treehole/treehole_page.dart`

- [ ] **Step 1: 创建 treehole_page.dart**

```dart
import 'package:flutter/material.dart';
import '../../core/ui/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'treehole_post_page.dart';
import 'treehole_detail_page.dart';
import 'treehole_mine_page.dart';
import 'treehole_models.dart';
import 'treehole_service.dart';
import 'widgets/treehole_card.dart';

/// 树洞浏览页
class TreeholePage extends StatefulWidget {
  const TreeholePage({super.key});

  @override
  State<TreeholePage> createState() => _TreeholePageState();
}

class _TreeholePageState extends State<TreeholePage> {
  TreeholePost? _currentPost;
  String _selectedTag = TreeholeTags.all;
  bool _isLoading = false;
  bool _hasNoMore = false;

  @override
  void initState() {
    super.initState();
    _loadRandomPost();
  }

  Future<void> _loadRandomPost() async {
    if (_isLoading) return;

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先登录')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _hasNoMore = false;
    });

    try {
      final tag = _selectedTag == TreeholeTags.all ? null : _selectedTag;
      final post = await TreeholeService.getRandomPost(tag: tag);

      if (mounted) {
        setState(() {
          _currentPost = post;
          _hasNoMore = post == null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onTagChanged(String tag) {
    setState(() {
      _selectedTag = tag;
    });
    _loadRandomPost();
  }

  void _onPostTap() {
    if (_currentPost == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TreeholeDetailPage(postId: _currentPost!.id),
      ),
    );
  }

  void _onCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TreeholePostPage(),
      ),
    ).then((_) {
      _loadRandomPost();
    });
  }

  void _onMyPosts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TreeholeMinePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('树洞'),
        actions: [
          TextButton(
            onPressed: _onMyPosts,
            child: const Text('我的'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTagBar(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreatePost,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTagBar() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: TreeholeTags.allTags.length,
        itemBuilder: (context, index) {
          final tag = TreeholeTags.allTags[index];
          final isSelected = tag == _selectedTag;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _onTagChanged(tag);
                }
              },
              selectedColor: AppColors.primaryLight,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasNoMore || _currentPost == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _hasNoMore ? '今天没有更多树洞了~' : '暂无树洞',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '去说点什么吧',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Dismissible(
              key: Key(_currentPost!.id.toString()),
              direction: DismissDirection.horizontal,
              onDismissed: (direction) {
                _loadRandomPost();
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TreeholeCard(
                  post: _currentPost!,
                  onTap: _onPostTap,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            children: [
              Text(
                '左滑或右滑换一个',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _loadRandomPost,
                icon: const Icon(Icons.refresh),
                label: const Text('换一个'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd /home/nano/little-grid2
git add app/lib/tools/treehole/treehole_page.dart
git commit -m "feat: add treehole browse page

- Add TreeholePage with random post display
- Add tag filter bar
- Add swipe gesture for next post
- Add navigation to detail, my posts, and create post

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

## Task 11: 前端页面 - 发布页

**Files:**
- Create: `app/lib/tools/treehole/treehole_post_page.dart`

- [ ] **Step 1: 创建 treehole_post_page.dart**

```dart
import 'package:flutter/material.dart';
import '../../core/ui/app_colors.dart';
import 'treehole_models.dart';
import 'treehole_service.dart';

/// 发布树洞页
class TreeholePostPage extends StatefulWidget {
  const TreeholePostPage({super.key});

  @override
  State<TreeholePostPage> createState() => _TreeholePostPageState();
}

class _TreeholePostPageState extends State<TreeholePostPage> {
  final _textController = TextEditingController();
  String _selectedTag = TreeholeTags.selectableTags.first;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  int get _currentLength => _textController.text.length;
  bool get _canSubmit => _textController.text.isNotEmpty && _currentLength <= 500;

  Future<void> _onSubmit() async {
    if (!_canSubmit || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await TreeholeService.createPost(
        _textController.text,
        _selectedTag,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('发布成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发布失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('说点什么'),
        actions: [
          TextButton(
            onPressed: _canSubmit && !_isSubmitting ? _onSubmit : null,
            child: const Text('发布'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _textController,
                    autofocus: true,
                    maxLines: null,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: '写下你的秘密或烦恼...',
                      hintStyle: TextStyle(color: AppColors.textTertiary),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '选择标签',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TreeholeTags.selectableTags.map((tag) {
                    final isSelected = tag == _selectedTag;
                    return ChoiceChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedTag = tag;
                          });
                        }
                      },
                      selectedColor: AppColors.primaryLight,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$_currentLength/500',
                    style: TextStyle(
                      fontSize: 12,
                      color: _currentLength > 500
                          ? AppColors.error
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd /home/nano/little-grid2
git add app/lib/tools/treehole/treehole_post_page.dart
git commit -m "feat: add treehole post creation page

- Add TreeholePostPage with text input
- Add tag selection chips
- Add character count and validation
- Add submit logic with loading state

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

## Task 12: 前端页面 - 详情页

**Files:**
- Create: `app/lib/tools/treehole/treehole_detail_page.dart`

- [ ] **Step 1: 创建 treehole_detail_page.dart**

```dart
import 'package:flutter/material.dart';
import '../../core/ui/app_colors.dart';
import 'treehole_models.dart';
import 'treehole_service.dart';
import 'widgets/treehole_card.dart';
import 'widgets/reply_item.dart';

/// 树洞详情页
class TreeholeDetailPage extends StatefulWidget {
  final int postId;

  const TreeholeDetailPage({super.key, required this.postId});

  @override
  State<TreeholeDetailPage> createState() => _TreeholeDetailPageState();
}

class _TreeholeDetailPageState extends State<TreeholeDetailPage> {
  PostDetail? _detail;
  bool _isLoading = false;
  final _replyController = TextEditingController();
  int? _replyingTo;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final detail = await TreeholeService.getPostDetail(widget.postId);
      if (mounted) {
        setState(() {
          _detail = detail;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onSubmitReply() async {
    final content = _replyController.text.trim();
    if (content.isEmpty) return;

    try {
      await TreeholeService.createReply(
        widget.postId,
        content,
        parentId: _replyingTo,
      );

      _replyController.clear();
      setState(() {
        _replyingTo = null;
      });
      _loadDetail();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('回复成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('回复失败: $e')),
        );
      }
    }
  }

  Future<void> _onLikeReply(TreeholeReply reply) async {
    try {
      if (reply.isLiked) {
        await TreeholeService.unlikeReply(reply.id);
      } else {
        await TreeholeService.likeReply(reply.id);
      }
      _loadDetail();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  void _onReplyTo(TreeholeReply reply) {
    setState(() {
      _replyingTo = reply.id;
    });
    _replyController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('树洞详情'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _detail == null
                    ? const Center(child: Text('加载失败'))
                    : _buildContent(),
          ),
          _buildReplyInput(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TreeholeCard(
            post: _detail!.post,
            showReplyCount: false,
          ),
          const SizedBox(height: 24),
          const Text(
            '回复',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          if (_detail!.replies.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  '还没有回复,来说点什么吧~',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            ..._detail!.replies.map((reply) {
              return ReplyItem(
                reply: reply,
                onLike: () => _onLikeReply(reply),
                onUnlike: () => _onLikeReply(reply),
                onReply: () => _onReplyTo(reply),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildReplyInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 8 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_replyingTo != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '回复中...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _replyingTo = null;
                        });
                      },
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    maxLines: null,
                    maxLength: 300,
                    decoration: InputDecoration(
                      hintText: '说点温暖的话吧...',
                      hintStyle: TextStyle(color: AppColors.textTertiary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      isDense: true,
                      counterText: '',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _replyController.text.trim().isEmpty ? null : _onSubmitReply,
                  icon: const Icon(Icons.send),
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd /home/nano/little-grid2
git add app/lib/tools/treehole/treehole_detail_page.dart
git commit -m "feat: add treehole detail page

- Add TreeholeDetailPage with post and replies
- Add nested reply display
- Add reply input with replying-to state
- Add like/unlike functionality

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

## Task 13: 前端页面 - 我的树洞页

**Files:**
- Create: `app/lib/tools/treehole/treehole_mine_page.dart`

- [ ] **Step 1: 创建 treehole_mine_page.dart**

```dart
import 'package:flutter/material.dart';
import '../../core/ui/app_colors.dart';
import 'treehole_detail_page.dart';
import 'treehole_models.dart';
import 'treehole_service.dart';
import 'widgets/treehole_card.dart';

/// 我的树洞页
class TreeholeMinePage extends StatefulWidget {
  const TreeholeMinePage({super.key});

  @override
  State<TreeholeMinePage> createState() => _TreeholeMinePageState();
}

class _TreeholeMinePageState extends State<TreeholeMinePage> {
  List<TreeholePost> _posts = [];
  bool _isLoading = false;
  int _page = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      setState(() {
        _page = 0;
        _hasMore = true;
        _posts = [];
      });
    }

    if (!_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final posts = await TreeholeService.getMyPosts(page: _page);

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (posts.isEmpty) {
            _hasMore = false;
          } else {
            _posts.addAll(posts);
            _page++;
            if (posts.length < 20) {
              _hasMore = false;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onDeletePost(TreeholePost post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条树洞吗?删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await TreeholeService.deletePost(post.id);
        if (mounted) {
          setState(() {
            _posts.remove(post);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除成功')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e')),
          );
        }
      }
    }
  }

  void _onPostTap(TreeholePost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TreeholeDetailPage(postId: post.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的树洞'),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadPosts(refresh: true),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              '还没有发过树洞',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '去说点什么吧~',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _posts.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _posts.length) {
          _loadPosts();
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final post = _posts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Dismissible(
            key: Key(post.id.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              color: AppColors.error,
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            confirmDismiss: (direction) async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('确认删除'),
                  content: const Text('确定要删除这条树洞吗?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: AppColors.error),
                      child: const Text('删除'),
                    ),
                  ],
                ),
              );
              return confirmed == true;
            },
            onDismissed: (direction) {
              _onDeletePost(post);
            },
            child: _buildPostItem(post),
          ),
        );
      },
    );
  }

  Widget _buildPostItem(TreeholePost post) {
    return Card(
      child: InkWell(
        onTap: () => _onPostTap(post),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            post.tag,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (post.replyCount != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 14,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${post.replyCount}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: AppColors.textTertiary,
                onPressed: () => _onDeletePost(post),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd /home/nano/little-grid2
git add app/lib/tools/treehole/treehole_mine_page.dart
git commit -m "feat: add my treehole page

- Add TreeholeMinePage with post list
- Add pull-to-refresh and pagination
- Add delete with confirmation dialog
- Add swipe-to-dismiss gesture

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

## Task 14: 前端工具注册

**Files:**
- Create: `app/lib/tools/treehole/treehole_tool.dart`
- Modify: `app/lib/main.dart`

- [ ] **Step 1: 创建 treehole_tool.dart**

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'treehole_page.dart';

class TreeholeTool implements ToolModule {
  @override
  String get id => 'treehole';

  @override
  String get name => '树洞';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.psychology;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) => const TreeholePage();

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

- [ ] **Step 2: 修改 main.dart 注册工具**

在导入部分添加:
```dart
import 'tools/treehole/treehole_tool.dart';
```

在 `main()` 函数的 ToolRegistry.register 部分添加:
```dart
ToolRegistry.register(TreeholeTool());
```

完整的修改应该是:

读取现有文件后,在导入区添加,在注册区添加。

- [ ] **Step 3: Commit**

```bash
cd /home/nano/little-grid2
git add app/lib/tools/treehole/treehole_tool.dart
git add app/lib/main.dart
git commit -m "feat: register treehole tool

- Add TreeholeTool class
- Register treehole tool in main.dart

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

## Task 15: 自我审查和最终确认

**Files:**
- Review: All files created in previous tasks

- [ ] **Step 1: 审查所有新增文件**

确认:
- 后端文件结构完整
- 前端文件结构完整
- API 路径一致
- 数据模型字段匹配
- 所有功能已覆盖

- [ ] **Step 2: 检查 spec 覆盖情况**

Spec 需求对照:
- [x] 发布树洞 - Task 11
- [x] 随机浏览 - Task 10
- [x] 标签筛选 - Task 10
- [x] 查看详情 - Task 12
- [x] 一级回复 - Task 12
- [x] 二级回复 - Task 12
- [x] 回复点赞 - Task 12
- [x] 我的树洞 - Task 13
- [x] 删除帖子 - Task 13
- [x] 半匿名 - Task 6 (DTO不含用户信息)
- [x] 登录鉴权 - Task 6
- [x] 浏览历史去重 - Task 5

- [ ] **Step 3: 最终确认并完成**

Plan is complete!

---

## Plan Complete

Plan complete and saved to `docs/superpowers/plans/2026-04-14-treehole-implementation.md`.

Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?
