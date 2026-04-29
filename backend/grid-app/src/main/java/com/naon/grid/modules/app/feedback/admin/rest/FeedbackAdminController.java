package com.naon.grid.modules.app.feedback.admin.rest;

import com.naon.grid.modules.app.feedback.admin.dto.AdminFeedbackDetailDTO;
import com.naon.grid.modules.app.feedback.admin.dto.AdminFeedbackListDTO;
import com.naon.grid.modules.app.feedback.admin.service.FeedbackAdminService;
import com.naon.grid.utils.PageResult;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/feedback")
@RequiredArgsConstructor
@Api(tags = "Admin：反馈管理")
public class FeedbackAdminController {

    private final FeedbackAdminService feedbackAdminService;

    @GetMapping
    @ApiOperation("获取反馈列表")
    public ResponseEntity<PageResult<AdminFeedbackListDTO>> getFeedbackList(
            @ApiParam("页码，从1开始") @RequestParam(defaultValue = "1") int page,
            @ApiParam("每页数量") @RequestParam(defaultValue = "20") int size,
            @ApiParam("反馈类型过滤") @RequestParam(required = false) String type,
            @ApiParam("状态过滤") @RequestParam(required = false) String status) {
        return ResponseEntity.ok(feedbackAdminService.getFeedbackList(page, size, type, status));
    }

    @GetMapping("/{id}")
    @ApiOperation("获取反馈详情")
    public ResponseEntity<AdminFeedbackDetailDTO> getFeedbackDetail(@PathVariable Long id) {
        return ResponseEntity.ok(feedbackAdminService.getFeedbackDetail(id));
    }

    @PutMapping("/{id}/read")
    @ApiOperation("标记已读")
    public ResponseEntity<Map<String, Object>> markAsRead(@PathVariable Long id) {
        feedbackAdminService.markAsRead(id);
        Map<String, Object> result = new HashMap<>();
        result.put("message", "操作成功");
        return ResponseEntity.ok(result);
    }
}
