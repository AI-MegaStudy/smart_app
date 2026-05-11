# SMART_APP FastAPI 연동 플랜 및 체크리스트

작성일: 2026-05-11

기준 문서:
- `docs/backend_docs/API_SPEC_BACKEND.md`
- `docs/backend_docs/INTEGRATION_CHECKLIST.md`
- `docs/backend_docs/SMART_APP_백엔드_연결검토_2026-05-11.md`
- 보조 참고: `C:\Users\ose\smart_docs\00_harvest_slot_docs_v3_2`
- 읽기 전용 참고 가능: `C:\Users\ose\smart_web`

## 원칙

- DB와 FastAPI 계약은 `docs/backend_docs`를 최종 기준으로 둔다.
- 데이터가 없거나 API 계약이 부족한 기능은 억지 구현하지 않고 후순위로 미루며 원인을 이 문서에 남긴다.
- `smart_web` 프로젝트는 참고만 하고 수정하지 않는다.
- 한 번에 모든 화면을 붙이지 않고, 공통 API 계층부터 작은 단위로 연결하고 검증한다.

## 진행 체크리스트

### 1. 공통 API 및 인증

- [x] `ApiService` base URL을 `/api/v1` 포함 구조로 변경
- [x] `data/message/error` 응답 envelope 처리
- [x] Bearer token 헤더 주입 구조 추가
- [x] GET/POST/PUT/PATCH 공통 메서드 추가
- [x] 점주 로그인 `POST /api/v1/auth/login` 연결
- [x] 로그인 후 `GET /api/v1/me`로 OWNER role 확인
- [x] 회원가입 이메일 인증 발송 `POST /api/v1/auth/email/send` 연결
- [x] 회원가입 이메일 인증 확인 `POST /api/v1/auth/email/verify` 연결
- [x] 점주 회원가입 `POST /api/v1/auth/owners/signup` 연결
- [ ] 토큰 영구 저장소 적용
  - 보류 사유: 현재 의존성에 secure storage/shared preferences가 없어 우선 메모리 토큰으로 연결했다.
- [x] 401 응답 시 로그인 화면 복귀

### 2. 대시보드

- [x] `GET /api/v1/owner/dashboard` 실제 호출
- [x] snake_case 필드 매핑
- [x] demo fallback 제거 및 오류 표시
- [ ] 백엔드 서버 실행 상태에서 실제 응답 확인

### 3. 농장 관리

- [x] `GET /api/v1/owner/farms/me`
- [x] `PUT /api/v1/owner/farms/{farm_id}`
- [ ] 농장 생성 API
  - 보류 사유: 최종 백엔드 명세에 `POST /owner/farms` 또는 회원가입 시 농장 자동 생성 API가 없다. 신규 점주가 가입 직후 농장을 하나도 갖고 있지 않으면 농장 수정/상품 등록 흐름이 시작되지 않는다.
- [x] 농장 이미지 업로드 방식 확정
  - 농장 전용 multipart 업로드 API가 없어 `farm_image_url` 문자열 입력/저장 방식으로 처리한다.
- [x] 복수 농장 선택 UI
  - `/owner/farms/me` 결과가 2개 이상이면 수정할 농장을 선택할 수 있다.

### 4. 상품 관리

- [x] `GET /api/v1/owner/products`
- [x] `POST /api/v1/owner/products`
- [x] `PUT /api/v1/owner/products/{product_id}`
- [x] `PATCH /api/v1/owner/products/{product_id}/status`
- [x] 상품 이미지 업로드 연결
  - 상품 수정 화면에서 저장된 상품의 이미지를 `POST /owner/products/{product_id}/image`로 업로드한다.
- [x] 삭제 UI를 숨김/판매중지 정책으로 변경
  - 보류 사유: 백엔드 최종 명세에 `DELETE /owner/products/{id}`가 없다.
- [x] 상품 등록 시 농장 직접 선택 UI
  - `GET /owner/farms/me` 결과에서 농장을 선택해 `farm_id`로 상품을 등록한다.

### 5. ML 예측 및 수확 슬롯

- [x] `POST /api/v1/owner/ml/predictions`
- [x] `GET /api/v1/owner/ml/predictions`
- [x] `GET /api/v1/owner/harvest-slots`
- [x] `POST /api/v1/owner/harvest-slots`
- [x] `PUT /api/v1/owner/harvest-slots/{slot_id}`
- [x] `PATCH /api/v1/owner/harvest-slots/{slot_id}/status`
- [x] 예측 결과를 슬롯 생성 payload로 넘기는 화면 흐름 정리
- [x] ML 예측 입력 features UI
  - 과거 수확량, 시장 가격, 품종, 3월 평균기온, 8월 일조시간, 10월 강수량, 8월 습도를 입력받아 최종 ML 예측 API feature로 전달한다.
