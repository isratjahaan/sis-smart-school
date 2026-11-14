'use client';

import React from 'react';
import Link from 'next/link';
import { Bell, Globe, School, User } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { isSupabaseConfigured } from '@/lib/supabase/client';

export function Header({ title }: { title?: string }) {
  return (
    <header className="h-16 border-b border-slate-200 bg-white px-6 flex items-center justify-between sticky top-0 z-30 shadow-xs">
      <div className="flex items-center space-x-3">
        <h2 className="text-xl font-bold text-slate-800 tracking-tight">{title || 'Dashboard'}</h2>
        <Badge variant={isSupabaseConfigured ? 'success' : 'warning'} className="gap-1.5 font-normal text-xs">
          <span className={`h-1.5 w-1.5 rounded-full ${isSupabaseConfigured ? 'bg-emerald-500' : 'bg-amber-500'}`} />
          {isSupabaseConfigured ? 'Live Database' : 'Local Mode'}
        </Badge>
      </div>

      <div className="flex items-center space-x-3">
        {/* Quick Public Website Link */}
        <Link href="http://localhost:3001/school/sas-smart-school" target="_blank">
          <Button variant="outline" size="sm" className="gap-2 text-xs hover:bg-blue-50 hover:text-blue-700 hover:border-blue-200">
            <Globe className="h-3.5 w-3.5 text-blue-600" />
            <span>View School Website</span>
          </Button>
        </Link>

        {/* Notifications Button */}
        <Button variant="ghost" size="icon" className="relative text-slate-600">
          <Bell className="h-4 w-4" />
          <span className="absolute top-2 right-2 h-2 w-2 rounded-full bg-red-500" />
        </Button>

        {/* Admin Profile */}
        <div className="flex items-center space-x-3 pl-3 border-l border-slate-200">
          <div className="h-8 w-8 rounded-full bg-blue-100 text-blue-700 flex items-center justify-center font-bold text-xs">
            SAS
          </div>
          <div className="hidden md:block text-left text-xs">
            <p className="font-semibold text-slate-800">School Principal / Admin</p>
            <p className="text-slate-500">SAS Smart School</p>
          </div>
        </div>
      </div>
    </header>
  );
}
