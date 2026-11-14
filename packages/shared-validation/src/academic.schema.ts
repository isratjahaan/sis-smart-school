import { z } from 'zod';

export const attendanceSubmissionSchema = z.object({
  school_id: z.string().uuid(),
  academic_session_id: z.string().uuid(),
  class_id: z.string().uuid(),
  section_id: z.string().uuid(),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  records: z.array(
    z.object({
      student_id: z.string().uuid(),
      status: z.enum(['present', 'absent', 'late', 'half_day', 'excused']),
      remarks: z.string().optional().nullable(),
    })
  ).min(1, 'At least one student attendance record is required'),
});

export const marksEntrySubmissionSchema = z.object({
  school_id: z.string().uuid(),
  examination_id: z.string().uuid(),
  subject_id: z.string().uuid(),
  marks: z.array(
    z.object({
      student_id: z.string().uuid(),
      marks_obtained: z.number().min(0).max(100),
      is_absent: z.boolean().default(false),
      remarks: z.string().optional().nullable(),
    })
  ).min(1, 'At least one student mark must be submitted'),
});

export type AttendanceSubmissionInput = z.infer<typeof attendanceSubmissionSchema>;
export type MarksEntrySubmissionInput = z.infer<typeof marksEntrySubmissionSchema>;
