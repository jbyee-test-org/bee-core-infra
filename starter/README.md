# starter — 모듈 starter 데이터 (Phase 3 슬롯)

`bee new <module>` 이 복사할 모듈 뼈대. **chart 와 공동 버전** — starter 의 module.yaml 은
chart 의 values 계약과 한 몸이고, `spec.chart.version` 을 현재 chart 버전으로 프리필한다(G5·G6).

규칙: 치환은 이름만. 변형(언어/유형)은 조건 분기가 아니라 **starter 디렉토리 추가**로
(`starter/rust/`, `starter/python/` …). CLI 에 if 문이 생기는 순간이 위반 신호다(G5).
