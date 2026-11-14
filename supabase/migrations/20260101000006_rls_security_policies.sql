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
    FOR SELECT USING (is_active = true OR auth.is_super_admin());

CREATE POLICY "Super Admins can manage subscription plans" ON subscription_plans
    FOR ALL USING (auth.is_super_admin());

-- Platform Settings: Read by all authenticated/anon, mutate by Super Admin only
CREATE POLICY "Anyone can read platform settings" ON platform_settings
    FOR SELECT USING (true);

CREATE POLICY "Super Admins can modify platform settings" ON platform_settings
    FOR ALL USING (auth.is_super_admin());

-- Platform Admins: Only Super Admins can query or manage
CREATE POLICY "Super Admin access to platform admins" ON platform_admins
    FOR ALL USING (auth.is_super_admin());

-- ------------------------------------------------------------------------------
-- 2. SCHOOL TENANT ISOLATION POLICIES
-- ------------------------------------------------------------------------------
-- Schools: Anyone can read active basic school info (for public website / login discovery)
CREATE POLICY "Public can read active school info" ON schools
    FOR SELECT USING (status = 'active' OR auth.is_super_admin() OR id = auth.current_user_school_id());

CREATE POLICY "Super Admin can manage all schools" ON schools
    FOR ALL USING (auth.is_super_admin());

CREATE POLICY "School Admin can update own school" ON schools
    FOR UPDATE USING (
        id = auth.current_user_school_id() AND auth.current_user_role() = 'school_admin'
    );

-- School Settings
CREATE POLICY "School members and public can read settings" ON school_settings
    FOR SELECT USING (
        school_id = auth.current_user_school_id() OR auth.is_super_admin() OR true
    );

CREATE POLICY "School Admin can update school settings" ON school_settings
    FOR ALL USING (
        auth.is_super_admin() OR 
        (school_id = auth.current_user_school_id() AND auth.current_user_role() = 'school_admin')
    );

-- School Subscriptions: Read by School Admin, Managed by Super Admin
CREATE POLICY "School Admin can view own subscription" ON school_subscriptions
    FOR SELECT USING (
        auth.is_super_admin() OR 
        (school_id = auth.current_user_school_id() AND auth.current_user_role() = 'school_admin')
    );

CREATE POLICY "Super Admin can manage subscriptions" ON school_subscriptions
    FOR ALL USING (auth.is_super_admin());

-- ------------------------------------------------------------------------------
-- 3. PROFILES & USER MEMBERSHIPS
-- ------------------------------------------------------------------------------
CREATE POLICY "Users can view and update their own profile" ON profiles
    FOR ALL USING (id = auth.current_user_id());

CREATE POLICY "School Admins can view members in their school" ON profiles
    FOR SELECT USING (
        auth.is_super_admin() OR 
        EXISTS (
            SELECT 1 FROM user_school_memberships m1
            WHERE m1.user_id = profiles.id 
              AND m1.school_id = auth.current_user_school_id()
        )
    );

CREATE POLICY "School Admins manage memberships in own school" ON user_school_memberships
    FOR ALL USING (
        auth.is_super_admin() OR 
        (school_id = auth.current_user_school_id() AND auth.current_user_role() = 'school_admin')
    );

CREATE POLICY "Users view own school memberships" ON user_school_memberships
    FOR SELECT USING (user_id = auth.current_user_id());

-- ------------------------------------------------------------------------------
-- 4. SERVER-DRIVEN UI & CONFIGURATION POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Members can read published configuration versions" ON configuration_versions
    FOR SELECT USING (
        is_published = true AND (
            school_id IS NULL OR 
            school_id = auth.current_user_school_id() OR 
            auth.is_super_admin()
        )
    );

CREATE POLICY "Super Admin and School Admin manage configurations" ON configuration_versions
    FOR ALL USING (
        auth.is_super_admin() OR (
            school_id = auth.current_user_school_id() AND 
            auth.current_user_role() = 'school_admin'
        )
    );

CREATE POLICY "Auditors can view configuration audit logs" ON configuration_audit_logs
    FOR SELECT USING (
        auth.is_super_admin() OR (
            school_id = auth.current_user_school_id() AND 
            auth.current_user_role() = 'school_admin'
        )
    );

CREATE POLICY "System can record configuration audit logs" ON configuration_audit_logs
    FOR INSERT WITH CHECK (true);

-- ------------------------------------------------------------------------------
-- 5. ACADEMIC MODULE POLICIES (CLASSES, SECTIONS, SUBJECTS, ROUTINES)
-- ------------------------------------------------------------------------------
-- Read access: All members of that specific school
CREATE POLICY "School members can view academic sessions" ON academic_sessions
    FOR SELECT USING (auth.is_super_admin() OR school_id = auth.current_user_school_id());
