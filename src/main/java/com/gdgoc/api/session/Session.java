package com.gdgoc.api.session;

/**
 * 세션 한 개. 이 필드 이름이 곧 프론트와 맺은 "API 약속(JSON 키)"입니다.
 * 실습 4에서 title → name 으로 바꿔 보고, CI가 무엇을 막아 주는지 확인합니다.
 */
public record Session(int order, String title, String speaker, String school, int minutes) {
}
