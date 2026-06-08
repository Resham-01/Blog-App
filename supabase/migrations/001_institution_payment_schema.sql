-- Multi-institution payment account schema
-- Run this in Supabase SQL Editor

CREATE TABLE IF NOT EXISTS institutions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('school', 'college')),
  address TEXT,
  contact_email TEXT,
  contact_phone TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('super_admin', 'school_admin', 'college_admin', 'parent')),
  institution_id UUID REFERENCES institutions(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS payment_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  institution_id UUID NOT NULL REFERENCES institutions(id) ON DELETE CASCADE,
  submitted_by UUID NOT NULL REFERENCES profiles(id),
  account_holder_name TEXT NOT NULL,
  bank_name TEXT NOT NULL,
  account_number TEXT NOT NULL,
  ifsc_code TEXT,
  upi_id TEXT,
  branch_name TEXT,
  payment_instructions TEXT,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'approved', 'rejected', 'inactive')),
  is_active BOOLEAN NOT NULL DEFAULT FALSE,
  reviewed_by UUID REFERENCES profiles(id),
  review_note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS parent_children (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  institution_id UUID NOT NULL REFERENCES institutions(id) ON DELETE CASCADE,
  child_name TEXT NOT NULL,
  class_name TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_profiles_institution ON profiles(institution_id);
CREATE INDEX IF NOT EXISTS idx_payment_accounts_institution ON payment_accounts(institution_id);
CREATE INDEX IF NOT EXISTS idx_payment_accounts_active ON payment_accounts(institution_id, is_active);
CREATE INDEX IF NOT EXISTS idx_parent_children_parent ON parent_children(parent_id);

-- Only one active payment account per institution
CREATE OR REPLACE FUNCTION deactivate_other_payment_accounts()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_active = TRUE THEN
    UPDATE payment_accounts
    SET is_active = FALSE,
        status = CASE WHEN status = 'approved' THEN 'inactive' ELSE status END,
        updated_at = NOW()
    WHERE institution_id = NEW.institution_id
      AND id != NEW.id
      AND is_active = TRUE;
    NEW.status := 'approved';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS ensure_single_active_payment_account ON payment_accounts;
CREATE TRIGGER ensure_single_active_payment_account
BEFORE UPDATE ON payment_accounts
FOR EACH ROW
WHEN (NEW.is_active = TRUE)
EXECUTE FUNCTION deactivate_other_payment_accounts();

ALTER TABLE institutions ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE parent_children ENABLE ROW LEVEL SECURITY;

-- Profiles: users can read their own profile
CREATE POLICY "Users read own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Super admin reads all profiles" ON profiles
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'super_admin')
  );

-- Institutions: readable by all authenticated users (for parent signup dropdown)
CREATE POLICY "Authenticated users read institutions" ON institutions
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Admins insert institutions" ON institutions
  FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Super admin manages institutions" ON institutions
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'super_admin')
  );

-- Payment accounts
CREATE POLICY "Institution admin manages own payment accounts" ON payment_accounts
  FOR ALL USING (
    institution_id IN (
      SELECT institution_id FROM profiles
      WHERE id = auth.uid() AND role IN ('school_admin', 'college_admin')
    )
  );

CREATE POLICY "Super admin manages all payment accounts" ON payment_accounts
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'super_admin')
  );

CREATE POLICY "Parents read active payment account" ON payment_accounts
  FOR SELECT USING (
    is_active = TRUE AND institution_id IN (
      SELECT institution_id FROM parent_children WHERE parent_id = auth.uid()
    )
  );

-- Parent children
CREATE POLICY "Parents manage own children" ON parent_children
  FOR ALL USING (parent_id = auth.uid());

CREATE POLICY "Super admin reads parent children" ON parent_children
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'super_admin')
  );

-- Create your first super admin manually after signup:
-- UPDATE profiles SET role = 'super_admin' WHERE email = 'your-admin@email.com';
