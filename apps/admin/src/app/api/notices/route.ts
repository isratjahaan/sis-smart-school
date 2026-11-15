import { NextRequest, NextResponse } from 'next/server';
import { createAdminClient } from '@/lib/supabase/server';

const SAS_SCHOOL_ID = '11111111-1111-1111-1111-111111111111';

export async function GET() {
  try {
    const supabase = createAdminClient();
    const { data, error } = await supabase
      .from('notices')
      .select('*')
      .eq('school_id', SAS_SCHOOL_ID)
      .order('created_at', { ascending: false });

    if (error) {
      return NextResponse.json({ success: false, error: error.message }, { status: 500 });
    }

    return NextResponse.json({ success: true, data: data || [] });
  } catch (err: any) {
    return NextResponse.json({ success: false, error: err.message }, { status: 500 });
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { title, content, priority = 'normal', targetAudience = 'all' } = body;

    const supabase = createAdminClient();

    // 1. Insert into Supabase notices table
    const { data: notice, error: noticeErr } = await supabase
      .from('notices')
      .insert({
        school_id: SAS_SCHOOL_ID,
        title,
        content,
        priority,
        is_published: true,
      })
      .select()
      .single();

    if (noticeErr) {
      return NextResponse.json({ success: false, error: noticeErr.message }, { status: 500 });
    }

    // 2. Fetch latest published SDUI layout
    const { data: latestConfig } = await supabase
      .from('configuration_versions')
      .select('*')
      .eq('screen_id', 'student_home')
      .order('version', { ascending: false })
      .limit(1)
      .maybeSingle();

    const nextVer = (latestConfig?.version || 1) + 1;
    let payload = latestConfig?.payload;

    if (!payload || !payload.components) {
      payload = {
        title: 'SAS Smart School Dashboard',
        version: nextVer,
        screenId: 'student_home',
        components: [
          { id: 'comp_welcome', type: 'welcome_banner', title: `Notice: ${title}`, subtitle: content, visible: true, order: 1 },
          { id: 'comp_quick_actions', type: 'quick_actions', order: 2, visible: true },
          { id: 'comp_notices', type: 'notice_list', title: title, subtitle: content, order: 3, visible: true },
          { id: 'comp_attendance', type: 'attendance_card', order: 4, visible: true },
          { id: 'comp_routine', type: 'routine_strip', order: 5, visible: true },
          { id: 'comp_result', type: 'result_card', order: 6, visible: true },
          { id: 'comp_fees', type: 'fee_summary_card', order: 7, visible: true },
        ],
      };
    } else {
      // Update the notice card in components
      const updatedComps = payload.components.map((c: any) => {
        if (c.type === 'notice_list') {
          return { ...c, title, subtitle: content, visible: true };
        }
        if (c.type === 'welcome_banner') {
          return { ...c, subtitle: `Latest Notice: ${title}` };
        }
        return c;
      });
      payload = { ...payload, version: nextVer, components: updatedComps, updated_at: new Date().toISOString() };
    }

    // 3. Insert new configuration_version so mobile APK auto-updates in real time!
    await supabase.from('configuration_versions').insert({
      school_id: null,
      config_type: 'screen_layout',
      screen_id: 'student_home',
      version: nextVer,
      is_published: true,
      payload,
      notes: `Notice Published: "${title}"`,
    });

    return NextResponse.json({
      success: true,
      data: notice,
      config_version: nextVer,
    });
  } catch (err: any) {
    return NextResponse.json({ success: false, error: err.message }, { status: 500 });
  }
}
