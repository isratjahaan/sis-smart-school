import { NextRequest, NextResponse } from 'next/server';
import { createAdminClient } from '@/lib/supabase/server';

const SAS_SCHOOL_ID = '11111111-1111-1111-1111-111111111111';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const screenId = searchParams.get('screenId') || 'student_home';

    const supabase = createAdminClient();

    // 1. Fetch latest published screen layout
    const { data: layoutData } = await supabase
      .from('configuration_versions')
      .select('*')
      .eq('screen_id', screenId)
      .eq('is_published', true)
      .order('version', { ascending: false })
      .limit(1)
      .maybeSingle();

    // 2. Fetch latest device security state
    const { data: secData } = await supabase
      .from('configuration_versions')
      .select('*')
      .eq('screen_id', 'device_security')
      .order('version', { ascending: false })
      .limit(1)
      .maybeSingle();

    return NextResponse.json({
      success: true,
      layout: layoutData?.payload || null,
      device_security: secData?.payload || { is_locked: false },
      version: layoutData?.version || 1,
    });
  } catch (err: any) {
    return NextResponse.json({ success: false, error: err.message }, { status: 500 });
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { screenId = 'student_home', components, title = 'SAS Smart School Dashboard' } = body;

    const supabase = createAdminClient();

    // Get current version
    const { data: latest } = await supabase
      .from('configuration_versions')
      .select('version')
      .eq('screen_id', screenId)
      .order('version', { ascending: false })
      .limit(1)
      .maybeSingle();

    const nextVersion = (latest?.version || 0) + 1;

    const payload = {
      title,
      version: nextVersion,
      screenId,
      components,
      updated_at: new Date().toISOString(),
    };

    const { data: inserted, error: insertError } = await supabase
      .from('configuration_versions')
      .insert({
        school_id: null,
        config_type: 'screen_layout',
        screen_id: screenId,
        version: nextVersion,
        is_published: true,
        payload,
        published_at: new Date().toISOString(),
        notes: `Mobile Dashboard Updated from Web Admin at ${new Date().toLocaleTimeString()}`,
      })
      .select()
      .single();

    if (insertError) {
      return NextResponse.json({ success: false, error: insertError.message }, { status: 500 });
    }

    return NextResponse.json({
      success: true,
      version: nextVersion,
      data: payload,
    });
  } catch (err: any) {
    return NextResponse.json({ success: false, error: err.message }, { status: 500 });
  }
}
