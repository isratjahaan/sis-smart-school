export interface GradingScale {
  id: string;
  school_id: string;
  name: string; // e.g. "Standard Bangladesh SSC/HSC Scale"
  min_mark: number;
  max_mark: number;
  grade_name: string; // "A+", "A", "A-", "B", "C", "D", "F"
  grade_point: number; // 5.00, 4.00, 3.50, 3.00, 2.00, 1.00, 0.00
  remarks?: string | null;
}

export interface Examination {
  id: string;
  school_id: string;
  academic_session_id: string;
  name: string; // e.g. "First Term Examination 2026", "Annual Exam"
  term: 'first_term' | 'mid_term' | 'final_term' | 'test' | 'annual';
  start_date: string;
  end_date: string;
  is_published: boolean;
  published_at?: string | null;
  created_at: string;
  updated_at: string;
}

export interface ExamSubject {
  id: string;
  school_id: string;
  examination_id: string;
  class_id: string;
  subject_id: string;
  exam_date: string;
  start_time: string;
  end_time: string;
  max_marks: number;
  pass_marks: number;
  created_at: string;
}

export interface StudentMark {
  id: string;
  school_id: string;
  examination_id: string;
  student_id: string;
  subject_id: string;
  marks_obtained: number;
  theory_marks?: number;
  practical_marks?: number;
  grade_name?: string;
  grade_point?: number;
  is_absent: boolean;
  remarks?: string | null;
  entered_by?: string | null;
  created_at: string;
  updated_at: string;
}

export interface ReportCardSummary {
  student_id: string;
  student_name: string;
  student_id_number: string;
  roll_number: number;
  class_name: string;
  section_name: string;
  total_marks: number;
  marks_obtained: number;
  percentage: number;
  gpa: number;
  final_grade: string;
  rank_in_class?: number;
  rank_in_section?: number;
  status: 'passed' | 'failed' | 'withheld';
  subject_results: Array<{
    subject_code: string;
    subject_name: string;
    marks_obtained: number;
    max_marks: number;
    grade_name: string;
    grade_point: number;
  }>;
}
