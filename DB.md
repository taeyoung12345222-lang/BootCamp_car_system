# 차량 관리 및 주차장 예약 시스템 (caroom) - 데이터베이스 설계서

## 1. 데이터베이스 개요

### 프로젝트명
**caroom** - 차량 관리 및 주차장 예약 시스템

### 데이터베이스
- **DBMS**: PostgreSQL (Supabase)
- **TimeZone**: Asia/Seoul (KST)

---

## 2. 테이블 설계

### 2.1 사용자 관리 (users)

| 컬럼명 | 데이터타입 | 제약조건 | 설명 |
|--------|-----------|---------|------|
| user_id | UUID | PK, DEFAULT gen_random_uuid() | 사용자 고유 ID |
| email | TEXT | UNIQUE, NOT NULL | 이메일 (유니크) |
| name | TEXT | NOT NULL | 사용자 이름 |
| department | TEXT | | 부서명 |
| phone | TEXT | | 전화번호 |
| is_admin | BOOLEAN | DEFAULT false | 관리자 여부 |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | 생성 시간 |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | 수정 시간 |

**Primary Key**: user_id
**Indexes**: email (UNIQUE)

---

### 2.2 차량 정보 (vehicles)

| 컬럼명 | 데이터타입 | 제약조건 | 설명 |
|--------|-----------|---------|------|
| vehicle_id | UUID | PK, DEFAULT gen_random_uuid() | 차량 고유 ID |
| license_plate | TEXT | NOT NULL, UNIQUE | 차량번호 (예: "12가 3456") |
| model_name | TEXT | NOT NULL | 차량명/모델명 (예: "테슬라", "현대 K5") |
| year | INTEGER | NOT NULL | 연식 (예: 2022) |
| vehicle_type | TEXT | NOT NULL | 종류 (예: "세단", "중형", "소형") |
| grade | INTEGER | | 등급 |
| color | TEXT | | 색상 (예: "검정", "흰색") |
| fuel_type | TEXT | | 연료 타입 (가솔린, 디젤, 전기, 하이브리드) |
| mileage_efficiency | TEXT | | 연비 등급 (탁월, 우수, 보통) |
| status | VARCHAR(20) | DEFAULT 'active' | 상태 (active, maintenance, inactive) |
| owner_id | UUID | FK | 소유자 ID (users.user_id 참조) |
| current_location | TEXT | | 현재 주차 위치 |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | 생성 시간 |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | 수정 시간 |

**Primary Key**: vehicle_id
**Foreign Keys**: owner_id → users.user_id
**Indexes**: license_plate (UNIQUE), owner_id, status

---

### 2.3 주차 공간 (parking_spaces)

| 컬럼명 | 데이터타입 | 제약조건 | 설명 |
|--------|-----------|---------|------|
| space_id | UUID | PK, DEFAULT gen_random_uuid() | 주차 공간 고유 ID |
| floor | INTEGER | NOT NULL | 층 (1, 2) |
| space_number | INTEGER | NOT NULL | 공간 번호 (1-20) |
| location_code | TEXT | NOT NULL, UNIQUE | 위치 코드 (예: "1-1", "2-10") |
| is_active | BOOLEAN | DEFAULT true | 사용 가능 여부 |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | 생성 시간 |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | 수정 시간 |

**Primary Key**: space_id
**Indexes**: floor (복합 UNIQUE: floor + space_number), location_code (UNIQUE)

---

### 2.4 주차 예약 (parking_reservations)

| 컬럼명 | 데이터타입 | 제약조건 | 설명 |
|--------|-----------|---------|------|
| reservation_id | BIGSERIAL | PK | 예약 고유 ID |
| space_id | UUID | NOT NULL, FK | 주차 공간 ID (parking_spaces.space_id 참조) |
| vehicle_id | UUID | NOT NULL, FK | 차량 ID (vehicles.vehicle_id 참조) |
| user_id | UUID | NOT NULL, FK | 사용자 ID (users.user_id 참조) |
| start_time | TIMESTAMP | NOT NULL | 예약 시작 시간 |
| end_time | TIMESTAMP | NOT NULL | 예약 종료 시간 |
| special_requests | TEXT | | 특별 요청사항 |
| status | VARCHAR(20) | DEFAULT 'scheduled' | 예약 상태 (scheduled, active, completed, cancelled) |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | 생성 시간 |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | 수정 시간 |

