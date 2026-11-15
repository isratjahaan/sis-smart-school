'use client';

import React, { useState, useEffect } from 'react';
import {
  Smartphone,
  Upload,
  CheckCircle2,
  Bell,
  Calendar,
  Award,
  CreditCard,
  Zap,
  Sparkles,
  Layers,
  Eye,
  EyeOff,
  MoveUp,
  MoveDown,
  RefreshCw,
} from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';

interface ComponentItem {
  id: string;
  type: string;
  title: string;
  subtitle?: string;
  visible: boolean;
  order: number;
}

export default function MobileDashboardControlPage() {
  const [publishing, setPublishing] = useState(false);
  const [publishSuccess, setPublishSuccess] = useState(false);
  const [version, setVersion] = useState(1);
  const [bannerTitle, setBannerTitle] = useState('Welcome, Tahmid Rahman');
  const [bannerSubtitle, setBannerSubtitle] = useState('Class 10 (Section A) • Roll #1');

  const [components, setComponents] = useState<ComponentItem[]>([
    { id: 'comp_welcome', type: 'welcome_banner', title: 'Welcome, Tahmid Rahman', subtitle: 'Class 10 (Section A) • Roll #1', visible: true, order: 1 },
    { id: 'comp_quick_actions', type: 'quick_actions', title: 'Quick Actions', subtitle: 'Shortcuts to key features', visible: true, order: 2 },
    { id: 'comp_attendance', type: 'attendance_card', title: "Today's Attendance Status", subtitle: 'Present • 94% Monthly Rate', visible: true, order: 3 },
    { id: 'comp_routine', type: 'routine_strip', title: "Today's Class Timetable", subtitle: 'Next: General Math (Room 301)', visible: true, order: 4 },
    { id: 'comp_result', type: 'result_card', title: 'First Term Examination 2026', subtitle: 'GPA: 5.00 (Golden A+)', visible: true, order: 5 },
    { id: 'comp_fees', type: 'fee_summary_card', title: 'Monthly Tuition Fee Due', subtitle: '৳ 3,500 due on 10th', visible: true, order: 6 },
    { id: 'comp_notices', type: 'notice_list', title: 'School Circulars & Notices', subtitle: 'Latest announcements', visible: true, order: 7 },
  ]);

  const fetchCurrentConfig = async () => {
    try {
      const res = await fetch('/api/mobile/sync?screenId=student_home');
      const json = await res.json();
      if (json.success && json.layout) {
        if (json.layout.components) setComponents(json.layout.components);
        if (json.version) setVersion(json.version);
        const welcome = json.layout.components.find((c: any) => c.type === 'welcome_banner');
        if (welcome) {
          setBannerTitle(welcome.title);
          setBannerSubtitle(welcome.subtitle || '');
        }
      }
    } catch (e) {
      console.error(e);
    }
  };

  useEffect(() => {
    fetchCurrentConfig();
  }, []);

  const toggleVisibility = (index: number) => {
    const updated = [...components];
    updated[index].visible = !updated[index].visible;
    setComponents(updated);
  };

  const moveComponent = (index: number, direction: 'up' | 'down') => {
    const targetIdx = direction === 'up' ? index - 1 : index + 1;
    if (targetIdx < 0 || targetIdx >= components.length) return;
    const reordered = [...components];
    const [moved] = reordered.splice(index, 1);
    reordered.splice(targetIdx, 0, moved);
    setComponents(reordered.map((c, i) => ({ ...c, order: i + 1 })));
  };

  const handlePublish = async () => {
    setPublishing(true);
    setPublishSuccess(false);
    try {
      // update banner component
      const updatedComps = components.map((c) => {
        if (c.type === 'welcome_banner') {
          return { ...c, title: bannerTitle, subtitle: bannerSubtitle };
        }
        return c;
      });

      const res = await fetch('/api/mobile/sync', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          screenId: 'student_home',
          title: 'SAS Smart School Dashboard',
          components: updatedComps,
        }),
      });

      const json = await res.json();
      if (json.success) {
        setVersion(json.version);
        setPublishSuccess(true);
        setTimeout(() => setPublishSuccess(false), 4000);
      }
    } catch (e) {
      console.error(e);
    } finally {
      setPublishing(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="bg-slate-900 p-6 rounded-2xl text-white shadow-xl border border-slate-800 flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 mb-2">
            <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-blue-500/20 text-blue-300 border border-blue-500/30 flex items-center gap-1.5">
              <Sparkles className="h-3.5 w-3.5" />
              <span>Real-Time App Sync Engine</span>
            </span>
            <Badge variant="outline" className="border-slate-700 text-slate-300">
              Live Version: v{version}
            </Badge>
          </div>
          <h1 className="text-2xl font-bold tracking-tight">Mobile App Dashboard Live Control</h1>
          <p className="text-sm text-slate-300 mt-1">
            ওয়েবসাইটে তথ্য বা কার্ড পরিবর্তন করলে সাথে সাথে মোবাইলের APK ড্যাশবোর্ডে রিয়েল-টাইমে আপডেট হবে।
          </p>
        </div>

        <div className="flex items-center gap-3">
          <Button
            onClick={handlePublish}
            disabled={publishing}
            className="bg-blue-600 hover:bg-blue-700 text-white font-bold gap-2 shadow-lg cursor-pointer"
          >
            <Upload className="h-4 w-4" />
            <span>{publishing ? 'Syncing to Mobile...' : 'Sync Live to Mobile APK'}</span>
          </Button>
        </div>
      </div>

      {publishSuccess && (
        <div className="p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-900 flex items-center gap-3 animate-in fade-in">
          <CheckCircle2 className="h-5 w-5 text-emerald-600" />
          <span className="font-semibold">সফলভাবে তথ্য সিঙ্ক হয়েছে! মোবাইল অ্যাপে (MuMu Player) পরিবর্তন লাইভ রিফ্লেক্ট হয়েছে।</span>
        </div>
      )}

      {/* Grid: Editor + Phone Mockup */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left 2 Cols: Editor Controls */}
        <div className="lg:col-span-2 space-y-6">
          {/* Welcome Banner Editor */}
          <Card className="border-slate-200 shadow-sm">
            <CardHeader>
              <CardTitle className="text-base flex items-center gap-2">
                <Sparkles className="h-4 w-4 text-blue-600" />
                <span>Dashboard Welcome Banner Customization</span>
              </CardTitle>
              <CardDescription>মোবাইলের ওপরের ব্যানারের টাইটেল ও সাবটাইটেল পরিবর্তন করুন</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <label className="text-xs font-bold text-slate-700 block mb-1">Banner Title (ব্যানারের শিরোনাম)</label>
                <Input
                  value={bannerTitle}
                  onChange={(e) => setBannerTitle(e.target.value)}
                  placeholder="e.g. Welcome, Tahmid Rahman"
                />
              </div>
              <div>
                <label className="text-xs font-bold text-slate-700 block mb-1">Banner Subtitle (সাবটাইটেল / নোটিশ)</label>
                <Input
                  value={bannerSubtitle}
                  onChange={(e) => setBannerSubtitle(e.target.value)}
                  placeholder="e.g. First Term Exam Starts Next Week"
                />
              </div>
            </CardContent>
          </Card>

          {/* Cards Visibility & Ordering */}
          <Card className="border-slate-200 shadow-sm">
            <CardHeader>
              <CardTitle className="text-base flex items-center gap-2">
                <Layers className="h-4 w-4 text-blue-600" />
                <span>Mobile Dashboard Cards (কার্ড নিয়ন্ত্রণ ও ক্রম)</span>
              </CardTitle>
              <CardDescription>মোবাইল ড্যাশবোর্ডে কোন কার্ডগুলো দেখাবে তা চালু বা বন্ধ করুন</CardDescription>
            </CardHeader>
            <CardContent className="space-y-3">
              {components.map((comp, idx) => (
                <div
                  key={comp.id}
                  className={`p-3.5 rounded-xl border flex items-center justify-between transition-all ${
                    comp.visible ? 'bg-white border-slate-200 shadow-xs' : 'bg-slate-50 border-slate-200 opacity-60'
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <span className="h-7 w-7 rounded-lg bg-blue-100 text-blue-800 text-xs font-bold flex items-center justify-center">
                      {comp.order}
                    </span>
                    <div>
                      <p className="text-sm font-bold text-slate-800">{comp.title}</p>
                      <p className="text-xs text-slate-500">{comp.subtitle || comp.type}</p>
                    </div>
                  </div>

                  <div className="flex items-center gap-2">
                    <Button
                      variant="ghost"
                      size="sm"
                      disabled={idx === 0}
                      onClick={() => moveComponent(idx, 'up')}
                      className="h-8 w-8 p-0 cursor-pointer"
                    >
                      <MoveUp className="h-4 w-4 text-slate-600" />
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      disabled={idx === components.length - 1}
                      onClick={() => moveComponent(idx, 'down')}
                      className="h-8 w-8 p-0 cursor-pointer"
                    >
                      <MoveDown className="h-4 w-4 text-slate-600" />
                    </Button>
                    <Button
                      variant={comp.visible ? 'outline' : 'secondary'}
                      size="sm"
                      onClick={() => toggleVisibility(idx)}
                      className="h-8 gap-1.5 cursor-pointer text-xs"
                    >
                      {comp.visible ? (
                        <>
                          <Eye className="h-3.5 w-3.5 text-emerald-600" />
                          <span>Visible</span>
                        </>
                      ) : (
                        <>
                          <EyeOff className="h-3.5 w-3.5 text-slate-400" />
                          <span>Hidden</span>
                        </>
                      )}
                    </Button>
                  </div>
                </div>
              ))}
            </CardContent>
          </Card>
        </div>

        {/* Right Col: Live Smartphone Preview */}
        <div className="space-y-6">
          <Card className="border-slate-200 shadow-sm">
            <CardHeader>
              <CardTitle className="text-base flex items-center gap-2">
                <Smartphone className="h-4 w-4 text-slate-700" />
                <span>Live Mobile Preview</span>
              </CardTitle>
            </CardHeader>
            <CardContent>
              {/* Phone Frame */}
              <div className="max-w-[300px] mx-auto bg-slate-950 p-3 rounded-[32px] shadow-2xl border-4 border-slate-800 space-y-3">
                {/* Status Bar */}
                <div className="flex items-center justify-between px-3 text-[10px] text-slate-400 font-mono">
                  <span>12:30</span>
                  <div className="flex items-center gap-1">
                    <span className="h-2 w-2 rounded-full bg-emerald-500"></span>
                    <span>SAS 4G</span>
                  </div>
                </div>

                {/* App Content */}
                <div className="bg-slate-900 rounded-[20px] p-3 space-y-2 text-white min-h-[420px]">
                  {/* Header in phone */}
                  <div className="flex items-center justify-between pb-2 border-b border-slate-800">
                    <span className="text-xs font-bold text-blue-400">SAS SMART SCHOOL</span>
                    <Badge variant="outline" className="text-[9px] border-slate-700 text-slate-300">STUDENT</Badge>
                  </div>

                  {/* Banner in phone */}
                  <div className="bg-gradient-to-r from-blue-600 to-indigo-700 p-3 rounded-xl text-white shadow-sm">
                    <p className="text-xs font-bold leading-tight">{bannerTitle}</p>
                    <p className="text-[10px] text-blue-100 mt-0.5">{bannerSubtitle}</p>
                  </div>

                  {/* Components preview */}
                  <div className="space-y-1.5 pt-1">
                    {components
                      .filter((c) => c.visible && c.type !== 'welcome_banner')
                      .map((c) => (
                        <div key={c.id} className="p-2 rounded-lg bg-slate-800 border border-slate-700 text-[11px] flex items-center justify-between">
                          <span className="font-semibold text-slate-200">{c.title}</span>
                          <span className="text-[9px] text-emerald-400 font-mono">LIVE</span>
                        </div>
                      ))}
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