- [x] 슬롯 수정 및 상태 변경 UI
  - 슬롯 목록에서 상세 편집 화면으로 이동해 날짜/수량/가격/공지/상태를 수정한다.

### 6. 예약 및 주문 현황

- [x] `GET /api/v1/owner/reservations`
- [x] `GET /api/v1/owner/orders`
- [x] 예약과 주문을 한 화면에 합쳐 볼지 분리할지 확정
  - 1차 연동에서는 기존 `OrdersPage`에 예약/주문을 합쳐 표시한다.

### 7. 발주 승인

- [x] `GET /api/v1/owner/procurements`
- [x] `GET /api/v1/owner/procurements/{procurement_id}`
- [x] `PATCH /api/v1/owner/procurements/{procurement_id}/decision`
- [x] 현재 일괄 승인 UI를 procurement 단위 PATCH 흐름에 맞게 조정
  - 화면에서는 여러 건을 선택할 수 있지만 API 호출은 `procurement_id` 단위로 순차 처리한다.

### 8. 선별/품질 검사

- [x] `GET /api/v1/owner/quality-inspections`
- [x] `POST /api/v1/owner/quality-inspections/analyze`
- [x] `POST /api/v1/owner/quality-inspections`
- [x] 검사 대상 `procurement_item_id` 선택 UI 추가
- [x] 품질 이미지 multipart 업로드

### 9. 배송 관리

- [x] `POST /api/v1/owner/shipments`
- [ ] `PATCH /api/v1/owner/shipments/{shipment_id}/status`
  - 부분 구현: 앱 세션 안에서 방금 등록한 배송은 `POST /owner/shipments` 응답의 `shipment_id`를 이용해 `DELIVERED` 처리할 수 있다.
  - 보류 사유: 기존 배송 목록을 다시 조회할 점주용 API가 없어 전체 배송 상태 변경 기능으로 보기는 어렵다.
- [x] 배송 등록 화면에서 실제 `order_id`를 선택하도록 변경
- [ ] 배송 목록 조회 API
  - 보류 사유: 최종 명세에는 점주용 배송 목록 조회 API가 없다. 또한 `/owner/orders` 응답에는 `shipment_status`, `tracking_no`만 있고 `shipment_id`가 없어 상태 변경 PATCH를 안정적으로 호출할 수 없다.
- [ ] 배송 상태 변경 UI/API 연결
  - 보류 사유: 상태 변경 API는 있으나 현재 화면에서 `shipment_id`를 안정적으로 조회할 점주 배송 목록 API 또는 `/owner/orders`의 `shipment_id` 필드가 필요하다.

### 10. 반품/환불

- [x] `GET /api/v1/owner/returns`
- [x] `PATCH /api/v1/owner/returns/{return_request_id}/decision`

### 11. 프로필 및 계정 보조 기능

- [x] `GET /api/v1/owner/profile`
- [x] `PUT /api/v1/owner/profile`
- [ ] 이메일/비밀번호 변경 API 확정
  - 보류 사유: 현재 프로필 수정 API는 `owner_name`, `owner_phone`, `business_number`만 지원한다. 이메일은 읽기 전용으로 표시하고 비밀번호 변경 UI는 제거했다.
- [ ] 이메일 찾기 API 확정
  - 보류 사유: 최종 백엔드 명세에 점주 이메일 찾기 API가 없다.
- [ ] 비밀번호 재설정 API 확정
  - 보류 사유: 최종 백엔드 명세에 비밀번호 재설정 API가 없다.

## 이번 작업 결과

- 공통 API 계층, 로그인, 대시보드의 1차 FastAPI 연결을 시작했다.
- 남은 화면들은 위 체크리스트 순서대로 진행한다.
- 상품 관리 1차 연결을 추가했다.
  - 목록: `GET /owner/products`
  - 등록: `POST /owner/products`
  - 수정: `PUT /owner/products/{product_id}`
  - 숨김 처리: `PATCH /owner/products/{product_id}/status` with `HIDDEN`
- 농장 관리 1차 연결을 추가했다.
  - 조회: `GET /owner/farms/me`
  - 수정: `PUT /owner/farms/{farm_id}`
  - 현재 화면 구조상 첫 농장을 수정 대상으로 사용한다.
