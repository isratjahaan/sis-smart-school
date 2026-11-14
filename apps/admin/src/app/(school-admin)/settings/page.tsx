'use client';

import React, { useState } from 'react';
import { Settings, Save, CheckCircle, Palette, CreditCard, Shield, Bell } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { supabase, isSupabaseConfigured } from '@/lib/supabase/client';

export default function SettingsPage() {
  const [saved, setSaved] = useState(false);
  const [saving, setSaving] = useState(false);

  const [settings, setSettings] = useState({
    schoolName: 'SAS Smart School',
    principalName: 'Prof. Mohammad Rafiqul Islam',
    email: 'contact@dhakamodel.edu.bd',
    phone: '+8801711223344',
    address: 'House 42, Road 11, Dhanmondi, Dhaka',
    primaryColor: '#2563EB',
    secondaryColor: '#0F172A',
    accentColor: '#F59E0B',
    fontFamily: 'Inter',
    bkashNumber: '01711223344',
    nagadNumber: '01811223344',
    rocketNumber: '01911223344',
    autoSmsAbsent: true,
    onlineAdmission: true,
  });

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);

    if (isSupabaseConfigured) {
      try {
        const schoolId = '11111111-1111-1111-1111-111111111111';
        await supabase.from('school_settings').upsert({
          school_id: schoolId,
          primary_color: settings.primaryColor,
          secondary_color: settings.secondaryColor,
          accent_color: settings.accentColor,
          font_family: settings.fontFamily,
          payment_bkash_number: settings.bkashNumber,
          payment_nagad_number: settings.nagadNumber,
          payment_rocket_number: settings.rocketNumber,
          auto_sms_absent: settings.autoSmsAbsent,
          online_admission_enabled: settings.onlineAdmission,
          updated_at: new Date().toISOString(),
        }, { onConflict: 'school_id' });
      } catch (err) {
        console.error('Failed to update settings in Supabase:', err);
      }
    }

    setTimeout(() => {
      setSaving(false);
      setSaved(true);
    }, 400);
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">School Configuration & Branding</h1>
          <p className="text-sm text-slate-500">
            Control school identity, payment gateway merchant accounts, colors, and operational rules
          </p>
        </div>
        <Button onClick={handleSave} disabled={saving} className="bg-blue-600 hover:bg-blue-700 gap-2">
          <Save className="h-4 w-4" />
          <span>{saving ? 'Saving...' : 'Save Changes'}</span>
        </Button>
      </div>

      {saved && (
        <div className="p-4 rounded-xl bg-green-50 border border-green-200 text-green-800 flex items-center gap-2">
          <CheckCircle className="h-5 w-5 text-green-600" />
          <span className="font-semibold text-sm">
            School settings and branding tokens updated successfully!
          </span>
        </div>
      )}

      <form onSubmit={handleSave} className="space-y-6">
        {/* Branding & Visual Identity */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-base">
              <Palette className="h-4 w-4 text-blue-600" />
              <span>Theme & Visual Branding</span>
            </CardTitle>
            <CardDescription>
              Configured colors instantly propagate to the public school website and mobile applications
            </CardDescription>
          </CardHeader>
          <CardContent className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label className="text-xs font-semibold text-slate-600">Primary Brand Color</label>
              <div className="flex items-center gap-3 mt-1.5">
                <input
                  type="color"
                  className="h-10 w-12 rounded border border-slate-300 cursor-pointer p-0.5"
                  value={settings.primaryColor}
                  onChange={(e) => setSettings({ ...settings, primaryColor: e.target.value })}
                />
                <Input
                  className="font-mono text-xs uppercase"
                  value={settings.primaryColor}
                  onChange={(e) => setSettings({ ...settings, primaryColor: e.target.value })}
                />
              </div>
            </div>

            <div>
              <label className="text-xs font-semibold text-slate-600">Secondary Dark Color</label>
              <div className="flex items-center gap-3 mt-1.5">
                <input
                  type="color"
                  className="h-10 w-12 rounded border border-slate-300 cursor-pointer p-0.5"
                  value={settings.secondaryColor}
                  onChange={(e) => setSettings({ ...settings, secondaryColor: e.target.value })}
                />
                <Input
                  className="font-mono text-xs uppercase"
                  value={settings.secondaryColor}
                  onChange={(e) => setSettings({ ...settings, secondaryColor: e.target.value })}
                />
              </div>
            </div>

            <div>
              <label className="text-xs font-semibold text-slate-600">Accent Highlight Color</label>
              <div className="flex items-center gap-3 mt-1.5">
                <input
                  type="color"
                  className="h-10 w-12 rounded border border-slate-300 cursor-pointer p-0.5"
                  value={settings.accentColor}
                  onChange={(e) => setSettings({ ...settings, accentColor: e.target.value })}
                />
                <Input
                  className="font-mono text-xs uppercase"
                  value={settings.accentColor}
                  onChange={(e) => setSettings({ ...settings, accentColor: e.target.value })}
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Payment Gateway Accounts */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-base">
              <CreditCard className="h-4 w-4 text-emerald-600" />
              <span>Mobile Financial Services (MFS) Merchant Receivers</span>
            </CardTitle>
            <CardDescription>
              Receiver account numbers presented to students and parents during online payment
            </CardDescription>
          </CardHeader>
          <CardContent className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label className="text-xs font-semibold text-slate-600">bKash Merchant / Personal No.</label>
              <Input
                className="mt-1.5"
                placeholder="01700000000"
                value={settings.bkashNumber}
                onChange={(e) => setSettings({ ...settings, bkashNumber: e.target.value })}
              />
            </div>
            <div>
              <label className="text-xs font-semibold text-slate-600">Nagad Merchant No.</label>
              <Input
                className="mt-1.5"
                placeholder="01800000000"
                value={settings.nagadNumber}
                onChange={(e) => setSettings({ ...settings, nagadNumber: e.target.value })}
              />
            </div>
            <div>
              <label className="text-xs font-semibold text-slate-600">Rocket Account No.</label>
              <Input
                className="mt-1.5"
                placeholder="01900000000"
                value={settings.rocketNumber}
                onChange={(e) => setSettings({ ...settings, rocketNumber: e.target.value })}
              />
            </div>
          </CardContent>
        </Card>

        {/* Operational Policies */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-base">
              <Shield className="h-4 w-4 text-purple-600" />
              <span>Operational Toggles</span>
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center justify-between p-3 rounded-xl border border-slate-200">
              <div>
                <p className="text-sm font-semibold text-slate-800">Automated SMS Alert on Absence</p>
                <p className="text-xs text-slate-500">Instantly notify guardian phone when a student is marked absent</p>
              </div>
              <input
                type="checkbox"
                className="h-5 w-5 rounded text-blue-600 cursor-pointer"
                checked={settings.autoSmsAbsent}
                onChange={(e) => setSettings({ ...settings, autoSmsAbsent: e.target.checked })}
              />
            </div>

            <div className="flex items-center justify-between p-3 rounded-xl border border-slate-200">
              <div>
                <p className="text-sm font-semibold text-slate-800">Online Admission Application Portal</p>
                <p className="text-xs text-slate-500">Enable prospective students to submit admission forms on the school website</p>
              </div>
              <input
                type="checkbox"
                className="h-5 w-5 rounded text-blue-600 cursor-pointer"
                checked={settings.onlineAdmission}
                onChange={(e) => setSettings({ ...settings, onlineAdmission: e.target.checked })}
              />
            </div>
          </CardContent>
        </Card>
      </form>
    </div>
  );
}
