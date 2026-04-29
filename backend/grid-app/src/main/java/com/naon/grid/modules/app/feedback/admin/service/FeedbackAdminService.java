package com.naon.grid.modules.app.feedback.admin.service;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.TypeReference;
import com.naon.grid.exception.EntityNotFoundException;
import com.naon.grid.modules.app.domain.GridUser;
import com.naon.grid.modules.app.feedback.admin.dto.AdminFeedbackDetailDTO;
import com.naon.grid.modules.app.feedback.admin.dto.AdminFeedbackListDTO;
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
