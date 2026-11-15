import { NextRequest, NextResponse } from 'next/server';
import { createAdminClient } from '@/lib/supabase/server';

const SAS_SCHOOL_ID = '11111111-1111-1111-1111-111111111111';

export async function GET() {
  try {
    const supabase = createAdminClient();
    const { data, error } = await supabase
      .from('configuration_versions')
      .select('*')
      .eq('screen_id', 'device_security')
      .order('version', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (error) {
      return NextResponse.json({ success: false, error: error.message }, { status: 500 });
    }

    const payload = data?.payload || {
      is_locked: false,
      lock_message: 'Normal Operation',
      emergency_phone: '+8801711223344',
      wipe_data: false,
      updated_at: new Date().toISOString(),
    };

    return NextResponse.json({
      success: true,
      data: payload,
      version: data?.version || 1,
    });
  } catch (err: any) {
    return NextResponse.json({ success: false, error: err.message }, { status: 500 });
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { action, message, phone } = body;

    const supabase = createAdminClient();

    // Get current version
    const { data: latest } = await supabase
      .from('configuration_versions')
      .select('version')
      .eq('screen_id', 'device_security')
      .order('version', { ascending: false })
      .limit(1)
      .maybeSingle();

    const nextVersion = (latest?.version || 0) + 1;

    let isLocked = false;
    let wipeData = false;
    let lockMessage = message || 'This mobile device has been reported Lost/Stolen to SAS Smart School authority.';
    let emergencyPhone = phone || '+8801711223344';

    if (action === 'lock') {
      isLocked = true;
    } else if (action === 'unlock') {
      isLocked = false;
      lockMessage = 'Device unlocked by SAS Smart School Administrator.';
    } else if (action === 'wipe') {
      isLocked = true;
      wipeData = true;
      lockMessage = 'Device data wiped and session terminated remotely by Admin.';
    }

    const payload = {
      is_locked: isLocked,
      lock_message: lockMessage,
      emergency_phone: emergencyPhone,
      wipe_data: wipeData,
      alarm_active: isLocked,
      updated_at: new Date().toISOString(),
    };

    const { data: inserted, error: insertError } = await supabase
      .from('configuration_versions')
      .insert({
        school_id: null,
        config_type: 'screen_layout',
        screen_id: 'device_security',
        version: nextVersion,
        is_published: true,
        payload,
        published_at: new Date().toISOString(),
        notes: `Remote Anti-Theft Action: ${action.toUpperCase()}`,
      })
      .select()
      .single();

    if (insertError) {
      return NextResponse.json({ success: false, error: insertError.message }, { status: 500 });
    }

    // Write to audit log
    await supabase.from('configuration_audit_logs').insert({
      school_id: SAS_SCHOOL_ID,
      action: `device_security_${action}`,
      entity_type: 'device_security',
      entity_id: 'device_security',
      new_state: payload,
    });

    return NextResponse.json({
      success: true,
      action,
      version: nextVersion,
      data: payload,
    });
  } catch (err: any) {
    return NextResponse.json({ success: false, error: err.message }, { status: 500 });
  }
}
