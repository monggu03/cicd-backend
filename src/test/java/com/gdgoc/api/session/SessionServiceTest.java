package com.gdgoc.api.session;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import org.junit.jupiter.api.Test;

/** 스프링 없이 도는 순수 단위 테스트 (가장 빠름) */
class SessionServiceTest {

    private final SessionService sessionService = new SessionService();

    @Test
    void 세션은_order_순서로_정렬된다() {
        List<Integer> orders = sessionService.findAll().stream().map(Session::order).toList();

        assertThat(orders).containsExactly(1, 2, 3, 4);
    }

    @Test
    void 전체_진행_시간은_80분이다() {
        assertThat(sessionService.totalMinutes()).isEqualTo(80);
    }
}
