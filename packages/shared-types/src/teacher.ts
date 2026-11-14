export interface Teacher {
  id: string;
  school_id: string;
  user_id?: string | null;
  teacher_id_number: string; // e.g. "TCH-001"
  first_name: string;
  last_name: string;
  gender: 'male' | 'female' | 'other';
  date_of_birth?: string | null;
  phone: string;
  email: string;
  qualification: string;
  designation: string; // e.g. "Senior Assistant Teacher", "Lecturer"
  department?: string | null;
  joining_date: string;
  basic_salary?: number;
  status: 'active' | 'on_leave' | 'resigned' | 'terminated';
  photo_url?: string | null;
  address?: string | null;
  created_at: string;
  updated_at: string;
}

export interface TeacherAssignment {
  id: string;
  school_id: string;
  teacher_id: string;
  class_id: string;
  section_id: string;
  subject_id: string;
  academic_session_id: string;
  is_class_teacher: boolean;
  created_at: string;
}
