import { NextRequest, NextResponse } from 'next/server';
import { createAdminClient } from '@/lib/supabase/server';
import { SDUIScreenLayout, FeatureFlagConfig } from '@sis/shared-types';

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const schoolSlug = searchParams.get('schoolSlug') || 'dhaka-model';
  const role = searchParams.get('role') || 'student';
  const platform = searchParams.get('platform') || 'android';

  const supabase = createAdminClient();

  // 1. Resolve school metadata
  let school = {
    id: '11111111-1111-1111-1111-111111111111',
    name: 'Dhaka Model School',
    slug: 'dhaka-model',
    primary_color: '#2563EB',
    secondary_color: '#0F172A',
    theme_mode: 'light' as const,
  };

  try {
    const { data: schoolData } = await supabase
      .from('schools')
      .select('id, name, slug, school_settings (primary_color, secondary_color)')
      .eq('slug', schoolSlug)
      .single();

    if (schoolData) {
      const settings = (schoolData as any).school_settings?.[0];
      school = {
        id: schoolData.id,
        name: schoolData.name,
        slug: schoolData.slug,
        primary_color: settings?.primary_color || '#2563EB',
        secondary_color: settings?.secondary_color || '#0F172A',
        theme_mode: 'light',
      };
    }
  } catch (e) {
    // Graceful fallback to default seed tenant
  }

  // 2. Default Feature Flags
  const featureFlags: FeatureFlagConfig = {
    attendance_enabled: true,
    examinations_enabled: true,
    online_fees_enabled: true,
    library_enabled: true,
    transport_enabled: true,
    hostel_enabled: false,
    parent_messaging_enabled: true,
    live_bus_tracking: false,
    homework_submission_enabled: true,
    online_admission_enabled: true,
    sms_alerts_enabled: true,
  };

  // 3. Fallback SDUI Screen Layout for student_home
  const studentHomeLayout: SDUIScreenLayout = {
    screenId: 'student_home',
    version: 1,
    title: 'Student Dashboard',
    updatedAt: new Date().toISOString(),
    components: [
      {
        id: 'comp_welcome',
        type: 'welcome_banner',
        visible: true,
        order: 1,
        title: `Welcome to ${school.name}`,
        subtitle: 'Knowledge is Power',
      },
      {
        id: 'comp_quick_actions',
        type: 'quick_actions',
        visible: true,
        order: 2,
      },
      {
        id: 'comp_attendance',
        type: 'attendance_card',
        visible: true,
        order: 3,
      },
      {
        id: 'comp_routine',
        type: 'routine_strip',
        visible: true,
        order: 4,
      },
      {
        id: 'comp_result',
        type: 'result_card',
        visible: true,
        order: 5,
      },
      {
        id: 'comp_fees',
        type: 'fee_summary_card',
        visible: true,
        order: 6,
      },
      {
        id: 'comp_notices',
        type: 'notice_list',
        visible: true,
        order: 7,
      },
    ],
  };

  const responsePayload = {
    success: true,
    data: {
      school,
      featureFlags,
      navigation: {
        id: 'nav_default',
        role: role as any,
        version: 1,
        updated_at: new Date().toISOString(),
        items: [
          { id: '1', title: 'Home', icon: 'home', route: '/home', visible: true, order: 1 },
          { id: '2', title: 'Routine', icon: 'clock', route: '/routine', visible: true, order: 2 },
          { id: '3', title: 'Results', icon: 'award', route: '/results', visible: true, order: 3 },
          { id: '4', title: 'Fees', icon: 'credit-card', route: '/fees', visible: true, order: 4 },
          { id: '5', title: 'Profile', icon: 'user', route: '/profile', visible: true, order: 5 },
        ],
      },
      screens: {
        student_home: studentHomeLayout,
      },
      maintenance: {
        enabled: false,
        message: 'System upgrade in progress.',
      },
      versionControl: {
        minVersionCode: 1,
        latestVersionCode: 1,
        forceUpdate: false,
      },
    },
    timestamp: new Date().toISOString(),
  };

  return NextResponse.json(responsePayload);
}
