'use client';

import React, { useState } from 'react';
import { Building2, Plus, Search, ShieldAlert, CheckCircle, Sliders, ExternalLink } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';

export default function SchoolsManagementPage() {
  const [showAddModal, setShowAddModal] = useState(false);
  const [search, setSearch] = useState('');

  const [schools, setSchools] = useState([
    {
      id: '11111111-1111-1111-1111-111111111111',
      name: 'Dhaka Model School',
      code: 'DMS',
      slug: 'dhaka-model',
      city: 'Dhaka',
      email: 'contact@dhakamodel.edu.bd',
      phone: '+8801711223344',
      plan: 'Professional',
      maxStudents: 1500,
      enrolledStudents: 3,
      status: 'active',
      established: 1995,
    },
    {
      id: '22222222-2222-2222-2222-222222222222',
      name: 'Chittagong Grammar School',
      code: 'CGS',
      slug: 'cgs-ctg',
      city: 'Chittagong',
      email: 'admin@cgs.edu.bd',
      phone: '+8801819876543',
      plan: 'Standard',
      maxStudents: 600,
      enrolledStudents: 3,
      status: 'active',
      established: 2002,
    },
  ]);

  const [newSchool, setNewSchool] = useState({
    name: '',
    slug: '',
    code: '',
    email: '',
    phone: '',
    city: 'Dhaka',
    plan: 'Standard',
  });

  const toggleStatus = (id: string) => {
    setSchools(
      schools.map((s) => {
        if (s.id === id) {
          const next = s.status === 'active' ? 'suspended' : 'active';
          return { ...s, status: next };
        }
        return s;
      })
    );
  };

  const handleAddSchool = (e: React.FormEvent) => {
    e.preventDefault();
    const created = {
      id: `school-${Date.now()}`,
      name: newSchool.name,
      code: newSchool.code.toUpperCase(),
      slug: newSchool.slug.toLowerCase(),
      city: newSchool.city,
      email: newSchool.email,
      phone: newSchool.phone,
      plan: newSchool.plan,
      maxStudents: 600,
      enrolledStudents: 0,
      status: 'active',
      established: 2026,
    };
    setSchools([...schools, created]);
    setShowAddModal(false);
    setNewSchool({ name: '', slug: '', code: '', email: '', phone: '', city: 'Dhaka', plan: 'Standard' });
  };

  const filteredSchools = schools.filter(
    (s) =>
      s.name.toLowerCase().includes(search.toLowerCase()) ||
      s.code.toLowerCase().includes(search.toLowerCase()) ||
      s.slug.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">Multi-Tenant School Directory</h1>
          <p className="text-sm text-slate-500">
            Provision, manage, activate, or suspend independent school institutions in the ecosystem
          </p>
        </div>
        <Button onClick={() => setShowAddModal(true)} className="bg-blue-600 hover:bg-blue-700 gap-2">
          <Plus className="h-4 w-4" />
          <span>Provision New School</span>
        </Button>
      </div>

      <Card>
        <CardContent className="p-4">
          <div className="relative w-full md:w-96">
            <Search className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
            <Input
              placeholder="Search school name, slug, or code..."
              className="pl-9"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
        </CardContent>
      </Card>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {filteredSchools.map((s) => (
          <Card key={s.id} className="hover:shadow-md transition">
            <CardHeader className="flex flex-row items-start justify-between pb-3">
              <div>
                <div className="flex items-center gap-2 mb-1">
                  <span className="font-mono text-xs font-bold text-blue-600 uppercase bg-blue-50 px-2 py-0.5 rounded">
                    {s.code}
                  </span>
                  <Badge variant={s.status === 'active' ? 'success' : 'destructive'} className="capitalize">
                    {s.status}
                  </Badge>
                </div>
                <CardTitle className="text-lg">{s.name}</CardTitle>
                <p className="text-xs text-slate-400 font-mono mt-0.5">slug: {s.slug}</p>
              </div>
              <Badge variant="outline" className="font-semibold text-slate-700">
                Plan: {s.plan}
              </Badge>
            </CardHeader>
            <CardContent className="space-y-3 text-xs text-slate-600 border-t border-slate-100 pt-3">
              <div className="grid grid-cols-2 gap-2">
                <div>
                  <span className="text-slate-400 block">Location:</span>
                  <strong className="text-slate-800">{s.city}, Bangladesh</strong>
                </div>
                <div>
                  <span className="text-slate-400 block">Quota Usage:</span>
                  <strong className="text-slate-800">{s.enrolledStudents} / {s.maxStudents} Students</strong>
                </div>
              </div>
              <div>
                <span className="text-slate-400 block">Contact:</span>
                <span className="text-slate-700">{s.email} • {s.phone}</span>
              </div>
              <div className="flex items-center justify-between pt-2 border-t border-slate-100">
                <Button
                  size="sm"
                  variant="outline"
                  onClick={() => toggleStatus(s.id)}
                  className={`text-xs ${s.status === 'active' ? 'text-red-600 hover:bg-red-50' : 'text-green-600 hover:bg-green-50'}`}
                >
                  {s.status === 'active' ? 'Suspend Tenant' : 'Reactivate Tenant'}
                </Button>
                <a
                  href={`http://localhost:3001/school/${s.slug}`}
                  target="_blank"
                  rel="noreferrer"
                  className="text-xs text-blue-600 hover:underline flex items-center gap-1 font-medium"
                >
                  Visit Public Web <ExternalLink className="h-3 w-3" />
                </a>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {showAddModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl border border-slate-100 space-y-4">
            <h3 className="font-bold text-lg text-slate-900">Provision New School Tenant</h3>
            <form onSubmit={handleAddSchool} className="space-y-4">
              <div>
                <label className="text-xs font-semibold text-slate-600">School Name *</label>
                <Input
                  required
                  placeholder="e.g. Sylhet Cadet Academy"
                  value={newSchool.name}
                  onChange={(e) => setNewSchool({ ...newSchool, name: e.target.value })}
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-xs font-semibold text-slate-600">Unique Code (Uppercase) *</label>
                  <Input
                    required
                    placeholder="e.g. SCA"
                    value={newSchool.code}
                    onChange={(e) => setNewSchool({ ...newSchool, code: e.target.value })}
                  />
                </div>
                <div>
                  <label className="text-xs font-semibold text-slate-600">URL Slug *</label>
                  <Input
                    required
                    placeholder="e.g. sylhet-cadet"
                    value={newSchool.slug}
                    onChange={(e) => setNewSchool({ ...newSchool, slug: e.target.value })}
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-xs font-semibold text-slate-600">Email *</label>
                  <Input
                    required
                    type="email"
                    placeholder="admin@school.edu.bd"
                    value={newSchool.email}
                    onChange={(e) => setNewSchool({ ...newSchool, email: e.target.value })}
                  />
                </div>
                <div>
                  <label className="text-xs font-semibold text-slate-600">Phone *</label>
                  <Input
                    required
                    placeholder="+8801700000000"
                    value={newSchool.phone}
                    onChange={(e) => setNewSchool({ ...newSchool, phone: e.target.value })}
                  />
                </div>
              </div>
              <div>
                <label className="text-xs font-semibold text-slate-600">Subscription Tier</label>
                <select
                  className="h-10 w-full rounded-lg border border-slate-300 bg-white px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={newSchool.plan}
                  onChange={(e) => setNewSchool({ ...newSchool, plan: e.target.value })}
                >
                  <option value="Basic">Basic (250 Students)</option>
                  <option value="Standard">Standard (600 Students)</option>
                  <option value="Professional">Professional (1,500 Students)</option>
                  <option value="Enterprise">Enterprise (5,000 Students)</option>
                </select>
              </div>
              <div className="flex justify-end gap-3 pt-3 border-t border-slate-100">
                <Button type="button" variant="outline" onClick={() => setShowAddModal(false)}>
                  Cancel
                </Button>
                <Button type="submit" className="bg-blue-600 hover:bg-blue-700">
                  Provision School Tenant
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