CREATE POLICY "School Admin manages academic sessions" ON academic_sessions
    FOR ALL USING (auth.is_super_admin() OR (school_id = auth.current_user_school_id() AND auth.current_user_role() = 'school_admin'));

CREATE POLICY "School members can view classes" ON classes
    FOR SELECT USING (auth.is_super_admin() OR school_id = auth.current_user_school_id());
CREATE POLICY "School Admin manages classes" ON classes
    FOR ALL USING (auth.is_super_admin() OR (school_id = auth.current_user_school_id() AND auth.current_user_role() = 'school_admin'));

CREATE POLICY "School members can view sections" ON sections
    FOR SELECT USING (auth.is_super_admin() OR school_id = auth.current_user_school_id());
CREATE POLICY "School Admin manages sections" ON sections
    FOR ALL USING (auth.is_super_admin() OR (school_id = auth.current_user_school_id() AND auth.current_user_role() = 'school_admin'));

CREATE POLICY "School members can view subjects" ON subjects
    FOR SELECT USING (auth.is_super_admin() OR school_id = auth.current_user_school_id());
CREATE POLICY "School Admin manages subjects" ON subjects
    FOR ALL USING (auth.is_super_admin() OR (school_id = auth.current_user_school_id() AND auth.current_user_role() = 'school_admin'));

CREATE POLICY "School members can view routines" ON class_routines
    FOR SELECT USING (auth.is_super_admin() OR school_id = auth.current_user_school_id());
CREATE POLICY "School Admin manages routines" ON class_routines
    FOR ALL USING (auth.is_super_admin() OR (school_id = auth.current_user_school_id() AND auth.current_user_role() = 'school_admin'));

-- ------------------------------------------------------------------------------
-- 6. STUDENTS & PARENTS ISOLATION POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Student records read access" ON students
    FOR SELECT USING (
        auth.is_super_admin() OR
        (school_id = auth.current_user_school_id() AND (
            auth.current_user_role() IN ('school_admin', 'teacher', 'staff', 'accountant') OR
            user_id = auth.current_user_id() OR
            EXISTS (
                SELECT 1 FROM parent_student_relationships psr
                JOIN parents p ON p.id = psr.parent_id
                WHERE psr.student_id = students.id AND p.user_id = auth.current_user_id()
            )
        ))
    );

CREATE POLICY "School Admin manages students" ON students
    FOR ALL USING (
        auth.is_super_admin() OR 
        (school_id = auth.current_user_school_id() AND auth.current_user_role() = 'school_admin')
    );

CREATE POLICY "Enrollments read access" ON student_enrollments
    FOR SELECT USING (
        auth.is_super_admin() OR 
        (school_id = auth.current_user_school_id() AND (
            auth.current_user_role() IN ('school_admin', 'teacher', 'staff', 'accountant') OR
            EXISTS (SELECT 1 FROM students s WHERE s.id = student_enrollments.student_id AND s.user_id = auth.current_user_id()) OR
            EXISTS (
                SELECT 1 FROM parent_student_relationships psr
                JOIN parents p ON p.id = psr.parent_id
                WHERE psr.student_id = student_enrollments.student_id AND p.user_id = auth.current_user_id()
            )
        ))
    );

CREATE POLICY "School Admin manages student enrollments" ON student_enrollments
    FOR ALL USING (
        auth.is_super_admin() OR 
        (school_id = auth.current_user_school_id() AND auth.current_user_role() = 'school_admin')
    );

-- ------------------------------------------------------------------------------
-- 7. ATTENDANCE & EXAMINATION POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Student attendance read access" ON student_attendance
    FOR SELECT USING (
        auth.is_super_admin() OR 
        (school_id = auth.current_user_school_id() AND (
            auth.current_user_role() IN ('school_admin', 'teacher', 'staff') OR
            EXISTS (SELECT 1 FROM students s WHERE s.id = student_attendance.student_id AND s.user_id = auth.current_user_id()) OR
            EXISTS (
                SELECT 1 FROM parent_student_relationships psr
                JOIN parents p ON p.id = psr.parent_id
                WHERE psr.student_id = student_attendance.student_id AND p.user_id = auth.current_user_id()
            )
        ))
    );

CREATE POLICY "Authorized staff mark student attendance" ON student_attendance
    FOR ALL USING (
        auth.is_super_admin() OR 
        (school_id = auth.current_user_school_id() AND auth.current_user_role() IN ('school_admin', 'teacher'))
    );

