package com.naon.grid.modules.app.rest;

import com.naon.grid.annotation.Log;
import com.naon.grid.annotation.rest.AnonymousPostMapping;
import com.naon.grid.modules.app.security.AppTokenProvider;
import com.naon.grid.modules.app.service.AppAuthService;
import com.naon.grid.modules.app.service.dto.LoginDTO;
import com.naon.grid.modules.app.service.dto.RegisterDTO;
import com.naon.grid.modules.app.service.dto.TokenDTO;
import com.naon.grid.modules.app.service.dto.UpdateUserDTO;
import com.naon.grid.modules.app.service.dto.AppUserDTO;
import com.naon.grid.modules.security.config.SecurityProperties;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/app/auth")
@Api(tags = "APP：认证接口")
public class AppAuthController {

    private final AppAuthService appAuthService;
    private final AppTokenProvider appTokenProvider;
    private final SecurityProperties securityProperties;

    @Log("APP用户注册")
    @ApiOperation("用户注册")
    @AnonymousPostMapping("/register")
    public ResponseEntity<TokenDTO> register(@Validated @RequestBody RegisterDTO registerDTO,
                                              HttpServletRequest request) {
        TokenDTO tokenDTO = appAuthService.register(registerDTO, request);
        return ResponseEntity.ok(tokenDTO);
    }

    @Log("APP用户登录")
    @ApiOperation("用户登录")
    @AnonymousPostMapping("/login")
    public ResponseEntity<TokenDTO> login(@Validated @RequestBody LoginDTO loginDTO,
                                           HttpServletRequest request) {
        TokenDTO tokenDTO = appAuthService.login(loginDTO, request);
        return ResponseEntity.ok(tokenDTO);
    }

    @Log("APP用户退出")
    @ApiOperation("退出登录")
    @AnonymousPostMapping("/logout")
    public ResponseEntity<Void> logout(@RequestParam String deviceId,
                                        HttpServletRequest request) {
        String authHeader = request.getHeader(securityProperties.getHeader());
        String token = null;
        if (authHeader != null && authHeader.startsWith(securityProperties.getTokenStartWith())) {
            token = authHeader.substring(securityProperties.getTokenStartWith().length());
        }
        if (token == null) {
            throw new com.naon.grid.exception.BadRequestException("请先登录");
        }
        Long userId = appTokenProvider.getUserIdFromToken(token);
        appAuthService.logout(userId, deviceId);
        return ResponseEntity.ok().build();
    }

    @Log("APP用户更新信息")
    @ApiOperation("更新用户信息")
    @AnonymousPostMapping("/user/update")
    public ResponseEntity<AppUserDTO> updateUser(@Validated @RequestBody UpdateUserDTO updateUserDTO,
                                                   HttpServletRequest request) {
        log.info("Received updateUser request, nickname={}, email={}", updateUserDTO.getNickname(), updateUserDTO.getEmail());
        String authHeader = request.getHeader(securityProperties.getHeader());
        log.info("Authorization header: {}", authHeader != null ? "present" : "missing");
        String token = null;
        if (authHeader != null && authHeader.startsWith(securityProperties.getTokenStartWith())) {
            token = authHeader.substring(securityProperties.getTokenStartWith().length());
        }
        if (token == null) {
            log.warn("No token found in request");
            throw new com.naon.grid.exception.BadRequestException("请先登录");
        }
        Long userId = appTokenProvider.getUserIdFromToken(token);
        log.info("Current user ID from token: {}", userId);
        AppUserDTO userDTO = appAuthService.updateUser(userId, updateUserDTO);
        log.info("updateUser completed successfully");
        return ResponseEntity.ok(userDTO);
    }
}
