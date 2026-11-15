'use client';

import React, { useState, useEffect } from 'react';
import {
  ShieldAlert,
  ShieldCheck,
  Lock,
  Unlock,
  Trash2,
  Smartphone,
  AlertTriangle,
  Radio,
  RefreshCw,
  PhoneCall,
  CheckCircle2,
} from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';

export default function AntiTheftControlPage() {
  const [loading, setLoading] = useState(false);
  const [deviceState, setDeviceState] = useState({
    is_locked: false,
    lock_message: 'This mobile device has been reported Lost/Stolen to SAS Smart School authority.',
    emergency_phone: '+8801711223344',
    wipe_data: false,
    updated_at: new Date().toISOString(),
  });
  const [customMessage, setCustomMessage] = useState(deviceState.lock_message);
  const [customPhone, setCustomPhone] = useState(deviceState.emergency_phone);
  const [statusNote, setStatusNote] = useState<string | null>(null);

  const fetchStatus = async () => {
    try {
      const res = await fetch('/api/mobile/device-security');
      const json = await res.json();
      if (json.success && json.data) {
        setDeviceState(json.data);
        if (json.data.lock_message) setCustomMessage(json.data.lock_message);
        if (json.data.emergency_phone) setCustomPhone(json.data.emergency_phone);
      }
    } catch (e) {
      console.error(e);
    }
  };

  useEffect(() => {
    fetchStatus();
  }, []);

  const handleAction = async (action: 'lock' | 'unlock' | 'wipe') => {
    setLoading(true);
    setStatusNote(null);
    try {
      const res = await fetch('/api/mobile/device-security', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action,
          message: customMessage,
          phone: customPhone,
        }),
      });
      const json = await res.json();
      if (json.success) {
        setDeviceState(json.data);
        setStatusNote(
          action === 'lock'
            ? '🚨 Stolen Lock command broadcasted! Mobile APK locked instantly.'
            : action === 'unlock'
            ? '🔓 Unlock signal broadcasted! Mobile APK restored to normal.'
            : '🗑️ Remote wipe & session terminate command broadcasted!'
        );
      } else {
        setStatusNote(`Error: ${json.error}`);
      }
    } catch (e: any) {
      setStatusNote(`Error: ${e.message}`);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Page Title & Status Banner */}
      <div className={`p-6 rounded-2xl text-white shadow-xl border transition-all ${
        deviceState.is_locked ? 'bg-red-950 border-red-800' : 'bg-slate-900 border-slate-800'
      }`}>
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <div className="flex items-center gap-2 mb-2">
              <span className={`px-2.5 py-0.5 rounded-full text-xs font-semibold flex items-center gap-1.5 ${
                deviceState.is_locked ? 'bg-red-500/20 text-red-300 border border-red-500/30' : 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30'
              }`}>
                {deviceState.is_locked ? <AlertTriangle className="h-3.5 w-3.5 animate-pulse" /> : <ShieldCheck className="h-3.5 w-3.5" />}
                <span>{deviceState.is_locked ? 'DEVICE EMERGENCY LOCK ACTIVE' : 'ALL MOBILE DEVICES SECURE'}</span>
              </span>
              <Badge variant="outline" className="border-slate-700 text-slate-300">
                School: SAS Smart School
              </Badge>
            </div>
            <h1 className="text-2xl font-bold tracking-tight">Anti-Theft Remote Mobile Control</h1>
            <p className="text-sm text-slate-300 mt-1">
              মোবাইল চুরি বা হারিয়ে গেলে অ্যাডমিন এখান থেকে সরাসরি মোবাইলের অ্যাপ সম্পূর্ণ লক, সাইরেন অ্যালার্ট ও ডেটা মুছে দিতে পারবেন।
            </p>
          </div>

          <Button
            onClick={fetchStatus}
            variant="outline"
            size="sm"
            className="border-slate-700 text-slate-200 hover:bg-slate-800 gap-2 shrink-0 cursor-pointer"
          >
            <RefreshCw className="h-4 w-4" />
            <span>Refresh Status</span>
          </Button>
        </div>
      </div>

      {statusNote && (
        <div className={`p-4 rounded-xl border flex items-center gap-3 animate-in fade-in ${
          statusNote.includes('🚨') ? 'bg-red-50 border-red-200 text-red-900 font-bold' : 'bg-emerald-50 border-emerald-200 text-emerald-900 font-semibold'
        }`}>
          <CheckCircle2 className="h-5 w-5 shrink-0 text-emerald-600" />
          <span>{statusNote}</span>
        </div>
      )}

      {/* Grid: Connected Device Status & Remote Trigger Actions */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left 2 Cols: Remote Control Controls */}
        <div className="lg:col-span-2 space-y-6">
          <Card className="border-slate-200 shadow-sm">
            <CardHeader>
              <CardTitle className="text-lg flex items-center gap-2">
                <Radio className="h-5 w-5 text-blue-600" />
                <span>Remote Command Center (রিমোট কন্ট্রোল কমান্ড)</span>
              </CardTitle>
              <CardDescription>
                নিচের যেকোনো কমান্ড দিলে সাথে সাথে ইন্টারনেটের মাধ্যমে সংযুক্ত শিক্ষার্থীর ফোনে কার্যকর হবে।
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              {/* Form Inputs for Lock Screen Message */}
              <div className="space-y-4 bg-slate-50 p-4 rounded-xl border border-slate-200">
                <div>
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider block mb-1">
                    Emergency Lock Screen Message (লক স্ক্রিনের বার্তা)
                  </label>
                  <Input
                    value={customMessage}
                    onChange={(e) => setCustomMessage(e.target.value)}
                    placeholder="This device belongs to SAS Smart School..."
                    className="bg-white"
                  />
                  <p className="text-[11px] text-slate-500 mt-1">চোর বা অচেনা ব্যক্তি মোবাইল ওপেন করলেই লাল স্ক্রিনে এই মেসেজটি বড় করে দেখতে পাবে।</p>
                </div>

                <div>
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider block mb-1">
                    School Security Hotline (স্কুল অফিসের যোগাযোগ নম্বর)
                  </label>
                  <div className="flex items-center gap-2">
                    <Input
                      value={customPhone}
                      onChange={(e) => setCustomPhone(e.target.value)}
                      placeholder="+8801711223344"
                      className="bg-white"
                    />
                  </div>
                  <p className="text-[11px] text-slate-500 mt-1">লক স্ক্রিনে ফোন করার জন্য এই হটলাইন নম্বর প্রদর্শিত হবে।</p>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                {/* 1. Lock Button */}
                <Button
                  onClick={() => handleAction('lock')}
                  disabled={loading || deviceState.is_locked}
                  className="bg-red-600 hover:bg-red-700 text-white font-bold h-14 flex flex-col items-center justify-center gap-1 shadow-md cursor-pointer"
                >
                  <div className="flex items-center gap-2">
                    <Lock className="h-4 w-4" />
                    <span>Lock Stolen Mobile</span>
                  </div>
                  <span className="text-[10px] font-normal opacity-90">মোবাইল সম্পূর্ণ লক করুন</span>
                </Button>

                {/* 2. Unlock Button */}
                <Button
                  onClick={() => handleAction('unlock')}
                  disabled={loading || !deviceState.is_locked}
                  className="bg-emerald-600 hover:bg-emerald-700 text-white font-bold h-14 flex flex-col items-center justify-center gap-1 shadow-md cursor-pointer"
                >
                  <div className="flex items-center gap-2">
                    <Unlock className="h-4 w-4" />
                    <span>Unlock Mobile</span>
                  </div>
                  <span className="text-[10px] font-normal opacity-90">মোবাইল আনলক করুন</span>
                </Button>

                {/* 3. Wipe Button */}
                <Button
                  onClick={() => handleAction('wipe')}
                  disabled={loading}
                  className="bg-amber-600 hover:bg-amber-700 text-white font-bold h-14 flex flex-col items-center justify-center gap-1 shadow-md cursor-pointer"
                >
                  <div className="flex items-center gap-2">
                    <Trash2 className="h-4 w-4" />
                    <span>Wipe Data & Logout</span>
                  </div>
                  <span className="text-[10px] font-normal opacity-90">ডেটা মুছে দিন ও লগআউট</span>
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Right Col: Live Device Preview Status */}
        <div className="space-y-6">
          <Card className="border-slate-200 shadow-sm">
            <CardHeader>
              <CardTitle className="text-base flex items-center gap-2">
                <Smartphone className="h-4 w-4 text-slate-700" />
                <span>Connected Target Device</span>
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="p-4 rounded-xl border bg-slate-50 space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-xs text-slate-500 font-medium">Student Name:</span>
                  <span className="text-xs font-bold text-slate-800">Tahmid Rahman</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-xs text-slate-500 font-medium">ID Number:</span>
                  <span className="text-xs font-mono font-bold bg-blue-100 text-blue-800 px-2 py-0.5 rounded">
                    SAS-2026-001
                  </span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-xs text-slate-500 font-medium">Device Target:</span>
                  <span className="text-xs font-semibold text-slate-700">MuMu Player / Android 12</span>
                </div>
                <div className="flex items-center justify-between pt-2 border-t border-slate-200">
                  <span className="text-xs text-slate-500 font-medium">Current Status:</span>
                  <Badge className={deviceState.is_locked ? 'bg-red-600 text-white' : 'bg-emerald-600 text-white'}>
                    {deviceState.is_locked ? '🚨 REMOTELY LOCKED' : '🟢 ONLINE / SECURE'}
                  </Badge>
                </div>
              </div>

              {/* Stolen Mode Simulator Preview */}
              <div className="p-4 rounded-xl border border-dashed border-slate-300 bg-slate-900 text-white text-center space-y-2">
                <p className="text-[11px] uppercase tracking-wider text-slate-400 font-bold">Mobile Screen Preview</p>
                <div className={`p-4 rounded-lg transition-all ${
                  deviceState.is_locked ? 'bg-red-900 border border-red-600' : 'bg-slate-800 border border-slate-700'
                }`}>
                  {deviceState.is_locked ? (
                    <div className="space-y-1">
                      <ShieldAlert className="h-8 w-8 text-red-400 mx-auto animate-bounce" />
                      <p className="text-xs font-bold text-white uppercase">DEVICE LOCKED BY SCHOOL</p>
                      <p className="text-[10px] text-red-200 leading-tight">{customMessage}</p>
                      <p className="text-[11px] font-bold text-amber-300 pt-1">Hotline: {customPhone}</p>
                    </div>
                  ) : (
                    <div className="space-y-1 py-3">
                      <ShieldCheck className="h-8 w-8 text-emerald-400 mx-auto" />
                      <p className="text-xs font-bold text-emerald-300">NORMAL DASHBOARD ACTIVE</p>
                      <p className="text-[10px] text-slate-400">Student can access results, routine & fees.</p>
                    </div>
                  )}
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
