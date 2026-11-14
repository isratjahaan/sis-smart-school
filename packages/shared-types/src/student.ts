import { Profile } from './auth';

export type Gender = 'male' | 'female' | 'other';
export type BloodGroup = 'A+' | 'A-' | 'B+' | 'B-' | 'AB+' | 'AB-' | 'O+' | 'O-';

export interface Student {
  id: string;
  school_id: string;
  user_id?: string | null;
  student_id_number: string; // School-specific unique student ID code, e.g. "DMS-2026-001"
  admission_number: string;
  admission_date: string;
  first_name: string;
  last_name: string;
  date_of_birth: string;
  gender: Gender;
  blood_group?: BloodGroup | null;
  religion?: string | null;
  nationality: string;
  phone?: string | null;
  email?: string | null;
  address: string;
  photo_url?: string | null;
  status: 'active' | 'graduated' | 'transferred' | 'suspended';
  created_at: string;
  updated_at: string;
}

export interface StudentEnrollment {
  id: string;
  school_id: string;
  student_id: string;
  academic_session_id: string;
  class_id: string;
  section_id: string;
  group_id?: string | null;
  roll_number: number;
  is_active: boolean;
  student?: Student;
  created_at: string;
  updated_at: string;
}

export interface Parent {
  id: string;
  school_id: string;
  user_id?: string | null;
  first_name: string;
  last_name: string;
  relationship: 'father' | 'mother' | 'guardian';
  occupation?: string | null;
  phone: string;
  email?: string | null;
  address?: string | null;
  nid_number?: string | null;
  photo_url?: string | null;
  created_at: string;
  updated_at: string;
}

export interface ParentStudentRelationship {
  id: string;
  school_id: string;
  parent_id: string;
  student_id: string;
  is_primary_contact: boolean;
  can_pickup: boolean;
  parent?: Parent;
  student?: Student;
  created_at: string;
}

export interface StudentDocument {
  id: string;
  school_id: string;
  student_id: string;
  title: string;
  document_type: 'birth_certificate' | 'transfer_certificate' | 'previous_marksheet' | 'medical_record' | 'other';
  file_url: string;
  file_size_bytes?: number;
  mime_type?: string;
  created_at: string;
}
