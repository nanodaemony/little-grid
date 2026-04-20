package com.naon.grid.modules.app.security;

import cn.hutool.core.util.IdUtil;
import io.jsonwebtoken.*;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@Component
public class AppTokenProvider implements InitializingBean {

    public static final String TOKEN_PREFIX = "Bearer ";
    public static final String AUTHORITIES_UID_KEY = "uid";
    public static final String DEVICE_ID_KEY = "did";
    public static final String TOKEN_TYPE_KEY = "type";
    public static final String TOKEN_TYPE_ACCESS = "access";
    public static final String TOKEN_TYPE_REFRESH = "refresh";

    private Key signingKey;
    private JwtParser jwtParser;
    private final com.naon.grid.config.SecurityProperties properties;

    @Value("${app.auth.token-validity-in-seconds:15552000}")
    private long tokenValidityInSeconds;

    public AppTokenProvider(com.naon.grid.config.SecurityProperties properties) {
        this.properties = properties;
    }

    @Override
    public void afterPropertiesSet() {
        byte[] keyBytes = Decoders.BASE64.decode(properties.getBase64Secret());
        this.signingKey = Keys.hmacShaKeyFor(keyBytes);
        this.jwtParser = Jwts.parserBuilder()
                .setSigningKey(signingKey)
                .build();
    }

    public String createToken(Long userId, String deviceId) {
        Map<String, Object> claims = new HashMap<>();
        claims.put(AUTHORITIES_UID_KEY, userId);
        claims.put(DEVICE_ID_KEY, deviceId);
        claims.put(TOKEN_TYPE_KEY, TOKEN_TYPE_ACCESS);
        claims.put("jti", IdUtil.simpleUUID());

        Date now = new Date();
        Date expiration = new Date(now.getTime() + tokenValidityInSeconds * 1000);

        return Jwts.builder()
                .setClaims(claims)
                .setSubject(String.valueOf(userId))
                .setIssuedAt(now)
                .setExpiration(expiration)
                .signWith(signingKey, SignatureAlgorithm.HS512)
                .compact();
    }

    public Claims getClaims(String token) {
        return jwtParser.parseClaimsJws(token).getBody();
    }

    public Long getUserIdFromToken(String token) {
        Claims claims = getClaims(token);
        return claims.get(AUTHORITIES_UID_KEY, Long.class);
    }

    public boolean isTokenExpired(String token) {
        try {
            Claims claims = getClaims(token);
            Date expiration = claims.getExpiration();
            return expiration.before(new Date());
        } catch (ExpiredJwtException e) {
            return true;
        } catch (Exception e) {
            log.error("Token validation error", e);
            return true;
        }
    }

    public boolean validateToken(String token) {
        try {
            getClaims(token);
            return !isTokenExpired(token);
        } catch (ExpiredJwtException e) {
            log.warn("Token expired: {}", e.getMessage());
            return false;
        } catch (JwtException e) {
            log.warn("Invalid token: {}", e.getMessage());
            return false;
        }
    }
}
