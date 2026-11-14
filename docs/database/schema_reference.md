# SIS Smart School — Database Schema & Architecture Reference

## Overview
SIS Smart School utilizes a multi-tenant PostgreSQL schema engineered for high throughput, strict data isolation, and comprehensive auditability. All tenant-owned records enforce foreign keys referencing `schools(id) ON DELETE CASCADE` and are protected by PostgreSQL Row-Level Security (RLS).

---

## 1. Domain Groupings & Tables

### A. Platform & Tenant Governance
- `subscription_plans`: Defines SaaS tiers (Free Trial, Basic, Standard, Professional, Enterprise) with quotas (students, teachers, storage).
- `schools`: Core multi-tenant record (name, slug, code, contact, status, principal).
- `school_domains`: Custom domain bindings with SSL verification flags.
- `school_subscriptions`: Subscriptions linking schools to plans with expiration and renewal tracking.
- `school_settings`: School branding (primary, secondary, accent colors, typography) and MFS payment receiver numbers (bKash, Nagad, Rocket).
- `platform_settings`: Global application configurations, maintenance mode, minimum supported app versions.
- `feature_flags`: Centralized feature toggle matrix with tenant-level override support.
- `configuration_versions`: Versioned Server-Driven UI schemas and navigation configurations.
- `configuration_audit_logs`: Immutable audit trails of configuration publications and rollbacks.

### B. User Profiles & Role-Based Access Control (RBAC)
- `profiles`: Synced from `auth.users` with names, contact, locale, and avatar.
- `platform_admins`: Restricts Super Admin authority to authorized platform managers.
- `user_school_memberships`: Maps users to specific schools with roles (`super_admin`, `school_admin`, `teacher`, `student`, `parent`, `accountant`, `staff`).
- `permissions` & `role_permissions`: Granular capability flags.

### C. Academic Core
- `academic_sessions`: Academic years (e.g., "2026", "2026-2027") with `is_current` active session indicator.
- `classes`: Academic grades (Class 1 to 12).
- `sections`: Divisions within classes (Padma, Meghna, Jamuna) with capacity limits.
- `groups`: Specialized secondary groups (Science, Commerce, Humanities, General).
- `subjects`: Curriculum courses with theory/practical types and pass marks.
- `class_subjects`: Subject mappings per class with credit hour designations.
- `class_routines`: Weekly timetable schedule by day, period, teacher, and room.
- `teachers`: Faculty records, designations, salaries, qualifications.
- `teacher_assignments`: Class and subject teacher assignments.

### D. Students & Parents
- `students`: Student profile details, unique student ID number (e.g. `DMS-2026-001`), admission date, blood group.
- `student_enrollments`: Class, section, and roll number per academic session.
- `parents`: Guardian profile records with contact and NID numbers.
- `parent_student_relationships`: Links guardians to one or more children with primary contact flags.
- `student_documents`: Birth certificates, previous marksheets, medical files.

### E. Attendance & Examination Engine
- `student_attendance`: Daily attendance with unique `(student_id, date)` constraint and statuses (`present`, `absent`, `late`, `half_day`, `excused`).
- `teacher_attendance`: Faculty check-in and check-out logs.
- `grading_scales`: Standard Bangladesh grading scale (A+, A, A-, B, C, D, F) with grade points (5.00, 4.00, 3.50, 3.00, 2.00, 1.00, 0.00).
- `examinations`: Term exams (First Term, Mid Term, Annual Exam).
- `examination_subjects`: Exam schedule, max marks, and pass marks per subject.
- `student_marks`: Marks obtained per subject with automated grade assignment.
- `report_cards`: Cumulative grade points average (GPA), final letter grade, percentage, and subject details JSON.

### F. Finance, Invoicing & Payments
- `fee_categories`: Monthly tuition, examination fees, admission fees, library charges.
- `fee_structures`: Standard fee amounts by class and session.
- `student_invoices`: Invoices generated for students with total amount, discount, paid amount, due amount, and status.
- `payment_transactions`: Completed payments across Cash, bKash, Nagad, Rocket, or Bank transfer.
- `expenses`: Institutional expense logging with categorization.

---

## 2. Key Database Stored Procedures & Triggers

1. **`fn_calculate_grade(p_school_id, p_mark)`**:
   Computes letter grade and grade point based on school or national grading scale.
2. **`trg_student_marks_grade_eval`**:
   Trigger automatically running on `student_marks` insert/update to assign `grade_name` and `grade_point`.
3. **`fn_generate_student_report_card(p_school_id, p_exam_id, p_student_id)`**:
   Aggregates student marks across all examination subjects, calculates GPA, determines Pass/Fail status, and updates `report_cards`.
4. **`trg_sync_invoice_payments`**:
   Trigger automatically running on `payment_transactions` to calculate total paid amount, update due amount, and transition invoice status (`unpaid` -> `partially_paid` -> `paid`).
