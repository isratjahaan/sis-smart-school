'use client';

import React, { useState } from 'react';
import { Award, Search, CheckCircle, FileText, Printer, ArrowRight } from 'lucide-react';

export function ResultCheckerSection() {
  const [studentId, setStudentId] = useState('SAS-2026-001');
  const [examName, setExamName] = useState('First Term Examination 2026');
  const [result, setResult] = useState<any>(null);
  const [searched, setSearched] = useState(false);

  const sampleResults: Record<string, any> = {
    'SAS-2026-001': {
      studentName: 'Tahmid Rahman',
      roll: 1,
      class: 'Class 10 (Section A)',
      gpa: 5.0,
      grade: 'A+',
      status: 'Passed',
      subjects: [
        { name: 'Bangla 1st Paper', marks: 88, grade: 'A+', point: '5.00' },
        { name: 'English 1st Paper', marks: 84, grade: 'A+', point: '5.00' },
        { name: 'General Mathematics', marks: 95, grade: 'A+', point: '5.00' },
        { name: 'General Science', marks: 91, grade: 'A+', point: '5.00' },
      ],
    },
    'SAS-2026-002': {
      studentName: 'Samia Chowdhury',
      roll: 2,
      class: 'Class 10 (Section A)',
      gpa: 4.85,
      grade: 'A',
      status: 'Passed',
      subjects: [
        { name: 'Bangla 1st Paper', marks: 78, grade: 'A', point: '4.00' },
        { name: 'English 1st Paper', marks: 82, grade: 'A+', point: '5.00' },
        { name: 'General Mathematics', marks: 88, grade: 'A+', point: '5.00' },
        { name: 'General Science', marks: 85, grade: 'A+', point: '5.00' },
      ],
    },
  };

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    setSearched(true);
    const found = sampleResults[studentId.trim().toUpperCase()];
    setResult(found || null);
  };

  return (
    <section id="results" className="py-20 bg-slate-900 text-white border-b border-slate-800">
      <div className="max-w-4xl mx-auto px-6 space-y-8">
        <div className="text-center space-y-2">
          <span className="text-xs font-bold uppercase tracking-wider text-blue-400">Online Examination Portal</span>
          <h2 className="text-3xl font-extrabold tracking-tight">Check Student Report Card & GPA</h2>
          <p className="text-sm text-slate-400">
            Enter your official Student ID to instantly inspect term examination results
          </p>
        </div>

        {/* Search Box */}
        <form onSubmit={handleSearch} className="bg-slate-800/90 p-4 rounded-2xl border border-slate-700 shadow-xl flex flex-col sm:flex-row gap-3">
          <div className="flex-1">
            <input
              type="text"
              required
              placeholder="e.g. SAS-2026-001"
              className="w-full h-12 bg-slate-900 rounded-xl px-4 text-sm font-mono text-white placeholder:text-slate-500 border border-slate-700 focus:outline-none focus:ring-2 focus:ring-blue-500 uppercase"
              value={studentId}
              onChange={(e) => setStudentId(e.target.value)}
            />
          </div>
          <button
            type="submit"
            className="h-12 px-6 rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-bold text-sm flex items-center justify-center gap-2 cursor-pointer shadow-md transition"
          >
            <Search className="h-4 w-4" />
            <span>Search Result</span>
          </button>
        </form>

        {/* Result Card Preview */}
        {searched && result && (
          <div className="bg-white text-slate-900 rounded-2xl p-6 sm:p-8 shadow-2xl border border-slate-200 space-y-6 animate-in fade-in zoom-in-95">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between pb-4 border-b border-slate-100 gap-2">
              <div>
                <p className="text-xs font-bold text-blue-600 uppercase">First Term Examination 2026</p>
                <h3 className="text-xl font-bold text-slate-900">{result.studentName}</h3>
                <p className="text-xs text-slate-500 font-mono mt-0.5">
                  ID: {studentId.toUpperCase()} • {result.class} • Roll #{result.roll}
                </p>
              </div>
              <div className="text-right">
                <span className="text-3xl font-black text-blue-600">GPA {result.gpa.toFixed(2)}</span>
                <p className="text-xs font-bold text-green-600">Grade: {result.grade} ({result.status})</p>
              </div>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-slate-50 text-slate-500 uppercase font-bold border-b border-slate-100">
                  <tr>
                    <th className="p-3">Subject</th>
                    <th className="p-3 text-center">Marks Obtained</th>
                    <th className="p-3 text-center">Letter Grade</th>
                    <th className="p-3 text-right">Grade Point</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 font-medium">
                  {result.subjects.map((s: any, idx: number) => (
                    <tr key={idx}>
                      <td className="p-3 font-semibold text-slate-800">{s.name}</td>
                      <td className="p-3 text-center font-bold">{s.marks}</td>
                      <td className="p-3 text-center font-bold text-blue-600">{s.grade}</td>
                      <td className="p-3 text-right font-mono">{s.point}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            <div className="pt-2 flex justify-between items-center text-xs text-slate-400">
              <span>Verified by Central Examination Controller</span>
              <button
                onClick={() => window.print()}
                className="text-blue-600 font-semibold hover:underline flex items-center gap-1 cursor-pointer"
              >
                <Printer className="h-3.5 w-3.5" /> Print Transcript
              </button>
            </div>
          </div>
        )}

        {searched && !result && (
          <div className="p-6 rounded-2xl bg-slate-800/60 border border-slate-700 text-center text-slate-300 text-sm">
            No academic records found for ID <strong className="font-mono text-white">{studentId}</strong>. Please ensure you entered the exact student ID code.
          </div>
        )}
      </div>
    </section>
  );
}
