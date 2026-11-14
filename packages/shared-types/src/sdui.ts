import { UserRole } from './auth';

export type SDUIComponentType =
  | 'welcome_banner'
  | 'attendance_card'
  | 'result_card'
  | 'routine_strip'
  | 'notice_list'
  | 'quick_actions'
  | 'fee_summary_card'
  | 'stat_metric'
  | 'announcement_bar'
  | 'class_list'
  | 'custom_html_notice';

export interface SDUIAction {
  type: 'navigate' | 'external_url' | 'open_modal' | 'call_phone' | 'trigger_refresh';
  target: string;
  params?: Record<string, unknown>;
}

export interface SDUIComponentConfig {
  id: string;
  type: SDUIComponentType;
  visible: boolean;
  order: number;
  title?: string;
  subtitle?: string;
  props?: Record<string, unknown>;
  action?: SDUIAction;
  allowedRoles?: UserRole[];
}

export interface SDUIScreenLayout {
  screenId: string; // e.g. "student_home", "teacher_home", "parent_home", "school_landing"
  version: number;
  title?: string;
  components: SDUIComponentConfig[];
  updatedAt: string;
}

export interface SDUINavigationItem {
  id: string;
  title: string;
  icon: string; // Approved Lucide/Material icon identifier, e.g. "home", "calendar", "award", "book"
  route: string;
  badgeCount?: number;
  visible: boolean;
  order: number;
  requiredRole?: UserRole[];
  featureFlag?: string; // e.g. "attendance_enabled"
}

export interface SDUINavigationConfig {
  id: string;
  school_id?: string | null;
  role: UserRole;
  items: SDUINavigationItem[];
  version: number;
  updated_at: string;
}

export interface FeatureFlagConfig {
  attendance_enabled: boolean;
  examinations_enabled: boolean;
  online_fees_enabled: boolean;
  library_enabled: boolean;
  transport_enabled: boolean;
  hostel_enabled: boolean;
  parent_messaging_enabled: boolean;
  live_bus_tracking: boolean;
  homework_submission_enabled: boolean;
  online_admission_enabled: boolean;
  sms_alerts_enabled: boolean;
}

export interface GlobalAppConfig {
  app_name: string;
  logo_url: string;
  primary_color: string;
  secondary_color: string;
  theme_mode: 'light' | 'dark' | 'system';
  supported_languages: Array<'en' | 'bn'>;
  default_language: 'en' | 'bn';
  maintenance_mode: boolean;
  maintenance_message?: string;
  min_supported_version_code: number;
  latest_version_code: number;
  force_update: boolean;
  privacy_policy_url: string;
  terms_conditions_url: string;
  contact_email: string;
  support_phone: string;
}

export interface ConfigurationVersionRecord {
  id: string;
  school_id?: string | null;
  config_type: 'screen_layout' | 'navigation' | 'feature_flags' | 'branding' | 'global';
  version: number;
  is_published: boolean;
  payload: Record<string, unknown>;
  published_by?: string | null;
  published_at?: string | null;
  created_at: string;
}
