-- ==============================================================================
-- 20260101000002_users_and_rbac.sql
-- SIS SMART SCHOOL: USERS, PROFILES, RBAC & SECURITY HELPERS
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. USER PROFILES
-- ------------------------------------------------------------------------------
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    full_name VARCHAR(200) GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
    phone VARCHAR(50),
    avatar_url TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'inactive')),
    preferred_locale VARCHAR(10) NOT NULL DEFAULT 'en' CHECK (preferred_locale IN ('en', 'bn')),
    theme_mode VARCHAR(20) NOT NULL DEFAULT 'light' CHECK (theme_mode IN ('light', 'dark', 'system')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX idx_profiles_email ON profiles(email);
CREATE INDEX idx_profiles_status ON profiles(status);

-- ------------------------------------------------------------------------------
-- 2. PLATFORM SUPER ADMINS
-- ------------------------------------------------------------------------------
CREATE TABLE platform_admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- ------------------------------------------------------------------------------
-- 3. PERMISSIONS TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    module VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- ------------------------------------------------------------------------------
-- 4. USER SCHOOL MEMBERSHIPS (MULTI-TENANT RBAC)
-- ------------------------------------------------------------------------------
CREATE TABLE user_school_memberships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL CHECK (role IN (
        'super_admin',
        'school_admin',
        'teacher',
        'student',
        'parent',
        'accountant',
        'librarian',
        'staff'
    )),
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_primary BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_user_school_membership UNIQUE (user_id, school_id, role)
);

CREATE INDEX idx_user_school_memberships_lookup ON user_school_memberships(user_id, school_id, is_active);
CREATE INDEX idx_user_school_memberships_school ON user_school_memberships(school_id);

-- ------------------------------------------------------------------------------
-- 5. ROLE PERMISSIONS
-- ------------------------------------------------------------------------------
CREATE TABLE role_permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID REFERENCES schools(id) ON DELETE CASCADE, -- NULL = System default role permissions
    role VARCHAR(50) NOT NULL,
    permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_role_permission UNIQUE (school_id, role, permission_id)
);

-- ------------------------------------------------------------------------------
-- 6. SECURITY HELPER FUNCTIONS FOR RLS
-- ------------------------------------------------------------------------------

-- Get current authenticated user ID
CREATE OR REPLACE FUNCTION auth.current_user_id()
RETURNS UUID AS $$
    SELECT nullif(current_setting('request.jwt.claim.sub', true), '')::uuid;
$$ LANGUAGE sql STABLE;

-- Check if current user is Platform Super Admin
CREATE OR REPLACE FUNCTION auth.is_super_admin()
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 
        FROM platform_admins 
        WHERE user_id = auth.current_user_id() 
          AND is_active = true
    );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Get current user's active school ID from primary membership or session claim
CREATE OR REPLACE FUNCTION auth.current_user_school_id()
RETURNS UUID AS $$
    SELECT school_id 
    FROM user_school_memberships 
    WHERE user_id = auth.current_user_id() 
      AND is_active = true 
    ORDER BY is_primary DESC, created_at ASC 
    LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Get current user's role in the specified or current school
CREATE OR REPLACE FUNCTION auth.current_user_role(p_school_id UUID DEFAULT NULL)
RETURNS VARCHAR AS $$
    SELECT role 
    FROM user_school_memberships 
    WHERE user_id = auth.current_user_id() 
      AND is_active = true 
      AND (p_school_id IS NULL OR school_id = p_school_id)
    ORDER BY is_primary DESC 
    LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Granular permission check
CREATE OR REPLACE FUNCTION auth.has_permission(p_permission_code VARCHAR, p_school_id UUID DEFAULT NULL)
RETURNS BOOLEAN AS $$
DECLARE
    v_role VARCHAR;
    v_school UUID;
BEGIN
    IF auth.is_super_admin() THEN
        RETURN true;
    END IF;

    v_school := COALESCE(p_school_id, auth.current_user_school_id());
    v_role := auth.current_user_role(v_school);

    IF v_role = 'school_admin' THEN
        RETURN true; -- School Admins possess complete administrative authority within their tenant
    END IF;

    RETURN EXISTS (
        SELECT 1 
        FROM role_permissions rp
        JOIN permissions p ON p.id = rp.permission_id
        WHERE p.code = p_permission_code
          AND rp.role = v_role
          AND (rp.school_id = v_school OR rp.school_id IS NULL)
    );
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- ------------------------------------------------------------------------------
-- 7. AUTOMATED PROFILE CREATION TRIGGER ON AUTH.USERS
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (
        id, 
        email, 
        first_name, 
        last_name, 
        phone, 
        preferred_locale
    ) VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'first_name', 'User'),
        COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
        NEW.raw_user_meta_data->>'phone',
        COALESCE(NEW.raw_user_meta_data->>'preferred_locale', 'en')
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        updated_at = timezone('utc', now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