**Primary Key**: reservation_id
**Foreign Keys**: 
- space_id → parking_spaces.space_id
- vehicle_id → vehicles.vehicle_id
- user_id → users.user_id
**Indexes**: 
- space_id, start_time, end_time (복합 인덱스)
- vehicle_id
- user_id
- status

**제약조건**:
- `start_time < end_time` (시작 시간이 종료 시간보다 이전)

---

### 2.5 주차 이력 (parking_logs)

| 컬럼명 | 데이터타입 | 제약조건 | 설명 |
|--------|-----------|---------|------|
| log_id | BIGSERIAL | PK | 이력 고유 ID |
| vehicle_id | UUID | NOT NULL, FK | 차량 ID (vehicles.vehicle_id 참조) |
| space_id | UUID | FK | 주차 공간 ID (parking_spaces.space_id 참조) |
| check_in_time | TIMESTAMP | NOT NULL | 입차 시간 |
| check_out_time | TIMESTAMP | | 출차 시간 |
| duration_minutes | INTEGER | | 주차 시간(분) |
| operator_id | UUID | FK | 담당자 ID (users.user_id 참조) |
| notes | TEXT | | 특이사항 |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | 생성 시간 |

**Primary Key**: log_id
**Foreign Keys**: 
- vehicle_id → vehicles.vehicle_id
- space_id → parking_spaces.space_id
- operator_id → users.user_id
**Indexes**: vehicle_id + check_in_time (복합), space_id

---

## 3. 관계도

```
users (1) ───────────────┬─ (N) vehicles
                         │
                         ├─ (N) parking_reservations
                         │
                         └─ (N) parking_logs
                              ↓ (N)

parking_spaces (1) ─────────── (N) parking_reservations
                                ↓ (N)
                         
vehicles (1) ──────────── (N) parking_reservations
                          │
                          └─ (N) parking_logs
```

---

## 4. Supabase SQL DDL (테이블 생성)

### 4.1 사용자 테이블 생성

```sql
CREATE TABLE users (
  user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  department TEXT,
  phone TEXT,
  is_admin BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
```

### 4.2 차량 테이블 생성

```sql
CREATE TABLE vehicles (
  vehicle_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  license_plate TEXT NOT NULL UNIQUE,
  model_name TEXT NOT NULL,
  year INTEGER NOT NULL,
  vehicle_type TEXT NOT NULL,
  grade INTEGER,
  color TEXT,
  fuel_type TEXT,
  mileage_efficiency TEXT,
  status VARCHAR(20) DEFAULT 'active',
  owner_id UUID REFERENCES users(user_id) ON DELETE SET NULL,
  current_location TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_vehicles_license_plate ON vehicles(license_plate);
CREATE INDEX idx_vehicles_owner ON vehicles(owner_id);
CREATE INDEX idx_vehicles_status ON vehicles(status);
```

### 4.3 주차 공간 테이블 생성

```sql
CREATE TABLE parking_spaces (
  space_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  floor INTEGER NOT NULL,
  space_number INTEGER NOT NULL,
  location_code TEXT NOT NULL UNIQUE,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(floor, space_number)
);

CREATE INDEX idx_parking_spaces_floor ON parking_spaces(floor);
CREATE INDEX idx_parking_spaces_location ON parking_spaces(location_code);
```

### 4.4 주차 예약 테이블 생성

```sql
CREATE TABLE parking_reservations (
  reservation_id BIGSERIAL PRIMARY KEY,
  space_id UUID NOT NULL REFERENCES parking_spaces(space_id) ON DELETE CASCADE,
  vehicle_id UUID NOT NULL REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP NOT NULL,
  special_requests TEXT,
  status VARCHAR(20) DEFAULT 'scheduled',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT check_time_validity CHECK (start_time < end_time)
);

CREATE INDEX idx_parking_reservations_space_time ON parking_reservations(space_id, start_time, end_time);
CREATE INDEX idx_parking_reservations_vehicle ON parking_reservations(vehicle_id);
CREATE INDEX idx_parking_reservations_user ON parking_reservations(user_id);
CREATE INDEX idx_parking_reservations_status ON parking_reservations(status);
```