CREATE POLICY "Student marks read access" ON student_marks
    FOR SELECT USING (
        auth.is_super_admin() OR 
        (school_id = auth.current_user_school_id() AND (
            auth.current_user_role() IN ('school_admin', 'teacher') OR
            EXISTS (SELECT 1 FROM students s WHERE s.id = student_marks.student_id AND s.user_id = auth.current_user_id()) OR
            EXISTS (
                SELECT 1 FROM parent_student_relationships psr
                JOIN parents p ON p.id = psr.parent_id
                WHERE psr.student_id = student_marks.student_id AND p.user_id = auth.current_user_id()
            )
        ))
    );

CREATE POLICY "Teachers and School Admin enter marks" ON student_marks
    FOR ALL USING (
        auth.is_super_admin() OR 
        (school_id = auth.current_user_school_id() AND auth.current_user_role() IN ('school_admin', 'teacher'))
    );

CREATE POLICY "Report cards read access" ON report_cards
    FOR SELECT USING (
        auth.is_super_admin() OR 
        (school_id = auth.current_user_school_id() AND (
            auth.current_user_role() IN ('school_admin', 'teacher') OR
            EXISTS (SELECT 1 FROM students s WHERE s.id = report_cards.student_id AND s.user_id = auth.current_user_id()) OR
            EXISTS (
                SELECT 1 FROM parent_student_relationships psr
                JOIN parents p ON p.id = psr.parent_id
                WHERE psr.student_id = report_cards.student_id AND p.user_id = auth.current_user_id()
            )
        ))
    );

-- ------------------------------------------------------------------------------
-- 8. FINANCIAL POLICIES (INVOICES & PAYMENTS)
-- ------------------------------------------------------------------------------
CREATE POLICY "Student invoices read access" ON student_invoices
    FOR SELECT USING (
        auth.is_super_admin() OR 
        (school_id = auth.current_user_school_id() AND (
            auth.current_user_role() IN ('school_admin', 'accountant', 'staff') OR
            EXISTS (SELECT 1 FROM students s WHERE s.id = student_invoices.student_id AND s.user_id = auth.current_user_id()) OR
            EXISTS (
                SELECT 1 FROM parent_student_relationships psr
                JOIN parents p ON p.id = psr.parent_id
                WHERE psr.student_id = student_invoices.student_id AND p.user_id = auth.current_user_id()
            )
        ))
    );

CREATE POLICY "Accountants and School Admin manage invoices" ON student_invoices
    FOR ALL USING (
        auth.is_super_admin() OR 
        (school_id = auth.current_user_school_id() AND auth.current_user_role() IN ('school_admin', 'accountant'))
    );

CREATE POLICY "Payment transactions view access" ON payment_transactions
    FOR SELECT USING (
        auth.is_super_admin() OR 
        (school_id = auth.current_user_school_id() AND (
            auth.current_user_role() IN ('school_admin', 'accountant') OR
            EXISTS (
                SELECT 1 FROM student_invoices si
                JOIN students s ON s.id = si.student_id
                WHERE si.id = payment_transactions.invoice_id AND s.user_id = auth.current_user_id()
            ) OR
            EXISTS (
                SELECT 1 FROM student_invoices si
                JOIN parent_student_relationships psr ON psr.student_id = si.student_id
                JOIN parents p ON p.id = psr.parent_id
                WHERE si.id = payment_transactions.invoice_id AND p.user_id = auth.current_user_id()
            )
        ))
    );

CREATE POLICY "Payment transactions recording" ON payment_transactions
    FOR INSERT WITH CHECK (
        auth.is_super_admin() OR 
        (school_id = auth.current_user_school_id() AND auth.current_user_role() IN ('school_admin', 'accountant', 'student', 'parent'))
    );

-- ------------------------------------------------------------------------------
-- 9. NOTICES & NOTIFICATIONS
-- ------------------------------------------------------------------------------
CREATE POLICY "School members read published notices" ON notices
    FOR SELECT USING (
        auth.is_super_admin() OR (
            school_id = auth.current_user_school_id() AND is_published = true
        )
    );

CREATE POLICY "School Admin and teachers manage notices" ON notices
    FOR ALL USING (
        auth.is_super_admin() OR 
        (school_id = auth.current_user_school_id() AND auth.current_user_role() IN ('school_admin', 'teacher'))
    );

CREATE POLICY "Users read own notifications" ON notifications
    FOR ALL USING (recipient_user_id = auth.current_user_id() OR auth.is_super_admin());
