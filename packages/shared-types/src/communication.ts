import { UserRole } from './auth';

export interface Notice {
  id: string;
  school_id: string;
  title: string;
  content: string;
  target_audience: 'all' | 'students' | 'parents' | 'teachers' | 'staff';
  target_class_id?: string | null;
  priority: 'low' | 'normal' | 'high' | 'urgent';
  attachment_url?: string | null;
  is_published: boolean;
  published_at?: string | null;
  author_id?: string | null;
  created_at: string;
  updated_at: string;
}

export interface NotificationItem {
  id: string;
  school_id?: string | null;
  recipient_user_id: string;
  title: string;
  body: string;
  type: 'attendance' | 'exam_result' | 'fee_due' | 'notice' | 'system' | 'homework';
  data_payload?: Record<string, unknown> | null;
  is_read: boolean;
  read_at?: string | null;
  created_at: string;
}

export interface LeaveApplication {
  id: string;
  school_id: string;
  applicant_user_id: string;
  applicant_role: UserRole;
  student_id?: string | null; // if applied on behalf of a student by parent or student
  teacher_id?: string | null;
  leave_type: 'sick' | 'casual' | 'emergency' | 'maternity' | 'other';
  start_date: string;
  end_date: string;
  days_count: number;
  reason: string;
  attachment_url?: string | null;
  status: 'pending' | 'approved' | 'rejected';
  reviewed_by?: string | null;
  reviewed_at?: string | null;
  reviewer_comments?: string | null;
  created_at: string;
  updated_at: string;
}

export interface Homework {
  id: string;
  school_id: string;
  academic_session_id: string;
  class_id: string;
  section_id: string;
  subject_id: string;
  teacher_id: string;
  title: string;
  description: string;
  submission_deadline: string;
  attachment_url?: string | null;
  created_at: string;
  updated_at: string;
}

export interface HomeworkSubmission {
  id: string;
  school_id: string;
  homework_id: string;
  student_id: string;
  submission_text?: string | null;
  file_url?: string | null;
  submitted_at: string;
  status: 'submitted' | 'late' | 'evaluated' | 'resubmit';
  marks_obtained?: number | null;
  teacher_feedback?: string | null;
  evaluated_at?: string | null;
}
