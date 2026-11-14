'use client';

import React, { useState } from 'react';
import {
  Award,
  BookOpen,
  CheckCircle,
  FileText,
  Printer,
  Sparkles,
  TrendingUp,
} from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';

export default function ExaminationsPage() {
  const [selectedExam, setSelectedExam] = useState('First Term Examination 2026');
  const [selectedStudent, setSelectedStudent] = useState<any>(null);
  const [showReportCardModal, setShowReportCardModal] = useState(false);

  // Student Examination Results and Marks
  const [studentsMarks, setStudentsMarks] = useState([
    {
      id: '1',
      studentId: '11111111-9999-1111-1111-000000000001',
      roll: 1,
      idNumber: 'SAS-2026-001',
      name: 'Tahmid Rahman',
      bangla: 88,
      english: 84,
      math: 95,
      science: 91,
      gpa: 5.0,
      grade: 'A+',
      status: 'Passed',
    },
    {
      id: '2',
      studentId: '11111111-9999-1111-1111-000000000002',
      roll: 2,
      idNumber: 'SAS-2026-002',
      name: 'Samia Chowdhury',
      bangla: 78,
      english: 82,
      math: 88,
      science: 85,
      gpa: 4.85,
      grade: 'A',
      status: 'Passed',
    },
    {
      id: '3',
      studentId: '11111111-9999-1111-1111-000000000003',
      roll: 3,
      idNumber: 'SAS-2026-003',
      name: 'Nafis Iqbal',
      bangla: 62,
      english: 55,
      math: 70,
      science: 65,
      gpa: 3.4,
      grade: 'B',
      status: 'Passed',
    },
  ]);

  const openReportCard = (student: any) => {
    setSelectedStudent(student);
    setShowReportCardModal(true);
  };

  return (
    <div className="space-y-6">
      {/* Page Title & Controls */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">
            Examinations & Academic Grading
          </h1>
          <p className="text-sm text-slate-500">
            Configure terms, enter subject marks, calculate Bangladesh GPA, and publish official report cards
          </p>
        </div>
        <div className="flex items-center gap-3">
          <Badge variant="success" className="px-3 py-1 text-xs">
            Grading Scale: Bangladesh SSC/HSC (5.00 Max)
          </Badge>
          <Button className="bg-blue-600 hover:bg-blue-700 gap-2">
            <Award className="h-4 w-4" />
            <span>Create New Exam</span>
          </Button>
        </div>
      </div>

      {/* Exam Selector and Summary Card */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card className="lg:col-span-2">
          <CardHeader>
            <div className="flex items-center justify-between">
              <div>
                <CardTitle>First Term Examination 2026</CardTitle>
                <CardDescription>Published on April 30, 2026 • Target: Class 6 to 10</CardDescription>
              </div>
              <Badge variant="success">Results Published</Badge>
            </div>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-4 gap-4 p-4 rounded-xl bg-slate-50 border border-slate-100 text-center">
              <div>
                <p className="text-xs text-slate-500 font-medium">Students Tested</p>
                <p className="text-xl font-bold text-slate-900 mt-1">3</p>
              </div>
              <div>
                <p className="text-xs text-slate-500 font-medium">Pass Rate</p>
                <p className="text-xl font-bold text-green-600 mt-1">100%</p>
              </div>
              <div>
                <p className="text-xs text-slate-500 font-medium">Class Avg GPA</p>
                <p className="text-xl font-bold text-blue-600 mt-1">4.42</p>
              </div>
              <div>
                <p className="text-xs text-slate-500 font-medium">A+ Achievers</p>
                <p className="text-xl font-bold text-amber-500 mt-1">1</p>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Bangladesh Grading Key */}
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-sm">Bangladesh Standard Grading Scale</CardTitle>
          </CardHeader>
          <CardContent className="text-xs space-y-1.5 font-medium">
            <div className="flex justify-between py-0.5 border-b border-slate-100">
              <span>80 - 100%</span>
              <span className="font-bold text-emerald-600">A+ (GPA 5.00)</span>
            </div>
            <div className="flex justify-between py-0.5 border-b border-slate-100">
              <span>70 - 79%</span>
              <span className="font-bold text-green-600">A (GPA 4.00)</span>
            </div>
            <div className="flex justify-between py-0.5 border-b border-slate-100">
              <span>60 - 69%</span>
              <span className="font-bold text-blue-600">A- (GPA 3.50)</span>
            </div>
            <div className="flex justify-between py-0.5 border-b border-slate-100">
              <span>50 - 59%</span>
              <span className="font-bold text-yellow-600">B (GPA 3.00)</span>
            </div>
            <div className="flex justify-between py-0.5 border-b border-slate-100">
              <span>40 - 49%</span>
              <span className="font-bold text-orange-600">C (GPA 2.00)</span>
            </div>
            <div className="flex justify-between py-0.5">
              <span>0 - 32%</span>
              <span className="font-bold text-red-600">F (Fail 0.00)</span>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Marks & Results Matrix */}
      <Card>
        <CardHeader>
          <CardTitle>Class 10 — Section A Marks & GPA Matrix</CardTitle>
          <CardDescription>
            Live calculations generated by PostgreSQL procedure `fn_calculate_grade` and `fn_generate_student_report_card`
          </CardDescription>
        </CardHeader>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-slate-600">
            <thead className="bg-slate-50 border-b border-slate-200 text-xs uppercase font-semibold text-slate-500">
              <tr>
                <th className="p-4">Roll</th>
                <th className="p-4">Student ID</th>
                <th className="p-4">Student Name</th>
                <th className="p-4 text-center">Bangla (100)</th>
                <th className="p-4 text-center">English (100)</th>
                <th className="p-4 text-center">Math (100)</th>
                <th className="p-4 text-center">Science (100)</th>
                <th className="p-4 text-center">GPA (5.0)</th>
                <th className="p-4 text-center">Grade</th>
                <th className="p-4 text-right">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 font-medium">
              {studentsMarks.map((s) => (
                <tr key={s.id} className="hover:bg-slate-50/70 transition">
                  <td className="p-4 font-bold text-slate-900">#{s.roll}</td>
                  <td className="p-4 font-mono text-xs text-blue-600">{s.idNumber}</td>
                  <td className="p-4 font-semibold text-slate-900">{s.name}</td>
                  <td className="p-4 text-center">{s.bangla}</td>
                  <td className="p-4 text-center">{s.english}</td>
                  <td className="p-4 text-center font-bold text-slate-800">{s.math}</td>
                  <td className="p-4 text-center">{s.science}</td>
                  <td className="p-4 text-center font-bold text-blue-600">{s.gpa.toFixed(2)}</td>
                  <td className="p-4 text-center">
                    <Badge variant={s.grade === 'A+' ? 'success' : 'default'} className="font-bold">
                      {s.grade}
                    </Badge>
                  </td>
                  <td className="p-4 text-right">
                    <Button
                      size="sm"
                      variant="outline"
                      className="gap-1.5 text-xs text-blue-600 hover:text-blue-700"
                      onClick={() => openReportCard(s)}
                    >
                      <FileText className="h-3.5 w-3.5" />
                      <span>Report Card</span>
                    </Button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>

      {/* Official Report Card Modal */}
      {showReportCardModal && selectedStudent && (
        <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-2xl w-full p-8 shadow-2xl border border-slate-200 space-y-6 animate-in fade-in zoom-in-95">
            {/* School Header */}
            <div className="text-center pb-4 border-b border-slate-200 space-y-1">
              <h2 className="text-2xl font-bold text-blue-900">SAS SMART SCHOOL</h2>
              <p className="text-xs text-slate-500">House 42, Road 11, Dhanmondi, Dhaka • Estd. 1995</p>
              <h3 className="text-sm font-bold text-slate-800 uppercase tracking-widest pt-2">
                Official Academic Transcript / Report Card
              </h3>
              <p className="text-xs text-slate-500 font-medium">First Term Examination 2026</p>
            </div>

            {/* Student Info Grid */}
            <div className="grid grid-cols-2 gap-4 text-xs bg-slate-50 p-4 rounded-xl border border-slate-100">
              <div>
                <p className="text-slate-500">Student Name: <strong className="text-slate-900">{selectedStudent.name}</strong></p>
                <p className="text-slate-500 mt-1">Student ID: <strong className="text-slate-900 font-mono">{selectedStudent.idNumber}</strong></p>
              </div>
              <div className="text-right">
                <p className="text-slate-500">Class: <strong className="text-slate-900">Class 10 (SSC)</strong></p>
                <p className="text-slate-500 mt-1">Section: <strong className="text-slate-900">Padma (Roll #{selectedStudent.roll})</strong></p>
              </div>
            </div>

            {/* Subject Marks Breakdown Table */}
            <div className="border border-slate-200 rounded-xl overflow-hidden">
              <table className="w-full text-left text-xs">
                <thead className="bg-slate-100 font-bold text-slate-700">
                  <tr>
                    <th className="p-3">Subject</th>
                    <th className="p-3 text-center">Full Marks</th>
                    <th className="p-3 text-center">Marks Obtained</th>
                    <th className="p-3 text-center">Letter Grade</th>
                    <th className="p-3 text-center">Grade Point</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  <tr>
                    <td className="p-3 font-medium">Bangla 1st Paper</td>
                    <td className="p-3 text-center">100</td>
                    <td className="p-3 text-center font-bold">{selectedStudent.bangla}</td>
                    <td className="p-3 text-center">A+</td>
                    <td className="p-3 text-center">5.00</td>
                  </tr>
                  <tr>
                    <td className="p-3 font-medium">English 1st Paper</td>
                    <td className="p-3 text-center">100</td>
                    <td className="p-3 text-center font-bold">{selectedStudent.english}</td>
                    <td className="p-3 text-center">A+</td>
                    <td className="p-3 text-center">5.00</td>
                  </tr>
                  <tr>
                    <td className="p-3 font-medium">General Mathematics</td>
                    <td className="p-3 text-center">100</td>
                    <td className="p-3 text-center font-bold">{selectedStudent.math}</td>
                    <td className="p-3 text-center">A+</td>
                    <td className="p-3 text-center">5.00</td>
                  </tr>
                  <tr>
                    <td className="p-3 font-medium">General Science</td>
                    <td className="p-3 text-center">100</td>
                    <td className="p-3 text-center font-bold">{selectedStudent.science}</td>
                    <td className="p-3 text-center">A+</td>
                    <td className="p-3 text-center">5.00</td>
                  </tr>
                </tbody>
              </table>
            </div>

            {/* Summary Box */}
            <div className="flex items-center justify-between p-4 bg-blue-50 border border-blue-200 rounded-xl text-blue-900">
              <div>
                <p className="text-xs font-semibold">Overall Examination Result</p>
                <p className="text-2xl font-bold text-blue-700 mt-0.5">
                  GPA: {selectedStudent.gpa.toFixed(2)} / 5.00 ({selectedStudent.grade})
                </p>
              </div>
              <Badge variant="success" className="text-sm px-4 py-1.5">
                Status: {selectedStudent.status}
              </Badge>
            </div>

            {/* Modal Footer */}
            <div className="flex items-center justify-between pt-4 border-t border-slate-100">
              <Button variant="outline" className="gap-2" onClick={() => window.print()}>
                <Printer className="h-4 w-4" />
                <span>Print / Download PDF</span>
              </Button>
              <Button onClick={() => setShowReportCardModal(false)} className="bg-slate-900 hover:bg-slate-800">
                Close
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
