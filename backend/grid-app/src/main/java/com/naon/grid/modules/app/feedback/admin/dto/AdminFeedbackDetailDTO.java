package com.naon.grid.modules.app.feedback.admin.dto;

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
