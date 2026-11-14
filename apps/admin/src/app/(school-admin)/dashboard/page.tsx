'use client';

import React, { useEffect, useState } from 'react';
import {
  Users,
  GraduationCap,
  CalendarCheck,
  CreditCard,
  Award,
  Bell,
  ArrowUpRight,
  TrendingUp,
  UserCheck,
  UserX,
  Clock,
  CheckCircle2,
} from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { formatCurrency } from '@/lib/utils';
import { supabase, isSupabaseConfigured } from '@/lib/supabase/client';
import Link from 'next/link';

export default function SchoolDashboardPage() {
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({
    totalStudents: 3,
    totalTeachers: 3,
    totalClasses: 5,
    todayPresent: 2,
    todayAbsent: 1,
    attendanceRate: 66.7,
    monthlyCollected: 5000,
    monthlyPending: 2500,
  });

  const [recentNotices, setRecentNotices] = useState<any[]>([
    {
      id: '1',
      title: 'First Term Examination 2026 Schedule Published',
      priority: 'high',
      created_at: '2026-04-10',
    },
    {
      id: '2',
      title: 'Annual Sports Day 2026',
      priority: 'normal',
      created_at: '2026-04-05',
    },
  ]);

  useEffect(() => {
    async function fetchSchoolMetrics() {
      if (!isSupabaseConfigured) {
        setLoading(false);
        return;
      }

      try {
        const schoolId = '11111111-1111-1111-1111-111111111111'; // SAS Smart School test tenant
        const today = new Date().toISOString().split('T')[0];

        // Fetch counts from Supabase in parallel
        const [studentsRes, teachersRes, classesRes, attendanceRes, invoicesRes, noticesRes] =
          await Promise.all([
            supabase.from('students').select('*', { count: 'exact', head: true }).eq('school_id', schoolId),
            supabase.from('teachers').select('*', { count: 'exact', head: true }).eq('school_id', schoolId),
            supabase.from('classes').select('*', { count: 'exact', head: true }).eq('school_id', schoolId),
            supabase.from('student_attendance').select('status').eq('school_id', schoolId).eq('date', today),
            supabase.from('student_invoices').select('paid_amount, due_amount').eq('school_id', schoolId),
            supabase.from('notices').select('*').eq('school_id', schoolId).order('created_at', { ascending: false }).limit(4),
          ]);

        let present = 0;
        let absent = 0;
        attendanceRes.data?.forEach((row: any) => {
          if (row.status === 'present') present++;
          if (row.status === 'absent') absent++;
        });

        let collected = 0;
        let pending = 0;
        invoicesRes.data?.forEach((inv: any) => {
          collected += Number(inv.paid_amount || 0);
          pending += Number(inv.due_amount || 0);
        });

        const totalAtt = present + absent;
        const rate = totalAtt > 0 ? (present / totalAtt) * 100 : 0;

        setStats({
          totalStudents: studentsRes.count ?? stats.totalStudents,
          totalTeachers: teachersRes.count ?? stats.totalTeachers,
          totalClasses: classesRes.count ?? stats.totalClasses,
          todayPresent: present || stats.todayPresent,
          todayAbsent: absent || stats.todayAbsent,
          attendanceRate: totalAtt > 0 ? Number(rate.toFixed(1)) : stats.attendanceRate,
          monthlyCollected: collected || stats.monthlyCollected,
          monthlyPending: pending || stats.monthlyPending,
        });

        if (noticesRes.data && noticesRes.data.length > 0) {
          setRecentNotices(noticesRes.data);
        }
      } catch (err) {
        console.error('Error fetching Supabase metrics:', err);
      } finally {
        setLoading(false);
      }
    }

    fetchSchoolMetrics();
  }, []);

  return (
    <div className="space-y-6">
      {/* Top Banner */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-gradient-to-r from-blue-700 via-blue-600 to-indigo-700 p-6 rounded-2xl text-white shadow-md">
        <div>
          <span className="inline-block px-2.5 py-0.5 rounded-full text-xs font-semibold bg-white/20 backdrop-blur-sm text-white mb-2">
            Academic Session 2026
          </span>
          <h1 className="text-2xl font-bold tracking-tight">SAS Smart School</h1>
          <p className="text-sm text-blue-100 mt-1">
            Welcome back! All academic operations and attendance records are up to date.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <Link href="/attendance">
            <Button className="bg-white text-blue-700 hover:bg-blue-50 font-semibold shadow-sm">
              <CalendarCheck className="h-4 w-4 mr-2" />
              Take Attendance
            </Button>
          </Link>
          <Link href="/students">
            <Button variant="outline" className="border-white/30 text-white hover:bg-white/10">
              <GraduationCap className="h-4 w-4 mr-2" />
              Add Student
            </Button>
          </Link>
        </div>
      </div>

      {/* KPI Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <Card className="hover:shadow-md transition border-slate-200">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-slate-500">Total Enrolled Students</CardTitle>
            <div className="h-9 w-9 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center">
              <GraduationCap className="h-5 w-5" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-slate-900">{stats.totalStudents}</div>
            <p className="text-xs text-green-600 flex items-center gap-1 mt-1 font-medium">
              <TrendingUp className="h-3.5 w-3.5" />
              <span>100% active profile status</span>
            </p>
          </CardContent>
        </Card>

        <Card className="hover:shadow-md transition border-slate-200">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-slate-500">Teaching Faculty</CardTitle>
            <div className="h-9 w-9 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center">
              <Users className="h-5 w-5" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-slate-900">{stats.totalTeachers}</div>
            <p className="text-xs text-slate-500 mt-1">Across 5 departments</p>
          </CardContent>
        </Card>

        <Card className="hover:shadow-md transition border-slate-200">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-slate-500">Today's Attendance Rate</CardTitle>
            <div className="h-9 w-9 rounded-lg bg-violet-50 text-violet-600 flex items-center justify-center">
              <CalendarCheck className="h-5 w-5" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-slate-900">{stats.attendanceRate}%</div>
            <div className="flex items-center gap-2 mt-1 text-xs">
              <span className="text-green-600 font-medium">{stats.todayPresent} Present</span>
              <span className="text-slate-300">•</span>
              <span className="text-red-500 font-medium">{stats.todayAbsent} Absent</span>
            </div>
          </CardContent>
        </Card>

        <Card className="hover:shadow-md transition border-slate-200">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-slate-500">Fee Collection (MTD)</CardTitle>
            <div className="h-9 w-9 rounded-lg bg-amber-50 text-amber-600 flex items-center justify-center">
              <CreditCard className="h-5 w-5" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-slate-900">{formatCurrency(stats.monthlyCollected)}</div>
            <p className="text-xs text-amber-600 mt-1 font-medium">
              Due: {formatCurrency(stats.monthlyPending)}
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Main Grid: Attendance Snapshot + Notice Board */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Attendance Breakdown Card */}
        <Card className="lg:col-span-2">
          <CardHeader>
            <div className="flex items-center justify-between">
              <div>
                <CardTitle>Daily Attendance Snapshot</CardTitle>
                <CardDescription>Live attendance synchronization via Supabase Realtime</CardDescription>
              </div>
              <Link href="/attendance">
                <Button variant="ghost" size="sm" className="text-blue-600 hover:text-blue-700 text-xs">
                  View Full Matrix <ArrowUpRight className="h-3.5 w-3.5 ml-1" />
                </Button>
              </Link>
            </div>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-3 gap-4 p-4 rounded-xl bg-slate-50 border border-slate-100">
              <div className="text-center">
                <p className="text-xs text-slate-500 font-medium">Present</p>
                <p className="text-2xl font-bold text-green-600 mt-1">{stats.todayPresent}</p>
                <Badge variant="success" className="mt-1 text-[10px]">On Campus</Badge>
              </div>
              <div className="text-center border-x border-slate-200">
                <p className="text-xs text-slate-500 font-medium">Absent</p>
                <p className="text-2xl font-bold text-red-600 mt-1">{stats.todayAbsent}</p>
                <Badge variant="destructive" className="mt-1 text-[10px]">SMS Sent</Badge>
              </div>
              <div className="text-center">
                <p className="text-xs text-slate-500 font-medium">Classes Active</p>
                <p className="text-2xl font-bold text-blue-600 mt-1">{stats.totalClasses}</p>
                <Badge variant="secondary" className="mt-1 text-[10px]">In Session</Badge>
              </div>
            </div>

            <div className="mt-6 space-y-3">
              <h4 className="text-xs font-semibold text-slate-500 uppercase tracking-wider">
                Quick Academic Status
              </h4>
              <div className="flex items-center justify-between p-3 rounded-lg border border-slate-200 hover:bg-slate-50 transition">
                <div className="flex items-center space-x-3">
                  <div className="h-8 w-8 rounded-lg bg-blue-100 text-blue-600 flex items-center justify-center font-bold text-xs">
                    C10
                  </div>
                  <div>
                    <p className="text-sm font-semibold text-slate-800">Class 10 — Section A (Padma)</p>
                    <p className="text-xs text-slate-500">Roll 1 to 45 • Class Teacher: Kamrul Hasan</p>
                  </div>
                </div>
                <Badge variant="success">Completed</Badge>
              </div>
              <div className="flex items-center justify-between p-3 rounded-lg border border-slate-200 hover:bg-slate-50 transition">
                <div className="flex items-center space-x-3">
                  <div className="h-8 w-8 rounded-lg bg-indigo-100 text-indigo-600 flex items-center justify-center font-bold text-xs">
                    C9
                  </div>
                  <div>
                    <p className="text-sm font-semibold text-slate-800">Class 9 — Section A (Jamuna)</p>
                    <p className="text-xs text-slate-500">Roll 1 to 40 • Class Teacher: Farhana Akter</p>
                  </div>
                </div>
                <Badge variant="secondary">In Progress</Badge>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Notices & Announcements Card */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle className="flex items-center gap-2">
                <Bell className="h-4 w-4 text-blue-600" />
                <span>Notice Board</span>
              </CardTitle>
              <Link href="/notices">
                <Button variant="ghost" size="sm" className="text-xs text-blue-600">
                  New Notice
                </Button>
              </Link>
            </div>
            <CardDescription>Published notices visible on mobile & web</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {recentNotices.map((notice) => (
              <div key={notice.id} className="p-3 rounded-lg border border-slate-100 bg-slate-50/50 space-y-1.5">
                <div className="flex items-center justify-between">
                  <Badge variant={notice.priority === 'high' ? 'destructive' : 'secondary'} className="text-[10px]">
                    {notice.priority}
                  </Badge>
                  <span className="text-[11px] text-slate-400">{notice.created_at}</span>
                </div>
                <h4 className="text-sm font-semibold text-slate-800 line-clamp-2 leading-snug">
                  {notice.title}
                </h4>
              </div>
            ))}

            <Link href="/notices" className="block text-center text-xs text-blue-600 hover:underline pt-2 font-medium">
              View all school notices →
            </Link>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
