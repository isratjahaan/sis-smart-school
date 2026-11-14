-- ==============================================================================
-- supabase/migrations/20260101000001_platform_and_tenants.sql
-- ==============================================================================

-- ==============================================================================
-- 20260101000001_platform_and_tenants.sql
-- SIS SMART SCHOOL: PLATFORM & MULTI-TENANT CORE SCHEMA
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ------------------------------------------------------------------------------
-- 1. SUBSCRIPTION PLANS
-- ------------------------------------------------------------------------------
CREATE TABLE subscription_plans (
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
CREATE TABLE schools (
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

CREATE INDEX idx_schools_slug ON schools(slug);
CREATE INDEX idx_schools_status ON schools(status);

-- ------------------------------------------------------------------------------
-- 3. SCHOOL DOMAINS
-- ------------------------------------------------------------------------------
CREATE TABLE school_domains (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    domain VARCHAR(255) NOT NULL UNIQUE,
    is_verified BOOLEAN NOT NULL DEFAULT false,
    is_primary BOOLEAN NOT NULL DEFAULT false,
    ssl_status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (ssl_status IN ('active', 'pending', 'failed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX idx_school_domains_school_id ON school_domains(school_id);
CREATE INDEX idx_school_domains_domain ON school_domains(domain);

-- ------------------------------------------------------------------------------
-- 4. SCHOOL SUBSCRIPTIONS
-- ------------------------------------------------------------------------------
CREATE TABLE school_subscriptions (
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

CREATE INDEX idx_school_subscriptions_school_id ON school_subscriptions(school_id);

-- ------------------------------------------------------------------------------
-- 5. SCHOOL SETTINGS & BRANDING
-- ------------------------------------------------------------------------------
CREATE TABLE school_settings (
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
CREATE TABLE platform_settings (
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
CREATE TABLE feature_flags (
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
CREATE TABLE configuration_versions (
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

CREATE INDEX idx_config_versions_lookup ON configuration_versions(school_id, config_type, screen_id, is_published);

-- ------------------------------------------------------------------------------
-- 9. AUDIT LOGGING FOR CONFIGURATIONS & PLATFORM
-- ------------------------------------------------------------------------------
CREATE TABLE configuration_audit_logs (
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

CREATE INDEX idx_config_audit_school_id ON configuration_audit_logs(school_id);
CREATE INDEX idx_config_audit_created_at ON configuration_audit_logs(created_at DESC);


-- ==============================================================================
-- supabase/migrations/20260101000002_users_and_rbac.sql
-- ==============================================================================

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
-- supabase/migrations/20260101000003_academic_structure.sql
-- ==============================================================================

-- ==============================================================================
-- 20260101000003_academic_structure.sql
-- SIS SMART SCHOOL: ACADEMIC CORE, STUDENTS, TEACHERS & PARENTS
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. ACADEMIC SESSIONS
-- ------------------------------------------------------------------------------
CREATE TABLE academic_sessions (
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

CREATE INDEX idx_academic_sessions_school ON academic_sessions(school_id, is_current);

-- ------------------------------------------------------------------------------
-- 2. CLASSES & SECTIONS
-- ------------------------------------------------------------------------------
CREATE TABLE classes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL, -- e.g. "Class 6", "Class 10"
    numeric_grade INT NOT NULL, -- 1 to 12
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_school_class_name UNIQUE (school_id, name)
);

CREATE INDEX idx_classes_school ON classes(school_id, numeric_grade);

CREATE TABLE sections (
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

CREATE INDEX idx_sections_class ON sections(class_id);

CREATE TABLE groups (
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
CREATE TABLE subjects (
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

CREATE INDEX idx_subjects_school ON subjects(school_id);

CREATE TABLE class_subjects (
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

CREATE INDEX idx_class_subjects_class ON class_subjects(class_id);

-- ------------------------------------------------------------------------------
-- 4. TEACHERS & TEACHER ASSIGNMENTS
-- ------------------------------------------------------------------------------
CREATE TABLE teachers (
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

CREATE INDEX idx_teachers_school ON teachers(school_id, status);

CREATE TABLE teacher_assignments (
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

CREATE INDEX idx_teacher_assignments_lookup ON teacher_assignments(teacher_id, academic_session_id);

-- ------------------------------------------------------------------------------
-- 5. CLASS ROUTINES (TIMETABLE)
-- ------------------------------------------------------------------------------
CREATE TABLE class_routines (
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

CREATE INDEX idx_class_routines_lookup ON class_routines(school_id, class_id, section_id, day_of_week);

-- ------------------------------------------------------------------------------
-- 6. STUDENTS & PARENTS
-- ------------------------------------------------------------------------------
CREATE TABLE students (
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

CREATE INDEX idx_students_school ON students(school_id, status);

CREATE TABLE student_enrollments (
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

CREATE INDEX idx_enrollments_lookup ON student_enrollments(academic_session_id, class_id, section_id, is_active);
CREATE INDEX idx_enrollments_student ON student_enrollments(student_id);

CREATE TABLE parents (
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

CREATE INDEX idx_parents_school ON parents(school_id);

CREATE TABLE parent_student_relationships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    parent_id UUID NOT NULL REFERENCES parents(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    is_primary_contact BOOLEAN NOT NULL DEFAULT true,
    can_pickup BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_parent_student UNIQUE (parent_id, student_id)
);

CREATE INDEX idx_parent_student_lookup ON parent_student_relationships(parent_id, student_id);

CREATE TABLE student_documents (
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

CREATE INDEX idx_student_documents ON student_documents(student_id);


-- ==============================================================================
-- supabase/migrations/20260101000004_attendance_exams_and_gpa.sql
-- ==============================================================================

-- ==============================================================================
-- 20260101000004_attendance_exams_and_gpa.sql
-- SIS SMART SCHOOL: ATTENDANCE, EXAMINATIONS & BANGLADESH GPA CALCULATION ENGINE
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. ATTENDANCE TABLES
-- ------------------------------------------------------------------------------
CREATE TABLE student_attendance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    academic_session_id UUID NOT NULL REFERENCES academic_sessions(id) ON DELETE CASCADE,
    class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    section_id UUID NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('present', 'absent', 'late', 'half_day', 'excused')),
    check_in_time TIME,
    remarks TEXT,
    recorded_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_student_attendance_date UNIQUE (student_id, date)
);

CREATE INDEX idx_student_attendance_lookup ON student_attendance(school_id, class_id, section_id, date);
CREATE INDEX idx_student_attendance_student ON student_attendance(student_id, date);

CREATE TABLE teacher_attendance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    teacher_id UUID NOT NULL REFERENCES teachers(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('present', 'absent', 'late', 'half_day', 'excused')),
    check_in_time TIME,
    check_out_time TIME,
    remarks TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_teacher_attendance_date UNIQUE (teacher_id, date)
);

CREATE INDEX idx_teacher_attendance_lookup ON teacher_attendance(school_id, date);

-- ------------------------------------------------------------------------------
-- 2. GRADING SCALES (BANGLADESH NATIONAL BOARD & CUSTOM SCHOOL SCALES)
-- ------------------------------------------------------------------------------
CREATE TABLE grading_scales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID REFERENCES schools(id) ON DELETE CASCADE, -- NULL = System default scale
    name VARCHAR(100) NOT NULL,
    min_mark NUMERIC(5, 2) NOT NULL,
    max_mark NUMERIC(5, 2) NOT NULL,
    grade_name VARCHAR(10) NOT NULL, -- "A+", "A", "A-", "B", "C", "D", "F"
    grade_point NUMERIC(3, 2) NOT NULL, -- 5.00, 4.00, 3.50, 3.00, 2.00, 1.00, 0.00
    remarks VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_grading_scale_range UNIQUE (school_id, grade_name)
);

-- ------------------------------------------------------------------------------
-- 3. EXAMINATIONS & SUBJECTS
-- ------------------------------------------------------------------------------
CREATE TABLE examinations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    academic_session_id UUID NOT NULL REFERENCES academic_sessions(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    term VARCHAR(50) NOT NULL CHECK (term IN ('first_term', 'mid_term', 'final_term', 'test', 'annual')),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_published BOOLEAN NOT NULL DEFAULT false,
    published_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX idx_examinations_school ON examinations(school_id, academic_session_id);

CREATE TABLE examination_subjects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    examination_id UUID NOT NULL REFERENCES examinations(id) ON DELETE CASCADE,
    class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    exam_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    max_marks NUMERIC(5, 2) NOT NULL DEFAULT 100.00,
    pass_marks NUMERIC(5, 2) NOT NULL DEFAULT 33.00,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_exam_class_subject UNIQUE (examination_id, class_id, subject_id)
);

-- ------------------------------------------------------------------------------
-- 4. STUDENT MARKS & AUTOMATED GRADING
-- ------------------------------------------------------------------------------
CREATE TABLE student_marks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    examination_id UUID NOT NULL REFERENCES examinations(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    marks_obtained NUMERIC(5, 2) NOT NULL DEFAULT 0.00,
    theory_marks NUMERIC(5, 2),
    practical_marks NUMERIC(5, 2),
    grade_name VARCHAR(10),
    grade_point NUMERIC(3, 2),
    is_absent BOOLEAN NOT NULL DEFAULT false,
    remarks TEXT,
    entered_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_student_exam_subject_mark UNIQUE (examination_id, student_id, subject_id)
);

CREATE INDEX idx_student_marks_lookup ON student_marks(examination_id, student_id);

-- Stored Procedure to compute grade name and point from mark
CREATE OR REPLACE FUNCTION public.fn_calculate_grade(
    p_school_id UUID, 
    p_mark NUMERIC,
    OUT p_grade_name VARCHAR,
    OUT p_grade_point NUMERIC
) AS $$
BEGIN
    SELECT grade_name, grade_point 
    INTO p_grade_name, p_grade_point
    FROM grading_scales
    WHERE (school_id = p_school_id OR school_id IS NULL)
      AND p_mark >= min_mark 
      AND p_mark <= max_mark
    ORDER BY school_id NULLS LAST, min_mark DESC
    LIMIT 1;

    -- Standard Bangladesh fallback if no matching row
    IF p_grade_name IS NULL THEN
        IF p_mark >= 80 THEN
            p_grade_name := 'A+'; p_grade_point := 5.00;
        ELSIF p_mark >= 70 THEN
            p_grade_name := 'A';  p_grade_point := 4.00;
        ELSIF p_mark >= 60 THEN
            p_grade_name := 'A-'; p_grade_point := 3.50;
        ELSIF p_mark >= 50 THEN
            p_grade_name := 'B';  p_grade_point := 3.00;
        ELSIF p_mark >= 40 THEN
            p_grade_name := 'C';  p_grade_point := 2.00;
        ELSIF p_mark >= 33 THEN
            p_grade_name := 'D';  p_grade_point := 1.00;
        ELSE
            p_grade_name := 'F';  p_grade_point := 0.00;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql STABLE;

-- Trigger to automatically evaluate grade_name and grade_point on student_marks
CREATE OR REPLACE FUNCTION public.trg_student_marks_grade_eval()
RETURNS TRIGGER AS $$
DECLARE
    v_grade_name VARCHAR;
    v_grade_point NUMERIC;
BEGIN
    IF NEW.is_absent THEN
        NEW.marks_obtained := 0.00;
        NEW.grade_name := 'F';
        NEW.grade_point := 0.00;
    ELSE
        SELECT p_grade_name, p_grade_point 
        INTO v_grade_name, v_grade_point
        FROM public.fn_calculate_grade(NEW.school_id, NEW.marks_obtained);
        
        NEW.grade_name := v_grade_name;
        NEW.grade_point := v_grade_point;
    END IF;
    NEW.updated_at := timezone('utc', now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_student_marks_save ON student_marks;
CREATE TRIGGER on_student_marks_save
    BEFORE INSERT OR UPDATE ON student_marks
    FOR EACH ROW EXECUTE FUNCTION public.trg_student_marks_grade_eval();

-- ------------------------------------------------------------------------------
-- 5. REPORT CARDS & CUMULATIVE GPA ENGINE
-- ------------------------------------------------------------------------------
CREATE TABLE report_cards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    examination_id UUID NOT NULL REFERENCES examinations(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    section_id UUID NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
    total_marks NUMERIC(7, 2) NOT NULL DEFAULT 0.00,
    marks_obtained NUMERIC(7, 2) NOT NULL DEFAULT 0.00,
    percentage NUMERIC(5, 2) NOT NULL DEFAULT 0.00,
    gpa NUMERIC(3, 2) NOT NULL DEFAULT 0.00,
    final_grade VARCHAR(10) NOT NULL,
    rank_in_class INT,
    rank_in_section INT,
    status VARCHAR(20) NOT NULL DEFAULT 'passed' CHECK (status IN ('passed', 'failed', 'withheld')),
    subject_details JSONB NOT NULL DEFAULT '[]'::jsonb,
    remarks TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_report_card_student_exam UNIQUE (examination_id, student_id)
);

CREATE INDEX idx_report_cards_lookup ON report_cards(examination_id, class_id, section_id);
CREATE INDEX idx_report_cards_student ON report_cards(student_id);

-- Stored Procedure to generate or recalculate student report card
CREATE OR REPLACE FUNCTION public.fn_generate_student_report_card(
    p_school_id UUID,
    p_exam_id UUID,
    p_student_id UUID
) RETURNS VOID AS $$
DECLARE
    v_class_id UUID;
    v_section_id UUID;
    v_total_max_marks NUMERIC := 0;
    v_total_obtained NUMERIC := 0;
    v_subject_count INT := 0;
    v_has_failed BOOLEAN := false;
    v_total_points NUMERIC := 0;
    v_calculated_gpa NUMERIC := 0.00;
    v_final_grade VARCHAR(10);
    v_percentage NUMERIC := 0.00;
    v_subjects_json JSONB;
BEGIN
    -- 1. Find student's active enrollment
    SELECT class_id, section_id INTO v_class_id, v_section_id
    FROM student_enrollments
    WHERE student_id = p_student_id 
      AND school_id = p_school_id 
      AND is_active = true
    LIMIT 1;

    -- 2. Aggregate marks and build details JSON
    WITH subject_data AS (
        SELECT 
            s.id AS subject_id,
            s.name AS subject_name,
            s.code AS subject_code,
            COALESCE(es.max_marks, s.total_marks) AS max_marks,
            COALESCE(es.pass_marks, s.pass_marks) AS pass_marks,
            sm.marks_obtained,
            sm.grade_name,
            sm.grade_point,
            sm.is_absent,
            (sm.marks_obtained < COALESCE(es.pass_marks, s.pass_marks) OR sm.is_absent) AS is_failed
        FROM student_marks sm
        JOIN subjects s ON s.id = sm.subject_id
        LEFT JOIN examination_subjects es ON es.examination_id = sm.examination_id AND es.subject_id = sm.subject_id
        WHERE sm.examination_id = p_exam_id 
          AND sm.student_id = p_student_id
          AND sm.school_id = p_school_id
    )
    SELECT 
        COALESCE(SUM(max_marks), 0),
        COALESCE(SUM(marks_obtained), 0),
        COUNT(*),
        BOOL_OR(is_failed),
        COALESCE(SUM(grade_point), 0),
        jsonb_agg(to_jsonb(subject_data))
    INTO 
        v_total_max_marks,
        v_total_obtained,
        v_subject_count,
        v_has_failed,
        v_total_points,
        v_subjects_json
    FROM subject_data;

    IF v_subject_count > 0 THEN
        IF v_total_max_marks > 0 THEN
            v_percentage := ROUND((v_total_obtained / v_total_max_marks) * 100, 2);
        END IF;

        IF v_has_failed THEN
            v_calculated_gpa := 0.00;
            v_final_grade := 'F';
        ELSE
            v_calculated_gpa := LEAST(5.00, ROUND(v_total_points / v_subject_count, 2));
            -- Assign final grade based on GPA
            IF v_calculated_gpa >= 5.00 THEN v_final_grade := 'A+';
            ELSIF v_calculated_gpa >= 4.00 THEN v_final_grade := 'A';
            ELSIF v_calculated_gpa >= 3.50 THEN v_final_grade := 'A-';
            ELSIF v_calculated_gpa >= 3.00 THEN v_final_grade := 'B';
            ELSIF v_calculated_gpa >= 2.00 THEN v_final_grade := 'C';
            ELSIF v_calculated_gpa >= 1.00 THEN v_final_grade := 'D';
            ELSE v_final_grade := 'F';
            END IF;
        END IF;

        -- Upsert report card
        INSERT INTO report_cards (
            school_id, examination_id, student_id, class_id, section_id,
            total_marks, marks_obtained, percentage, gpa, final_grade,
            status, subject_details, updated_at
        ) VALUES (
            p_school_id, p_exam_id, p_student_id, v_class_id, v_section_id,
            v_total_max_marks, v_total_obtained, v_percentage, v_calculated_gpa, v_final_grade,
            CASE WHEN v_has_failed THEN 'failed' ELSE 'passed' END,
            COALESCE(v_subjects_json, '[]'::jsonb),
            timezone('utc', now())
        )
        ON CONFLICT (examination_id, student_id) DO UPDATE SET
            total_marks = EXCLUDED.total_marks,
            marks_obtained = EXCLUDED.marks_obtained,
            percentage = EXCLUDED.percentage,
            gpa = EXCLUDED.gpa,
            final_grade = EXCLUDED.final_grade,
            status = EXCLUDED.status,
            subject_details = EXCLUDED.subject_details,
            updated_at = timezone('utc', now());
    END IF;
END;
$$ LANGUAGE plpgsql;


-- ==============================================================================
-- supabase/migrations/20260101000005_finance_accounts_and_communication.sql
-- ==============================================================================

-- ==============================================================================
-- 20260101000005_finance_accounts_and_communication.sql
-- SIS SMART SCHOOL: FINANCE, NOTICES, HOMEWORK & AUXILIARY MODULES
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. FEES & INVOICING
-- ------------------------------------------------------------------------------
CREATE TABLE fee_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_school_fee_category UNIQUE (school_id, name)
);

CREATE TABLE fee_structures (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    academic_session_id UUID NOT NULL REFERENCES academic_sessions(id) ON DELETE CASCADE,
    class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    fee_category_id UUID NOT NULL REFERENCES fee_categories(id) ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    due_date_day_of_month INT NOT NULL DEFAULT 10,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_class_fee_structure UNIQUE (academic_session_id, class_id, fee_category_id)
);

CREATE TABLE student_invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    invoice_number VARCHAR(50) NOT NULL,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    academic_session_id UUID NOT NULL REFERENCES academic_sessions(id) ON DELETE CASCADE,
    fee_category_id UUID NOT NULL REFERENCES fee_categories(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    discount_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    net_amount NUMERIC(10, 2) GENERATED ALWAYS AS (total_amount - discount_amount) STORED,
    paid_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    due_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    due_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'unpaid' CHECK (status IN ('unpaid', 'paid', 'partially_paid', 'overdue', 'waived')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_school_invoice_number UNIQUE (school_id, invoice_number)
);

CREATE INDEX idx_student_invoices_lookup ON student_invoices(school_id, student_id, status);

CREATE TABLE payment_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    invoice_id UUID NOT NULL REFERENCES student_invoices(id) ON DELETE CASCADE,
    transaction_number VARCHAR(100) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL CHECK (payment_method IN ('cash', 'bkash', 'nagad', 'rocket', 'bank_transfer', 'cheque')),
    payment_gateway_trx_id VARCHAR(100),
    receiver_number VARCHAR(50),
    sender_number VARCHAR(50),
    bank_name VARCHAR(150),
    status VARCHAR(30) NOT NULL DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    notes TEXT,
    collected_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_school_payment_trx UNIQUE (school_id, transaction_number)
);

-- Trigger to automatically synchronize student_invoices on payment insertion/status update
CREATE OR REPLACE FUNCTION public.trg_sync_invoice_payments()
RETURNS TRIGGER AS $$
DECLARE
    v_total_paid NUMERIC(10, 2);
    v_net_amount NUMERIC(10, 2);
BEGIN
    -- Sum all completed payments for this invoice
    SELECT COALESCE(SUM(amount), 0.00)
    INTO v_total_paid
    FROM payment_transactions
    WHERE invoice_id = NEW.invoice_id AND status = 'completed';

    SELECT net_amount INTO v_net_amount
    FROM student_invoices
    WHERE id = NEW.invoice_id;

    UPDATE student_invoices
    SET 
        paid_amount = v_total_paid,
        due_amount = GREATEST(0.00, v_net_amount - v_total_paid),
        status = CASE 
            WHEN v_total_paid >= v_net_amount THEN 'paid'
            WHEN v_total_paid > 0.00 THEN 'partially_paid'
            ELSE 'unpaid'
        END,
        updated_at = timezone('utc', now())
    WHERE id = NEW.invoice_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_payment_saved ON payment_transactions;
CREATE TRIGGER on_payment_saved
    AFTER INSERT OR UPDATE ON payment_transactions
    FOR EACH ROW EXECUTE FUNCTION public.trg_sync_invoice_payments();

CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    expense_date DATE NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    recipient_name VARCHAR(150),
    invoice_receipt_url TEXT,
    notes TEXT,
    recorded_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX idx_expenses_school ON expenses(school_id, expense_date);

-- ------------------------------------------------------------------------------
-- 2. NOTICES & ANNOUNCEMENTS
-- ------------------------------------------------------------------------------
CREATE TABLE notices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    target_audience VARCHAR(50) NOT NULL DEFAULT 'all' CHECK (target_audience IN ('all', 'students', 'parents', 'teachers', 'staff')),
    target_class_id UUID REFERENCES classes(id) ON DELETE SET NULL,
    priority VARCHAR(20) NOT NULL DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    attachment_url TEXT,
    is_published BOOLEAN NOT NULL DEFAULT true,
    published_at TIMESTAMPTZ DEFAULT timezone('utc', now()),
    author_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX idx_notices_school ON notices(school_id, is_published, created_at DESC);

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID REFERENCES schools(id) ON DELETE CASCADE,
    recipient_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    type VARCHAR(50) NOT NULL DEFAULT 'system',
    data_payload JSONB DEFAULT '{}'::jsonb,
    is_read BOOLEAN NOT NULL DEFAULT false,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX idx_notifications_recipient ON notifications(recipient_user_id, is_read, created_at DESC);

-- ------------------------------------------------------------------------------
-- 3. HOMEWORK & STUDY MATERIALS
-- ------------------------------------------------------------------------------
CREATE TABLE homework (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    academic_session_id UUID NOT NULL REFERENCES academic_sessions(id) ON DELETE CASCADE,
    class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    section_id UUID NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    teacher_id UUID NOT NULL REFERENCES teachers(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    submission_deadline TIMESTAMPTZ NOT NULL,
    attachment_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX idx_homework_lookup ON homework(school_id, class_id, section_id);

CREATE TABLE homework_submissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    homework_id UUID NOT NULL REFERENCES homework(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    submission_text TEXT,
    file_url TEXT,
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    status VARCHAR(30) NOT NULL DEFAULT 'submitted' CHECK (status IN ('submitted', 'late', 'evaluated', 'resubmit')),
    marks_obtained NUMERIC(5, 2),
    teacher_feedback TEXT,
    evaluated_at TIMESTAMPTZ,
    CONSTRAINT uq_homework_student UNIQUE (homework_id, student_id)
);

CREATE TABLE study_materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    file_url TEXT NOT NULL,
    file_type VARCHAR(50),
    file_size_bytes BIGINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- ------------------------------------------------------------------------------
-- 4. LEAVE APPLICATIONS
-- ------------------------------------------------------------------------------
CREATE TABLE leave_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    applicant_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    applicant_role VARCHAR(50) NOT NULL,
    student_id UUID REFERENCES students(id) ON DELETE SET NULL,
    teacher_id UUID REFERENCES teachers(id) ON DELETE SET NULL,
    leave_type VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    days_count INT NOT NULL,
    reason TEXT NOT NULL,
    attachment_url TEXT,
    status VARCHAR(30) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    reviewed_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMPTZ,
    reviewer_comments TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- ------------------------------------------------------------------------------
-- 5. AUXILIARY MODULES: LIBRARY, TRANSPORT, ADMISSIONS, EVENTS & GALLERY
-- ------------------------------------------------------------------------------
CREATE TABLE library_books (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(150) NOT NULL,
    isbn VARCHAR(50),
    publisher VARCHAR(150),
    quantity_total INT NOT NULL DEFAULT 1,
    quantity_available INT NOT NULL DEFAULT 1,
    rack_number VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE TABLE transport_routes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    route_name VARCHAR(150) NOT NULL,
    start_point VARCHAR(150) NOT NULL,
    end_point VARCHAR(150) NOT NULL,
    monthly_fare NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE TABLE admission_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    applicant_name VARCHAR(150) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(20) NOT NULL,
    applying_for_class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    parent_name VARCHAR(150) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(255),
    address TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'enrolled')),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE TABLE school_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    venue VARCHAR(150),
    is_public BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE TABLE gallery_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    image_url TEXT NOT NULL,
    caption TEXT,
    album_name VARCHAR(100) DEFAULT 'General',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);


-- ==============================================================================
-- supabase/migrations/20260101000006_rls_security_policies.sql
-- ==============================================================================

-- ==============================================================================
-- 20260101000006_rls_security_policies.sql
-- SIS SMART SCHOOL: STRICT MULTI-TENANT POSTGRESQL ROW-LEVEL SECURITY (RLS)
-- ==============================================================================

-- Enable RLS on all tables
ALTER TABLE schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE school_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE school_domains ENABLE ROW LEVEL SECURITY;
ALTER TABLE school_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE platform_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE feature_flags ENABLE ROW LEVEL SECURITY;
ALTER TABLE configuration_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE configuration_audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE platform_admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_school_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE academic_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_routines ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE parents ENABLE ROW LEVEL SECURITY;
ALTER TABLE parent_student_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE grading_scales ENABLE ROW LEVEL SECURITY;
ALTER TABLE examinations ENABLE ROW LEVEL SECURITY;
ALTER TABLE examination_subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_marks ENABLE ROW LEVEL SECURITY;
ALTER TABLE report_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE fee_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE fee_structures ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE notices ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE homework ENABLE ROW LEVEL SECURITY;
ALTER TABLE homework_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE leave_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE library_books ENABLE ROW LEVEL SECURITY;
ALTER TABLE transport_routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE admission_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE school_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE gallery_items ENABLE ROW LEVEL SECURITY;

-- ------------------------------------------------------------------------------
-- 1. PLATFORM & SUBSCRIPTION POLICIES
-- ------------------------------------------------------------------------------
-- Subscription Plans: Publicly visible, but only Super Admin can mutate
CREATE POLICY "Public can view active subscription plans" ON subscription_plans
    FOR SELECT USING (is_active = true OR public.is_super_admin());

CREATE POLICY "Super Admins can manage subscription plans" ON subscription_plans
    FOR ALL USING (public.is_super_admin());

-- Platform Settings: Read by all authenticated/anon, mutate by Super Admin only
CREATE POLICY "Anyone can read platform settings" ON platform_settings
    FOR SELECT USING (true);

CREATE POLICY "Super Admins can modify platform settings" ON platform_settings
    FOR ALL USING (public.is_super_admin());

-- Platform Admins: Only Super Admins can query or manage
CREATE POLICY "Super Admin access to platform admins" ON platform_admins
    FOR ALL USING (public.is_super_admin());

-- ------------------------------------------------------------------------------
-- 2. SCHOOL TENANT ISOLATION POLICIES
-- ------------------------------------------------------------------------------
-- Schools: Anyone can read active basic school info (for public website / login discovery)
CREATE POLICY "Public can read active school info" ON schools
    FOR SELECT USING (status = 'active' OR public.is_super_admin() OR id = public.current_user_school_id());

CREATE POLICY "Super Admin can manage all schools" ON schools
    FOR ALL USING (public.is_super_admin());

CREATE POLICY "School Admin can update own school" ON schools
    FOR UPDATE USING (
        id = public.current_user_school_id() AND public.current_user_role() = 'school_admin'
    );

-- School Settings
CREATE POLICY "School members and public can read settings" ON school_settings
    FOR SELECT USING (
        school_id = public.current_user_school_id() OR public.is_super_admin() OR true
    );

CREATE POLICY "School Admin can update school settings" ON school_settings
    FOR ALL USING (
        public.is_super_admin() OR 
        (school_id = public.current_user_school_id() AND public.current_user_role() = 'school_admin')
    );

-- School Subscriptions: Read by School Admin, Managed by Super Admin
CREATE POLICY "School Admin can view own subscription" ON school_subscriptions
    FOR SELECT USING (
        public.is_super_admin() OR 
        (school_id = public.current_user_school_id() AND public.current_user_role() = 'school_admin')
    );

CREATE POLICY "Super Admin can manage subscriptions" ON school_subscriptions
    FOR ALL USING (public.is_super_admin());

-- ------------------------------------------------------------------------------
-- 3. PROFILES & USER MEMBERSHIPS
-- ------------------------------------------------------------------------------
CREATE POLICY "Users can view and update their own profile" ON profiles
    FOR ALL USING (id = auth.uid());

CREATE POLICY "School Admins can view members in their school" ON profiles
    FOR SELECT USING (
        public.is_super_admin() OR 
        EXISTS (
            SELECT 1 FROM user_school_memberships m1
            WHERE m1.user_id = profiles.id 
              AND m1.school_id = public.current_user_school_id()
        )
    );

CREATE POLICY "School Admins manage memberships in own school" ON user_school_memberships
    FOR ALL USING (
        public.is_super_admin() OR 
        (school_id = public.current_user_school_id() AND public.current_user_role() = 'school_admin')
    );

CREATE POLICY "Users view own school memberships" ON user_school_memberships
    FOR SELECT USING (user_id = auth.uid());

-- ------------------------------------------------------------------------------
-- 4. SERVER-DRIVEN UI & CONFIGURATION POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Members can read published configuration versions" ON configuration_versions
    FOR SELECT USING (
        is_published = true AND (
            school_id IS NULL OR 
            school_id = public.current_user_school_id() OR 
            public.is_super_admin()
        )
    );

CREATE POLICY "Super Admin and School Admin manage configurations" ON configuration_versions
    FOR ALL USING (
        public.is_super_admin() OR (
            school_id = public.current_user_school_id() AND 
            public.current_user_role() = 'school_admin'
        )
    );

CREATE POLICY "Auditors can view configuration audit logs" ON configuration_audit_logs
    FOR SELECT USING (
        public.is_super_admin() OR (
            school_id = public.current_user_school_id() AND 
            public.current_user_role() = 'school_admin'
        )
    );

CREATE POLICY "System can record configuration audit logs" ON configuration_audit_logs
    FOR INSERT WITH CHECK (true);

-- ------------------------------------------------------------------------------
-- 5. ACADEMIC MODULE POLICIES (CLASSES, SECTIONS, SUBJECTS, ROUTINES)
-- ------------------------------------------------------------------------------
-- Read access: All members of that specific school
CREATE POLICY "School members can view academic sessions" ON academic_sessions
    FOR SELECT USING (public.is_super_admin() OR school_id = public.current_user_school_id());
CREATE POLICY "School Admin manages academic sessions" ON academic_sessions
    FOR ALL USING (public.is_super_admin() OR (school_id = public.current_user_school_id() AND public.current_user_role() = 'school_admin'));

CREATE POLICY "School members can view classes" ON classes
    FOR SELECT USING (public.is_super_admin() OR school_id = public.current_user_school_id());
CREATE POLICY "School Admin manages classes" ON classes
    FOR ALL USING (public.is_super_admin() OR (school_id = public.current_user_school_id() AND public.current_user_role() = 'school_admin'));

CREATE POLICY "School members can view sections" ON sections
    FOR SELECT USING (public.is_super_admin() OR school_id = public.current_user_school_id());
CREATE POLICY "School Admin manages sections" ON sections
    FOR ALL USING (public.is_super_admin() OR (school_id = public.current_user_school_id() AND public.current_user_role() = 'school_admin'));

CREATE POLICY "School members can view subjects" ON subjects
    FOR SELECT USING (public.is_super_admin() OR school_id = public.current_user_school_id());
CREATE POLICY "School Admin manages subjects" ON subjects
    FOR ALL USING (public.is_super_admin() OR (school_id = public.current_user_school_id() AND public.current_user_role() = 'school_admin'));

CREATE POLICY "School members can view routines" ON class_routines
    FOR SELECT USING (public.is_super_admin() OR school_id = public.current_user_school_id());
CREATE POLICY "School Admin manages routines" ON class_routines
    FOR ALL USING (public.is_super_admin() OR (school_id = public.current_user_school_id() AND public.current_user_role() = 'school_admin'));

-- ------------------------------------------------------------------------------
-- 6. STUDENTS & PARENTS ISOLATION POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Student records read access" ON students
    FOR SELECT USING (
        public.is_super_admin() OR
        (school_id = public.current_user_school_id() AND (
            public.current_user_role() IN ('school_admin', 'teacher', 'staff', 'accountant') OR
            user_id = auth.uid() OR
            EXISTS (
                SELECT 1 FROM parent_student_relationships psr
                JOIN parents p ON p.id = psr.parent_id
                WHERE psr.student_id = students.id AND p.user_id = auth.uid()
            )
        ))
    );

CREATE POLICY "School Admin manages students" ON students
    FOR ALL USING (
        public.is_super_admin() OR 
        (school_id = public.current_user_school_id() AND public.current_user_role() = 'school_admin')
    );

CREATE POLICY "Enrollments read access" ON student_enrollments
    FOR SELECT USING (
        public.is_super_admin() OR 
        (school_id = public.current_user_school_id() AND (
            public.current_user_role() IN ('school_admin', 'teacher', 'staff', 'accountant') OR
            EXISTS (SELECT 1 FROM students s WHERE s.id = student_enrollments.student_id AND s.user_id = auth.uid()) OR
            EXISTS (
                SELECT 1 FROM parent_student_relationships psr
                JOIN parents p ON p.id = psr.parent_id
                WHERE psr.student_id = student_enrollments.student_id AND p.user_id = auth.uid()
            )
        ))
    );

CREATE POLICY "School Admin manages student enrollments" ON student_enrollments
    FOR ALL USING (
        public.is_super_admin() OR 
        (school_id = public.current_user_school_id() AND public.current_user_role() = 'school_admin')
    );

-- ------------------------------------------------------------------------------
-- 7. ATTENDANCE & EXAMINATION POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Student attendance read access" ON student_attendance
    FOR SELECT USING (
        public.is_super_admin() OR 
        (school_id = public.current_user_school_id() AND (
            public.current_user_role() IN ('school_admin', 'teacher', 'staff') OR
            EXISTS (SELECT 1 FROM students s WHERE s.id = student_attendance.student_id AND s.user_id = auth.uid()) OR
            EXISTS (
                SELECT 1 FROM parent_student_relationships psr
                JOIN parents p ON p.id = psr.parent_id
                WHERE psr.student_id = student_attendance.student_id AND p.user_id = auth.uid()
            )
        ))
    );

CREATE POLICY "Authorized staff mark student attendance" ON student_attendance
    FOR ALL USING (
        public.is_super_admin() OR 
        (school_id = public.current_user_school_id() AND public.current_user_role() IN ('school_admin', 'teacher'))
    );

CREATE POLICY "Student marks read access" ON student_marks
    FOR SELECT USING (
        public.is_super_admin() OR 
        (school_id = public.current_user_school_id() AND (
            public.current_user_role() IN ('school_admin', 'teacher') OR
            EXISTS (SELECT 1 FROM students s WHERE s.id = student_marks.student_id AND s.user_id = auth.uid()) OR
            EXISTS (
                SELECT 1 FROM parent_student_relationships psr
                JOIN parents p ON p.id = psr.parent_id
                WHERE psr.student_id = student_marks.student_id AND p.user_id = auth.uid()
            )
        ))
    );

CREATE POLICY "Teachers and School Admin enter marks" ON student_marks
    FOR ALL USING (
        public.is_super_admin() OR 
        (school_id = public.current_user_school_id() AND public.current_user_role() IN ('school_admin', 'teacher'))
    );

CREATE POLICY "Report cards read access" ON report_cards
    FOR SELECT USING (
        public.is_super_admin() OR 
        (school_id = public.current_user_school_id() AND (
            public.current_user_role() IN ('school_admin', 'teacher') OR
            EXISTS (SELECT 1 FROM students s WHERE s.id = report_cards.student_id AND s.user_id = auth.uid()) OR
            EXISTS (
                SELECT 1 FROM parent_student_relationships psr
                JOIN parents p ON p.id = psr.parent_id
                WHERE psr.student_id = report_cards.student_id AND p.user_id = auth.uid()
            )
        ))
    );

-- ------------------------------------------------------------------------------
-- 8. FINANCIAL POLICIES (INVOICES & PAYMENTS)
-- ------------------------------------------------------------------------------
CREATE POLICY "Student invoices read access" ON student_invoices
    FOR SELECT USING (
        public.is_super_admin() OR 
        (school_id = public.current_user_school_id() AND (
            public.current_user_role() IN ('school_admin', 'accountant', 'staff') OR
            EXISTS (SELECT 1 FROM students s WHERE s.id = student_invoices.student_id AND s.user_id = auth.uid()) OR
            EXISTS (
                SELECT 1 FROM parent_student_relationships psr
                JOIN parents p ON p.id = psr.parent_id
                WHERE psr.student_id = student_invoices.student_id AND p.user_id = auth.uid()
            )
        ))
    );

CREATE POLICY "Accountants and School Admin manage invoices" ON student_invoices
    FOR ALL USING (
        public.is_super_admin() OR 
        (school_id = public.current_user_school_id() AND public.current_user_role() IN ('school_admin', 'accountant'))
    );

CREATE POLICY "Payment transactions view access" ON payment_transactions
    FOR SELECT USING (
        public.is_super_admin() OR 
        (school_id = public.current_user_school_id() AND (
            public.current_user_role() IN ('school_admin', 'accountant') OR
            EXISTS (
                SELECT 1 FROM student_invoices si
                JOIN students s ON s.id = si.student_id
                WHERE si.id = payment_transactions.invoice_id AND s.user_id = auth.uid()
            ) OR
            EXISTS (
                SELECT 1 FROM student_invoices si
                JOIN parent_student_relationships psr ON psr.student_id = si.student_id
                JOIN parents p ON p.id = psr.parent_id
                WHERE si.id = payment_transactions.invoice_id AND p.user_id = auth.uid()
            )
        ))
    );

CREATE POLICY "Payment transactions recording" ON payment_transactions
    FOR INSERT WITH CHECK (
        public.is_super_admin() OR 
        (school_id = public.current_user_school_id() AND public.current_user_role() IN ('school_admin', 'accountant', 'student', 'parent'))
    );

-- ------------------------------------------------------------------------------
-- 9. NOTICES & NOTIFICATIONS
-- ------------------------------------------------------------------------------
CREATE POLICY "School members read published notices" ON notices
    FOR SELECT USING (
        public.is_super_admin() OR (
            school_id = public.current_user_school_id() AND is_published = true
        )
    );

CREATE POLICY "School Admin and teachers manage notices" ON notices
    FOR ALL USING (
        public.is_super_admin() OR 
        (school_id = public.current_user_school_id() AND public.current_user_role() IN ('school_admin', 'teacher'))
    );

CREATE POLICY "Users read own notifications" ON notifications
    FOR ALL USING (recipient_user_id = auth.uid() OR public.is_super_admin());



-- ==============================================================================
-- supabase/seed.sql
-- ==============================================================================

-- ==============================================================================
-- supabase/seed.sql
-- SIS SMART SCHOOL: PRODUCTION-GRADE MULTI-TENANT SEED DATA
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. SUBSCRIPTION PLANS
-- ------------------------------------------------------------------------------
INSERT INTO subscription_plans (id, name, code, description, price_monthly, price_yearly, max_students, max_teachers, max_storage_mb, features, is_active)
VALUES
('a0000000-0000-0000-0000-000000000001', 'Free Trial', 'free_trial', '14-day fully featured evaluation plan for new schools', 0.00, 0.00, 50, 5, 512, '{"attendance": true, "exams": true, "fees": false, "mobile_app": true, "website": true}'::jsonb, true),
('a0000000-0000-0000-0000-000000000002', 'Basic', 'basic', 'Essential academic & attendance tracking for small schools', 2500.00, 25000.00, 250, 20, 2048, '{"attendance": true, "exams": true, "fees": true, "mobile_app": true, "website": false}'::jsonb, true),
('a0000000-0000-0000-0000-000000000003', 'Standard', 'standard', 'Comprehensive school management with web portal & payments', 5000.00, 50000.00, 600, 50, 5120, '{"attendance": true, "exams": true, "fees": true, "mobile_app": true, "website": true, "sms": true}'::jsonb, true),
('a0000000-0000-0000-0000-000000000004', 'Professional', 'professional', 'Advanced analytics, remote control, and automated report cards', 9000.00, 90000.00, 1500, 120, 15360, '{"attendance": true, "exams": true, "fees": true, "mobile_app": true, "website": true, "sms": true, "sdui_customization": true}'::jsonb, true),
('a0000000-0000-0000-0000-000000000005', 'Enterprise', 'enterprise', 'Unlimited capacity, dedicated support, custom domain & SLA', 18000.00, 180000.00, 5000, 300, 51200, '{"attendance": true, "exams": true, "fees": true, "mobile_app": true, "website": true, "sms": true, "sdui_customization": true, "custom_domain": true}'::jsonb, true)
ON CONFLICT (code) DO NOTHING;

-- ------------------------------------------------------------------------------
-- 2. GLOBAL PLATFORM SETTINGS
-- ------------------------------------------------------------------------------
INSERT INTO platform_settings (id, app_name, logo_url, primary_color, secondary_color, theme_mode, supported_languages, default_language, maintenance_mode, min_supported_version_code, latest_version_code, force_update, contact_email, support_phone)
VALUES
('b0000000-0000-0000-0000-000000000001', 'SIS Smart School', '/logo.svg', '#2563EB', '#0F172A', 'light', '["en", "bn"]'::jsonb, 'en', false, 1, 1, false, 'support@sissmartschool.com', '+8801700000000')
ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------------------------
-- 3. BANGLADESH STANDARD GRADING SCALES (SYSTEM DEFAULT)
-- ------------------------------------------------------------------------------
INSERT INTO grading_scales (id, school_id, name, min_mark, max_mark, grade_name, grade_point, remarks)
VALUES
('c0000000-0000-0000-0000-000000000001', NULL, 'Standard Bangladesh National Scale', 80.00, 100.00, 'A+', 5.00, 'Outstanding / Outstanding performance'),
('c0000000-0000-0000-0000-000000000002', NULL, 'Standard Bangladesh National Scale', 70.00, 79.99, 'A', 4.00, 'Excellent'),
('c0000000-0000-0000-0000-000000000003', NULL, 'Standard Bangladesh National Scale', 60.00, 69.99, 'A-', 3.50, 'Very Good'),
('c0000000-0000-0000-0000-000000000004', NULL, 'Standard Bangladesh National Scale', 50.00, 59.99, 'B', 3.00, 'Good'),
('c0000000-0000-0000-0000-000000000005', NULL, 'Standard Bangladesh National Scale', 40.00, 49.99, 'C', 2.00, 'Satisfactory'),
('c0000000-0000-0000-0000-000000000006', NULL, 'Standard Bangladesh National Scale', 33.00, 39.99, 'D', 1.00, 'Pass'),
('c0000000-0000-0000-0000-000000000007', NULL, 'Standard Bangladesh National Scale', 0.00, 32.99, 'F', 0.00, 'Fail')
ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------------------------
-- 4. SYSTEM PERMISSIONS
-- ------------------------------------------------------------------------------
INSERT INTO permissions (id, code, name, module, description)
VALUES
('d0000000-0000-0000-0000-000000000001', 'students.view', 'View Students', 'students', 'Can view student profiles and lists'),
('d0000000-0000-0000-0000-000000000002', 'students.manage', 'Manage Students', 'students', 'Can create, edit and archive students'),
('d0000000-0000-0000-0000-000000000003', 'teachers.view', 'View Teachers', 'teachers', 'Can view teacher records'),
('d0000000-0000-0000-0000-000000000004', 'teachers.manage', 'Manage Teachers', 'teachers', 'Can manage teachers and assignments'),
('d0000000-0000-0000-0000-000000000005', 'attendance.mark', 'Mark Attendance', 'attendance', 'Can take daily attendance'),
('d0000000-0000-0000-0000-000000000006', 'attendance.reports', 'View Attendance Reports', 'attendance', 'Can view attendance summaries'),
('d0000000-0000-0000-0000-000000000007', 'exams.marks', 'Enter Marks', 'examinations', 'Can submit and update student marks'),
('d0000000-0000-0000-0000-000000000008', 'exams.publish', 'Publish Results', 'examinations', 'Can publish examination results'),
('d0000000-0000-0000-0000-000000000009', 'finance.invoices', 'Manage Invoices', 'finance', 'Can generate and edit student invoices'),
('d0000000-0000-0000-0000-000000000010', 'finance.collect', 'Collect Payments', 'finance', 'Can record manual fee collections'),
('d0000000-0000-0000-0000-000000000011', 'sdui.customize', 'Customize Remote UI', 'sdui', 'Can customize screen layouts and navigation')
ON CONFLICT (code) DO NOTHING;

-- ------------------------------------------------------------------------------
-- 5. TWO MULTI-TENANT TEST SCHOOLS
-- ------------------------------------------------------------------------------
-- School 1: Dhaka Model School
INSERT INTO schools (id, name, slug, code, email, phone, address, city, country, status, logo_url, established_year, principal_name)
VALUES (
    '11111111-1111-1111-1111-111111111111',
    'Dhaka Model School',
    'dhaka-model',
    'DMS',
    'contact@dhakamodel.edu.bd',
    '+8801711223344',
    'House 42, Road 11, Dhanmondi, Dhaka',
    'Dhaka',
    'Bangladesh',
    'active',
    'https://images.unsplash.com/photo-1546410531-bb4caa6b424d?w=200&h=200&fit=crop',
    1995,
    'Prof. Mohammad Rafiqul Islam'
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO school_settings (id, school_id, timezone, currency, currency_symbol, primary_color, secondary_color, accent_color, font_family, payment_bkash_number, payment_nagad_number, payment_rocket_number, attendance_type, auto_sms_absent, online_admission_enabled)
VALUES (
    '11111111-1111-1111-1111-222222222222',
    '11111111-1111-1111-1111-111111111111',
    'Asia/Dhaka',
    'BDT',
    '৳',
    '#2563EB',
    '#0F172A',
    '#F59E0B',
    'Inter',
    '01711223344',
    '01811223344',
    '01911223344',
    'daily',
    true,
    true
) ON CONFLICT (school_id) DO NOTHING;

INSERT INTO school_subscriptions (id, school_id, plan_id, status, start_date, end_date, auto_renew, payment_status)
VALUES (
    '11111111-1111-1111-1111-333333333333',
    '11111111-1111-1111-1111-111111111111',
    'a0000000-0000-0000-0000-000000000004', -- Professional
    'active',
    '2026-01-01',
    '2026-12-31',
    true,
    'paid'
) ON CONFLICT DO NOTHING;

-- School 2: Chittagong Grammar School
INSERT INTO schools (id, name, slug, code, email, phone, address, city, country, status, logo_url, established_year, principal_name)
VALUES (
    '22222222-2222-2222-2222-222222222222',
    'Chittagong Grammar School',
    'cgs-ctg',
    'CGS',
    'admin@cgs.edu.bd',
    '+8801819876543',
    'Plot 15, Nasirabad Hills, Chittagong',
    'Chittagong',
    'Bangladesh',
    'active',
    'https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=200&h=200&fit=crop',
    2002,
    'Dr. Syeda Nusrat Jahan'
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO school_settings (id, school_id, timezone, currency, currency_symbol, primary_color, secondary_color, accent_color, font_family, payment_bkash_number, payment_nagad_number, attendance_type, auto_sms_absent, online_admission_enabled)
VALUES (
    '22222222-2222-2222-2222-222222222222',
    '22222222-2222-2222-2222-222222222222',
    'Asia/Dhaka',
    'BDT',
    '৳',
    '#059669', -- Emerald Theme for CGS
    '#111827',
    '#D97706',
    'Inter',
    '01819876543',
    '01719876543',
    'daily',
    false,
    true
) ON CONFLICT (school_id) DO NOTHING;

INSERT INTO school_subscriptions (id, school_id, plan_id, status, start_date, end_date, auto_renew, payment_status)
VALUES (
    '22222222-2222-2222-2222-333333333333',
    '22222222-2222-2222-2222-222222222222',
    'a0000000-0000-0000-0000-000000000003', -- Standard
    'active',
    '2026-01-01',
    '2026-12-31',
    true,
    'paid'
) ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------------------------
-- 6. ACADEMIC SESSIONS, CLASSES & SECTIONS (FOR DHAKA MODEL SCHOOL)
-- ------------------------------------------------------------------------------
INSERT INTO academic_sessions (id, school_id, name, start_date, end_date, is_current)
VALUES ('11111111-aaaa-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', '2026', '2026-01-01', '2026-12-31', true)
ON CONFLICT DO NOTHING;

INSERT INTO classes (id, school_id, name, numeric_grade, description)
VALUES 
('11111111-cccc-1111-1111-000000000006', '11111111-1111-1111-1111-111111111111', 'Class 6', 6, 'Junior Secondary Grade 6'),
('11111111-cccc-1111-1111-000000000007', '11111111-1111-1111-1111-111111111111', 'Class 7', 7, 'Junior Secondary Grade 7'),
('11111111-cccc-1111-1111-000000000008', '11111111-1111-1111-1111-111111111111', 'Class 8', 8, 'Junior Secondary Grade 8'),
('11111111-cccc-1111-1111-000000000009', '11111111-1111-1111-1111-111111111111', 'Class 9', 9, 'Secondary School Certificate Grade 9'),
('11111111-cccc-1111-1111-000000000010', '11111111-1111-1111-1111-111111111111', 'Class 10', 10, 'Secondary School Certificate Grade 10')
ON CONFLICT (school_id, name) DO NOTHING;

INSERT INTO sections (id, school_id, class_id, name, capacity, room_number)
VALUES
('11111111-dddd-1111-1111-000000000001', '11111111-1111-1111-1111-111111111111', '11111111-cccc-1111-1111-000000000010', 'Padma (Section A)', 45, 'Room 301'),
('11111111-dddd-1111-1111-000000000002', '11111111-1111-1111-1111-111111111111', '11111111-cccc-1111-1111-000000000010', 'Meghna (Section B)', 45, 'Room 302'),
('11111111-dddd-1111-1111-000000000003', '11111111-1111-1111-1111-111111111111', '11111111-cccc-1111-1111-000000000009', 'Jamuna (Section A)', 40, 'Room 201')
ON CONFLICT (class_id, name) DO NOTHING;

-- ------------------------------------------------------------------------------
-- 7. SUBJECTS FOR DHAKA MODEL SCHOOL
-- ------------------------------------------------------------------------------
INSERT INTO subjects (id, school_id, name, code, type, total_marks, pass_marks)
VALUES
('11111111-eeee-1111-1111-000000000001', '11111111-1111-1111-1111-111111111111', 'Bangla 1st Paper', 'BAN-101', 'theory', 100, 33),
('11111111-eeee-1111-1111-000000000002', '11111111-1111-1111-1111-111111111111', 'English 1st Paper', 'ENG-101', 'theory', 100, 33),
('11111111-eeee-1111-1111-000000000003', '11111111-1111-1111-1111-111111111111', 'General Mathematics', 'MAT-101', 'theory', 100, 33),
('11111111-eeee-1111-1111-000000000004', '11111111-1111-1111-1111-111111111111', 'General Science', 'SCI-101', 'both', 100, 33),
('11111111-eeee-1111-1111-000000000005', '11111111-1111-1111-1111-111111111111', 'Information & Communication Technology', 'ICT-101', 'both', 50, 17)
ON CONFLICT (school_id, code) DO NOTHING;

-- ------------------------------------------------------------------------------
-- 8. TEACHERS FOR DHAKA MODEL SCHOOL
-- ------------------------------------------------------------------------------
INSERT INTO teachers (id, school_id, teacher_id_number, first_name, last_name, gender, phone, email, qualification, designation, department, joining_date, basic_salary, status)
VALUES
('11111111-ffff-1111-1111-000000000001', '11111111-1111-1111-1111-111111111111', 'TCH-001', 'Kamrul', 'Hasan', 'male', '+8801712000001', 'kamrul.hasan@dhakamodel.edu.bd', 'M.Sc in Mathematics (DU)', 'Senior Assistant Teacher', 'Mathematics', '2018-03-01', 45000.00, 'active'),
('11111111-ffff-1111-1111-000000000002', '11111111-1111-1111-1111-111111111111', 'TCH-002', 'Farhana', 'Akter', 'female', '+8801712000002', 'farhana.akter@dhakamodel.edu.bd', 'M.A in English (JU)', 'Assistant Teacher', 'English', '2020-01-15', 38000.00, 'active'),
('11111111-ffff-1111-1111-000000000003', '11111111-1111-1111-1111-111111111111', 'TCH-003', 'Shahidul', 'Alam', 'male', '+8801712000003', 'shahidul.alam@dhakamodel.edu.bd', 'B.Sc in Computer Science (BUET)', 'Lecturer in ICT', 'Computer Science', '2021-08-01', 42000.00, 'active')
ON CONFLICT (school_id, teacher_id_number) DO NOTHING;

-- ------------------------------------------------------------------------------
-- 9. STUDENTS & ENROLLMENTS FOR DHAKA MODEL SCHOOL
-- ------------------------------------------------------------------------------
INSERT INTO students (id, school_id, student_id_number, admission_number, admission_date, first_name, last_name, date_of_birth, gender, blood_group, nationality, phone, email, address, status)
VALUES
('11111111-9999-1111-1111-000000000001', '11111111-1111-1111-1111-111111111111', 'DMS-2026-001', 'ADM-1001', '2024-01-05', 'Tahmid', 'Rahman', '2010-04-12', 'male', 'B+', 'Bangladeshi', '+8801710000001', 'tahmid.rahman@student.dhakamodel.edu.bd', 'House 12, Road 4, Dhanmondi, Dhaka', 'active'),
('11111111-9999-1111-1111-000000000002', '11111111-1111-1111-1111-111111111111', 'DMS-2026-002', 'ADM-1002', '2024-01-05', 'Samia', 'Chowdhury', '2010-08-22', 'female', 'A+', 'Bangladeshi', '+8801710000002', 'samia.chowdhury@student.dhakamodel.edu.bd', 'Apartment 5B, Green Road, Dhaka', 'active'),
('11111111-9999-1111-1111-000000000003', '11111111-1111-1111-1111-111111111111', 'DMS-2026-003', 'ADM-1003', '2024-01-06', 'Nafis', 'Iqbal', '2010-11-15', 'male', 'O+', 'Bangladeshi', '+8801710000003', 'nafis.iqbal@student.dhakamodel.edu.bd', 'House 7, Road 2, Lalmatia, Dhaka', 'active')
ON CONFLICT (school_id, student_id_number) DO NOTHING;

INSERT INTO student_enrollments (id, school_id, student_id, academic_session_id, class_id, section_id, roll_number, is_active)
VALUES
('11111111-9999-2222-1111-000000000001', '11111111-1111-1111-1111-111111111111', '11111111-9999-1111-1111-000000000001', '11111111-aaaa-1111-1111-111111111111', '11111111-cccc-1111-1111-000000000010', '11111111-dddd-1111-1111-000000000001', 1, true),
('11111111-9999-2222-1111-000000000002', '11111111-1111-1111-1111-111111111111', '11111111-9999-1111-1111-000000000002', '11111111-aaaa-1111-1111-111111111111', '11111111-cccc-1111-1111-000000000010', '11111111-dddd-1111-1111-000000000001', 2, true),
('11111111-9999-2222-1111-000000000003', '11111111-1111-1111-1111-111111111111', '11111111-9999-1111-1111-000000000003', '11111111-aaaa-1111-1111-111111111111', '11111111-cccc-1111-1111-000000000010', '11111111-dddd-1111-1111-000000000001', 3, true)
ON CONFLICT (student_id, academic_session_id) DO NOTHING;

-- ------------------------------------------------------------------------------
-- 10. REALISTIC ATTENDANCE RECORDS FOR STUDENTS
-- ------------------------------------------------------------------------------
INSERT INTO student_attendance (id, school_id, student_id, academic_session_id, class_id, section_id, date, status, check_in_time)
VALUES
('11111111-8888-1111-1111-000000000001', '11111111-1111-1111-1111-111111111111', '11111111-9999-1111-1111-000000000001', '11111111-aaaa-1111-1111-111111111111', '11111111-cccc-1111-1111-000000000010', '11111111-dddd-1111-1111-000000000001', CURRENT_DATE, 'present', '07:55:00'),
('11111111-8888-1111-1111-000000000002', '11111111-1111-1111-1111-111111111111', '11111111-9999-1111-1111-000000000002', '11111111-aaaa-1111-1111-111111111111', '11111111-cccc-1111-1111-000000000010', '11111111-dddd-1111-1111-000000000001', CURRENT_DATE, 'present', '07:58:00'),
('11111111-8888-1111-1111-000000000003', '11111111-1111-1111-1111-111111111111', '11111111-9999-1111-1111-000000000003', '11111111-aaaa-1111-1111-111111111111', '11111111-cccc-1111-1111-000000000010', '11111111-dddd-1111-1111-000000000001', CURRENT_DATE, 'absent', NULL)
ON CONFLICT (student_id, date) DO NOTHING;

-- ------------------------------------------------------------------------------
-- 11. EXAMINATIONS, MARKS & REPORT CARDS
-- ------------------------------------------------------------------------------
INSERT INTO examinations (id, school_id, academic_session_id, name, term, start_date, end_date, is_published, published_at)
VALUES (
    '11111111-7777-1111-1111-000000000001',
    '11111111-1111-1111-1111-111111111111',
    '11111111-aaaa-1111-1111-111111111111',
    'First Term Examination 2026',
    'first_term',
    '2026-04-10',
    '2026-04-25',
    true,
    '2026-04-30 10:00:00+06'
) ON CONFLICT DO NOTHING;

-- Marks for Student 1 (Tahmid Rahman - Outstanding A+ Student)
INSERT INTO student_marks (id, school_id, examination_id, student_id, subject_id, marks_obtained, is_absent)
VALUES
('11111111-7777-2222-1111-000000000001', '11111111-1111-1111-1111-111111111111', '11111111-7777-1111-1111-000000000001', '11111111-9999-1111-1111-000000000001', '11111111-eeee-1111-1111-000000000001', 88.00, false),
('11111111-7777-2222-1111-000000000002', '11111111-1111-1111-1111-111111111111', '11111111-7777-1111-1111-000000000001', '11111111-9999-1111-1111-000000000001', '11111111-eeee-1111-1111-000000000002', 84.00, false),
('11111111-7777-2222-1111-000000000003', '11111111-1111-1111-1111-111111111111', '11111111-7777-1111-1111-000000000001', '11111111-9999-1111-1111-000000000001', '11111111-eeee-1111-1111-000000000003', 95.00, false),
('11111111-7777-2222-1111-000000000004', '11111111-1111-1111-1111-111111111111', '11111111-7777-1111-1111-000000000001', '11111111-9999-1111-1111-000000000001', '11111111-eeee-1111-1111-000000000004', 91.00, false)
ON CONFLICT (examination_id, student_id, subject_id) DO NOTHING;

-- Generate Report Card for Tahmid
SELECT public.fn_generate_student_report_card(
    '11111111-1111-1111-1111-111111111111',
    '11111111-7777-1111-1111-000000000001',
    '11111111-9999-1111-1111-000000000001'
);

-- ------------------------------------------------------------------------------
-- 12. FEES, INVOICES & PAYMENTS
-- ------------------------------------------------------------------------------
INSERT INTO fee_categories (id, school_id, name, description)
VALUES
('11111111-6666-1111-1111-000000000001', '11111111-1111-1111-1111-111111111111', 'Monthly Tuition Fee', 'Regular monthly academic fee'),
('11111111-6666-1111-1111-000000000002', '11111111-1111-1111-1111-111111111111', 'Examination Fee', 'Term examination fee')
ON CONFLICT (school_id, name) DO NOTHING;

INSERT INTO student_invoices (id, school_id, invoice_number, student_id, academic_session_id, fee_category_id, title, total_amount, discount_amount, paid_amount, due_amount, due_date, status)
VALUES
('11111111-6666-2222-1111-000000000001', '11111111-1111-1111-1111-111111111111', 'INV-DMS-2026-0001', '11111111-9999-1111-1111-000000000001', '11111111-aaaa-1111-1111-111111111111', '11111111-6666-1111-1111-000000000001', 'January 2026 Tuition Fee', 2500.00, 0.00, 2500.00, 0.00, '2026-01-15', 'paid'),
('11111111-6666-2222-1111-000000000002', '11111111-1111-1111-1111-111111111111', 'INV-DMS-2026-0002', '11111111-9999-1111-1111-000000000001', '11111111-aaaa-1111-1111-111111111111', '11111111-6666-1111-1111-000000000001', 'February 2026 Tuition Fee', 2500.00, 0.00, 0.00, 2500.00, '2026-02-15', 'unpaid'),
('11111111-6666-2222-1111-000000000003', '11111111-1111-1111-1111-111111111111', 'INV-DMS-2026-0003', '11111111-9999-1111-1111-000000000002', '11111111-aaaa-1111-1111-111111111111', '11111111-6666-1111-1111-000000000001', 'January 2026 Tuition Fee', 2500.00, 0.00, 2500.00, 0.00, '2026-01-15', 'paid')
ON CONFLICT (school_id, invoice_number) DO NOTHING;

INSERT INTO payment_transactions (id, school_id, invoice_id, transaction_number, amount, payment_method, payment_gateway_trx_id, receiver_number, status)
VALUES
('11111111-6666-3333-1111-000000000001', '11111111-1111-1111-1111-111111111111', '11111111-6666-2222-1111-000000000001', 'TRX-DMS-2026-0001', 2500.00, 'bkash', '9KJA7721L', '01711223344', 'completed')
ON CONFLICT (school_id, transaction_number) DO NOTHING;

-- ------------------------------------------------------------------------------
-- 13. NOTICES & ANNOUNCEMENTS
-- ------------------------------------------------------------------------------
INSERT INTO notices (id, school_id, title, content, target_audience, priority, is_published)
VALUES
('11111111-5555-1111-1111-000000000001', '11111111-1111-1111-1111-111111111111', 'First Term Examination 2026 Schedule Published', 'Dear students and guardians, the schedule for the upcoming First Term Examination 2026 has been published. All students are requested to clear their academic fees before the exam commences.', 'all', 'high', true),
('11111111-5555-1111-1111-000000000002', '11111111-1111-1111-1111-111111111111', 'Annual Sports Day 2026', 'Annual sports competition will be held on the school playground next Saturday. Attendance is mandatory for all students.', 'all', 'normal', true)
ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------------------------
-- 14. SERVER-DRIVEN UI SCREEN LAYOUT & NAVIGATION CONFIGURATIONS
-- ------------------------------------------------------------------------------
-- Global Platform Default Student Home Layout
INSERT INTO configuration_versions (id, school_id, config_type, screen_id, version, is_published, payload)
VALUES (
    'e0000000-0000-0000-0000-000000000001',
    NULL,
    'screen_layout',
    'student_home',
    1,
    true,
    '{
        "screenId": "student_home",
        "version": 1,
        "title": "Student Dashboard",
        "components": [
            {
                "id": "comp_welcome",
                "type": "welcome_banner",
                "visible": true,
                "order": 1,
                "title": "Welcome to SIS Smart School",
                "subtitle": "Knowledge is Power"
            },
            {
                "id": "comp_quick_actions",
                "type": "quick_actions",
                "visible": true,
                "order": 2
            },
            {
                "id": "comp_attendance",
                "type": "attendance_card",
                "visible": true,
                "order": 3
            },
            {
                "id": "comp_routine",
                "type": "routine_strip",
                "visible": true,
                "order": 4
            },
            {
                "id": "comp_result",
                "type": "result_card",
                "visible": true,
                "order": 5
            },
            {
                "id": "comp_fees",
                "type": "fee_summary_card",
                "visible": true,
                "order": 6
            },
            {
                "id": "comp_notices",
                "type": "notice_list",
                "visible": true,
                "order": 7
            }
        ]
    }'::jsonb
) ON CONFLICT DO NOTHING;

-- Dhaka Model School Specific Student Home Layout (School Override)
INSERT INTO configuration_versions (id, school_id, config_type, screen_id, version, is_published, payload)
VALUES (
    'e0000000-0000-0000-0000-000000000002',
    '11111111-1111-1111-1111-111111111111',
    'screen_layout',
    'student_home',
    1,
    true,
    '{
        "screenId": "student_home",
        "version": 1,
        "title": "Dhaka Model School Student Portal",
        "components": [
            {
                "id": "comp_welcome",
                "type": "welcome_banner",
                "visible": true,
                "order": 1,
                "title": "Welcome to Dhaka Model School",
                "subtitle": "Excellence in Education since 1995"
            },
            {
                "id": "comp_attendance",
                "type": "attendance_card",
                "visible": true,
                "order": 2
            },
            {
                "id": "comp_quick_actions",
                "type": "quick_actions",
                "visible": true,
                "order": 3
            },
            {
                "id": "comp_result",
                "type": "result_card",
                "visible": true,
                "order": 4
            },
            {
                "id": "comp_routine",
                "type": "routine_strip",
                "visible": true,
                "order": 5
            },
            {
                "id": "comp_fees",
                "type": "fee_summary_card",
                "visible": true,
                "order": 6
            },
            {
                "id": "comp_notices",
                "type": "notice_list",
                "visible": true,
                "order": 7
            }
        ]
    }'::jsonb
) ON CONFLICT DO NOTHING;



