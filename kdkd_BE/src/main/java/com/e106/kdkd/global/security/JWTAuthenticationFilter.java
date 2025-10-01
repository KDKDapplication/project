package com.e106.kdkd.global.security;

import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.global.common.enums.Role;
import com.e106.kdkd.global.util.JWTService;
import com.e106.kdkd.users.repository.UserRepository;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
@RequiredArgsConstructor
public class JWTAuthenticationFilter extends OncePerRequestFilter {

    private final JWTService jwtService;
    private final UserRepository userRepository;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
        HttpServletResponse response,
        FilterChain filterChain) throws ServletException, IOException {

        // 이미 인증이 세팅되어 있으면 건드리지 않고 통과
        if (SecurityContextHolder.getContext().getAuthentication() != null) {
            filterChain.doFilter(request, response);
            return;
        }

        String header = request.getHeader("Authorization");

        if (!StringUtils.hasText(header) || !header.startsWith("Bearer ")) {
            // 토큰이 없으면 인증 없이 다음 필터로 진행(요청이 인증이 필요한 경우 Security가 차단)
            filterChain.doFilter(request, response);
            return;
        }

        String token = header.substring(7).trim();
        if (!StringUtils.hasText(token)) {
            filterChain.doFilter(request, response);
            return;
        }

        try {
            Jws<Claims> jws = jwtService.parseToken(token); // 검증 및 파싱 (예외 발생 시 catch)
            Claims claims = jws.getBody();
            String userUuid = claims.getSubject();
            if (userUuid == null) {
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED,
                    "Invalid token: no subject");
                return;
            }

            Optional<User> optUser = userRepository.findById(userUuid);
            if (optUser.isEmpty()) {
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "User not found");
                return;
            }

            User user = optUser.get();

            Role roleName = user.getRole();
            if (roleName == null) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Role not assigned");
                return;
            }

            var authority = new SimpleGrantedAuthority("ROLE_" + roleName.name());

            String email = user.getEmail();

            CustomPrincipal principal = new CustomPrincipal(userUuid, email, roleName);

            var authentication =
                new UsernamePasswordAuthenticationToken(principal, null, List.of(authority));
            authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

            // SecurityContext 세팅
            SecurityContextHolder.getContext().setAuthentication(authentication);

            filterChain.doFilter(request, response);
        } catch (JwtException ex) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid or expired token");
        } catch (Exception ex) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Authentication error");
        }
    }
}
