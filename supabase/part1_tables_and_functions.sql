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



