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
