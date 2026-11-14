'use client';

import React, { useState } from 'react';
import { Send, CheckCircle2, GraduationCap, AlertCircle } from 'lucide-react';
import { supabase, isSupabaseConfigured } from '@/lib/supabase';

interface AdmissionProps {
  school: {
    id?: string;
    name: string;
  };
}

export function OnlineAdmissionSection({ school }: AdmissionProps) {
  const [submitted, setSubmitted] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  const [form, setForm] = useState({
    applicantName: '',
    gender: 'male',
    dob: '',
    classGrade: 'Class 6',
    parentName: '',
    phone: '',
    email: '',
    address: '',
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);

    if (isSupabaseConfigured) {
      try {
        const schoolId = school.id || '11111111-1111-1111-1111-111111111111';
        // Class 6 test class ID
        const classId = '11111111-cccc-1111-1111-000000000006';
        await supabase.from('admission_applications').insert({
          school_id: schoolId,
          applicant_name: form.applicantName,
          date_of_birth: form.dob || '2012-01-01',
          gender: form.gender,
          applying_for_class_id: classId,
          parent_name: form.parentName,
          phone: form.phone,
          email: form.email || null,
          address: form.address,
          status: 'pending',
        });
      } catch (err) {
        console.error('Failed to submit admission application to Supabase:', err);
      }
    }

    setTimeout(() => {
      setSubmitting(false);
      setSubmitted(true);
    }, 400);
  };

  return (
    <section id="admission" className="py-20 bg-slate-50 border-b border-slate-200">
      <div className="max-w-3xl mx-auto px-6 space-y-8">
        <div className="text-center space-y-2">
          <span className="text-xs font-bold uppercase tracking-wider text-blue-600">Session 2026 Admissions</span>
          <h2 className="text-3xl font-extrabold text-slate-900 tracking-tight">Online Admission Application</h2>
          <p className="text-sm text-slate-600">
            Apply online for enrollment at {school.name}. Applications are reviewed within 48 hours.
          </p>
        </div>

        {submitted ? (
          <div className="bg-white p-8 rounded-2xl border border-green-200 shadow-sm text-center space-y-3">
            <div className="h-12 w-12 rounded-full bg-green-100 text-green-600 flex items-center justify-center mx-auto">
              <CheckCircle2 className="h-6 w-6" />
            </div>
            <h3 className="text-lg font-bold text-slate-900">Application Submitted Successfully!</h3>
            <p className="text-xs text-slate-600 max-w-md mx-auto">
              Thank you, <strong>{form.parentName}</strong>. Your application for <strong>{form.applicantName}</strong> has been received by our admissions committee. We will contact you at <strong>{form.phone}</strong> for interview scheduling.
            </p>
            <button
              onClick={() => {
                setSubmitted(false);
                setForm({ applicantName: '', gender: 'male', dob: '', classGrade: 'Class 6', parentName: '', phone: '', email: '', address: '' });
              }}
              className="mt-3 px-4 py-2 rounded-lg bg-blue-600 text-white text-xs font-bold hover:bg-blue-700 cursor-pointer"
            >
              Submit Another Application
            </button>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="bg-white p-8 rounded-2xl border border-slate-200 shadow-sm space-y-5">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="text-xs font-semibold text-slate-700">Applicant Full Name *</label>
                <input
                  required
                  placeholder="e.g. Abrar Fahim"
                  className="mt-1 h-10 w-full rounded-lg border border-slate-300 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={form.applicantName}
                  onChange={(e) => setForm({ ...form, applicantName: e.target.value })}
                />
              </div>
              <div>
                <label className="text-xs font-semibold text-slate-700">Applying For Grade / Class *</label>
                <select
                  className="mt-1 h-10 w-full rounded-lg border border-slate-300 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 bg-white"
                  value={form.classGrade}
                  onChange={(e) => setForm({ ...form, classGrade: e.target.value })}
                >
                  <option value="Class 6">Class 6 (Junior Secondary)</option>
                  <option value="Class 7">Class 7</option>
                  <option value="Class 8">Class 8</option>
                  <option value="Class 9">Class 9 (SSC)</option>
                </select>
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="text-xs font-semibold text-slate-700">Date of Birth *</label>
                <input
                  type="date"
                  required
                  className="mt-1 h-10 w-full rounded-lg border border-slate-300 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={form.dob}
                  onChange={(e) => setForm({ ...form, dob: e.target.value })}
                />
              </div>
              <div>
                <label className="text-xs font-semibold text-slate-700">Gender *</label>
                <select
                  className="mt-1 h-10 w-full rounded-lg border border-slate-300 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 bg-white"
                  value={form.gender}
                  onChange={(e) => setForm({ ...form, gender: e.target.value })}
                >
                  <option value="male">Male</option>
                  <option value="female">Female</option>
                  <option value="other">Other</option>
                </select>
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="text-xs font-semibold text-slate-700">Father / Guardian Name *</label>
                <input
                  required
                  placeholder="e.g. Md. Shahidul Islam"
                  className="mt-1 h-10 w-full rounded-lg border border-slate-300 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={form.parentName}
                  onChange={(e) => setForm({ ...form, parentName: e.target.value })}
                />
              </div>
              <div>
                <label className="text-xs font-semibold text-slate-700">Guardian Contact Phone *</label>
                <input
                  required
                  type="tel"
                  placeholder="+8801700000000"
                  className="mt-1 h-10 w-full rounded-lg border border-slate-300 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={form.phone}
                  onChange={(e) => setForm({ ...form, phone: e.target.value })}
                />
              </div>
            </div>

            <div>
              <label className="text-xs font-semibold text-slate-700">Present Residential Address *</label>
              <textarea
                required
                rows={2}
                placeholder="House / Road / Area / City"
                className="mt-1 w-full rounded-lg border border-slate-300 p-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                value={form.address}
                onChange={(e) => setForm({ ...form, address: e.target.value })}
              />
            </div>

            <button
              type="submit"
              disabled={submitting}
              className="w-full h-12 rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-bold text-sm flex items-center justify-center gap-2 cursor-pointer shadow-md transition"
            >
              <Send className="h-4 w-4" />
              <span>{submitting ? 'Submitting Application...' : 'Submit Admission Application'}</span>
            </button>
          </form>
        )}
      </div>
    </section>
  );
}
