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
