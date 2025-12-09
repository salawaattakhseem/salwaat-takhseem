-- =============================================
-- SALWAAT TAKHSEEM - SAFE UPDATE SCRIPT
-- =============================================
-- Run this entire script in Supabase SQL Editor.
-- This script is SAFE: It will NOT delete your existing data.
-- It fixes the login issues and updates security policies.

-- Step 1: Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- Step 2: ENSURE TABLES EXIST (Safe)
-- =============================================

CREATE TABLE IF NOT EXISTS users (
  its TEXT PRIMARY KEY,
  full_name TEXT NOT NULL,
  mobile TEXT NOT NULL,
  mohallah TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'subadmin', 'user')),
  password_last4 TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS mohallahs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  booking_limit INTEGER NOT NULL DEFAULT 2 CHECK (booking_limit >= 1 AND booking_limit <= 10),
  subadmin_its TEXT REFERENCES users(its) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS bookings (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  its TEXT NOT NULL REFERENCES users(its) ON DELETE CASCADE,
  mohallah TEXT NOT NULL,
  date TEXT NOT NULL,
  item TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(its, date)
);

-- =============================================
-- Step 3: INDEXES
-- =============================================

CREATE INDEX IF NOT EXISTS idx_users_mohallah ON users(mohallah);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_bookings_date ON bookings(date);
CREATE INDEX IF NOT EXISTS idx_bookings_mohallah ON bookings(mohallah);
CREATE INDEX IF NOT EXISTS idx_bookings_its ON bookings(its);

-- =============================================
-- Step 4: SECURITY (RLS)
-- =============================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE mohallahs ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

-- =============================================
-- Step 5: POLICIES (Reset & Fix)
-- =============================================

-- Drop existing policies to ensure clean state (Does not delete data)
DROP POLICY IF EXISTS "Users can read own data" ON users;
DROP POLICY IF EXISTS "Allow read access to users" ON users;
DROP POLICY IF EXISTS "Admins full access to users" ON users;
DROP POLICY IF EXISTS "Admins can insert users" ON users;
DROP POLICY IF EXISTS "Admins can update users" ON users;
DROP POLICY IF EXISTS "Admins can delete users" ON users;
DROP POLICY IF EXISTS "SubAdmins can read mohallah users" ON users;
DROP POLICY IF EXISTS "SubAdmins can insert mohallah users" ON users;

DROP POLICY IF EXISTS "Everyone can read mohallahs" ON mohallahs;
DROP POLICY IF EXISTS "Admins full access to mohallahs" ON mohallahs;
DROP POLICY IF EXISTS "Admins can insert mohallahs" ON mohallahs;
DROP POLICY IF EXISTS "Admins can update mohallahs" ON mohallahs;
DROP POLICY IF EXISTS "Admins can delete mohallahs" ON mohallahs;

DROP POLICY IF EXISTS "Users can read own bookings" ON bookings;
DROP POLICY IF EXISTS "Users can create own bookings" ON bookings;
DROP POLICY IF EXISTS "Users can delete own bookings" ON bookings;
DROP POLICY IF EXISTS "Users can insert own bookings" ON bookings;
DROP POLICY IF EXISTS "Admins full access to bookings" ON bookings;
DROP POLICY IF EXISTS "SubAdmins can read mohallah bookings" ON bookings;
DROP POLICY IF EXISTS "SubAdmins can delete mohallah bookings" ON bookings;


-- ---------- USERS POLICIES (FIXED) ----------

-- CRITICAL FIX: Match by Email (ITS@swt.com) not UUID
CREATE POLICY "Users can read own data" ON users
  FOR SELECT USING (
    its = SPLIT_PART(auth.jwt()->>'email', '@', 1) OR
    EXISTS (SELECT 1 FROM users WHERE its = SPLIT_PART(auth.jwt()->>'email', '@', 1) AND role IN ('admin', 'subadmin'))
  );

CREATE POLICY "Admins full access to users" ON users
  FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE its = SPLIT_PART(auth.jwt()->>'email', '@', 1) AND role = 'admin')
  );

CREATE POLICY "SubAdmins can read mohallah users" ON users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users u
      JOIN mohallahs m ON m.subadmin_its = u.its
      WHERE u.its = SPLIT_PART(auth.jwt()->>'email', '@', 1)
      AND u.role = 'subadmin'
      AND users.mohallah = m.name
    )
  );

