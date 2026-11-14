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
