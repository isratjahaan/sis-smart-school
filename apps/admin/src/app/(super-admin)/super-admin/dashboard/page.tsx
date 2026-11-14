'use client';

import React from 'react';
import {
  Building2,
  Users,
  CreditCard,
  Activity,
  ArrowUpRight,
  TrendingUp,
  Server,
  ShieldCheck,
  CheckCircle,
} from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { formatCurrency } from '@/lib/utils';
import Link from 'next/link';

export default function SuperAdminDashboardPage() {
  const platformStats = {
    totalSchools: 2,
    activeSchools: 2,
    totalStudents: 6,
    totalTeachers: 6,
    mrr: 14000,
    totalRevenue: 140000,
    apiHealth: '99.98%',
    activeConnections: 42,
  };

  const schools = [
    {
      id: '1',
      name: 'Dhaka Model School',
      code: 'DMS',
      slug: 'dhaka-model',
      city: 'Dhaka',
      plan: 'Professional',
      students: 3,
      status: 'active',
      renewDate: '2026-12-31',
    },
    {
      id: '2',
      name: 'Chittagong Grammar School',
      code: 'CGS',
      slug: 'cgs-ctg',
      city: 'Chittagong',
      plan: 'Standard',
      students: 3,
      status: 'active',
      renewDate: '2026-12-31',
    },
  ];

  return (
    <div className="space-y-6">
      {/* Super Admin Welcome Banner */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-gradient-to-r from-slate-900 via-slate-800 to-indigo-950 p-6 rounded-2xl text-white shadow-xl border border-slate-800">
        <div>
          <div className="flex items-center gap-2 mb-2">
            <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-amber-500/20 text-amber-300 border border-amber-500/30">
              Master Platform Control
            </span>
            <Badge variant="success" className="bg-emerald-500/20 text-emerald-300 border-emerald-500/30">
              Multi-Tenant Cluster Healthy
            </Badge>
          </div>
          <h1 className="text-2xl font-bold tracking-tight">SIS Smart School SaaS Control Center</h1>
          <p className="text-sm text-slate-300 mt-1">
            Centrally manage tenant institutions, subscriptions, remote configurations, and Server-Driven UI
          </p>
        </div>
        <div className="flex items-center gap-3">
          <Link href="/super-admin/remote-control">
            <Button className="bg-amber-600 hover:bg-amber-700 text-white font-semibold shadow-md gap-2">
              <ShieldCheck className="h-4 w-4" />
              <span>Remote App Control</span>
            </Button>
          </Link>
          <Link href="/super-admin/schools">
            <Button variant="outline" className="border-slate-700 text-slate-200 hover:bg-slate-800">
              <Building2 className="h-4 w-4 mr-2" />
              <span>Add School</span>
            </Button>
          </Link>
        </div>
      </div>

      {/* High-Level Platform KPIs */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <Card className="border-slate-200">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-xs font-semibold text-slate-500 uppercase">Registered Schools</CardTitle>
            <div className="h-8 w-8 rounded-lg bg-blue-100 text-blue-700 flex items-center justify-center">
              <Building2 className="h-4 w-4" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-slate-900">{platformStats.totalSchools}</div>
            <p className="text-xs text-green-600 flex items-center gap-1 mt-1 font-medium">
              <CheckCircle className="h-3 w-3" />
              <span>{platformStats.activeSchools} active & verified</span>
            </p>
          </CardContent>
        </Card>

        <Card className="border-slate-200">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-xs font-semibold text-slate-500 uppercase">Total Students</CardTitle>
            <div className="h-8 w-8 rounded-lg bg-emerald-100 text-emerald-700 flex items-center justify-center">
              <Users className="h-4 w-4" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-slate-900">{platformStats.totalStudents}</div>
            <p className="text-xs text-slate-500 mt-1">Across all school tenants</p>
          </CardContent>
        </Card>

        <Card className="border-slate-200">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-xs font-semibold text-slate-500 uppercase">Monthly Recurring (MRR)</CardTitle>
            <div className="h-8 w-8 rounded-lg bg-violet-100 text-violet-700 flex items-center justify-center">
              <CreditCard className="h-4 w-4" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-slate-900">{formatCurrency(platformStats.mrr)}</div>
            <p className="text-xs text-green-600 flex items-center gap-1 mt-1 font-medium">
              <TrendingUp className="h-3 w-3" />
              <span>+18.4% month-over-month</span>
            </p>
          </CardContent>
        </Card>

        <Card className="border-slate-200">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-xs font-semibold text-slate-500 uppercase">Backend API Health</CardTitle>
            <div className="h-8 w-8 rounded-lg bg-amber-100 text-amber-700 flex items-center justify-center">
              <Activity className="h-4 w-4" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-slate-900">{platformStats.apiHealth}</div>
            <p className="text-xs text-slate-500 mt-1">Supabase Edge Latency: 24ms</p>
          </CardContent>
        </Card>
      </div>

      {/* Tenants Table */}
      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <div>
            <CardTitle>Active School Tenants</CardTitle>
            <CardDescription>Schools isolated under PostgreSQL Row Level Security (RLS)</CardDescription>
          </div>
          <Link href="/super-admin/schools">
            <Button variant="ghost" size="sm" className="text-blue-600 text-xs">
              Manage All Tenants <ArrowUpRight className="h-3.5 w-3.5 ml-1" />
            </Button>
          </Link>
        </CardHeader>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-slate-600">
            <thead className="bg-slate-50 border-b border-slate-200 text-xs uppercase font-semibold text-slate-500">
              <tr>
                <th className="p-4">School Name</th>
                <th className="p-4">Tenant Code</th>
                <th className="p-4">City</th>
                <th className="p-4">Current Plan</th>
                <th className="p-4">Active Students</th>
                <th className="p-4">Status</th>
                <th className="p-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 font-medium">
              {schools.map((s) => (
                <tr key={s.id} className="hover:bg-slate-50/70 transition">
                  <td className="p-4 font-semibold text-slate-900">
                    <p>{s.name}</p>
                    <p className="text-xs text-slate-400 font-mono">slug: {s.slug}</p>
                  </td>
                  <td className="p-4 font-mono font-bold text-xs text-blue-600">{s.code}</td>
                  <td className="p-4">{s.city}</td>
                  <td className="p-4">
                    <Badge variant="outline" className="font-semibold text-slate-800">
                      {s.plan}
                    </Badge>
                  </td>
                  <td className="p-4 font-bold text-slate-900">{s.students}</td>
                  <td className="p-4">
                    <Badge variant="success">Active</Badge>
                  </td>
                  <td className="p-4 text-right">
                    <Link href={`/super-admin/schools?id=${s.id}`}>
                      <Button size="sm" variant="outline" className="text-xs">
                        Configure
                      </Button>
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}