CREATE POLICY "SubAdmins can insert mohallah users" ON users
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM users u
      JOIN mohallahs m ON m.subadmin_its = u.its
      WHERE u.its = SPLIT_PART(auth.jwt()->>'email', '@', 1)
      AND u.role = 'subadmin'
      AND users.mohallah = m.name
    )
  );


-- ---------- MOHALLAHS POLICIES ----------

CREATE POLICY "Everyone can read mohallahs" ON mohallahs
  FOR SELECT USING (true);

CREATE POLICY "Admins full access to mohallahs" ON mohallahs
  FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE its = SPLIT_PART(auth.jwt()->>'email', '@', 1) AND role = 'admin')
  );


-- ---------- BOOKINGS POLICIES (FIXED) ----------

CREATE POLICY "Users can read own bookings" ON bookings
  FOR SELECT USING (
    its = SPLIT_PART(auth.jwt()->>'email', '@', 1)
  );

CREATE POLICY "Users can create own bookings" ON bookings
  FOR INSERT WITH CHECK (
    its = SPLIT_PART(auth.jwt()->>'email', '@', 1)
  );

CREATE POLICY "Users can delete own bookings" ON bookings
  FOR DELETE USING (
    its = SPLIT_PART(auth.jwt()->>'email', '@', 1)
  );

CREATE POLICY "Admins full access to bookings" ON bookings
  FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE its = SPLIT_PART(auth.jwt()->>'email', '@', 1) AND role = 'admin')
  );

CREATE POLICY "SubAdmins can read mohallah bookings" ON bookings
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users u
      JOIN mohallahs m ON m.subadmin_its = u.its
      WHERE u.its = SPLIT_PART(auth.jwt()->>'email', '@', 1)
      AND u.role = 'subadmin'
      AND bookings.mohallah = m.name
    )
  );

CREATE POLICY "SubAdmins can delete mohallah bookings" ON bookings
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM users u
      JOIN mohallahs m ON m.subadmin_its = u.its
      WHERE u.its = SPLIT_PART(auth.jwt()->>'email', '@', 1)
      AND u.role = 'subadmin'
      AND bookings.mohallah = m.name
    )
  );


-- =============================================
-- Step 6: FUNCTIONS
-- =============================================

CREATE OR REPLACE FUNCTION create_booking_atomic(
  p_its TEXT,
  p_mohallah TEXT,
  p_date TEXT,
  p_item TEXT,
  p_limit INTEGER
)
RETURNS JSON AS $$
DECLARE
  v_count INTEGER;
  v_booking_id UUID;
BEGIN
  -- Lock the bookings for this mohallah and date to prevent race conditions
  PERFORM pg_advisory_xact_lock(hashtext(p_mohallah || p_date));
  
  -- Check if user already booked this date
  SELECT COUNT(*) INTO v_count
  FROM bookings
  WHERE its = p_its AND date = p_date;
  
  IF v_count > 0 THEN
    RETURN json_build_object(
      'success', false,
      'message', 'You have already booked a slot for this date'
    );
  END IF;
  
  -- Count existing bookings for this date and mohallah
  SELECT COUNT(*) INTO v_count
  FROM bookings
  WHERE mohallah = p_mohallah AND date = p_date;
  
  -- Check if limit reached
  IF v_count >= p_limit THEN
    RETURN json_build_object(
      'success', false,
      'message', 'This slot is fully booked'
    );
  END IF;
  
  -- Create the booking
  INSERT INTO bookings (its, mohallah, date, item)
  VALUES (p_its, p_mohallah, p_date, p_item)
  RETURNING id INTO v_booking_id;
  
  RETURN json_build_object(
    'success', true,
    'message', 'Booking confirmed successfully',
    'booking_id', v_booking_id
  );
  
EXCEPTION
  WHEN unique_violation THEN
    RETURN json_build_object(
      'success', false,
      'message', 'You have already booked a slot for this date'
    );
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', false,
      'message', 'An error occurred while creating the booking'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


CREATE OR REPLACE FUNCTION get_booking_count(
  p_date TEXT,
  p_mohallah TEXT
)
RETURNS INTEGER AS $$
DECLARE
  v_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM bookings
  WHERE date = p_date AND mohallah = p_mohallah;
  
  RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Final Status Check
SELECT 'SAFE UPDATE COMPLETED. Login should work now.' as status; 