- ML 예측 및 수확 슬롯 1차 연결을 추가했다.
  - 예측 생성/조회: `POST/GET /owner/ml/predictions`
  - 슬롯 조회/초안 생성: `GET/POST /owner/harvest-slots`
  - 슬롯 생성은 ML 예측 결과를 사용해 `DRAFT` 상태로 만든다.
  - 예측 feature로 과거 수확량과 시장 가격을 입력할 수 있다.
- ML 예측 API 최종 연동 문서를 반영했다.
  - 참고 문서: `C:\Users\ose\harvest-slot-backend\docs\api\frontend_integration_guide.md`, `ml_prediction_api.md`, `examples\ml_prediction_request.json`, `examples\ml_prediction_response.json`
  - 참고 프로젝트는 읽기만 했고 수정하지 않았다.
  - 호출 경로는 `POST /api/v1/owner/ml/predictions`를 유지한다.
  - OWNER 로그인 access token은 기존 공통 `ApiService`의 `Authorization: Bearer {token}` 헤더 주입을 사용한다.
  - 요청 feature를 최종 명세에 맞춰 `past_yield_kg`, `market_price`, `variety`, `mar_avg_temp`, `aug_sunshine`, `oct_rainfall`, `aug_humidity`로 변경했다.
  - 기존 앱의 `suggested_price`, `fruit_type` 전송은 ML 예측 API 최종 요청값과 맞지 않아 제거했다.
  - 화면 입력값으로 품종, 3월 평균기온, 8월 일조시간, 10월 강수량, 8월 습도를 추가했다.
  - 응답값의 `unit_yield_kg_10a`를 모델에 추가하고 수확 예측 화면에 표시한다.
  - Python 3.12 / scikit-learn 1.8.0 및 `model.joblib` 배치는 백엔드 런타임 관리 항목이므로 앱에서는 별도 처리하지 않는다.
- 예약 및 주문 현황 1차 연결을 추가했다.
  - 예약 목록: `GET /owner/reservations`
  - 주문 목록: `GET /owner/orders`
  - 기존 주문 현황 화면에 예약과 주문을 함께 표시한다.
- 발주 승인 1차 연결을 추가했다.
  - 목록/상세: `GET /owner/procurements`, `GET /owner/procurements/{id}`
  - 승인/거절: `PATCH /owner/procurements/{id}/decision`
  - 기존 일괄 선택 UI는 유지하되 실제 API는 발주 건별로 순차 호출한다.
- 선별/품질 검사 1차 연결을 추가했다.
  - 검사 대상은 승인/부분 승인 발주의 `procurement_item_id`에서 선택한다.
  - 선택 이미지를 `POST /owner/quality-inspections/image`로 업로드한 뒤 반환된 `image_url`로 분석/저장한다.
- 배송 관리 1차 연결을 추가했다.
  - `/owner/orders`에서 배송 가능한 주문을 선택한다.
  - 배송 등록은 `POST /owner/shipments`로 처리한다.
  - 점주 배송 목록 API와 `shipment_id` 조회 경로가 없어 배송 상태 변경은 보류했다.
- 반품/환불 관리 1차 연결을 추가했다.
  - 반품 목록: `GET /owner/returns`
  - 승인/거절: `PATCH /owner/returns/{return_request_id}/decision`
  - 처리 결과는 기존 반품 현황 목록에도 반영한다.
- 점주 프로필 1차 연결을 추가했다.
  - 조회/수정: `GET/PUT /owner/profile`
  - 이메일/비밀번호 변경은 API 범위 밖이라 이메일은 읽기 전용, 비밀번호 변경은 보류했다.
- 인증 만료 처리 1차 연결을 추가했다.
  - `ApiService`에서 401 응답 시 access token을 지우고 로그인 화면으로 이동한다.
  - 로그아웃 버튼도 토큰을 지운 뒤 로그인 화면으로 이동한다.

- 배송 상태 변경은 부분 우회 구현을 추가했다.
  - `POST /owner/shipments` 응답의 `shipment_id`를 배송 현황 로컬 레코드에 저장한다.
  - 앱을 끄지 않은 같은 세션에서 방금 등록한 배송은 배송 현황 화면에서 `PATCH /owner/shipments/{shipment_id}/status`로 `DELIVERED` 처리할 수 있다.
  - 기존 샘플 배송 또는 서버에서 다시 조회한 배송 목록은 여전히 상태 변경이 제한된다.
  - 남은 원인: 최종 백엔드 명세와 구현에는 점주용 배송 목록 조회 API가 없고, `/owner/orders` 응답에도 `shipment_id`가 없어 기존 배송의 상태 변경 대상을 안정적으로 찾을 수 없다.
