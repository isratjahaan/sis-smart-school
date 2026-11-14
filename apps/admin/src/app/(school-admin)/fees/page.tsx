'use client';

import React, { useState } from 'react';
import {
  CreditCard,
  Plus,
  CheckCircle,
  Clock,
  AlertCircle,
  Search,
  Filter,
  DollarSign,
  Download,
  Building2,
  Smartphone,
} from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { formatCurrency } from '@/lib/utils';
import { supabase, isSupabaseConfigured } from '@/lib/supabase/client';

export default function FeesPage() {
  const [filterStatus, setFilterStatus] = useState('All');
  const [showPaymentModal, setShowPaymentModal] = useState(false);
  const [selectedInvoice, setSelectedInvoice] = useState<any>(null);
  const [savingPayment, setSavingPayment] = useState(false);

  // Manual payment form
  const [paymentForm, setPaymentForm] = useState({
    amount: '',
    method: 'bkash',
    trxId: '',
    senderNumber: '',
    receiverNumber: '01711223344',
    notes: '',
  });

  const [invoices, setInvoices] = useState([
    {
      id: '11111111-6666-2222-1111-000000000001',
      invoiceNumber: 'INV-SAS-2026-0001',
      studentName: 'Tahmid Rahman',
      roll: 1,
      studentId: 'SAS-2026-001',
      title: 'January 2026 Tuition Fee',
      category: 'Monthly Tuition Fee',
      totalAmount: 2500,
      paidAmount: 2500,
      dueAmount: 0,
      dueDate: '2026-01-15',
      status: 'paid',
    },
    {
      id: '11111111-6666-2222-1111-000000000002',
      invoiceNumber: 'INV-SAS-2026-0002',
      studentName: 'Tahmid Rahman',
      roll: 1,
      studentId: 'SAS-2026-001',
      title: 'February 2026 Tuition Fee',
      category: 'Monthly Tuition Fee',
      totalAmount: 2500,
      paidAmount: 0,
      dueAmount: 2500,
      dueDate: '2026-02-15',
      status: 'unpaid',
    },
    {
      id: '11111111-6666-2222-1111-000000000003',
      invoiceNumber: 'INV-SAS-2026-0003',
      studentName: 'Samia Chowdhury',
      roll: 2,
      studentId: 'SAS-2026-002',
      title: 'January 2026 Tuition Fee',
      category: 'Monthly Tuition Fee',
      totalAmount: 2500,
      paidAmount: 2500,
      dueAmount: 0,
      dueDate: '2026-01-15',
      status: 'paid',
    },
  ]);

  const openPaymentModal = (invoice: any) => {
    setSelectedInvoice(invoice);
    setPaymentForm({
      amount: String(invoice.dueAmount),
      method: 'bkash',
      trxId: '',
      senderNumber: '',
      receiverNumber: '01711223344',
      notes: `Fee collection for ${invoice.invoiceNumber}`,
    });
    setShowPaymentModal(true);
  };

  const handleRecordPayment = async (e: React.FormEvent) => {
    e.preventDefault();
    setSavingPayment(true);

    const paidVal = Number(paymentForm.amount);
    const updatedInvoices = invoices.map((inv) => {
      if (inv.id === selectedInvoice.id) {
        const newPaid = inv.paidAmount + paidVal;
        const newDue = Math.max(0, inv.totalAmount - newPaid);
        return {
          ...inv,
          paidAmount: newPaid,
          dueAmount: newDue,
          status: newDue === 0 ? 'paid' : 'partially_paid',
        };
      }
      return inv;
    });

    if (isSupabaseConfigured) {
      try {
        const schoolId = '11111111-1111-1111-1111-111111111111';
        await supabase.from('payment_transactions').insert({
          school_id: schoolId,
          invoice_id: selectedInvoice.id,
          transaction_number: `TRX-${Date.now()}`,
          amount: paidVal,
          payment_method: paymentForm.method,
          payment_gateway_trx_id: paymentForm.trxId || null,
          receiver_number: paymentForm.receiverNumber || null,
          sender_number: paymentForm.senderNumber || null,
          status: 'completed',
          notes: paymentForm.notes || null,
        });
      } catch (err) {
        console.error('Failed to save payment transaction in Supabase:', err);
      }
    }

    setInvoices(updatedInvoices);
    setSavingPayment(false);
    setShowPaymentModal(false);
  };

  const filteredInvoices = invoices.filter((inv) => {
    if (filterStatus === 'All') return true;
    return inv.status === filterStatus.toLowerCase();
  });

  const totalCollected = invoices.reduce((acc, i) => acc + i.paidAmount, 0);
  const totalPending = invoices.reduce((acc, i) => acc + i.dueAmount, 0);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">Fee & Accounts Portal</h1>
          <p className="text-sm text-slate-500">
            Manage fee structures, student invoices, and manual verification for bKash, Nagad, Rocket & Cash
          </p>
        </div>
        <div className="flex items-center gap-3">
          <Button variant="outline" className="gap-2">
            <Download className="h-4 w-4" />
            <span>Export Statement</span>
          </Button>
          <Button className="bg-blue-600 hover:bg-blue-700 gap-2">
            <Plus className="h-4 w-4" />
            <span>Generate Invoices</span>
          </Button>
        </div>
      </div>

      {/* Summary KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-5">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-xs font-semibold text-slate-500 uppercase">Total Collected (YTD)</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">{formatCurrency(totalCollected)}</div>
            <p className="text-xs text-slate-500 mt-1">From verified transactions</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-xs font-semibold text-slate-500 uppercase">Outstanding Dues</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-red-600">{formatCurrency(totalPending)}</div>
            <p className="text-xs text-slate-500 mt-1">Pending student clearance</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-xs font-semibold text-slate-500 uppercase">Payment Channels</CardTitle>
          </CardHeader>
          <CardContent className="space-y-1 text-xs font-medium text-slate-700">
            <div className="flex items-center justify-between">
              <span className="flex items-center gap-1.5"><Smartphone className="h-3.5 w-3.5 text-pink-600" /> bKash Merchant:</span>
              <span className="font-mono font-semibold">01711223344</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="flex items-center gap-1.5"><Smartphone className="h-3.5 w-3.5 text-orange-600" /> Nagad Merchant:</span>
              <span className="font-mono font-semibold">01811223344</span>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Invoices List */}
      <Card>
        <CardHeader className="p-4 border-b border-slate-100 flex flex-row items-center justify-between">
          <CardTitle className="text-base">Student Invoices</CardTitle>
          <div className="flex items-center gap-2">
            {['All', 'Paid', 'Unpaid'].map((status) => (
              <button
                key={status}
                onClick={() => setFilterStatus(status)}
                className={`px-3 py-1 rounded-lg text-xs font-semibold transition cursor-pointer ${
                  filterStatus === status
                    ? 'bg-blue-600 text-white'
                    : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                }`}
              >
                {status}
              </button>
            ))}
          </div>
        </CardHeader>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-slate-600">
            <thead className="bg-slate-50 border-b border-slate-200 text-xs uppercase font-semibold text-slate-500">
              <tr>
                <th className="p-4">Invoice #</th>
                <th className="p-4">Student</th>
                <th className="p-4">Fee Title</th>
                <th className="p-4 text-right">Amount</th>
                <th className="p-4 text-right">Paid</th>
                <th className="p-4 text-right">Due</th>
                <th className="p-4">Due Date</th>
                <th className="p-4 text-center">Status</th>
                <th className="p-4 text-right">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 font-medium">
              {filteredInvoices.map((inv) => (
                <tr key={inv.id} className="hover:bg-slate-50/70 transition">
                  <td className="p-4 font-mono text-xs text-blue-600 font-bold">{inv.invoiceNumber}</td>
                  <td className="p-4">
                    <p className="text-slate-900 font-semibold">{inv.studentName}</p>
                    <p className="text-xs text-slate-400 font-mono">Roll #{inv.roll} • {inv.studentId}</p>
                  </td>
                  <td className="p-4 text-slate-800">{inv.title}</td>
                  <td className="p-4 text-right font-semibold text-slate-900">{formatCurrency(inv.totalAmount)}</td>
                  <td className="p-4 text-right text-green-600 font-semibold">{formatCurrency(inv.paidAmount)}</td>
                  <td className="p-4 text-right text-red-600 font-semibold">{formatCurrency(inv.dueAmount)}</td>
                  <td className="p-4 text-xs text-slate-500">{inv.dueDate}</td>
                  <td className="p-4 text-center">
                    <Badge variant={inv.status === 'paid' ? 'success' : 'destructive'} className="capitalize">
                      {inv.status}
                    </Badge>
                  </td>
                  <td className="p-4 text-right">
                    {inv.status !== 'paid' ? (
                      <Button
                        size="sm"
                        onClick={() => openPaymentModal(inv)}
                        className="bg-emerald-600 hover:bg-emerald-700 text-xs gap-1"
                      >
                        <CreditCard className="h-3.5 w-3.5" />
                        <span>Record Payment</span>
                      </Button>
                    ) : (
                      <span className="text-xs text-green-600 font-semibold flex items-center justify-end gap-1">
                        <CheckCircle className="h-3.5 w-3.5" /> Settled
                      </span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>

      {/* Manual Payment Recording Modal */}
      {showPaymentModal && selectedInvoice && (
        <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl border border-slate-200 space-y-5 animate-in fade-in zoom-in-95">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100">
              <h3 className="font-bold text-lg text-slate-900">Record Fee Payment</h3>
              <button
                onClick={() => setShowPaymentModal(false)}
                className="text-slate-400 hover:text-slate-600 text-lg font-bold"
              >
                ✕
              </button>
            </div>

            <div className="p-3 bg-slate-50 rounded-xl text-xs space-y-1">
              <p className="text-slate-500">Invoice: <strong className="text-slate-900 font-mono">{selectedInvoice.invoiceNumber}</strong></p>
              <p className="text-slate-500">Student: <strong className="text-slate-900">{selectedInvoice.studentName}</strong></p>
              <p className="text-slate-500">Outstanding Due: <strong className="text-red-600 font-bold">{formatCurrency(selectedInvoice.dueAmount)}</strong></p>
            </div>

            <form onSubmit={handleRecordPayment} className="space-y-4">
              <div>
                <label className="text-xs font-semibold text-slate-600">Payment Amount (৳) *</label>
                <Input
                  required
                  type="number"
                  value={paymentForm.amount}
                  onChange={(e) => setPaymentForm({ ...paymentForm, amount: e.target.value })}
                />
              </div>

              <div>
                <label className="text-xs font-semibold text-slate-600">Payment Channel *</label>
                <select
                  className="h-10 w-full rounded-lg border border-slate-300 bg-white px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={paymentForm.method}
                  onChange={(e) => setPaymentForm({ ...paymentForm, method: e.target.value })}
                >
                  <option value="bkash">bKash Mobile Wallet</option>
                  <option value="nagad">Nagad Mobile Wallet</option>
                  <option value="rocket">Rocket Mobile Banking</option>
                  <option value="cash">Direct Cash</option>
                  <option value="bank_transfer">Bank Deposit / Cheque</option>
                </select>
              </div>

              {paymentForm.method !== 'cash' && (
                <>
                  <div>
                    <label className="text-xs font-semibold text-slate-600">Transaction ID (TrxID) *</label>
                    <Input
                      required
                      placeholder="e.g. 9JH3KA19"
                      value={paymentForm.trxId}
                      onChange={(e) => setPaymentForm({ ...paymentForm, trxId: e.target.value })}
                    />
                  </div>
                  <div>
                    <label className="text-xs font-semibold text-slate-600">Sender Mobile / Account Number</label>
                    <Input
                      placeholder="e.g. 01700000000"
                      value={paymentForm.senderNumber}
                      onChange={(e) => setPaymentForm({ ...paymentForm, senderNumber: e.target.value })}
                    />
                  </div>
                </>
              )}

              <div className="flex items-center justify-end gap-3 pt-3 border-t border-slate-100">
                <Button type="button" variant="outline" onClick={() => setShowPaymentModal(false)}>
                  Cancel
                </Button>
                <Button type="submit" disabled={savingPayment} className="bg-emerald-600 hover:bg-emerald-700">
                  {savingPayment ? 'Verifying...' : 'Confirm & Settle Payment'}
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
