# caroom - 차량 관리 및 주차장 예약 시스템

> 🚗 차량 관리 및 주차장 예약을 쉽게 할 수 있는 스마트 시스템

## 📋 프로젝트 소개

**caroom**은 회사 또는 조직의 차량 및 주차장을 효율적으로 관리하고 예약할 수 있는 웹 기반 시스템입니다.

### 주요 기능

- ✅ **차량 목록 조회** - 20대 차량의 상태 실시간 확인
- ✅ **주차 공간 배치도** - 1층/2층 배치도 시각화
- ✅ **차량 예약** - 빈 공간 선택 → 차량 선택 → 예약 완료
- ✅ **반납 기능** - 예약한 차량 반납 및 상태 업데이트
- ✅ **실시간 동기화** - Supabase로 여러 사용자 실시간 동기화
- ✅ **PWA 지원** - 스마트폰에 앱처럼 설치 가능
- ✅ **오프라인 지원** - Service Worker로 오프라인 모드 지원

## 🚀 시작하기

### 준비물
- Supabase 계정
- 최신 브라우저 (Chrome, Firefox, Safari 등)

### 설정

1. **Supabase 데이터베이스 설정**
   - [Supabase](https://supabase.com)에서 프로젝트 생성
   - SQL Editor에서 `database-setup.sql` 실행

2. **Supabase 자격증명 입력**
   - `car-system.html` 파일 열기
   - `SUPABASE_URL`과 `SUPABASE_KEY` 값 수정

3. **로컬 실행**
   ```bash
   # Python 웹 서버 (권장)
   python3 -m http.server 8000
   
   # 또는 다른 웹 서버 사용
   # npm install -g http-server
   # http-server
   ```

4. **브라우저에서 접속**
   - http://localhost:8000/car-system.html

## 📱 PWA 설치

### 데스크탑
1. 브라우저 주소창의 설치 아이콘 클릭
2. "설치" 버튼 클릭

### 스마트폰 (iOS)
1. Safari 앱 열기
2. 공유 버튼 클릭
3. "홈 화면에 추가" 클릭

### 스마트폰 (Android)
1. Chrome 또는 Brave 열기
2. 메뉴 > "설치" 또는 "앱 설치" 클릭

## 🏗️ 프로젝트 구조

```
caroom/
├── car-system.html       # 메인 웹앱 (모든 기능 포함)
├── manifest.json         # PWA 설정 파일
├── sw.js                 # Service Worker (오프라인 지원)
├── DB.md                 # 데이터베이스 설계서
├── database-setup.sql    # Supabase SQL DDL
├── CAR_PRD.md           # 제품 요구사항 명세서 (PRD)
├── vercel.json          # Vercel 배포 설정
├── README.md            # 이 파일
└── carlist.xlsx         # 차량 정보 데이터 (참고)
```

## 🗄️ 데이터베이스 구조

### 주요 테이블

| 테이블 | 설명 |
|--------|------|
| `users` | 사용자 정보 |
| `vehicles` | 차량 정보 (20대) |
| `parking_spaces` | 주차 공간 (40개) |
| `parking_reservations` | 예약 정보 |
| `parking_logs` | 주차 이력 |

## 🎨 기술 스택

- **프론트엔드**: HTML5, CSS3, Vanilla JavaScript
- **백엔드**: Supabase (PostgreSQL)
- **인증**: Supabase Auth
- **PWA**: Manifest, Service Worker
- **배포**: Vercel

## 👥 기능별 사용자

### 일반 사용자
- 차량 목록 조회
- 주차 공간 예약
- 나의 예약 관리
- 차량 반납

### 관리자
- 차량 위치 관리
- 입출차 로그 기록
- 예약 통계 분석

## 🔐 보안

- Supabase Auth로 사용자 인증
- RLS (Row Level Security) 정책으로 데이터 보호
- HTTPS 통신 (Vercel 호스팅)

## 📞 지원

문제가 발생하거나 기능을 요청하려면:

1. GitHub Issues에서 보고
2. 팀 슬랙 채널에서 공유

## 📄 라이선스

이 프로젝트는 사내 용도로 개발되었습니다.

## 🔄 배포

### 로컬에서 Vercel로 배포

```bash
# 1. Vercel CLI 설치
npm install -g vercel

# 2. Vercel 로그인
vercel login

# 3. 배포
vercel

# 4. Vercel 대시보드에서 자동 배포 설정
# GitHub 계정 연결하고 main branch push 시 자동 배포
```

### GitHub Actions (자동 배포)

Vercel과 GitHub를 연결하면:
- `main` 브랜치에 push할 때마다 자동 배포
- Preview URL로 PR 검토 가능
- Production URL로 최신 버전 배포

---

**Last Updated**: 2026년 7월 14일  
**Version**: v1.0.0
