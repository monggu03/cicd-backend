package com.gdgoc.api.session;

import java.util.Comparator;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class SessionService {

    // 실습용이라 DB 없이 메모리에 둡니다.
    private static final List<Session> SESSIONS = List.of(
            new Session(3, "홍익대 세션", "홍익대 스피커", "홍익대", 20),
            new Session(1, "오프닝", "운영진", "공동", 10),
            new Session(2, "CI/CD, 어떻게 하는 걸까", "이도윤", "동국대", 20),
            new Session(4, "네트워킹", "모두", "공동", 30)
    );

    /** order 순서대로 정렬한 세션 목록 */
    public List<Session> findAll() {
        return SESSIONS.stream()
                .sorted(Comparator.comparingInt(Session::order))
                .toList();
    }

    /** 전체 진행 시간(분) */
    public int totalMinutes() {
        return SESSIONS.stream().mapToInt(Session::minutes).sum();
    }
}
