'use client';

import React from 'react';
import { CreditCard, Check, Shield, Star, Zap } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { formatCurrency } from '@/lib/utils';

export default function SubscriptionsPage() {
  const plans = [
    {
      id: '1',
      name: 'Basic',
      priceMonthly: 2500,
      priceYearly: 25000,
      maxStudents: 250,
      maxTeachers: 20,
      storageMB: 2048,
      features: ['Daily Attendance Tracking', 'Examination Marks & GPA', 'Manual Fee Recording', 'Basic Android Mobile App'],
      activeCount: 0,
    },
    {
      id: '2',
      name: 'Standard',
      priceMonthly: 5000,
      priceYearly: 50000,
      maxStudents: 600,
      maxTeachers: 50,
      storageMB: 5120,
      popular: true,
      features: ['All Basic Features', 'Public School Website Portal', 'Online Fee Collection (bKash/Nagad)', 'Parent Push Notifications', 'Report Card PDF Export'],
      activeCount: 1,
    },
    {
      id: '3',
      name: 'Professional',
      priceMonthly: 9000,
      priceYearly: 90000,
      maxStudents: 1500,
      maxTeachers: 120,
      storageMB: 15360,
      features: ['All Standard Features', 'Server-Driven UI Customization', 'Automated Absent SMS Gateway', 'Live Timetable Routines', 'Digital Student ID Generation'],
      activeCount: 1,
    },
    {
      id: '4',
      name: 'Enterprise',
      priceMonthly: 18000,
      priceYearly: 180000,
      maxStudents: 5000,
      maxTeachers: 300,
      storageMB: 51200,
      features: ['All Professional Features', 'Custom White-Label Domain', 'Dedicated PostgreSQL Instance', 'Live Bus Tracking GPS', '24/7 SLA Priority Support'],
      activeCount: 0,
    },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-slate-900">SaaS Subscription Plans & Quotas</h1>
        <p className="text-sm text-slate-500">
          Configure multi-tenant plan pricing, student limits, feature entitlements, and active subscriber metrics
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {plans.map((p) => (
          <Card key={p.id} className={`flex flex-col relative ${p.popular ? 'border-blue-600 shadow-md ring-2 ring-blue-600/20' : ''}`}>
            {p.popular && (
              <span className="absolute -top-3 left-1/2 -translate-x-1/2 px-3 py-0.5 rounded-full text-[11px] font-bold bg-blue-600 text-white shadow-xs">
                Most Popular
              </span>
            )}
            <CardHeader className="pb-3">
              <div className="flex items-center justify-between">
                <CardTitle className="text-lg">{p.name}</CardTitle>
                <Badge variant="secondary">{p.activeCount} Active Schools</Badge>
              </div>
              <div className="mt-2">
                <span className="text-3xl font-extrabold text-slate-900">{formatCurrency(p.priceMonthly)}</span>
                <span className="text-xs text-slate-400"> / month</span>
              </div>
            </CardHeader>
            <CardContent className="flex-1 flex flex-col justify-between space-y-4 border-t border-slate-100 pt-3">
              <div className="space-y-2 text-xs text-slate-600">
                <p>Capacity: <strong className="text-slate-900">{p.maxStudents} Students</strong></p>
                <p>Faculty: <strong className="text-slate-900">{p.maxTeachers} Teachers</strong></p>
                <p>Storage: <strong className="text-slate-900">{(p.storageMB / 1024).toFixed(1)} GB</strong></p>

                <div className="pt-2 space-y-1.5 border-t border-slate-100">
                  {p.features.map((f, i) => (
                    <div key={i} className="flex items-center gap-2">
                      <Check className="h-3.5 w-3.5 text-green-600 shrink-0" />
                      <span>{f}</span>
                    </div>
                  ))}
                </div>
              </div>

              <Button variant="outline" className="w-full text-xs font-semibold">
                Edit Quota & Pricing
              </Button>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
