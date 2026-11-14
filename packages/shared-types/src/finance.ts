export type PaymentMethod = 'cash' | 'bkash' | 'nagad' | 'rocket' | 'bank_transfer' | 'cheque';
export type InvoiceStatus = 'unpaid' | 'paid' | 'partially_paid' | 'overdue' | 'waived';
export type TransactionStatus = 'pending' | 'completed' | 'failed' | 'refunded';

export interface FeeCategory {
  id: string;
  school_id: string;
  name: string; // e.g. "Monthly Tuition", "Admission Fee", "Exam Fee", "Library Fee"
  description?: string | null;
  created_at: string;
  updated_at: string;
}

export interface FeeStructure {
  id: string;
  school_id: string;
  academic_session_id: string;
  class_id: string;
  fee_category_id: string;
  amount: number;
  due_date_day_of_month: number; // e.g. 10th of every month
  created_at: string;
  updated_at: string;
  category?: FeeCategory;
}

export interface StudentInvoice {
  id: string;
  school_id: string;
  invoice_number: string; // e.g. "INV-2026-00001"
  student_id: string;
  academic_session_id: string;
  fee_category_id: string;
  title: string;
  total_amount: number;
  discount_amount: number;
  net_amount: number;
  paid_amount: number;
  due_amount: number;
  due_date: string;
  status: InvoiceStatus;
  created_at: string;
  updated_at: string;
}

export interface PaymentTransaction {
  id: string;
  school_id: string;
  invoice_id: string;
  transaction_number: string; // e.g. "TRX-2026-001"
  amount: number;
  payment_method: PaymentMethod;
  payment_gateway_trx_id?: string | null; // e.g. bKash TrxID "9JH3KA19"
  receiver_number?: string | null;
  sender_number?: string | null;
  bank_name?: string | null;
  status: TransactionStatus;
  notes?: string | null;
  collected_by?: string | null;
  created_at: string;
}

export interface ExpenseRecord {
  id: string;
  school_id: string;
  title: string;
  category: string; // "Salaries", "Utilities", "Maintenance", "Books & Stationery"
  amount: number;
  expense_date: string;
  payment_method: PaymentMethod;
  recipient_name?: string | null;
  invoice_receipt_url?: string | null;
  notes?: string | null;
  recorded_by?: string | null;
  created_at: string;
}
