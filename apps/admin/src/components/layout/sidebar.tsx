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
  School,
  Building2,
  Sliders,
  ShieldCheck,
  ShieldAlert,
  Smartphone,
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
    { title: 'Mobile App Sync', href: '/mobile-control', icon: Smartphone, badge: 'Live' },
    { title: 'Anti-Theft Remote', href: '/anti-theft', icon: ShieldAlert, badge: 'Remote' },
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
      {/* Brand Header: School Name */}
      <div className="p-5 border-b border-slate-800 flex items-center space-x-3">
        <div className="h-10 w-10 rounded-xl bg-blue-600 flex items-center justify-center font-bold text-white shadow-lg ring-2 ring-blue-500/20">
          <School className="h-5 w-5" />
        </div>
        <div className="min-w-0 flex-1">
          <h1 className="font-bold text-sm leading-tight text-white truncate tracking-wide">
            SAS Smart School
          </h1>
          <p className="text-[11px] text-blue-400 font-medium">
            Smart School Dashboard
          </p>
        </div>
      </div>

      {/* Navigation List */}
      <nav className="flex-1 px-3 py-4 space-y-1.5 overflow-y-auto">
        <div className="px-3 pb-2 text-[10px] font-semibold uppercase tracking-wider text-slate-400">
          School Management
        </div>
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
      <div className="p-4 border-t border-slate-800 bg-slate-950/60">
        <div className="flex items-center space-x-3">
          <div className="h-8 w-8 rounded-full bg-blue-500/20 text-blue-400 flex items-center justify-center text-xs font-bold border border-blue-500/30">
            SAS
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-xs font-semibold text-slate-200 truncate">SAS Smart School</p>
            <p className="text-[10px] text-emerald-400 flex items-center gap-1.5 font-medium">
              <span className="h-1.5 w-1.5 rounded-full bg-emerald-400 inline-block animate-pulse" />
              Academic Session 2026
            </p>
          </div>
        </div>
      </div>
    </aside>
  );
}
