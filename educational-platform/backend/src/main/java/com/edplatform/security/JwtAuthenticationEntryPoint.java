package com.edplatform.security;

import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Custom authentication entry point for handling unauthorized access
 * This class is called when an unauthenticated user tries to access a secured endpoint
 */
@Component
@Slf4j
public class JwtAuthenticationEntryPoint implements AuthenticationEntryPoint {

    @Override
    public void commence(HttpServletRequest request, 
                        HttpServletResponse response,
                        AuthenticationException authException) throws IOException {
        
        log.error("Unauthorized access attempt to: {} - {}", 
                 request.getRequestURI(), authException.getMessage());

        // Set response status and content type
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Create JSON error response
        String jsonResponse = String.format(
            "{\n" +
            "  \"timestamp\": \"%s\",\n" +
            "  \"status\": 401,\n" +
            "  \"error\": \"Unauthorized\",\n" +
            "  \"message\": \"Access denied. Please provide valid authentication credentials.\",\n" +
            "  \"path\": \"%s\"\n" +
            "}",
            java.time.Instant.now().toString(),
            request.getRequestURI()
        );

        // Write JSON response
        response.getWriter().write(jsonResponse);
        response.getWriter().flush();
    }
}
