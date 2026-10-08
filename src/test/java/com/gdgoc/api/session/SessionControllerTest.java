package com.gdgoc.api.session;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.options;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;

/**
 * 실제 HTTP 요청처럼 API를 호출해 보는 테스트입니다.
 * "프론트와 약속한 JSON 모양"이 깨지면 여기서 빨간불이 켜집니다.
 */
@SpringBootTest
@AutoConfigureMockMvc
class SessionControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void 세션_목록_API는_프론트가_쓰는_필드를_모두_돌려준다() throws Exception {
        mockMvc.perform(get("/api/sessions"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(4))
                .andExpect(jsonPath("$[0].order").value(1))
                .andExpect(jsonPath("$[0].title").value("오프닝"))
                .andExpect(jsonPath("$[0].speaker").exists())
                .andExpect(jsonPath("$[0].school").exists())
                .andExpect(jsonPath("$[0].minutes").value(10));
    }

    @Test
    void 인사_API는_메시지와_리비전을_돌려준다() throws Exception {
        mockMvc.perform(get("/api/hello"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value(SessionController.GREETING))
                .andExpect(jsonPath("$.revision").value("local"));
    }

    @Test
    void 로컬_프론트에서_부르는_요청은_CORS로_허용된다() throws Exception {
        mockMvc.perform(options("/api/sessions")
                        .header("Origin", "http://localhost:5173")
                        .header("Access-Control-Request-Method", "GET"))
                .andExpect(status().isOk())
                .andExpect(header().string("Access-Control-Allow-Origin", "http://localhost:5173"));
    }
}
