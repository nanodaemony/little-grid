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
import java.util.Collections;
import java.util.HashMap;
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
        return PageUtil.toPage(postPage, dtoList);
    }

    @Override
    public PostDetailDTO getPostDetail(Long postId, Long userId) {
        TreeholePost post = postRepository.findById(postId)
                .orElseThrow(() -> new EntityNotFoundException(TreeholePost.class, "id", String.valueOf(postId)));

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
        List<Long> likedReplyIds = allReplyIds.isEmpty() ? Collections.emptyList() :
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
                .orElseThrow(() -> new EntityNotFoundException(TreeholePost.class, "id", String.valueOf(postId)));

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
            throw new EntityNotFoundException(TreeholePost.class, "id", String.valueOf(postId));
        }

        // 如果有parentId,验证父回复存在且属于同一帖子
        if (dto.getParentId() != null) {
            TreeholeReply parent = replyRepository.findById(dto.getParentId())
                    .orElseThrow(() -> new EntityNotFoundException(TreeholeReply.class, "id", String.valueOf(dto.getParentId())));
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
                .children(Collections.emptyList())
                .build();
    }

    @Override
    @Transactional
    public LikeResultDTO likeReply(Long replyId, Long userId) {
        TreeholeReply reply = replyRepository.findById(replyId)
                .orElseThrow(() -> new EntityNotFoundException(TreeholeReply.class, "id", String.valueOf(replyId)));

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
                .orElseThrow(() -> new EntityNotFoundException(TreeholeReply.class, "id", String.valueOf(replyId)));

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
        List<ReplyDTO> children = childrenMap.getOrDefault(reply.getId(), Collections.emptyList())
                .stream()
                .map(child -> toReplyDTO(child, likedReplyIds, Collections.emptyMap()))
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
