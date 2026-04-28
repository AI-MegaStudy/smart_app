# Harvest Slot 점주용 Flutter Android 앱 화면 이미지

문서 버전: v1.1 기준  
구성: 점주용 Flutter Android 앱 + 사용자용 Flutter Web  
점주 웹: MVP 제외

## 포함 화면

| File | Screen | Route 예시 | 설명 |
|---|---|---|---|
| O-001_login.png | 로그인 | `/owner/login` | 점주 계정 로그인 |
| O-002_dashboard.png | 대시보드 | `/owner/dashboard` | 오늘 출고, 슬롯, 예약률, 반품, SQLite 미동기화 요약 |
| O-003_product_management.png | 상품 관리 | `/owner/products` | 과일 상품 등록/수정/삭제 |
| O-004_ml_prediction_input.png | ML 예측 입력 | `/owner/ml/input` | 수확량/수확시기/가격 참고값 계산 입력 |
| O-005_ml_result_owner_confirmation.png | ML 결과 및 점주 확정 | `/owner/ml/result` | ML 참고 결과와 점주 확정 입력 분리 |
| O-006_harvest_slot_management.png | 수확 슬롯 관리 | `/owner/slots` | 점주 확정 예약 가능량 기준 슬롯 공개/마감 |
| O-007_order_management.png | 주문 관리 | `/owner/orders` | 예약, 수확 준비, 선별, 포장, 배송 상태 변경 |
| O-008_freshness_camera.png | 신선도 촬영 | `/owner/freshness/camera` | 카메라 촬영 후 DL 판별 요청 |
| O-009_freshness_result_confirmation.png | 신선도 결과 확정 | `/owner/freshness/result` | DL 결과 확인 후 점주 출고 여부 확정 |
| O-010_shipping_management.png | 배송 관리 | `/owner/shipments` | 포장, 송장 Mock 입력, 발송 처리 |
| O-011_return_management.png | 반품 관리 | `/owner/returns` | 고객 반품 요청 승인/거절 |
| O-012_settings_sync.png | 설정 및 동기화 | `/owner/settings` | 농장 정보, SQLite 큐, Open API 수집 상태 |
| 00_overview_owner_app.png | 전체 미리보기 | - | 전체 화면 모음 |

## 중요 정책 반영

- ML 예측값은 예약 확정 기준이 아니라 점주 의사결정 보조 정보입니다.
- 고객에게 노출되는 예약 수량과 판매가는 점주 확정값만 사용합니다.
- DL 신선도 판별 결과도 출고 자동 결정이 아니라 점주 선별 보조 정보입니다.
- 네트워크 실패 시 촬영/스캔 이벤트는 SQLite 큐에 저장 후 재동기화하는 구조입니다.
