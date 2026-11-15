'use client';

import React, { useState, useEffect } from 'react';
import { Users, Plus, Mail, Phone, BookOpen, Award, CheckCircle } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';

export default function TeachersPage() {
  const [teachers, setTeachers] = useState<any[]>([
    {
      id: '1',
      teacherIdNumber: 'TCH-001',
      name: 'Kamrul Hasan',
      qualification: 'M.Sc in Mathematics (DU)',
      designation: 'Senior Assistant Teacher',
      department: 'Mathematics',
      phone: '+8801712000001',
      email: 'kamrul.hasan@sas.edu.bd',
      assignedClass: 'Class 10 (Math)',
      status: 'active',
    },
    {
      id: '2',
      teacherIdNumber: 'TCH-002',
      name: 'Farhana Akter',
      qualification: 'M.A in English (JU)',
      designation: 'Assistant Teacher',
      department: 'English',
      phone: '+8801712000002',
      email: 'farhana.akter@sas.edu.bd',
      assignedClass: 'Class 9 (English)',
      status: 'active',
    },
    {
      id: '3',
      teacherIdNumber: 'TCH-003',
      name: 'Shahidul Alam',
      qualification: 'B.Sc in Computer Science (BUET)',
      designation: 'Lecturer in ICT',
      department: 'Computer Science',
      phone: '+8801712000003',
      email: 'shahidul.alam@sas.edu.bd',
      assignedClass: 'Class 10 (ICT)',
      status: 'active',
    },
  ]);

  useEffect(() => {
    async function loadTeachers() {
      try {
        const res = await fetch('/api/teachers');
        const json = await res.json();
        if (json.success && json.data && json.data.length > 0) {
          const mapped = json.data.map((t: any) => ({
            id: t.id,
            teacherIdNumber: t.teacher_id_number || 'TCH-001',
            name: `${t.first_name || ''} ${t.last_name || ''}`.trim(),
            qualification: t.qualification || 'Academic Faculty',
            designation: t.designation || 'Teacher',
            department: t.department || 'General',
            phone: t.phone || '+8801700000000',
            email: t.email || 'teacher@sas.edu.bd',
            assignedClass: 'Class 10',
            status: t.status || 'active',
          }));
          setTeachers(mapped);
        }
      } catch (err) {
        console.error('Failed to load teachers:', err);
      }
    }
    loadTeachers();
  }, []);

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">Teaching Faculty</h1>
          <p className="text-sm text-slate-500">
            Manage teacher profiles, designations, contact credentials, and subject assignments
          </p>
        </div>
        <Button className="bg-blue-600 hover:bg-blue-700 gap-2">
          <Plus className="h-4 w-4" />
          <span>Add Teacher</span>
        </Button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {teachers.map((t) => (
          <Card key={t.id} className="hover:shadow-md transition">
            <CardHeader className="flex flex-row items-center space-x-4 pb-3">
              <div className="h-12 w-12 rounded-full bg-blue-100 text-blue-700 font-bold flex items-center justify-center text-base">
                {t.name.split(' ').map((n: string) => n[0]).join('')}
              </div>
              <div>
                <CardTitle className="text-base">{t.name}</CardTitle>
                <p className="text-xs text-blue-600 font-medium">{t.designation}</p>
                <p className="text-[11px] font-mono text-slate-400">{t.teacherIdNumber}</p>
              </div>
            </CardHeader>
            <CardContent className="space-y-2.5 text-xs text-slate-600 border-t border-slate-100 pt-3">
              <div className="flex items-center space-x-2">
                <BookOpen className="h-3.5 w-3.5 text-slate-400" />
                <span>Department: <strong className="text-slate-800">{t.department}</strong></span>
              </div>
              <div className="flex items-center space-x-2">
                <Award className="h-3.5 w-3.5 text-slate-400" />
                <span>{t.qualification}</span>
              </div>
              <div className="flex items-center space-x-2">
                <Phone className="h-3.5 w-3.5 text-slate-400" />
                <span>{t.phone}</span>
              </div>
              <div className="flex items-center space-x-2">
                <Mail className="h-3.5 w-3.5 text-slate-400" />
                <span>{t.email}</span>
              </div>
              <div className="pt-2 flex items-center justify-between">
                <Badge variant="success">Active</Badge>
                <span className="text-[11px] text-slate-400">Assignment: {t.assignedClass}</span>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
