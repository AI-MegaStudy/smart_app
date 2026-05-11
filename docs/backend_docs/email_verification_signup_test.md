# 이메일 인증 회원가입 테스트 정리

이 문서는 `.env` 설정을 제외하고, 이메일 인증 기반 회원가입 API 테스트 전에 확인해야 할 DB 수정 사항과 테스트 요청/예상 응답을 정리한다.

## 1. 계정 타입

회원가입 API는 계정 타입별로 2개가 있다.

| 계정 타입 | role | API |
|---|---|---|
| 고객 | `CUSTOMER` | `POST /api/v1/auth/customers/signup` |
| 농가/판매자 | `OWNER` | `POST /api/v1/auth/owners/signup` |

두 회원가입 API 모두 이메일 인증 여부를 같은 방식으로 확인한다.

```text
이메일 인증 메일 발송
→ 이메일 인증 코드 확인
→ 고객 또는 농가 회원가입
```

## 2. DB 수정 사항

문제가 발생했던 테이블은 아래 테이블이다.

```text
email_verifications
```

누락되거나 코드 모델과 맞지 않았던 컬럼은 아래 4개다.

| 컬럼 | 문제 | 필요한 상태 |
|---|---|---|
| `attempt_count` | 컬럼이 없어서 조회 실패 | `INT NOT NULL DEFAULT 0` |
| `updated_at` | 컬럼이 없어서 조회 실패 | `DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP` |
| `account_id` | `NOT NULL`이라 회원가입 전 이메일 인증 저장 실패 | `INT NULL` |
| `verification_code` | `VARCHAR(20)`이라 SHA-256 해시 저장에 너무 짧음 | `VARCHAR(255) NOT NULL` |

최종 보정 SQL은 아래와 같다.

```sql
ALTER TABLE email_verifications
ADD COLUMN attempt_count INT NOT NULL DEFAULT 0 AFTER verified_at;

ALTER TABLE email_verifications
ADD COLUMN updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
ON UPDATE CURRENT_TIMESTAMP AFTER created_at;

ALTER TABLE email_verifications
MODIFY COLUMN account_id INT NULL;

ALTER TABLE email_verifications
MODIFY COLUMN verification_code VARCHAR(255) NOT NULL;
```

이미 컬럼이 추가된 상태라면 `ADD COLUMN` 구문은 다시 실행하지 않는다. 현재 상태 확인은 아래 명령으로 한다.

```sql
SHOW COLUMNS FROM email_verifications;
```

기대 상태:

```text
account_id          Null = YES
verification_code   Type = varchar(255)
attempt_count       Type = int, Default = 0
updated_at          Type = datetime
```

## 3. 테스트 전 서버 실행

프로젝트 루트에서 백엔드를 실행한다.

```bash
cd /Users/cheng80/Desktop/smart_web
uvicorn backend.app.main:app --reload
```

API 문서는 아래 주소에서 확인할 수 있다.

```text
http://127.0.0.1:8000/docs
```

## 4. 이메일 인증 보내기

요청:

```bash
curl -X POST http://127.0.0.1:8000/api/v1/auth/email/send \
  -H "Content-Type: application/json" \
  -d '{"email":"cheng80@naver.com","purpose":"SIGNUP"}'
```

예상 응답:

```json
{
  "data": {
    "email": "cheng80@naver.com",
    "purpose": "SIGNUP",
    "expires_in_minutes": 5,
    "resend_available_seconds": 60
  },
  "message": "verification email sent",
  "error": null
}
```

확인 사항:

```text
입력한 이메일 주소로 6자리 인증번호 메일이 도착해야 한다.
```

## 5. 이메일 인증 하기

요청:

```bash
curl -X POST http://127.0.0.1:8000/api/v1/auth/email/verify \
  -H "Content-Type: application/json" \
  -d '{"email":"cheng80@naver.com","code":"메일로받은6자리","purpose":"SIGNUP"}'
```

예상 응답:

```json
{
  "data": {
    "email": "cheng80@naver.com",
    "purpose": "SIGNUP",
    "verified": true
  },
  "message": "email verified",
  "error": null
}
```

주의 사항:

```text
code 값에는 실제 메일로 받은 6자리 숫자를 넣는다.
인증번호는 기본 5분 동안 유효하다.
```

## 6. 고객 회원가입

요청:

```bash
curl -X POST http://127.0.0.1:8000/api/v1/auth/customers/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"cheng80@naver.com","password":"pass1234!","name":"홍길동","phone":"010-1111-2222"}'
```

예상 응답:

```json
{
  "data": {
    "account_id": 6,
    "customer_id": 5,
    "email": "cheng80@naver.com",
    "email_verified": true,
    "email_verification_required": true
  },
  "message": "success",
  "error": null
}
```

참고:

```text
account_id와 customer_id는 DB 상태에 따라 달라진다.
email_verified가 true이면 이메일 인증 후 고객 회원가입 흐름이 정상 완료된 것이다.
```

## 7. 농가/판매자 회원가입

농가/판매자 가입도 이메일 인증 흐름은 동일하다. 단, 같은 이메일로 고객 가입을 이미 완료했다면 중복 이메일 오류가 발생하므로 다른 이메일로 테스트한다.

요청:

```bash
curl -X POST http://127.0.0.1:8000/api/v1/auth/owners/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"owner@example.com","password":"pass1234!","name":"농가대표","phone":"010-2222-3333"}'
```

예상 응답:

```json
{
  "data": {
    "account_id": 7,
    "owner_id": 1,
    "email": "owner@example.com",
    "email_verified": true,
    "email_verification_required": true
  },
  "message": "success",
  "error": null
}
```

참고:

```text
account_id와 owner_id는 DB 상태에 따라 달라진다.
email_verified가 true이면 이메일 인증 후 농가/판매자 회원가입 흐름이 정상 완료된 것이다.
```

## 8. 정상 완료 기준

아래 상태가 모두 확인되면 정상이다.

```text
이메일 인증 메일 발송 성공
인증 코드 검증 성공
고객 또는 농가 회원가입 성공
accounts.email_verified = true
응답의 email_verification_required = true
```
