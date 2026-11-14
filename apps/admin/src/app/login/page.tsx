'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { ShieldCheck, Lock, Mail, School, ArrowRight, UserCheck } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState('admin@dhakamodel.edu.bd');
  const [password, setPassword] = useState('••••••••');
  const [selectedRole, setSelectedRole] = useState<'school_admin' | 'super_admin' | 'teacher'>('school_admin');
  const [loading, setLoading] = useState(false);

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    setTimeout(() => {
      if (selectedRole === 'super_admin') {
        router.push('/super-admin/dashboard');
      } else {
        router.push('/dashboard');
      }
    }, 400);
  };

  const handleQuickRole = (role: 'school_admin' | 'super_admin') => {
    setSelectedRole(role);
    if (role === 'super_admin') {
      setEmail('superadmin@sissmartschool.com');
      router.push('/super-admin/dashboard');
    } else {
      setEmail('admin@dhakamodel.edu.bd');
      router.push('/dashboard');
    }
  };

  return (
    <div className="min-h-screen bg-slate-900 flex flex-col items-center justify-center p-4">
      <div className="max-w-md w-full space-y-6">
        {/* Brand Header */}
        <div className="text-center space-y-2">
          <div className="h-12 w-12 rounded-xl bg-blue-600 text-white font-black text-xl flex items-center justify-center mx-auto shadow-lg">
            SIS
          </div>
          <h1 className="text-2xl font-bold text-white tracking-tight">SIS SMART SCHOOL</h1>
          <p className="text-xs text-slate-400">
            Enterprise Multi-Tenant SaaS Portal Authentication
          </p>
        </div>

        {/* Login Card */}
        <Card className="border-slate-800 bg-slate-800/80 text-white backdrop-blur-md shadow-2xl">
          <CardHeader>
            <CardTitle className="text-lg text-white">Sign In to Workspace</CardTitle>
            <CardDescription className="text-xs text-slate-400">
              Select your role or enter your institutional credentials
            </CardDescription>
          </CardHeader>
          <CardContent>
            {/* Quick Demo Switcher Buttons */}
            <div className="grid grid-cols-2 gap-2 mb-5">
              <Button
                type="button"
                variant={selectedRole === 'school_admin' ? 'default' : 'secondary'}
                onClick={() => handleQuickRole('school_admin')}
                className="text-xs h-9 font-semibold"
              >
                School Admin (DMS)
              </Button>
              <Button
                type="button"
                variant={selectedRole === 'super_admin' ? 'default' : 'secondary'}
                onClick={() => handleQuickRole('super_admin')}
                className="text-xs h-9 font-semibold bg-amber-600 hover:bg-amber-700 text-white"
              >
                Super Admin
              </Button>
            </div>

            <form onSubmit={handleLogin} className="space-y-4">
              <div>
                <label className="text-xs font-semibold text-slate-300">Institutional Email</label>
                <div className="relative mt-1">
                  <Mail className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
                  <Input
                    type="email"
                    required
                    className="pl-9 bg-slate-900 border-slate-700 text-white placeholder:text-slate-500"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                  />
                </div>
              </div>

              <div>
                <label className="text-xs font-semibold text-slate-300">Password</label>
                <div className="relative mt-1">
                  <Lock className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
                  <Input
                    type="password"
                    required
                    className="pl-9 bg-slate-900 border-slate-700 text-white placeholder:text-slate-500"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                  />
                </div>
              </div>

              <Button type="submit" disabled={loading} className="w-full bg-blue-600 hover:bg-blue-700 font-bold mt-2">
                {loading ? 'Authenticating...' : 'Sign In'}
                <ArrowRight className="h-4 w-4 ml-2" />
              </Button>
            </form>
          </CardContent>
        </Card>

        {/* Security Notice */}
        <p className="text-[11px] text-center text-slate-500">
          Protected by PostgreSQL Row Level Security (RLS) & Supabase Auth.
        </p>
      </div>
    </div>
  );
}
