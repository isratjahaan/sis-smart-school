'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  LayoutDashboard,
  Users,
  GraduationCap,
  BookOpen,
  CalendarCheck,
  Award,
  CreditCard,
  Bell,
  Settings,
  Building2,
  Sliders,
  ShieldCheck,
  ChevronRight,
} from 'lucide-react';
import { cn } from '@/lib/utils';

interface NavItem {
  title: string;
  href: string;
  icon: React.ElementType;
  badge?: string;
}

export function Sidebar({ isSuperAdmin = false }: { isSuperAdmin?: boolean }) {
  const pathname = usePathname();

  const schoolAdminItems: NavItem[] = [
    { title: 'Overview', href: '/dashboard', icon: LayoutDashboard },
    { title: 'Students', href: '/students', icon: GraduationCap },
    { title: 'Teachers', href: '/teachers', icon: Users },
    { title: 'Academics', href: '/academics', icon: BookOpen },
    { title: 'Attendance', href: '/attendance', icon: CalendarCheck },
    { title: 'Examinations', href: '/examinations', icon: Award },
    { title: 'Fees & Accounts', href: '/fees', icon: CreditCard },
    { title: 'Notice Board', href: '/notices', icon: Bell },
    { title: 'School Settings', href: '/settings', icon: Settings },
  ];

  const superAdminItems: NavItem[] = [
    { title: 'Platform Health', href: '/super-admin/dashboard', icon: LayoutDashboard },
    { title: 'Schools / Tenants', href: '/super-admin/schools', icon: Building2 },
    { title: 'Subscription Plans', href: '/super-admin/subscriptions', icon: CreditCard },
    { title: 'Remote App Control', href: '/super-admin/remote-control', icon: Sliders, badge: 'SDUI' },
  ];

  const items = isSuperAdmin ? superAdminItems : schoolAdminItems;

  return (
    <aside className="w-64 bg-slate-900 text-slate-100 flex flex-col border-r border-slate-800 shrink-0 min-h-screen">
      {/* Brand Header */}
      <div className="p-6 border-b border-slate-800 flex items-center space-x-3">
        <div className="h-9 w-9 rounded-lg bg-blue-600 flex items-center justify-center font-bold text-white shadow-md">
          SIS
        </div>
        <div>
          <h1 className="font-bold text-sm leading-tight text-white tracking-wide">SIS SMART SCHOOL</h1>
          <p className="text-xs text-slate-400">
            {isSuperAdmin ? 'Platform Super Admin' : 'School Management'}
          </p>
        </div>
      </div>

      {/* Navigation Switcher Tab */}
      <div className="px-4 py-3 bg-slate-950/50 border-b border-slate-800/80 flex items-center justify-between text-xs">
        <span className="text-slate-400 font-medium">Mode:</span>
        <div className="flex space-x-2">
          <Link
            href="/dashboard"
            className={cn(
              'px-2 py-1 rounded text-xs font-semibold transition',
              !isSuperAdmin ? 'bg-blue-600 text-white' : 'text-slate-400 hover:text-white'
            )}
          >
            School
          </Link>
          <Link
            href="/super-admin/dashboard"
            className={cn(
              'px-2 py-1 rounded text-xs font-semibold transition',
              isSuperAdmin ? 'bg-amber-600 text-white' : 'text-slate-400 hover:text-white'
            )}
          >
            Super Admin
          </Link>
        </div>
      </div>

      {/* Navigation List */}
      <nav className="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
        {items.map((item) => {
          const isActive = pathname === item.href || (item.href !== '/dashboard' && pathname.startsWith(item.href));
          const Icon = item.icon;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                'flex items-center justify-between px-3 py-2.5 rounded-lg text-sm font-medium transition-all group',
                isActive
                  ? 'bg-blue-600 text-white shadow-sm'
                  : 'text-slate-300 hover:bg-slate-800 hover:text-white'
              )}
            >
              <div className="flex items-center space-x-3">
                <Icon className={cn('h-4 w-4', isActive ? 'text-white' : 'text-slate-400 group-hover:text-white')} />
                <span>{item.title}</span>
              </div>
              {item.badge && (
                <span className="text-[10px] uppercase font-bold tracking-wider px-1.5 py-0.5 rounded bg-amber-500/20 text-amber-300 border border-amber-500/30">
                  {item.badge}
                </span>
              )}
            </Link>
          );
        })}
      </nav>

      {/* Tenant Context Footer */}
      {!isSuperAdmin && (
        <div className="p-4 border-t border-slate-800 bg-slate-950/40">
          <div className="flex items-center space-x-3">
            <div className="h-8 w-8 rounded-full bg-slate-700 flex items-center justify-center text-xs font-bold text-blue-400">
              DMS
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-xs font-semibold text-slate-200 truncate">Dhaka Model School</p>
              <p className="text-[10px] text-green-400 flex items-center gap-1">
                <span className="h-1.5 w-1.5 rounded-full bg-green-400 inline-block animate-pulse" />
                Session 2026 (Active)
              </p>
            </div>
          </div>
        </div>
      )}

      {isSuperAdmin && (
        <div className="p-4 border-t border-slate-800 bg-amber-950/20">
          <div className="flex items-center space-x-2 text-amber-400 text-xs font-semibold">
            <ShieldCheck className="h-4 w-4" />
            <span>Remote Command Center</span>
          </div>
          <p className="text-[10px] text-slate-400 mt-1">Full Server-Driven UI Control</p>
        </div>
      )}
    </aside>
  );
}