- `git diff --check`로 빠른 공백 검사를 수행했다.
  - 결과: 공백 오류는 없었다.
  - `LF will be replaced by CRLF` 경고는 Windows 작업 트리의 줄바꿈 경고이며 이번 코드 동작 검증 실패는 아니다.
- `dart format`, `flutter test`, `flutter analyze`는 이전 장시간 지연 이슈 때문에 이번 단계에서 실행하지 않았다.
- 백엔드 서버 실행 여부를 짧게 확인했다.
  - 확인 명령: `GET http://127.0.0.1:8000/api/v1/health`
  - 결과: 원격 서버에 연결할 수 없었다.
  - 처리: 서버가 떠 있지 않은 상태로 판단하고, 실제 응답 기반 통합 검증은 보류한다.
- 점주 회원가입 화면을 실제 이메일 인증 기반 API 흐름으로 연결했다.
  - 인증번호 발송: `POST /auth/email/send`
  - 인증번호 확인: `POST /auth/email/verify`
  - 점주 계정 생성: `POST /auth/owners/signup`
  - 백엔드 `SignupRequest`가 `email`, `password`, `name`, `phone`만 받으므로 사업자번호, 농장명, 주소는 가입 API에 전송하지 않는다.
  - 보류 사유: 회원가입 시점에 사업자번호/농장 정보를 함께 생성하거나 저장하는 API가 최종 명세에 없다. 사업자번호는 로그인 후 `PUT /owner/profile`, 농장 정보는 기존 농장이 있을 때 `PUT /owner/farms/{farm_id}`로 처리해야 한다.
- 회원가입 직후 사업자번호 저장 우회 흐름을 추가했다.
  - 사업자번호가 입력된 경우 계정 생성 후 새 계정으로 자동 로그인한다.
  - `PUT /owner/profile`로 `business_number`를 저장한 뒤 토큰을 다시 비운다.
  - 이 저장 단계가 실패해도 계정 생성 자체는 유지되므로, 사용자에게 로그인 후 프로필에서 다시 저장하라고 안내한다.
  - 농장명/주소는 여전히 저장하지 않는다. 원인: 농장 생성 API가 최종 명세에 없고, `PUT /owner/farms/{farm_id}`는 기존 농장 ID가 있어야 호출할 수 있다.
- API 오류 메시지 처리를 보강했다.
  - 기존에는 `error` 필드만 우선 표시했다.
  - FastAPI 기본 오류 응답의 `detail` 문자열/리스트도 표시하도록 `ApiService`를 보완했다.
- 이메일 찾기/비밀번호 찾기 화면의 더미 성공 메시지를 제거했다.
  - 최종 백엔드 명세에 API가 없어 실제 값을 찾거나 재설정 메일을 보냈다고 표시하지 않는다.
  - 화면에서는 현재 API 미확정 안내만 보여준다.
- 발주/배송/반품 현황과 주문 현황의 남은 샘플 데이터를 제거했다.
  - `procurementStatusRecords`, `shipmentStatusRecords`, `returnStatusRecords`는 빈 목록으로 시작한다.
  - 실제 승인/배송 등록/반품 처리 결과가 발생했을 때만 현황 목록에 추가된다.
  - `OrdersPage` 하단에 남아 있던 미사용 `sampleOrders`/`OrderRecord` 더미 정의도 제거했다.
- 발주 현황과 반품/환불 현황을 서버 목록 기반으로 보강했다.
  - 발주 현황은 `GET /owner/procurements`에서 이미 처리된 발주를 읽어 표시한다.
  - 반품/환불 현황은 `GET /owner/returns`에서 이미 처리된 반품 요청을 읽어 표시한다.
  - 배송 현황은 점주용 배송 목록 조회 API가 없어 여전히 앱 세션 내 등록/상태 변경 결과만 표시한다.
- 발주/반품 현황의 서버 조회 결과와 앱 세션 내 처리 결과가 중복 표시되지 않도록 병합 로직을 추가했다.
  - 발주 현황은 `procurement_id` 기준으로 중복을 제거한다.
  - 반품/환불 현황은 `return_request_id` 기준으로 중복을 제거한다.
  - 배송 현황은 서버 목록 API와 `shipment_id` 재조회 경로가 없어 같은 방식의 병합을 적용하지 못했다.
