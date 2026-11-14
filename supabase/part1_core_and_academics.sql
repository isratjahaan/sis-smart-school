-- ==============================================================================
-- 20260101000001_platform_and_tenants.sql
-- SIS SMART SCHOOL: PLATFORM & MULTI-TENANT CORE SCHEMA
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ------------------------------------------------------------------------------
-- 1. SUBSCRIPTION PLANS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS subscription_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    code VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    price_monthly NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    price_yearly NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    max_students INT NOT NULL DEFAULT 100,
    max_teachers INT NOT NULL DEFAULT 10,
    max_storage_mb INT NOT NULL DEFAULT 1024,
    features JSONB NOT NULL DEFAULT '{}'::jsonb,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- ------------------------------------------------------------------------------
-- 2. SCHOOLS (TENANTS)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS schools (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100),
    country VARCHAR(100) NOT NULL DEFAULT 'Bangladesh',
    status VARCHAR(50) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'pending', 'archived')),
    logo_url TEXT,
    favicon_url TEXT,
    banner_url TEXT,
    website_url TEXT,
    established_year INT,
    principal_name VARCHAR(150),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX IF NOT EXISTS idx_schools_slug ON schools(slug);
CREATE INDEX IF NOT EXISTS idx_schools_status ON schools(status);

-- ------------------------------------------------------------------------------
-- 3. SCHOOL DOMAINS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS school_domains (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    domain VARCHAR(255) NOT NULL UNIQUE,
    is_verified BOOLEAN NOT NULL DEFAULT false,
    is_primary BOOLEAN NOT NULL DEFAULT false,
    ssl_status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (ssl_status IN ('active', 'pending', 'failed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX IF NOT EXISTS idx_school_domains_school_id ON school_domains(school_id);
CREATE INDEX IF NOT EXISTS idx_school_domains_domain ON school_domains(domain);

-- ------------------------------------------------------------------------------
-- 4. SCHOOL SUBSCRIPTIONS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS school_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES subscription_plans(id),
    status VARCHAR(50) NOT NULL DEFAULT 'active' CHECK (status IN ('trial', 'active', 'past_due', 'canceled', 'suspended')),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    trial_ends_at TIMESTAMPTZ,
    auto_renew BOOLEAN NOT NULL DEFAULT true,
    payment_status VARCHAR(50) NOT NULL DEFAULT 'paid' CHECK (payment_status IN ('paid', 'pending', 'failed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX IF NOT EXISTS idx_school_subscriptions_school_id ON school_subscriptions(school_id);

-- ------------------------------------------------------------------------------
-- 5. SCHOOL SETTINGS & BRANDING
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS school_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL UNIQUE REFERENCES schools(id) ON DELETE CASCADE,
    timezone VARCHAR(100) NOT NULL DEFAULT 'Asia/Dhaka',
    currency VARCHAR(20) NOT NULL DEFAULT 'BDT',
    currency_symbol VARCHAR(10) NOT NULL DEFAULT '৳',
    date_format VARCHAR(50) NOT NULL DEFAULT 'YYYY-MM-DD',
    primary_color VARCHAR(20) NOT NULL DEFAULT '#2563EB',
    secondary_color VARCHAR(20) NOT NULL DEFAULT '#0F172A',
    accent_color VARCHAR(20) NOT NULL DEFAULT '#F59E0B',
    font_family VARCHAR(100) NOT NULL DEFAULT 'Inter',
    payment_bkash_number VARCHAR(50),
    payment_nagad_number VARCHAR(50),
    payment_rocket_number VARCHAR(50),
    payment_bank_details TEXT,
    attendance_type VARCHAR(50) NOT NULL DEFAULT 'daily' CHECK (attendance_type IN ('daily', 'subject_wise')),
    auto_sms_absent BOOLEAN NOT NULL DEFAULT false,
    online_admission_enabled BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- ------------------------------------------------------------------------------
-- 6. PLATFORM SETTINGS & GLOBAL CONFIGURATION
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS platform_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    app_name VARCHAR(150) NOT NULL DEFAULT 'SIS Smart School',
    logo_url TEXT,
    primary_color VARCHAR(20) NOT NULL DEFAULT '#2563EB',
    secondary_color VARCHAR(20) NOT NULL DEFAULT '#0F172A',
    theme_mode VARCHAR(20) NOT NULL DEFAULT 'light' CHECK (theme_mode IN ('light', 'dark', 'system')),
    supported_languages JSONB NOT NULL DEFAULT '["en", "bn"]'::jsonb,
    default_language VARCHAR(10) NOT NULL DEFAULT 'en',
    maintenance_mode BOOLEAN NOT NULL DEFAULT false,
    maintenance_message TEXT,
    min_supported_version_code INT NOT NULL DEFAULT 1,
    latest_version_code INT NOT NULL DEFAULT 1,
    force_update BOOLEAN NOT NULL DEFAULT false,
    privacy_policy_url TEXT,
    terms_conditions_url TEXT,
    contact_email VARCHAR(255),
    support_phone VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- ------------------------------------------------------------------------------
-- 7. CENTRALIZED FEATURE FLAGS (PLATFORM & TENANT)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS feature_flags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID REFERENCES schools(id) ON DELETE CASCADE, -- NULL means Global platform default
    attendance_enabled BOOLEAN NOT NULL DEFAULT true,
    examinations_enabled BOOLEAN NOT NULL DEFAULT true,
    online_fees_enabled BOOLEAN NOT NULL DEFAULT true,
    library_enabled BOOLEAN NOT NULL DEFAULT true,
    transport_enabled BOOLEAN NOT NULL DEFAULT true,
    hostel_enabled BOOLEAN NOT NULL DEFAULT false,
    parent_messaging_enabled BOOLEAN NOT NULL DEFAULT true,
    live_bus_tracking BOOLEAN NOT NULL DEFAULT false,
    homework_submission_enabled BOOLEAN NOT NULL DEFAULT true,
    online_admission_enabled BOOLEAN NOT NULL DEFAULT true,
    sms_alerts_enabled BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_feature_flags_school UNIQUE (school_id)
);

-- ------------------------------------------------------------------------------
-- 8. SERVER-DRIVEN UI CONFIGURATION & VERSIONING
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS configuration_versions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID REFERENCES schools(id) ON DELETE CASCADE, -- NULL = Global Platform Template
    config_type VARCHAR(50) NOT NULL CHECK (config_type IN ('screen_layout', 'navigation', 'feature_flags', 'branding', 'global')),
    screen_id VARCHAR(100), -- e.g. 'student_home', 'parent_home', 'teacher_home'
    version INT NOT NULL DEFAULT 1,
    is_published BOOLEAN NOT NULL DEFAULT false,
    payload JSONB NOT NULL,
    published_by UUID,
    published_at TIMESTAMPTZ,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX IF NOT EXISTS idx_config_versions_lookup ON configuration_versions(school_id, config_type, screen_id, is_published);

-- ------------------------------------------------------------------------------
-- 9. AUDIT LOGGING FOR CONFIGURATIONS & PLATFORM
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS configuration_audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID REFERENCES schools(id) ON DELETE SET NULL,
    actor_id UUID,
    actor_email VARCHAR(255),
    action VARCHAR(100) NOT NULL, -- e.g. 'publish_screen_layout', 'toggle_feature'
    entity_type VARCHAR(100) NOT NULL,
    entity_id VARCHAR(100),
    old_state JSONB,
    new_state JSONB,
    ip_address VARCHAR(50),
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX IF NOT EXISTS idx_config_audit_school_id ON configuration_audit_logs(school_id);
CREATE INDEX IF NOT EXISTS idx_config_audit_created_at ON configuration_audit_logs(created_at DESC);


-- ==============================================================================
-- 20260101000002_users_and_rbac.sql
-- SIS SMART SCHOOL: USERS, PROFILES, RBAC & SECURITY HELPERS
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. USER PROFILES
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS profiles (
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

CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_status ON profiles(status);

-- ------------------------------------------------------------------------------
-- 2. PLATFORM SUPER ADMINS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS platform_admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- ------------------------------------------------------------------------------
-- 3. PERMISSIONS TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS permissions (
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
CREATE TABLE IF NOT EXISTS user_school_memberships (
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

CREATE INDEX IF NOT EXISTS idx_user_school_memberships_lookup ON user_school_memberships(user_id, school_id, is_active);
CREATE INDEX IF NOT EXISTS idx_user_school_memberships_school ON user_school_memberships(school_id);

-- ------------------------------------------------------------------------------
-- 5. ROLE PERMISSIONS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS role_permissions (
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
-- Note: auth.uid() is provided natively by Supabase

-- Check if current user is Platform Super Admin
CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 
        FROM platform_admins 
        WHERE user_id = auth.uid() 
          AND is_active = true
    );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Get current user's active school ID from primary membership or session claim
CREATE OR REPLACE FUNCTION public.current_user_school_id()
RETURNS UUID AS $$
    SELECT school_id 
    FROM user_school_memberships 
    WHERE user_id = auth.uid() 
      AND is_active = true 
    ORDER BY is_primary DESC, created_at ASC 
    LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Get current user's role in the specified or current school
CREATE OR REPLACE FUNCTION public.current_user_role(p_school_id UUID DEFAULT NULL)
RETURNS VARCHAR AS $$
    SELECT role 
    FROM user_school_memberships 
    WHERE user_id = auth.uid() 
      AND is_active = true 
      AND (p_school_id IS NULL OR school_id = p_school_id)
    ORDER BY is_primary DESC 
    LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Granular permission check
CREATE OR REPLACE FUNCTION public.has_permission(p_permission_code VARCHAR, p_school_id UUID DEFAULT NULL)
RETURNS BOOLEAN AS $$
DECLARE
    v_role VARCHAR;
    v_school UUID;
BEGIN
    IF public.is_super_admin() THEN
        RETURN true;
    END IF;

    v_school := COALESCE(p_school_id, public.current_user_school_id());
    v_role := public.current_user_role(v_school);

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



-- ==============================================================================
-- 20260101000003_academic_structure.sql
-- SIS SMART SCHOOL: ACADEMIC CORE, STUDENTS, TEACHERS & PARENTS
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. ACADEMIC SESSIONS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS academic_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL, -- e.g. "2026" or "2026-2027"
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_school_session UNIQUE (school_id, name)
);

CREATE INDEX IF NOT EXISTS idx_academic_sessions_school ON academic_sessions(school_id, is_current);

-- ------------------------------------------------------------------------------
-- 2. CLASSES & SECTIONS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS classes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL, -- e.g. "Class 6", "Class 10"
    numeric_grade INT NOT NULL, -- 1 to 12
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_school_class_name UNIQUE (school_id, name)
);

CREATE INDEX IF NOT EXISTS idx_classes_school ON classes(school_id, numeric_grade);

CREATE TABLE IF NOT EXISTS sections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL, -- e.g. "Section A", "Padma"
    capacity INT NOT NULL DEFAULT 40,
    room_number VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_class_section UNIQUE (class_id, name)
);

CREATE INDEX IF NOT EXISTS idx_sections_class ON sections(class_id);

CREATE TABLE IF NOT EXISTS groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL, -- "Science", "Commerce", "Humanities", "General"
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_school_group UNIQUE (school_id, name)
);

-- ------------------------------------------------------------------------------
-- 3. SUBJECTS & CLASS SUBJECTS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS subjects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    code VARCHAR(50) NOT NULL,
    type VARCHAR(50) NOT NULL DEFAULT 'theory' CHECK (type IN ('theory', 'practical', 'both')),
    total_marks INT NOT NULL DEFAULT 100,
    pass_marks INT NOT NULL DEFAULT 33,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_school_subject_code UNIQUE (school_id, code)
);

CREATE INDEX IF NOT EXISTS idx_subjects_school ON subjects(school_id);

CREATE TABLE IF NOT EXISTS class_subjects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    is_optional BOOLEAN NOT NULL DEFAULT false,
    credit_hours NUMERIC(4, 2) DEFAULT 1.0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_class_subject UNIQUE (class_id, subject_id)
);

CREATE INDEX IF NOT EXISTS idx_class_subjects_class ON class_subjects(class_id);

-- ------------------------------------------------------------------------------
-- 4. TEACHERS & TEACHER ASSIGNMENTS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS teachers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    teacher_id_number VARCHAR(50) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    gender VARCHAR(20) NOT NULL CHECK (gender IN ('male', 'female', 'other')),
    date_of_birth DATE,
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    qualification VARCHAR(255) NOT NULL,
    designation VARCHAR(150) NOT NULL,
    department VARCHAR(100),
    joining_date DATE NOT NULL,
    basic_salary NUMERIC(12, 2) DEFAULT 0.00,
    status VARCHAR(50) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'on_leave', 'resigned', 'terminated')),
    photo_url TEXT,
    address TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_school_teacher_id UNIQUE (school_id, teacher_id_number)
);