### 4.5 주차 이력 테이블 생성

```sql
CREATE TABLE parking_logs (
  log_id BIGSERIAL PRIMARY KEY,
  vehicle_id UUID NOT NULL REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
  space_id UUID REFERENCES parking_spaces(space_id) ON DELETE SET NULL,
  check_in_time TIMESTAMP NOT NULL,
  check_out_time TIMESTAMP,
  duration_minutes INTEGER,
  operator_id UUID REFERENCES users(user_id) ON DELETE SET NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_parking_logs_vehicle_time ON parking_logs(vehicle_id, check_in_time);
CREATE INDEX idx_parking_logs_space ON parking_logs(space_id);
CREATE INDEX idx_parking_logs_check_in_time ON parking_logs(check_in_time);
```

### 4.6 초기 주차 공간 데이터 삽입

```sql
-- 1층 주차 공간 (1-1 ~ 1-20)
INSERT INTO parking_spaces (floor, space_number, location_code) VALUES
(1, 1, '1-1'), (1, 2, '1-2'), (1, 3, '1-3'), (1, 4, '1-4'), (1, 5, '1-5'),
(1, 6, '1-6'), (1, 7, '1-7'), (1, 8, '1-8'), (1, 9, '1-9'), (1, 10, '1-10'),
(1, 11, '1-11'), (1, 12, '1-12'), (1, 13, '1-13'), (1, 14, '1-14'), (1, 15, '1-15'),
(1, 16, '1-16'), (1, 17, '1-17'), (1, 18, '1-18'), (1, 19, '1-19'), (1, 20, '1-20');

-- 2층 주차 공간 (2-1 ~ 2-20)
INSERT INTO parking_spaces (floor, space_number, location_code) VALUES
(2, 1, '2-1'), (2, 2, '2-2'), (2, 3, '2-3'), (2, 4, '2-4'), (2, 5, '2-5'),
(2, 6, '2-6'), (2, 7, '2-7'), (2, 8, '2-8'), (2, 9, '2-9'), (2, 10, '2-10'),
(2, 11, '2-11'), (2, 12, '2-12'), (2, 13, '2-13'), (2, 14, '2-14'), (2, 15, '2-15'),
(2, 16, '2-16'), (2, 17, '2-17'), (2, 18, '2-18'), (2, 19, '2-19'), (2, 20, '2-20');
```

### 4.7 초기 차량 데이터 삽입 (carlist.xlsx 기반)

```sql
INSERT INTO vehicles (license_plate, model_name, year, vehicle_type, grade, color, fuel_type, mileage_efficiency, current_location) VALUES
('12가 3456', '테슬라', 2022, '세단', 5, '가솔린', '가솔린', '보통', '건물 위치1층 1번'),
('34나 5678', '쌍용', 2021, '중형', 5, '가솔린', '가솔린', '우수', '건물 위치1층 3번'),
('56다 7890', '현대', 2023, '중형', 5, '하이브리드', '하이브리드', '탁월', '건물 위치1층 4번'),
('78라 1234', '기아', 2022, '소형', 9, '디젤', '디젤', '탁월', '건물 위치1층 5번'),
('90마 2345', '포르쉐', 2020, '소형', 12, '디젤', '디젤', '뛰어남', '건물 위치1층 6번'),
('11바 3456', '큐라2', 2021, '세단', 3, '디젤', '디젤', '우수', '건물 위치1층 7번'),
('22사 4567', 'K5', 2022, '중형', 5, '가솔린', '가솔린', '보통', '건물 위치1층 8번'),
('33아 5678', '쌍용', 2023, '중형', 5, '전기', '전기', '우수', '건물 위치1층 9번'),
('44자 6789', '테슬라', 2021, '중형', 5, '가솔린', '가솔린', '탁월', '건물 위치1층 10번'),
('55차 7890', '쌍용', 2022, '세단', 7, '디젤', '디젤', '탁월', '건물 위치2층 1번'),
('66카 8901', '페이', 2020, '준중형', 4, '가솔린', '가솔린', '뛰어남', '건물 위치2층 2번'),
('77타 9012', '저무', 2019, '준대형', 4, '가솔린', '가솔린', '우수', '건물 위치2층 3번'),
('88파 0123', '포르쉐', 2023, '소형', 5, '하이브리드', '하이브리드', '보통', '건물 위치2층 4번'),
('99하 1234', 'K8', 2023, '중형', 5, '가솔린', '가솔린', '우수', '건물 위치2층 5번'),
('13가 2345', '뉴', 2022, '세단', 7, '디젤', '디젤', '탁월', '건물 위치2층 6번'),
('24나 3456', '마렉', 2021, '중형', 5, '하이브리드', '하이브리드', '탁월', '건물 위치2층 7번'),
('35다 4567', 'EV6', 2023, '세단', 5, '전기', '전기', '뛰어남', '건물 위치2층 8번'),
('46라 5678', '현대', 2019, '소형', 11, '디젤', '디젤', '우수', '건물 위치2층 9번'),
('57마 6789', '썪터3', 2020, '세단', 3, '디젤', '디젤', '보통', '건물 위치2층 10번'),
('68바 7890', '제네시스 G80', 2023, '중형', 5, '가솔린', '가솔린', '우수', '건물 위치1층 1번');
```

