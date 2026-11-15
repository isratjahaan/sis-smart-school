import { NextRequest, NextResponse } from 'next/server';
import { createAdminClient } from '@/lib/supabase/server';

const SAS_SCHOOL_ID = '11111111-1111-1111-1111-111111111111';

export async function GET() {
  try {
    const supabase = createAdminClient();
    const { data, error } = await supabase
      .from('students')
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
    const {
      first_name,
      last_name,
      student_id_number,
      admission_number,
      gender = 'male',
      phone,
      address,
    } = body;

    const supabase = createAdminClient();
    const { data, error } = await supabase
      .from('students')
      .insert({
        school_id: SAS_SCHOOL_ID,
        first_name,
        last_name,
        student_id_number: student_id_number || `SAS-2026-${Math.floor(100 + Math.random() * 900)}`,
        admission_number: admission_number || `ADM-${Math.floor(1000 + Math.random() * 9000)}`,
        gender,
        phone,
        address,
        status: 'active',
      })
      .select()
      .single();

    if (error) {
      return NextResponse.json({ success: false, error: error.message }, { status: 500 });
    }

    return NextResponse.json({ success: true, data });
  } catch (err: any) {
    return NextResponse.json({ success: false, error: err.message }, { status: 500 });
  }
}
