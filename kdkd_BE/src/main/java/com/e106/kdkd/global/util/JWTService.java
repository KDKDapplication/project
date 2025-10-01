package com.e106.kdkd.global.util;

import com.e106.kdkd.global.common.entity.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class JWTService {

    private final Key key;
    private final long accessExpMs;

    public JWTService(@Value("${APP_JWT_SECRET}") String secret,
        @Value("${APP_JWT_ACCESS_EXP_MS:360000000}") long accessExpMs) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.accessExpMs = accessExpMs;
    }

    public String createAccessToken(User user) {
        Date now = new Date();
        Date exp = new Date(now.getTime() + accessExpMs);
        return Jwts.builder()
            .setSubject(user.getUserUuid())   // <-- userUuid 사용
            .claim("email", user.getEmail())
            .claim("name", user.getName())
            .setIssuedAt(now)
            .setExpiration(exp)
            .signWith(key, SignatureAlgorithm.HS256)
            .compact();
    }

    public Jws<Claims> parseToken(String token) {
        return Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token);
    }
}