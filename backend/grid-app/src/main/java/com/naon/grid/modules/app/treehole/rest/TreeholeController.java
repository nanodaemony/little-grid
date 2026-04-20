package com.naon.grid.modules.app.treehole.rest;

import com.naon.grid.config.SecurityProperties;
import com.naon.grid.modules.app.security.AppTokenProvider;
import com.naon.grid.modules.app.treehole.service.TreeholeService;
import com.naon.grid.modules.app.treehole.service.dto.*;
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

    @ApiOperation("发布树洞")
    @PostMapping("/posts")
    public ResponseEntity<PostDTO> createPost(
            @Validated @RequestBody CreatePostDTO dto,
            HttpServletRequest request) {
        Long userId = getUserIdFromRequest(request);
        PostDTO post = treeholeService.createPost(userId, dto);
        return ResponseEntity.ok(post);
    }

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

    @ApiOperation("获取树洞详情(含回复)")
    @GetMapping("/posts/{id}")
    public ResponseEntity<PostDetailDTO> getPostDetail(
            @PathVariable Long id,
            HttpServletRequest request) {
        Long userId = getUserIdFromRequest(request);
        PostDetailDTO detail = treeholeService.getPostDetail(id, userId);
        return ResponseEntity.ok(detail);
    }

    @ApiOperation("删除我的树洞")
    @DeleteMapping("/posts/{id}")
    public ResponseEntity<Void> deletePost(
            @PathVariable Long id,
            HttpServletRequest request) {
        Long userId = getUserIdFromRequest(request);
        treeholeService.deletePost(id, userId);
        return ResponseEntity.ok().build();
    }

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

    @ApiOperation("点赞回复")
    @PostMapping("/replies/{id}/like")
    public ResponseEntity<TreeholeService.LikeResultDTO> likeReply(
            @PathVariable Long id,
            HttpServletRequest request) {
        Long userId = getUserIdFromRequest(request);
        TreeholeService.LikeResultDTO result = treeholeService.likeReply(id, userId);
        return ResponseEntity.ok(result);
    }

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
