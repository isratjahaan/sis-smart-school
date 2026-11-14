export type AttendanceStatus = 'present' | 'absent' | 'late' | 'half_day' | 'excused';

export interface StudentAttendance {
  id: string;
  school_id: string;
  student_id: string;
  academic_session_id: string;
  class_id: string;
  section_id: string;
  date: string; // "YYYY-MM-DD"
  status: AttendanceStatus;
  check_in_time?: string | null;
  remarks?: string | null;
  recorded_by?: string | null;
  created_at: string;
  updated_at: string;
}

export interface TeacherAttendance {
  id: string;
  school_id: string;
  teacher_id: string;
  date: string; // "YYYY-MM-DD"
  status: AttendanceStatus;
  check_in_time?: string | null;
  check_out_time?: string | null;
  remarks?: string | null;
  created_at: string;
  updated_at: string;
}

export interface DailyAttendanceStats {
  date: string;
  total_students: number;
  present_count: number;
  absent_count: number;
  late_count: number;
  excused_count: number;
  attendance_percentage: number;
}
