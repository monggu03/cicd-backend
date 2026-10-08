package com.gdgoc.api.session;

import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class SessionController {

    // 실습 5에서 v1 → v2 로 바꿔 배포하고, 실습 6에서 v1 리비전으로 롤백합니다.
    static final String GREETING = "안녕하세요, 동홍동락 서버입니다 · v1";

    private final SessionService sessionService;
    private final String revision;

    // K_REVISION: Cloud Run이 "지금 돌고 있는 리비전 이름"을 넣어 주는 환경 변수입니다.
    // 로컬에는 없으니 기본값 local 이 들어갑니다.
    public SessionController(SessionService sessionService,
                             @Value("${K_REVISION:local}") String revision) {
        this.sessionService = sessionService;
        this.revision = revision;
    }

    @GetMapping("/sessions")
    public List<Session> sessions() {
        return sessionService.findAll();
    }

    @GetMapping("/hello")
    public HelloResponse hello() {
        return new HelloResponse(GREETING, revision);
    }

    public record HelloResponse(String message, String revision) {
    }
}