---

## 5. 행 단위 보안 (RLS) 정책 설정

### 5.1 RLS 비활성화 (개발 초기 단계)

```sql
-- 개발 초기 단계: RLS 비활성화 (빠른 개발 속도)
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles DISABLE ROW LEVEL SECURITY;
ALTER TABLE parking_spaces DISABLE ROW LEVEL SECURITY;
ALTER TABLE parking_reservations DISABLE ROW LEVEL SECURITY;
ALTER TABLE parking_logs DISABLE ROW LEVEL SECURITY;
```

### 5.2 RLS 정책 (프로덕션 배포 시)

```sql
-- 테이블별 RLS 활성화
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE parking_spaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE parking_reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE parking_logs ENABLE ROW LEVEL SECURITY;

-- Users 테이블: 모든 사용자가 조회 가능, 본인 정보만 수정 가능
CREATE POLICY "Users can read all users" ON users FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = user_id);

-- Vehicles 테이블: 모든 사용자가 조회 가능, 관리자만 수정 가능
CREATE POLICY "Anyone can read vehicles" ON vehicles FOR SELECT USING (true);
CREATE POLICY "Only admins can modify vehicles" ON vehicles 
  FOR UPDATE USING (EXISTS(
    SELECT 1 FROM users WHERE user_id = auth.uid() AND is_admin = true
  ));

-- Parking Spaces 테이블: 모든 사용자가 조회 가능 (읽기 전용)
CREATE POLICY "Anyone can read parking spaces" ON parking_spaces FOR SELECT USING (true);
CREATE POLICY "Only admins can modify spaces" ON parking_spaces 
  FOR UPDATE USING (EXISTS(
    SELECT 1 FROM users WHERE user_id = auth.uid() AND is_admin = true
  ));

-- Parking Reservations 테이블: 모든 사용자가 예약 조회, 본인 예약 수정/삭제
CREATE POLICY "Anyone can read reservations" ON parking_reservations FOR SELECT USING (true);
CREATE POLICY "Users can create reservations" ON parking_reservations 
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own reservations" ON parking_reservations 
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own reservations" ON parking_reservations 
  FOR DELETE USING (auth.uid() = user_id);

-- Parking Logs 테이블: 관리자만 조회/수정 가능
CREATE POLICY "Admins can read logs" ON parking_logs 
  FOR SELECT USING (EXISTS(
    SELECT 1 FROM users WHERE user_id = auth.uid() AND is_admin = true
  ));
CREATE POLICY "Admins can modify logs" ON parking_logs 
  FOR ALL USING (EXISTS(
    SELECT 1 FROM users WHERE user_id = auth.uid() AND is_admin = true
  ));
```

---

## 6. 예약 충돌 방지 함수 (선택사항)

```sql
-- 주차 공간의 예약 시간대 충돌 확인 트리거 함수
CREATE OR REPLACE FUNCTION check_parking_conflict()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM parking_reservations
    WHERE space_id = NEW.space_id
      AND status IN ('scheduled', 'active')
      AND reservation_id != COALESCE(NEW.reservation_id, 0)
      AND (
        (NEW.start_time < end_time AND NEW.end_time > start_time)
      )
  ) THEN
    RAISE EXCEPTION '이 시간대에 이미 예약된 주차 공간입니다.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 트리거 생성
CREATE TRIGGER trg_check_parking_conflict
BEFORE INSERT OR UPDATE ON parking_reservations
FOR EACH ROW
EXECUTE FUNCTION check_parking_conflict();
```

