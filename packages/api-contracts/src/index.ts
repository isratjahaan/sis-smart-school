import { SDUIScreenLayout, SDUINavigationConfig, FeatureFlagConfig } from '@sis/shared-types';

export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: unknown;
  };
  timestamp: string;
}

export interface RemoteConfigResolutionRequest {
  schoolSlug?: string;
  schoolId?: string;
  role?: string;
  appVersionCode?: number;
  platform: 'android' | 'web' | 'ios';
}

export interface RemoteConfigResolutionResponse {
  school: {
    id: string;
    name: string;
    slug: string;
    logo_url?: string | null;
    primary_color: string;
    secondary_color: string;
    theme_mode: 'light' | 'dark' | 'system';
  };
  featureFlags: FeatureFlagConfig;
  navigation: SDUINavigationConfig;
  screens: Record<string, SDUIScreenLayout>;
  maintenance: {
    enabled: boolean;
    message?: string;
  };
  versionControl: {
    minVersionCode: number;
    latestVersionCode: number;
    forceUpdate: boolean;
  };
}
