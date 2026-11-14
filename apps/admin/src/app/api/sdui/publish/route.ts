import { NextRequest, NextResponse } from 'next/server';
import { sduiScreenLayoutSchema } from '@sis/shared-validation';
import { createAdminClient } from '@/lib/supabase/server';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();

    // 1. Strict Schema Validation using Zod
    const validationResult = sduiScreenLayoutSchema.safeParse(body.layout);
    if (!validationResult.success) {
      return NextResponse.json(
        {
          success: false,
          error: {
            code: 'INVALID_SDUI_SCHEMA',
            message: 'Server-Driven UI layout schema validation failed',
            details: validationResult.error.format(),
          },
        },
        { status: 400 }
      );
    }

    const validatedLayout = validationResult.data;
    const schoolId = body.schoolId || null;
    const supabase = createAdminClient();

    // 2. Insert new version into configuration_versions
    const { data: versionRecord, error: insertError } = await supabase
      .from('configuration_versions')
      .insert({
        school_id: schoolId,
        config_type: 'screen_layout',
        screen_id: validatedLayout.screenId,
        version: validatedLayout.version,
        is_published: true,
        payload: validatedLayout,
        published_at: new Date().toISOString(),
        notes: body.notes || 'Published via Remote App Control Center',
      })
      .select()
      .single();

    // 3. Write Audit Log
    await supabase.from('configuration_audit_logs').insert({
      school_id: schoolId,
      action: 'publish_sdui_layout',
      entity_type: 'screen_layout',
      entity_id: validatedLayout.screenId,
      new_state: validatedLayout,
    });

    return NextResponse.json({
      success: true,
      data: {
        version: validatedLayout.version,
        screenId: validatedLayout.screenId,
        publishedAt: new Date().toISOString(),
      },
      timestamp: new Date().toISOString(),
    });
  } catch (err: any) {
    return NextResponse.json(
      {
        success: false,
        error: {
          code: 'SERVER_ERROR',
          message: err.message || 'An unexpected error occurred during publishing',
        },
      },
      { status: 500 }
    );
  }
}
