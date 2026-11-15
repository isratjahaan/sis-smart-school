import { NextRequest, NextResponse } from 'next/server';
import { createAdminClient } from '@/lib/supabase/server';

const SAS_SCHOOL_ID = '11111111-1111-1111-1111-111111111111';

export async function GET() {
  try {
    const supabase = createAdminClient();
    const { data, error } = await supabase
      .from('teachers')
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
      teacher_id_number,
      phone,
      email,
      department = 'General',
      designation = 'Assistant Teacher',
      qualification,
      basic_salary = 30000,
    } = body;

    const supabase = createAdminClient();
    const { data, error } = await supabase
      .from('teachers')
      .insert({
        school_id: SAS_SCHOOL_ID,
        first_name,
        last_name,
        teacher_id_number: teacher_id_number || `TCH-${Math.floor(100 + Math.random() * 900)}`,
        phone,
        email,
        department,
        designation,
        qualification,
        basic_salary,
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
