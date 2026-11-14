export type UserRole = 
  | 'super_admin'
  | 'school_admin'
  | 'teacher'
  | 'student'
  | 'parent'
  | 'accountant'
  | 'librarian'
  | 'staff';

export interface Profile {
  id: string; // Supabase auth.users UUID
  email: string;
  first_name: string;
  last_name: string;
  full_name: string;
  phone?: string | null;
  avatar_url?: string | null;
  status: 'active' | 'suspended' | 'inactive';
  preferred_locale: 'en' | 'bn';
  theme_mode: 'light' | 'dark' | 'system';
  created_at: string;
  updated_at: string;
}

export interface UserSchoolMembership {
  id: string;
  user_id: string;
  school_id: string;
  role: UserRole;
  is_active: boolean;
  is_primary: boolean;
  created_at: string;
  updated_at: string;
}

export interface Permission {
  id: string;
  code: string;
  name: string;
  module: string;
  description?: string;
}

export interface AuthSessionUser {
  id: string;
  email: string;
  profile: Profile;
  activeMembership?: UserSchoolMembership;
  roles: UserRole[];
  permissions: string[];
}
