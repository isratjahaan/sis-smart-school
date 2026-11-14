import { z } from 'zod';

export const createInvoiceSchema = z.object({
  school_id: z.string().uuid(),
  student_id: z.string().uuid(),
  academic_session_id: z.string().uuid(),
  fee_category_id: z.string().uuid(),
  title: z.string().min(2).max(100),
  total_amount: z.number().positive('Total amount must be greater than 0'),
  discount_amount: z.number().min(0).default(0),
  due_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
});

export const recordPaymentSchema = z.object({
  school_id: z.string().uuid(),
  invoice_id: z.string().uuid(),
  amount: z.number().positive('Payment amount must be greater than 0'),
  payment_method: z.enum(['cash', 'bkash', 'nagad', 'rocket', 'bank_transfer', 'cheque']),
  payment_gateway_trx_id: z.string().optional().nullable(),
  receiver_number: z.string().optional().nullable(),
  sender_number: z.string().optional().nullable(),
  bank_name: z.string().optional().nullable(),
  notes: z.string().optional().nullable(),
});

export type CreateInvoiceInput = z.infer<typeof createInvoiceSchema>;
export type RecordPaymentInput = z.infer<typeof recordPaymentSchema>;