---

## 7. 뷰 (View) - 유용한 쿼리

### 7.1 주차 공간별 예약 현황

```sql
CREATE VIEW v_parking_reservation_status AS
SELECT 
  ps.space_id,
  ps.floor,
  ps.space_number,
  ps.location_code,
  v.license_plate,
  v.model_name,
  u.name as reserved_by,
  pr.start_time,
  pr.end_time,
  pr.status,
  pr.reservation_id
FROM parking_spaces ps
LEFT JOIN parking_reservations pr ON ps.space_id = pr.space_id 
  AND pr.status IN ('scheduled', 'active')
  AND CURRENT_TIMESTAMP BETWEEN pr.start_time AND pr.end_time
LEFT JOIN vehicles v ON pr.vehicle_id = v.vehicle_id
LEFT JOIN users u ON pr.user_id = u.user_id
ORDER BY ps.floor, ps.space_number;
```

### 7.2 사용자별 예약 현황

```sql
CREATE VIEW v_user_parking_reservations AS
SELECT 
  u.user_id,
  u.name,
  u.email,
  COUNT(pr.reservation_id) as total_reservations,
  COUNT(CASE WHEN pr.status = 'scheduled' THEN 1 END) as scheduled_count,
  COUNT(CASE WHEN pr.status = 'active' THEN 1 END) as active_count,
  COUNT(CASE WHEN pr.status = 'completed' THEN 1 END) as completed_count
FROM users u
LEFT JOIN parking_reservations pr ON u.user_id = pr.user_id
GROUP BY u.user_id, u.name, u.email;
```

### 7.3 차량별 주차 통계

```sql
CREATE VIEW v_vehicle_parking_stats AS
SELECT 
  v.vehicle_id,
  v.license_plate,
  v.model_name,
  u.name as owner_name,
  COUNT(pl.log_id) as total_parking_count,
  AVG(pl.duration_minutes) as avg_parking_duration,
  MAX(pl.check_in_time) as last_parking_time
FROM vehicles v
LEFT JOIN users u ON v.owner_id = u.user_id
LEFT JOIN parking_logs pl ON v.vehicle_id = pl.vehicle_id
GROUP BY v.vehicle_id, v.license_plate, v.model_name, u.name;
```

---

## 8. 데이터 타입 및 제약조건 설명

### 8.1 데이터 타입
- **UUID**: 유니버설 고유 식별자 (사용자 ID)
- **TEXT**: 가변 길이 문자열
- **INTEGER**: 정수
- **BIGSERIAL**: 자동 증가 큰 정수 (64비트)
- **BOOLEAN**: 참/거짓
- **TIMESTAMP**: 날짜와 시간
- **VARCHAR(20)**: 최대 20자 문자열
- **TEXT[]**: 텍스트 배열

### 8.2 제약조건
- **PRIMARY KEY (PK)**: 유일한 행 식별자
- **FOREIGN KEY (FK)**: 다른 테이블 참조
- **UNIQUE**: 유니크한 값만 허용
- **NOT NULL**: 필수 입력
- **DEFAULT**: 기본값
- **CHECK**: 조건부 유효성 검증
- **ON DELETE CASCADE**: 부모 행 삭제 시 자식 행도 삭제

---

## 9. 운영 및 유지보수

### 9.1 백업 전략
- Supabase 자동 백업 (일일)
- 중요 데이터는 외부 저장소에 정기 백업

### 9.2 모니터링
- 예약 테이블 행 수 모니터링
- 쿼리 성능 모니터링
- 디스크 공간 모니터링

### 9.3 확장성 고려
- 주차 공간 수 증가 시 데이터 구조 변경 없음
- 차량 수 증가 시 인덱스 최적화 필요
- 멀티 건물/지점 지원하려면 location_code 확장 필요

---

**초안 작성일**: 2026년 7월 14일
**버전**: v2.0 (차량 관리 시스템 버전)