- 신규 점주가 농장이 없는 경우의 안내를 보강했다.
  - 농장 관리 화면은 농장 목록이 비어 있으면 수정 폼을 숨기고, 농장 생성 API가 없어 기존 농장만 수정 가능하다고 안내한다.
  - 상품 등록 화면은 농장이 없으면 상품 등록을 진행할 수 없다는 이유를 `농장 생성 API 부재`로 명확히 안내한다.
- 공통 API 네트워크 오류 처리를 보강했다.
  - `GET/POST/PUT/PATCH`와 multipart 업로드에서 타임아웃과 `http.ClientException`을 `ApiException`으로 변환한다.
  - 백엔드 서버가 꺼져 있거나 응답하지 않을 때 화면에 원시 예외 대신 “API 서버 연결 불가/응답 시간 초과” 안내가 보이도록 했다.
  - `ApiException.toString()`은 화면 표시용 메시지만 반환하도록 조정했다.
  - JSON이 아닌 응답이 와도 화면에서 파싱 예외가 그대로 노출되지 않도록 공통 응답 파싱 오류 메시지를 추가했다.
- 앱 자체에서 발생시키는 주요 `ApiException` 문구를 한국어로 정리했다.
  - 로그인/권한, 농장 없음, 상품 ID 없음, 수확 예측 조건 부족, 이미지 업로드 응답 누락 등 화면에 직접 노출될 수 있는 오류를 점주 앱 문구로 바꿨다.
- 대시보드의 남은 demo fallback 수치를 제거했다.
  - API 응답이 없을 때 `7/4/3/0` 같은 샘플 숫자를 보여주지 않고 `-`로 표시한다.
  - 대시보드 상단에 새로고침 버튼을 추가해 서버 재기동 후 바로 다시 조회할 수 있게 했다.
  - 대시보드 로드 실패 시 공통 API 오류 메시지를 그대로 보여주도록 조정했다.
- 운영 앱에 남아 있던 테스트 계정/특정 농장 하드코딩을 제거했다.
  - 로그인 화면의 `owner@test.com`/`demo1234!` 자동 입력을 제거했다.
  - 로그인/대시보드의 특정 농장명·점주명 문구를 일반 점주 앱 문구로 바꿨다.
  - 위젯 테스트는 자동 입력 제거에 맞춰 테스트 안에서 계정 정보를 입력하도록 수정했다.
- 주소 검색의 데스크톱 fallback 샘플 주소를 제거했다.
  - `SignupPage`, `FarmDetailPage`에서 Android/iOS가 아닌 환경이면 샘플 주소 목록을 보여주지 않는다.
  - 대신 “현재 주소 검색은 Android/iOS 환경에서만 사용할 수 있다”는 안내를 표시한다.
- 배송 현황 빈 상태 안내를 보강했다.
  - 점주용 배송 목록 조회 API가 없어 앱에서 방금 등록한 배송만 표시할 수 있다는 제한을 화면에 명시했다.

- 백엔드/의존성 필요 항목을 정리했다.
  - 토큰 영구 저장
    - 필요: `flutter_secure_storage` 또는 `shared_preferences` 계열 의존성 추가와 `pub get`.
    - 현재 조치: 장시간 지연 이슈 때문에 의존성 추가/Flutter 툴 실행 없이 메모리 토큰으로 유지한다.
  - 농장 생성
    - 필요 API 예: `POST /api/v1/owner/farms`
    - 이유: 신규 점주가 농장 없이 가입하면 `PUT /owner/farms/{farm_id}`와 상품 등록을 시작할 수 없다.
  - 점주 배송 목록 조회
    - 필요 API 예: `GET /api/v1/owner/shipments`
    - 최소 대안: `GET /owner/orders` 응답에 `shipment_id` 포함.
    - 이유: 기존 배송의 `PATCH /owner/shipments/{shipment_id}/status` 호출 대상 식별이 필요하다.
  - 이메일/비밀번호 변경
    - 필요 API 예: `PATCH /api/v1/auth/email`, `PATCH /api/v1/auth/password`
    - 현재 조치: 프로필 화면에서 이메일은 읽기 전용, 비밀번호 변경은 미제공.
  - 이메일 찾기/비밀번호 재설정
    - 필요 API 예: `POST /api/v1/auth/email/find`, `POST /api/v1/auth/password/reset/request`, `POST /api/v1/auth/password/reset/confirm`
    - 현재 조치: 화면에서 API 미확정 안내만 표시한다.
