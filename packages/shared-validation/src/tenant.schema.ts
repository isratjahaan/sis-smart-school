import { z } from 'zod';

export const createSchoolSchema = z.object({
  name: z.string().min(3, 'School name must be at least 3 characters').max(150),
  slug: z.string().min(2).max(50).regex(/^[a-z0-9-]+$/, 'Slug must only contain lowercase alphanumeric and dashes'),
  code: z.string().min(2).max(20).toUpperCase(),
  email: z.string().email('Invalid school email address'),
  phone: z.string().min(7).max(20),
  address: z.string().min(5),
  city: z.string().optional(),
  country: z.string().default('Bangladesh'),
  logo_url: z.string().url().optional().nullable(),
  established_year: z.number().int().min(1800).max(2100).optional(),
  principal_name: z.string().optional(),
});

export const updateSchoolSettingsSchema = z.object({
  timezone: z.string().default('Asia/Dhaka'),
  currency: z.string().default('BDT'),
  currency_symbol: z.string().default('৳'),
  date_format: z.string().default('YYYY-MM-DD'),
  primary_color: z.string().regex(/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/, 'Must be a valid hex color'),
  secondary_color: z.string().regex(/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/),
  payment_bkash_number: z.string().max(20).optional().nullable(),
  payment_nagad_number: z.string().max(20).optional().nullable(),
  payment_rocket_number: z.string().max(20).optional().nullable(),
  attendance_type: z.enum(['daily', 'subject_wise']).default('daily'),
  auto_sms_absent: z.boolean().default(false),
  online_admission_enabled: z.boolean().default(true),
});

export type CreateSchoolInput = z.infer<typeof createSchoolSchema>;
export type UpdateSchoolSettingsInput = z.infer<typeof updateSchoolSettingsSchema>;
