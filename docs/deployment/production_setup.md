# SIS Smart School — Production Deployment & Operations Guide

## 1. Backend & Database Setup (Supabase)

### Step 1: Create Supabase Project
1. Log in to [supabase.com](https://supabase.com) and create a new project.
2. Note your `Project URL`, `anon` key, and `service_role` key from **Settings > API**.

### Step 2: Apply Database Migrations & Seeds
Execute the migrations in sequential order using the Supabase CLI or SQL Editor:
```bash
# Using Supabase CLI:
supabase link --project-ref your-project-id
supabase db push

# Apply seed data:
psql -h db.your-project.supabase.co -U postgres -d postgres -f supabase/seed.sql
```

Migrations created:
- `20260101000001_platform_and_tenants.sql` (Platform tables & schools)
- `20260101000002_users_and_rbac.sql` (Profiles, RBAC & security helpers)
- `20260101000003_academic_structure.sql` (Sessions, classes, students, teachers)
- `20260101000004_attendance_exams_and_gpa.sql` (Attendance, grading, GPA engine)
- `20260101000005_finance_accounts_and_communication.sql` (Fees, MFS payments, notices)
- `20260101000006_rls_security_policies.sql` (Strict RLS on all 45+ tables)

### Step 3: Storage Buckets Configuration
Create the following private/public storage buckets under **Storage**:
- `public-assets` (Public: true) for school logos and gallery images.
- `private-student-documents` (Public: false) for certificates and student files.
- `private-academic-files` (Public: false) for report card exports and exams.

---

## 2. Next.js Admin & Web Deployment (Vercel)

Both applications can be deployed to Vercel with zero configuration:

### Admin Dashboard (`apps/admin`)
- Root Directory: `apps/admin`
- Build Command: `npm run build`
- Output Directory: `.next`
- Environment Variables:
  - `NEXT_PUBLIC_SUPABASE_URL`
  - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
  - `SUPABASE_SERVICE_ROLE_KEY` (Server-side only)

### Public School Website (`apps/web`)
- Root Directory: `apps/web`
- Build Command: `npm run build`
- Output Directory: `.next`
- Environment Variables:
  - `NEXT_PUBLIC_SUPABASE_URL`
  - `NEXT_PUBLIC_SUPABASE_ANON_KEY`

---

## 3. Flutter Android Build (APK & AAB)

Navigate to `apps/mobile`:

### 1. Build Android APK (Release)
```bash
cd apps/mobile
flutter pub get
flutter build apk --release --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### 2. Build Android App Bundle (Google Play Store AAB)
```bash
flutter build appbundle --release --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```
Output: `build/app/outputs/bundle/release/app-release.aab`