CREATE INDEX IF NOT EXISTS idx_teachers_school ON teachers(school_id, status);

CREATE TABLE IF NOT EXISTS teacher_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    teacher_id UUID NOT NULL REFERENCES teachers(id) ON DELETE CASCADE,
    class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    section_id UUID NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    academic_session_id UUID NOT NULL REFERENCES academic_sessions(id) ON DELETE CASCADE,
    is_class_teacher BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_teacher_assignment UNIQUE (teacher_id, class_id, section_id, subject_id, academic_session_id)
);

CREATE INDEX IF NOT EXISTS idx_teacher_assignments_lookup ON teacher_assignments(teacher_id, academic_session_id);

-- ------------------------------------------------------------------------------
-- 5. CLASS ROUTINES (TIMETABLE)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS class_routines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    academic_session_id UUID NOT NULL REFERENCES academic_sessions(id) ON DELETE CASCADE,
    class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    section_id UUID NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    teacher_id UUID REFERENCES teachers(id) ON DELETE SET NULL,
    day_of_week VARCHAR(20) NOT NULL CHECK (day_of_week IN ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room_no VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX IF NOT EXISTS idx_class_routines_lookup ON class_routines(school_id, class_id, section_id, day_of_week);

-- ------------------------------------------------------------------------------
-- 6. STUDENTS & PARENTS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    student_id_number VARCHAR(50) NOT NULL, -- e.g. "DMS-2026-001"
    admission_number VARCHAR(50) NOT NULL,
    admission_date DATE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(20) NOT NULL CHECK (gender IN ('male', 'female', 'other')),
    blood_group VARCHAR(10) CHECK (blood_group IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    religion VARCHAR(50),
    nationality VARCHAR(50) NOT NULL DEFAULT 'Bangladeshi',
    phone VARCHAR(50),
    email VARCHAR(255),
    address TEXT NOT NULL,
    photo_url TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'graduated', 'transferred', 'suspended')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_school_student_id UNIQUE (school_id, student_id_number)
);

