export interface AcademicSession {
  id: string;
  school_id: string;
  name: string; // e.g. "2026-2027" or "2026"
  start_date: string;
  end_date: string;
  is_current: boolean;
  created_at: string;
  updated_at: string;
}

export interface ClassItem {
  id: string;
  school_id: string;
  name: string; // e.g. "Class 6", "Class 10"
  numeric_grade: number; // e.g. 6, 10
  description?: string | null;
  created_at: string;
  updated_at: string;
}

export interface Section {
  id: string;
  school_id: string;
  class_id: string;
  name: string; // e.g. "Section A", "Padma", "Meghna"
  capacity: number;
  room_number?: string | null;
  created_at: string;
  updated_at: string;
}

export interface GroupItem {
  id: string;
  school_id: string;
  name: string; // e.g. "Science", "Commerce", "Humanities", "General"
  description?: string | null;
  created_at: string;
  updated_at: string;
}

export interface Subject {
  id: string;
  school_id: string;
  name: string;
  code: string; // e.g. "MATH-101", "BAN-101"
  type: 'theory' | 'practical' | 'both';
  total_marks: number;
  pass_marks: number;
  created_at: string;
  updated_at: string;
}

export interface ClassSubject {
  id: string;
  school_id: string;
  class_id: string;
  subject_id: string;
  is_optional: boolean;
  credit_hours?: number;
  subject?: Subject;
  created_at: string;
  updated_at: string;
}

export interface ClassRoutine {
  id: string;
  school_id: string;
  academic_session_id: string;
  class_id: string;
  section_id: string;
  subject_id: string;
  teacher_id?: string | null;
  day_of_week: 'Sunday' | 'Monday' | 'Tuesday' | 'Wednesday' | 'Thursday' | 'Friday' | 'Saturday';
  start_time: string; // "09:00:00"
  end_time: string;   // "09:45:00"
  room_no?: string | null;
  created_at: string;
  updated_at: string;
}
