import { z } from 'zod';

export const createStudentSchema = z.object({
  school_id: z.string().uuid(),
  first_name: z.string().min(1, 'First name is required').max(100),
  last_name: z.string().min(1, 'Last name is required').max(100),
  student_id_number: z.string().min(3).max(50),
  admission_number: z.string().min(1).max(50),
  admission_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be YYYY-MM-DD'),
  date_of_birth: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be YYYY-MM-DD'),
  gender: z.enum(['male', 'female', 'other']),
  blood_group: z.enum(['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']).optional().nullable(),
  religion: z.string().optional().nullable(),
  nationality: z.string().default('Bangladeshi'),
  phone: z.string().optional().nullable(),
  email: z.string().email().optional().nullable(),
  address: z.string().min(3),
  photo_url: z.string().url().optional().nullable(),
  // Enrollment details
  academic_session_id: z.string().uuid(),
  class_id: z.string().uuid(),
  section_id: z.string().uuid(),
  group_id: z.string().uuid().optional().nullable(),
  roll_number: z.number().int().min(1),
});

export const bulkStudentImportItemSchema = z.object({
  first_name: z.string().min(1),
  last_name: z.string().min(1),
  student_id_number: z.string().min(1),
  admission_number: z.string().min(1),
  roll_number: z.coerce.number().int().min(1),
  gender: z.enum(['male', 'female', 'other']),
  date_of_birth: z.string(),
  phone: z.string().optional(),
  address: z.string().min(1),
});

export type CreateStudentInput = z.infer<typeof createStudentSchema>;