CREATE INDEX IF NOT EXISTS idx_students_school ON students(school_id, status);

CREATE TABLE IF NOT EXISTS student_enrollments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    academic_session_id UUID NOT NULL REFERENCES academic_sessions(id) ON DELETE CASCADE,
    class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    section_id UUID NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
    group_id UUID REFERENCES groups(id) ON DELETE SET NULL,
    roll_number INT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_section_roll UNIQUE (academic_session_id, class_id, section_id, roll_number),
    CONSTRAINT uq_student_session UNIQUE (student_id, academic_session_id)
);

CREATE INDEX IF NOT EXISTS idx_enrollments_lookup ON student_enrollments(academic_session_id, class_id, section_id, is_active);
CREATE INDEX IF NOT EXISTS idx_enrollments_student ON student_enrollments(student_id);

CREATE TABLE IF NOT EXISTS parents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    relationship VARCHAR(50) NOT NULL CHECK (relationship IN ('father', 'mother', 'guardian')),
    occupation VARCHAR(100),
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(255),
    address TEXT,
    nid_number VARCHAR(50),
    photo_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX IF NOT EXISTS idx_parents_school ON parents(school_id);

CREATE TABLE IF NOT EXISTS parent_student_relationships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    parent_id UUID NOT NULL REFERENCES parents(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    is_primary_contact BOOLEAN NOT NULL DEFAULT true,
    can_pickup BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_parent_student UNIQUE (parent_id, student_id)
);

CREATE INDEX IF NOT EXISTS idx_parent_student_lookup ON parent_student_relationships(parent_id, student_id);

CREATE TABLE IF NOT EXISTS student_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    document_type VARCHAR(50) NOT NULL CHECK (document_type IN ('birth_certificate', 'transfer_certificate', 'previous_marksheet', 'medical_record', 'other')),
    file_url TEXT NOT NULL,
    file_size_bytes BIGINT,
    mime_type VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX IF NOT EXISTS idx_student_documents ON student_documents(student_id);



