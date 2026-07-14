-- Supabase SQL 스크립트: caroom 데이터베이스 테이블 생성

-- 1. 사용자 관리 테이블 (users)
CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    department TEXT,
    phone TEXT,
    is_admin BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. 차량 정보 테이블 (vehicles)
CREATE TABLE IF NOT EXISTS vehicles (
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

CREATE INDEX IF NOT EXISTS idx_vehicles_license_plate ON vehicles(license_plate);
CREATE INDEX IF NOT EXISTS idx_vehicles_owner_id ON vehicles(owner_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_status ON vehicles(status);

-- 3. 주차 공간 테이블 (parking_spaces)
CREATE TABLE IF NOT EXISTS parking_spaces (
    space_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    floor INTEGER NOT NULL,
    space_number INTEGER NOT NULL,
    location_code TEXT NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(floor, space_number)
);

CREATE INDEX IF NOT EXISTS idx_parking_spaces_location_code ON parking_spaces(location_code);

-- 4. 주차 예약 테이블 (parking_reservations)
CREATE TABLE IF NOT EXISTS parking_reservations (
    reservation_id BIGSERIAL PRIMARY KEY,
    space_id UUID NOT NULL REFERENCES parking_spaces(space_id) ON DELETE CASCADE,
    vehicle_id UUID NOT NULL REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    special_requests TEXT,
    status VARCHAR(20) DEFAULT 'scheduled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_parking_reservations_space_id ON parking_reservations(space_id);
CREATE INDEX IF NOT EXISTS idx_parking_reservations_vehicle_id ON parking_reservations(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_parking_reservations_user_id ON parking_reservations(user_id);
CREATE INDEX IF NOT EXISTS idx_parking_reservations_status ON parking_reservations(status);
CREATE INDEX IF NOT EXISTS idx_parking_reservations_time_range 
    ON parking_reservations(space_id, start_time, end_time);

-- 5. Row Level Security (RLS) 활성화
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE parking_spaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE parking_reservations ENABLE ROW LEVEL SECURITY;

-- 6. RLS 정책 설정

-- users 테이블 정책
CREATE POLICY "Users can view their own profile" ON users
    FOR SELECT USING (auth.uid()::text = user_id::text OR is_admin = true);

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth.uid()::text = user_id::text);

-- vehicles 테이블 정책
CREATE POLICY "Everyone can view vehicles" ON vehicles
    FOR SELECT USING (true);

CREATE POLICY "Admins can manage vehicles" ON vehicles
    FOR ALL USING (
        (SELECT is_admin FROM users WHERE email = auth.jwt()->>'email') = true
    );

-- parking_spaces 테이블 정책
CREATE POLICY "Everyone can view parking spaces" ON parking_spaces
    FOR SELECT USING (true);

-- parking_reservations 테이블 정책
CREATE POLICY "Users can view their own reservations" ON parking_reservations
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can view all active reservations" ON parking_reservations
    FOR SELECT USING (status IN ('scheduled', 'active', 'completed'));

CREATE POLICY "Users can create reservations" ON parking_reservations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own reservations" ON parking_reservations
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can cancel their own reservations" ON parking_reservations
    FOR DELETE USING (auth.uid() = user_id AND status = 'scheduled');

-- 7. Realtime 게시 활성화 (이 부분은 Supabase 콘솔에서 직접 설정해야 할 수도 있음)
ALTER PUBLICATION supabase_realtime ADD TABLE parking_reservations;
ALTER PUBLICATION supabase_realtime ADD TABLE vehicles;
