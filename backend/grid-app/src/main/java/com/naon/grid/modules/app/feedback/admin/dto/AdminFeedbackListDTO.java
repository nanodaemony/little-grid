package com.naon.grid.modules.app.feedback.admin.dto;

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
