'use client';

import React, { useState } from 'react';
import { BookOpen, Calendar, Clock, Plus, Layers, CheckCircle } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';

export default function AcademicsPage() {
  const [activeTab, setActiveTab] = useState<'classes' | 'subjects' | 'routines'>('classes');

  const classes = [
    { id: '1', name: 'Class 10', grade: 10, sections: 'Section A (Padma), Section B (Meghna)', studentsCount: 45 },
    { id: '2', name: 'Class 9', grade: 9, sections: 'Section A (Jamuna)', studentsCount: 40 },
    { id: '3', name: 'Class 8', grade: 8, sections: 'Section A, Section B', studentsCount: 50 },
    { id: '4', name: 'Class 7', grade: 7, sections: 'Section A', studentsCount: 42 },
    { id: '5', name: 'Class 6', grade: 6, sections: 'Section A', studentsCount: 38 },
  ];

  const subjects = [
    { code: 'BAN-101', name: 'Bangla 1st Paper', type: 'Theory', passMarks: 33, totalMarks: 100 },
    { code: 'ENG-101', name: 'English 1st Paper', type: 'Theory', passMarks: 33, totalMarks: 100 },
    { code: 'MAT-101', name: 'General Mathematics', type: 'Theory', passMarks: 33, totalMarks: 100 },
    { code: 'SCI-101', name: 'General Science', type: 'Both', passMarks: 33, totalMarks: 100 },
    { code: 'ICT-101', name: 'Information & Communication Technology', type: 'Both', passMarks: 17, totalMarks: 50 },
  ];

  const routine = [
    { day: 'Sunday', time: '09:00 - 09:45 AM', subject: 'General Mathematics', teacher: 'Kamrul Hasan', room: 'Room 301' },
    { day: 'Sunday', time: '09:45 - 10:30 AM', subject: 'English 1st Paper', teacher: 'Farhana Akter', room: 'Room 301' },
    { day: 'Sunday', time: '10:45 - 11:30 AM', subject: 'ICT', teacher: 'Shahidul Alam', room: 'Computer Lab 1' },
    { day: 'Monday', time: '09:00 - 09:45 AM', subject: 'Bangla 1st Paper', teacher: 'Kamrul Hasan', room: 'Room 301' },
  ];

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">Academic Structure</h1>
          <p className="text-sm text-slate-500">
            Configure sessions, classes, sections, subjects, and weekly timetable schedules
          </p>
        </div>
        <div className="flex items-center gap-2">
          {(['classes', 'subjects', 'routines'] as const).map((tab) => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              className={`px-4 py-2 rounded-lg text-xs font-semibold capitalize transition cursor-pointer ${
                activeTab === tab
                  ? 'bg-blue-600 text-white shadow-xs'
                  : 'bg-white border border-slate-200 text-slate-600 hover:bg-slate-50'
              }`}
            >
              {tab}
            </button>
          ))}
        </div>
      </div>

      {activeTab === 'classes' && (
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <div>
              <CardTitle>Classes & Sections (Session 2026)</CardTitle>
              <CardDescription>Academic grades recognized under SAS Smart School</CardDescription>
            </div>
            <Button size="sm" className="bg-blue-600 hover:bg-blue-700">Add Class</Button>
          </CardHeader>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm text-slate-600">
              <thead className="bg-slate-50 border-b border-slate-200 text-xs uppercase font-semibold text-slate-500">
                <tr>
                  <th className="p-4">Grade</th>
                  <th className="p-4">Class Name</th>
                  <th className="p-4">Active Sections</th>
                  <th className="p-4">Enrolled Capacity</th>
                  <th className="p-4 text-right">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 font-medium">
                {classes.map((c) => (
                  <tr key={c.id} className="hover:bg-slate-50/70">
                    <td className="p-4 font-bold text-slate-900">{c.grade}</td>
                    <td className="p-4 font-semibold text-blue-600">{c.name}</td>
                    <td className="p-4 text-slate-700">{c.sections}</td>
                    <td className="p-4 text-slate-500">{c.studentsCount} students</td>
                    <td className="p-4 text-right">
                      <Badge variant="success">Active</Badge>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
      )}

      {activeTab === 'subjects' && (
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <div>
              <CardTitle>School Subjects</CardTitle>
              <CardDescription>Approved curriculum subjects with passing criteria</CardDescription>
            </div>
            <Button size="sm" className="bg-blue-600 hover:bg-blue-700">Add Subject</Button>
          </CardHeader>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm text-slate-600">
              <thead className="bg-slate-50 border-b border-slate-200 text-xs uppercase font-semibold text-slate-500">
                <tr>
                  <th className="p-4">Code</th>
                  <th className="p-4">Subject Name</th>
                  <th className="p-4">Type</th>
                  <th className="p-4 text-center">Pass Marks</th>
                  <th className="p-4 text-center">Total Marks</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 font-medium">
                {subjects.map((sub) => (
                  <tr key={sub.code} className="hover:bg-slate-50/70">
                    <td className="p-4 font-mono font-bold text-xs text-blue-600">{sub.code}</td>
                    <td className="p-4 font-semibold text-slate-900">{sub.name}</td>
                    <td className="p-4 capitalize">{sub.type}</td>
                    <td className="p-4 text-center text-red-600 font-semibold">{sub.passMarks}</td>
                    <td className="p-4 text-center font-bold text-slate-900">{sub.totalMarks}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
      )}

      {activeTab === 'routines' && (
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <div>
              <CardTitle>Class 10 — Section A Timetable Routine</CardTitle>
              <CardDescription>Synchronized with mobile student and teacher applications</CardDescription>
            </div>
            <Button size="sm" className="bg-blue-600 hover:bg-blue-700">Add Period</Button>
          </CardHeader>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm text-slate-600">
              <thead className="bg-slate-50 border-b border-slate-200 text-xs uppercase font-semibold text-slate-500">
                <tr>
                  <th className="p-4">Day</th>
                  <th className="p-4">Time Interval</th>
                  <th className="p-4">Subject</th>
                  <th className="p-4">Assigned Teacher</th>
                  <th className="p-4">Room</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 font-medium">
                {routine.map((r, i) => (
                  <tr key={i} className="hover:bg-slate-50/70">
                    <td className="p-4 font-bold text-slate-900">{r.day}</td>
                    <td className="p-4 font-mono text-xs text-blue-600">{r.time}</td>
                    <td className="p-4 font-semibold text-slate-900">{r.subject}</td>
                    <td className="p-4 text-slate-700">{r.teacher}</td>
                    <td className="p-4 text-slate-500 font-mono text-xs">{r.room}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
      )}
    </div>
  );
}
