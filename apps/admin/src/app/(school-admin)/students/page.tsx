'use client';

import React, { useState, useEffect } from 'react';
import {
  GraduationCap,
  Plus,
  Search,
  Filter,
  Download,
  Upload,
  Eye,
  Edit,
  Trash2,
  CheckCircle2,
} from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { supabase, isSupabaseConfigured } from '@/lib/supabase/client';

export default function StudentsPage() {
  const [search, setSearch] = useState('');
  const [selectedClass, setSelectedClass] = useState('All');
  const [showAddModal, setShowAddModal] = useState(false);
  const [saving, setSaving] = useState(false);

  // Form State
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    studentIdNumber: '',
    admissionNumber: '',
    classGrade: 'Class 10',
    sectionName: 'Padma (Section A)',
    rollNumber: '',
    phone: '',
    gender: 'male',
    address: '',
  });

  // Students List
  const [students, setStudents] = useState<any[]>([
    {
      id: '1',
      student_id_number: 'SAS-2026-001',
      admission_number: 'ADM-1001',
      first_name: 'Tahmid',
      last_name: 'Rahman',
      class_name: 'Class 10',
      section_name: 'Padma',
      roll_number: 1,
      gender: 'male',
      phone: '+8801710000001',
      status: 'active',
    },
    {
      id: '2',
      student_id_number: 'SAS-2026-002',
      admission_number: 'ADM-1002',
      first_name: 'Samia',
      last_name: 'Chowdhury',
      class_name: 'Class 10',
      section_name: 'Padma',
      roll_number: 2,
      gender: 'female',
      phone: '+8801710000002',
      status: 'active',
    },
    {
      id: '3',
      student_id_number: 'SAS-2026-003',
      admission_number: 'ADM-1003',
      first_name: 'Nafis',
      last_name: 'Iqbal',
      class_name: 'Class 10',
      section_name: 'Padma',
      roll_number: 3,
      gender: 'male',
      phone: '+8801710000003',
      status: 'active',
    },
  ]);

  useEffect(() => {
    async function loadStudents() {
      try {
        const res = await fetch('/api/students');
        const json = await res.json();
        if (json.success && json.data && json.data.length > 0) {
          const mapped = json.data.map((s: any, idx: number) => ({
            id: s.id,
            student_id_number: s.student_id_number || `SAS-2026-${String(idx + 1).padStart(3, '0')}`,
            admission_number: s.admission_number || `ADM-${1000 + idx + 1}`,
            first_name: s.first_name,
            last_name: s.last_name,
            class_name: 'Class 10',
            section_name: 'Padma',
            roll_number: idx + 1,
            gender: s.gender || 'male',
            phone: s.phone || '+8801700000000',
            status: s.status || 'active',
          }));
          setStudents(mapped);
        }
      } catch (e) {
        console.error('Failed to load students:', e);
      }
    }
    loadStudents();
  }, []);

  const handleAddStudent = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);

    const payload = {
      first_name: formData.firstName,
      last_name: formData.lastName,
      student_id_number: formData.studentIdNumber || `SAS-2026-${String(students.length + 1).padStart(3, '0')}`,
      admission_number: formData.admissionNumber || `ADM-${1000 + students.length + 1}`,
      gender: formData.gender,
      phone: formData.phone || '+8801700000000',
      address: formData.address || 'Dhaka',
    };

    let newStudent: any = {
      id: String(Date.now()),
      ...payload,
      class_name: formData.classGrade,
      section_name: formData.sectionName,
      roll_number: Number(formData.rollNumber) || students.length + 1,
      status: 'active',
    };

    try {
      const res = await fetch('/api/students', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      const json = await res.json();
      if (json.success && json.data) {
        newStudent.id = json.data.id;
      }
    } catch (err) {
      console.error('Error inserting student to Supabase:', err);
    }

    setStudents([newStudent, ...students]);
    setSaving(false);
    setShowAddModal(false);
    setFormData({
      firstName: '',
      lastName: '',
      studentIdNumber: '',
      admissionNumber: '',
      classGrade: 'Class 10',
      sectionName: 'Padma (Section A)',
      rollNumber: '',
      phone: '',
      gender: 'male',
      address: '',
    });
  };

  const filteredStudents = students.filter((s) => {
    const matchesSearch =
      s.first_name.toLowerCase().includes(search.toLowerCase()) ||
      s.last_name.toLowerCase().includes(search.toLowerCase()) ||
      s.student_id_number.toLowerCase().includes(search.toLowerCase()) ||
      String(s.roll_number).includes(search);

    const matchesClass = selectedClass === 'All' || s.class_name === selectedClass;
    return matchesSearch && matchesClass;
  });

  return (
    <div className="space-y-6">
      {/* Header and Controls */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">Student Directory</h1>
          <p className="text-sm text-slate-500">
            Manage academic enrollments, roll numbers, and student records for SAS Smart School
          </p>
        </div>
        <div className="flex items-center gap-3">
          <Button variant="outline" className="gap-2">
            <Upload className="h-4 w-4" />
            <span>Bulk CSV Import</span>
          </Button>
          <Button onClick={() => setShowAddModal(true)} className="gap-2 bg-blue-600 hover:bg-blue-700">
            <Plus className="h-4 w-4" />
            <span>Add Student</span>
          </Button>
        </div>
      </div>

      {/* Filter and Search Bar */}
      <Card>
        <CardContent className="p-4 flex flex-col md:flex-row gap-4 items-center justify-between">
          <div className="relative w-full md:w-96">
            <Search className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
            <Input
              placeholder="Search by student name, ID or roll number..."
              className="pl-9"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>

          <div className="flex items-center gap-3 w-full md:w-auto">
            <span className="text-xs font-semibold text-slate-500">Filter Class:</span>
            <select
              className="h-10 rounded-lg border border-slate-300 bg-white px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              value={selectedClass}
              onChange={(e) => setSelectedClass(e.target.value)}
            >
              <option value="All">All Classes</option>
              <option value="Class 10">Class 10</option>
              <option value="Class 9">Class 9</option>
              <option value="Class 8">Class 8</option>
              <option value="Class 7">Class 7</option>
              <option value="Class 6">Class 6</option>
            </select>
          </div>
        </CardContent>
      </Card>

      {/* Students Data Table */}
      <Card>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-slate-600">
            <thead className="bg-slate-50 border-b border-slate-200 text-xs uppercase font-semibold text-slate-500 tracking-wider">
              <tr>
                <th className="p-4">Roll</th>
                <th className="p-4">Student ID</th>
                <th className="p-4">Full Name</th>
                <th className="p-4">Class & Section</th>
                <th className="p-4">Gender</th>
                <th className="p-4">Contact Phone</th>
                <th className="p-4">Status</th>
                <th className="p-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 font-medium">
              {filteredStudents.length === 0 ? (
                <tr>
                  <td colSpan={8} className="p-8 text-center text-slate-400">
                    No students found matching your criteria.
                  </td>
                </tr>
              ) : (
                filteredStudents.map((s) => (
                  <tr key={s.id} className="hover:bg-slate-50/80 transition">
                    <td className="p-4 font-bold text-slate-900">#{s.roll_number}</td>
                    <td className="p-4 font-mono text-xs text-blue-600">{s.student_id_number}</td>
                    <td className="p-4 text-slate-900 font-semibold">
                      {s.first_name} {s.last_name}
                    </td>
                    <td className="p-4">
                      {s.class_name} • <span className="text-slate-500">{s.section_name}</span>
                    </td>
                    <td className="p-4 capitalize">{s.gender}</td>
                    <td className="p-4 text-slate-500">{s.phone}</td>
                    <td className="p-4">
                      <Badge variant="success">Active</Badge>
                    </td>
                    <td className="p-4 text-right space-x-2">
                      <Button variant="ghost" size="sm" className="h-8 w-8 p-0">
                        <Eye className="h-4 w-4 text-slate-500 hover:text-blue-600" />
                      </Button>
                      <Button variant="ghost" size="sm" className="h-8 w-8 p-0">
                        <Edit className="h-4 w-4 text-slate-500 hover:text-amber-600" />
                      </Button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </Card>

      {/* Add Student Modal */}
      {showAddModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl border border-slate-100 space-y-5 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100">
              <h3 className="font-bold text-lg text-slate-900">Add New Student</h3>
              <button
                onClick={() => setShowAddModal(false)}
                className="text-slate-400 hover:text-slate-600 text-lg font-bold"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleAddStudent} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-xs font-semibold text-slate-600">First Name *</label>
                  <Input
                    required
                    placeholder="e.g. Shakib"
                    value={formData.firstName}
                    onChange={(e) => setFormData({ ...formData, firstName: e.target.value })}
                  />
                </div>
                <div>
                  <label className="text-xs font-semibold text-slate-600">Last Name *</label>
                  <Input
                    required
                    placeholder="e.g. Al Hasan"
                    value={formData.lastName}
                    onChange={(e) => setFormData({ ...formData, lastName: e.target.value })}
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-xs font-semibold text-slate-600">Roll Number *</label>
                  <Input
                    required
                    type="number"
                    placeholder="e.g. 4"
                    value={formData.rollNumber}
                    onChange={(e) => setFormData({ ...formData, rollNumber: e.target.value })}
                  />
                </div>
                <div>
                  <label className="text-xs font-semibold text-slate-600">Gender</label>
                  <select
                    className="h-10 w-full rounded-lg border border-slate-300 bg-white px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value={formData.gender}
                    onChange={(e) => setFormData({ ...formData, gender: e.target.value })}
                  >
                    <option value="male">Male</option>
                    <option value="female">Female</option>
                    <option value="other">Other</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-xs font-semibold text-slate-600">Class</label>
                  <select
                    className="h-10 w-full rounded-lg border border-slate-300 bg-white px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value={formData.classGrade}
                    onChange={(e) => setFormData({ ...formData, classGrade: e.target.value })}
                  >
                    <option value="Class 10">Class 10</option>
                    <option value="Class 9">Class 9</option>
                    <option value="Class 8">Class 8</option>
                  </select>
                </div>
                <div>
                  <label className="text-xs font-semibold text-slate-600">Guardian Contact Phone</label>
                  <Input
                    placeholder="+8801700000000"
                    value={formData.phone}
                    onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                  />
                </div>
              </div>

              <div>
                <label className="text-xs font-semibold text-slate-600">Present Address</label>
                <Input
                  placeholder="Street address, City"
                  value={formData.address}
                  onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                />
              </div>

              <div className="flex items-center justify-end gap-3 pt-3 border-t border-slate-100">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setShowAddModal(false)}
                >
                  Cancel
                </Button>
                <Button type="submit" disabled={saving} className="bg-blue-600 hover:bg-blue-700">
                  {saving ? 'Saving...' : 'Save Student'}
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
