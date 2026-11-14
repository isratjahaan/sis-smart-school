export type SchoolStatus = 'active' | 'suspended' | 'pending' | 'archived';

export interface School {
  id: string;
  name: string;
  slug: string;
  code: string;
  email: string;
  phone: string;
  address: string;
  city?: string;
  country: string;
  status: SchoolStatus;
  logo_url?: string | null;
  favicon_url?: string | null;
  banner_url?: string | null;
  website_url?: string | null;
  established_year?: number;
  principal_name?: string;
  created_at: string;
  updated_at: string;
}

export interface SchoolSetting {
  id: string;
  school_id: string;
  timezone: string;
  currency: string;
  currency_symbol: string;
  date_format: string;
  academic_session_id?: string | null;
  primary_color: string;
  secondary_color: string;
  accent_color: string;
  font_family: string;
  payment_bkash_number?: string | null;
  payment_nagad_number?: string | null;
  payment_rocket_number?: string | null;
  payment_bank_details?: string | null;
  attendance_type: 'daily' | 'subject_wise';
  auto_sms_absent: boolean;
  online_admission_enabled: boolean;
  created_at: string;
  updated_at: string;
}

export interface SchoolDomain {
  id: string;
  school_id: string;
  domain: string;
  is_verified: boolean;
  is_primary: boolean;
  ssl_status: 'active' | 'pending' | 'failed';
  created_at: string;
  updated_at: string;
}

export interface SubscriptionPlan {
  id: string;
  name: string;
  code: 'free_trial' | 'basic' | 'standard' | 'professional' | 'enterprise';
  description: string;
  price_monthly: number;
  price_yearly: number;
  max_students: number;
  max_teachers: number;
  max_storage_mb: number;
  features: Record<string, boolean>;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface SchoolSubscription {
  id: string;
  school_id: string;
  plan_id: string;
  status: 'trial' | 'active' | 'past_due' | 'canceled' | 'suspended';
  start_date: string;
  end_date: string;
  trial_ends_at?: string | null;
  auto_renew: boolean;
  payment_status: 'paid' | 'pending' | 'failed';
  created_at: string;
  updated_at: string;
  plan?: SubscriptionPlan;
}