- 더미/샘플 제거 상태를 빠르게 재검증했다.
  - `fallbackAddresses`, 샘플 주소, 테스트 계정, 샘플 농장명, demo/sample 키워드가 운영 화면/모델/저장소에 남아 있는지 `rg`로 확인했다.
  - 결과: 추가 제거 대상은 발견되지 않았다.
- 배송 현황의 백엔드 제약을 화면과 문서에 모두 반영했다.
  - 화면: 점주용 배송 목록 조회 API가 없어 앱에서 방금 등록한 배송만 표시된다는 빈 상태 안내를 추가했다.
  - 문서: 점주 배송 목록 조회 API 또는 `GET /owner/orders`의 `shipment_id` 포함이 필요하다고 기록했다.
- 주소 검색의 데스크톱 샘플 fallback 제거를 검증했다.
  - `SignupPage`, `FarmDetailPage`는 Android/iOS가 아닌 환경에서 샘플 주소를 보여주지 않고 기능 제한 안내만 표시한다.
- 빠른 정적 검증을 완료했다.
  - `git diff --check` 결과: 공백 오류 없음.
  - `LF will be replaced by CRLF` 경고는 Windows 작업 트리 줄바꿈 안내이며 이번 코드 동작 검증 실패가 아니다.
- 실행 보류 항목
  - `dart format`, `flutter analyze`, `flutter test`는 이전 장시간 지연 이슈 때문에 이번 배치에서도 실행하지 않았다.
  - 필요 시 파일 단위 포맷 또는 제한된 테스트만 별도 지시 후 진행한다.
- 공통 확인창의 비동기 처리 안정성을 보강했다.
  - `showConfirmAction`의 `onConfirm` 타입을 `VoidCallback`에서 `FutureOr<void> Function()`으로 변경했다.
  - 발주 승인, 상품 숨김, 반품 승인처럼 확인 후 API를 호출하는 작업이 완료될 때까지 공통 확인창 함수가 기다릴 수 있게 했다.
- 남은 작업 상태를 재분류했다.
  - 앱 코드에서 바로 처리 가능한 잔여 더미/샘플 제거 대상은 추가로 발견되지 않았다.
  - 실제 운영 기능으로 남은 항목은 토큰 영구 저장, 농장 생성, 점주 배송 목록 조회, 이메일/비밀번호 변경, 이메일 찾기/비밀번호 재설정처럼 백엔드 API 또는 의존성 설치가 필요한 항목이다.
- 테스트 코드의 샘플 로그인 값도 정리했다.
  - 운영 화면에서는 이미 제거된 `owner@test.com`, `demo1234!` 문자열이 위젯 테스트 입력값에만 남아 있어 테스트 전용 일반 값으로 변경했다.

## 작업 중 확인된 이슈

- `dart format`이 수정 파일 6개 기준으로도 30분 이상 종료되지 않는 지연이 발생했다.
  - 정상 기대 시간: 수 초.
  - 실제 상황: 장시간 진행 중 상태가 유지되어 사용자가 중단했다.
  - 추정 원인: 로컬 Dart/Flutter 툴 프로세스 초기화 지연, 파일 락 대기, Windows 백신/인덱싱, 또는 툴 프로세스 정체 가능성.
  - 확인 내용: 중단 후 확인 시점에 남아 있는 `dart` 프로세스는 보이지 않았다.
  - 우회: 포맷 명령에 의존하지 않고 파일을 직접 정리했다. 이후 원인 확인 전까지는 `dart format`을 장시간 대기하지 않고 짧은 타임아웃으로만 시도하거나 생략한다.
- `flutter test --no-pub test\widget_test.dart`도 짧은 확인 목적으로 실행했으나 장시간 종료되지 않았다.
  - 정상 기대 시간: 변경 범위가 작고 단일 widget test라면 짧게 완료되어야 한다.
  - 실제 상황: 약 5분 이상 진행 중 상태가 유지되어 사용자가 중단했다.
  - 추정 원인: `dart format`과 같은 로컬 Flutter/Dart 툴체인 지연 문제로 보인다.
  - 우회: Flutter/Dart 툴 명령으로 검증을 오래 기다리지 않는다. 당분간 `rg`, `git diff --check`, 파일 단위 리뷰, MockClient 기반 코드 점검처럼 빠르게 끝나는 확인만 우선 사용한다.
