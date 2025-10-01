package com.e106.kdkd.global.config;

import com.e106.kdkd.global.security.JWTAuthenticationFilter;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JWTAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration cfg = new CorsConfiguration();

        cfg.setAllowedOriginPatterns(List.of("*")); // dev: * , prod: 명시적 도메인으로 교체
        cfg.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
        cfg.setAllowedHeaders(List.of("*"));
        cfg.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource src = new UrlBasedCorsConfigurationSource();
        src.registerCorsConfiguration("/**", cfg);
        return src;
    }


    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(csrf -> csrf.disable())
            .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .httpBasic(AbstractHttpConfigurer::disable)
            .formLogin(AbstractHttpConfigurer::disable)
            .authorizeHttpRequests(auth -> auth
                    .requestMatchers(
                        "/swagger-ui/**",
                        "/v3/api-docs/**",
                        "/swagger-ui.html",
                        "/actuator/health",
                        "/actuator/info",
                        "/actuator/scheduledtasks",
                        "/api/ssafy/**"          // ← Swagger로 테스트할 프록시 API 오픈

                    ).permitAll()
                    .requestMatchers("/parent/**").hasRole("PARENT")
                    .requestMatchers("/child/**").hasRole("CHILD")
                    .anyRequest().permitAll()    // ← 개발 동안 전부 오픈 (운영에서 변경)
//                        // 인증 관련 엔드포인트와 OAuth 콜백은 열어둠
//                        .requestMatchers(
//                                "/api/auth/**",
//                                "/api/oauth2/**",
//                                "
//                                /api/login/oauth2/**"
//                        ).permitAll()
            )
            .httpBasic(basic -> basic.disable())   // ← 기본 인증 팝업 비활성화
            .formLogin(form -> form.disable());    // ← 폼 로그인 비활성화

        // JWT 필터 등록 (UsernamePasswordAuthenticationFilter 앞)
        http.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }


    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(); // strength는 필요에 따라 파라미터 조정
    }
}
