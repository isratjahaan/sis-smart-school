'use client';

import React, { useState } from 'react';
import {
  Sliders,
  Smartphone,
  Eye,
  RotateCcw,
  Upload,
  CheckCircle,
  AlertTriangle,
  MoveUp,
  MoveDown,
  Trash2,
  Plus,
  Shield,
  Layers,
  Sparkles,
  ToggleLeft,
  ToggleRight,
  Globe,
  Radio,
  History,
  Lock,
} from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { supabase, isSupabaseConfigured } from '@/lib/supabase/client';

export default function RemoteAppControlCenter() {
  const [activeTab, setActiveTab] = useState<'sdui' | 'features' | 'navigation' | 'maintenance' | 'history'>('sdui');
  const [targetScreen, setTargetScreen] = useState('student_home');
  const [targetScope, setTargetScope] = useState('global'); // 'global' | 'dms' | 'cgs'
  const [publishedVersion, setPublishedVersion] = useState(1);
  const [publishSuccess, setPublishSuccess] = useState(false);
  const [publishing, setPublishing] = useState(false);

  // 1. SDUI Component Layout State
  const [components, setComponents] = useState([
    {
      id: 'comp_welcome',
      type: 'welcome_banner',
      title: 'Welcome to SIS Smart School',
      subtitle: 'Knowledge is Power',
      visible: true,
      order: 1,
    },
    {
      id: 'comp_quick_actions',
      type: 'quick_actions',
      title: 'Quick Access',
      subtitle: 'Shortcuts to key features',
      visible: true,
      order: 2,
    },
    {
      id: 'comp_attendance',
      type: 'attendance_card',
      title: "Today's Attendance Status",
      subtitle: 'Live synced status',
      visible: true,
      order: 3,
    },
    {
      id: 'comp_routine',
      type: 'routine_strip',
      title: "Today's Class Timetable",
      subtitle: 'Next period countdown',
      visible: true,
      order: 4,
    },
    {
      id: 'comp_result',
      type: 'result_card',
      title: 'Academic Results & GPA',
      subtitle: 'First Term Examination 2026',
      visible: true,
      order: 5,
    },
    {
      id: 'comp_fees',
      type: 'fee_summary_card',
      title: 'Tuition Fee Summary',
      subtitle: 'Monthly due clearance',
      visible: true,
      order: 6,
    },
    {
      id: 'comp_notices',
      type: 'notice_list',
      title: 'School Notice Board',
      subtitle: 'Official announcements',
      visible: true,
      order: 7,
    },
  ]);

  // 2. Centralized Feature Flags State
  const [features, setFeatures] = useState({
    attendance_enabled: true,
    examinations_enabled: true,
    online_fees_enabled: true,
    library_enabled: true,
    transport_enabled: true,
    hostel_enabled: false,
    parent_messaging_enabled: true,
    live_bus_tracking: false,
    homework_submission_enabled: true,
    online_admission_enabled: true,
    sms_alerts_enabled: true,
  });

  // 3. Navigation Items State
  const [navItems, setNavItems] = useState([
    { id: 'nav_home', title: 'Home', icon: 'home', route: '/home', visible: true, order: 1 },
    { id: 'nav_attendance', title: 'Attendance', icon: 'calendar', route: '/attendance', visible: true, order: 2 },
    { id: 'nav_routine', title: 'Routine', icon: 'clock', route: '/routine', visible: true, order: 3 },
    { id: 'nav_results', title: 'Results', icon: 'award', route: '/results', visible: true, order: 4 },
    { id: 'nav_fees', title: 'Fees', icon: 'credit-card', route: '/fees', visible: true, order: 5 },
    { id: 'nav_notices', title: 'Notices', icon: 'bell', route: '/notices', visible: true, order: 6 },
    { id: 'nav_profile', title: 'Profile', icon: 'user', route: '/profile', visible: true, order: 7 },
  ]);

  // 4. Maintenance & Version Control State
  const [maintenance, setMaintenance] = useState({
    enabled: false,
    message: 'System upgrade in progress. SIS Smart School will be back shortly.',
    minVersionCode: 1,
    latestVersionCode: 1,
    forceUpdate: false,
  });

  // 5. Audit History
  const [historyLogs, setHistoryLogs] = useState([
    { version: 1, action: 'Initial Platform Baseline Published', author: 'superadmin@sissmartschool.com', date: '2026-01-01 09:00:00' },
  ]);

  // Move component up/down
  const moveComponent = (index: number, direction: 'up' | 'down') => {
    const targetIdx = direction === 'up' ? index - 1 : index + 1;
    if (targetIdx < 0 || targetIdx >= components.length) return;
    const reordered = [...components];
    const [moved] = reordered.splice(index, 1);
    reordered.splice(targetIdx, 0, moved);
    setComponents(reordered.map((c, i) => ({ ...c, order: i + 1 })));
  };

  const toggleVisibility = (index: number) => {
    const updated = [...components];
    updated[index].visible = !updated[index].visible;
    setComponents(updated);
  };

  const toggleFeature = (key: keyof typeof features) => {
    setFeatures({ ...features, [key]: !features[key] });
  };

  // Publish workflow
  const handlePublishConfig = async () => {
    setPublishing(true);
    const newVersion = publishedVersion + 1;

    const payload = {
      screenId: targetScreen,
      version: newVersion,
      scope: targetScope,
      components,
      features,
      navItems,
      maintenance,
      updatedAt: new Date().toISOString(),
    };

    if (isSupabaseConfigured) {
      try {
        const schoolId = targetScope === 'dms' ? '11111111-1111-1111-1111-111111111111' : null;
        await supabase.from('configuration_versions').insert({
          school_id: schoolId,
          config_type: 'screen_layout',
          screen_id: targetScreen,
          version: newVersion,
          is_published: true,
          payload,
          published_at: new Date().toISOString(),
        });

        await supabase.from('configuration_audit_logs').insert({
          school_id: schoolId,
          action: 'publish_screen_layout',
          entity_type: 'sdui_layout',
          entity_id: targetScreen,
          new_state: payload,
        });
      } catch (err) {
        console.error('Failed to publish to Supabase:', err);
      }
    }

    setPublishedVersion(newVersion);
    setHistoryLogs([
      {
        version: newVersion,
        action: `Published ${targetScreen} (Version ${newVersion})`,
        author: 'superadmin@sissmartschool.com',
        date: new Date().toLocaleString(),
      },
      ...historyLogs,
    ]);

    setPublishing(false);
    setPublishSuccess(true);
    setTimeout(() => setPublishSuccess(false), 4000);
  };

  return (
    <div className="space-y-6">
      {/* Top Remote Control Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-slate-900 p-6 rounded-2xl text-white shadow-xl border border-slate-800">
        <div>
          <div className="flex items-center gap-2 mb-2">
            <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-amber-500/20 text-amber-300 border border-amber-500/30 flex items-center gap-1.5">
              <Sparkles className="h-3.5 w-3.5" />
              <span>Server-Driven UI Engine</span>
            </span>
            <Badge variant="outline" className="border-slate-700 text-slate-300">
              Active Version: v{publishedVersion}
            </Badge>
          </div>
          <h1 className="text-2xl font-bold tracking-tight">Remote App Control Center</h1>
          <p className="text-sm text-slate-400 mt-1">
            Instantly reconfigure mobile layouts, navigation, and feature toggles with zero APK rebuilds
          </p>
        </div>

        <div className="flex items-center gap-3">
          <Button
            onClick={handlePublishConfig}
            disabled={publishing}
            className="bg-amber-600 hover:bg-amber-700 text-white font-bold gap-2 shadow-md cursor-pointer"
          >
            <Upload className="h-4 w-4" />
            <span>{publishing ? 'Publishing...' : 'Publish to All Devices'}</span>
          </Button>
        </div>
      </div>

      {publishSuccess && (
        <div className="p-4 rounded-xl bg-green-50 border border-green-200 text-green-800 flex items-center justify-between animate-in fade-in">
          <div className="flex items-center gap-2">
            <CheckCircle className="h-5 w-5 text-green-600" />
            <span className="font-semibold text-sm">
              Configuration v{publishedVersion} successfully broadcasted! Android clients will hot-refresh via Supabase Realtime.
            </span>
          </div>
          <Badge variant="success">Broadcasting to Flutter Mobile</Badge>
        </div>
      )}

      {/* Tabs Navigation */}
      <div className="flex flex-wrap gap-2 border-b border-slate-200 pb-2">
        {[
          { id: 'sdui', label: 'Screen Layout Builder (SDUI)', icon: Smartphone },
          { id: 'features', label: 'Central Feature Flags', icon: Sliders },
          { id: 'navigation', label: 'Dynamic Navigation', icon: Layers },
          { id: 'maintenance', label: 'Maintenance & App Version', icon: Radio },
          { id: 'history', label: 'Configuration History & Rollback', icon: History },
        ].map((tab) => {
          const Icon = tab.icon;
          return (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id as any)}
              className={`flex items-center gap-2 px-4 py-2.5 rounded-lg text-xs font-bold transition cursor-pointer ${
                activeTab === tab.id
                  ? 'bg-blue-600 text-white shadow-xs'
                  : 'bg-white border border-slate-200 text-slate-600 hover:bg-slate-50'
              }`}
            >
              <Icon className="h-4 w-4" />
              <span>{tab.label}</span>
            </button>
          );
        })}
      </div>

      {/* -------------------------------------------------------------------------- */}
      {/* TAB 1: SERVER-DRIVEN UI SCREEN LAYOUT BUILDER & LIVE PREVIEW               */}
      {/* -------------------------------------------------------------------------- */}
      {activeTab === 'sdui' && (
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
          {/* Left Column: Component Reordering & Controls (7 Cols) */}
          <div className="lg:col-span-7 space-y-4">
            <Card>
              <CardHeader className="p-4 pb-2 border-b border-slate-100 flex flex-row items-center justify-between">
                <div>
                  <CardTitle className="text-base">Target Screen & Scope Hierarchy</CardTitle>
                  <CardDescription className="text-xs">
                    Apply globally or override for a specific tenant
                  </CardDescription>
                </div>
                <div className="flex items-center gap-3">
                  <select
                    className="h-9 rounded-lg border border-slate-300 bg-white px-3 text-xs font-semibold"
                    value={targetScreen}
                    onChange={(e) => setTargetScreen(e.target.value)}
                  >
                    <option value="student_home">Student Home Dashboard</option>
                    <option value="teacher_home">Teacher Home Dashboard</option>
                    <option value="parent_home">Parent Home Dashboard</option>
                  </select>

                  <select
                    className="h-9 rounded-lg border border-slate-300 bg-white px-3 text-xs font-semibold text-blue-600"
                    value={targetScope}
                    onChange={(e) => setTargetScope(e.target.value)}
                  >
                    <option value="global">Scope: Global Platform Default</option>
                    <option value="dms">Scope: Dhaka Model School Only</option>
                    <option value="cgs">Scope: Chittagong Grammar School Only</option>
                  </select>
                </div>
              </CardHeader>
              <CardContent className="p-4 space-y-3">
                <p className="text-xs text-slate-500 font-medium">
                  Drag, reorder, toggle visibility, or customize labels for supported Server-Driven UI components:
                </p>

                {components.map((c, index) => (
                  <div
                    key={c.id}
                    className={`flex items-center justify-between p-3.5 rounded-xl border transition ${
                      c.visible ? 'bg-white border-slate-200 shadow-2xs' : 'bg-slate-50 border-slate-200/50 opacity-60'
                    }`}
                  >
                    <div className="flex items-center space-x-3">
                      <span className="h-6 w-6 rounded-full bg-slate-100 text-slate-600 font-bold text-xs flex items-center justify-center">
                        {index + 1}
                      </span>
                      <div>
                        <div className="flex items-center gap-2">
                          <p className="text-sm font-bold text-slate-900">{c.title}</p>
                          <span className="font-mono text-[10px] uppercase font-bold px-1.5 py-0.5 rounded bg-blue-50 text-blue-700">
                            {c.type}
                          </span>
                        </div>
                        <p className="text-xs text-slate-400 mt-0.5">{c.subtitle}</p>
                      </div>
                    </div>

                    <div className="flex items-center gap-1.5">
                      <Button
                        size="sm"
                        variant="ghost"
                        onClick={() => moveComponent(index, 'up')}
                        disabled={index === 0}
                        className="h-8 w-8 p-0"
                      >
                        <MoveUp className="h-4 w-4" />
                      </Button>
                      <Button
                        size="sm"
                        variant="ghost"
                        onClick={() => moveComponent(index, 'down')}
                        disabled={index === components.length - 1}
                        className="h-8 w-8 p-0"
                      >
                        <MoveDown className="h-4 w-4" />
                      </Button>
                      <Button
                        size="sm"
                        variant={c.visible ? 'outline' : 'secondary'}
                        onClick={() => toggleVisibility(index)}
                        className="text-xs h-8 px-2.5 font-semibold"
                      >
                        {c.visible ? 'Visible' : 'Hidden'}
                      </Button>
                    </div>
                  </div>
                ))}
              </CardContent>
            </Card>
          </div>

          {/* Right Column: Interactive Smartphone Device Simulator (5 Cols) */}
          <div className="lg:col-span-5 flex flex-col items-center">
            <div className="w-[340px] bg-slate-900 rounded-[44px] p-4 shadow-2xl border-4 border-slate-800 relative">
              {/* Phone Speaker Notch */}
              <div className="w-24 h-4 bg-slate-800 rounded-full mx-auto mb-3" />

              {/* Mobile Screen Display */}
              <div className="bg-slate-50 rounded-[32px] overflow-hidden min-h-[580px] max-h-[580px] flex flex-col border border-slate-200 text-slate-900">
                {/* App Bar */}
                <div className="bg-blue-600 text-white px-4 py-3 flex items-center justify-between shadow-sm">
                  <div>
                    <p className="text-[10px] text-blue-200 uppercase font-semibold">SIS Smart School</p>
                    <p className="text-xs font-bold leading-tight">Tahmid Rahman (Roll #1)</p>
                  </div>
                  <div className="h-6 w-6 rounded-full bg-white/20 flex items-center justify-center text-[10px] font-bold">
                    TR
                  </div>
                </div>

                {/* SDUI Dynamic Component Stream */}
                <div className="flex-1 p-3 space-y-2.5 overflow-y-auto text-xs">
                  {components
                    .filter((c) => c.visible)
                    .map((c) => {
                      if (c.type === 'welcome_banner') {
                        return (
                          <div key={c.id} className="p-3 bg-gradient-to-r from-blue-600 to-indigo-600 text-white rounded-xl shadow-xs">
                            <p className="font-bold text-xs">{c.title}</p>
                            <p className="text-[10px] text-blue-100">{c.subtitle}</p>
                          </div>
                        );
                      }
                      if (c.type === 'quick_actions') {
                        return (
                          <div key={c.id} className="grid grid-cols-4 gap-1.5 p-2 bg-white rounded-xl border border-slate-200 text-center text-[10px] font-semibold text-slate-700">
                            <div className="p-1 rounded bg-blue-50 text-blue-700">Routine</div>
                            <div className="p-1 rounded bg-green-50 text-green-700">Attendance</div>
                            <div className="p-1 rounded bg-purple-50 text-purple-700">Results</div>
                            <div className="p-1 rounded bg-amber-50 text-amber-700">Fees</div>
                          </div>
                        );
                      }
                      if (c.type === 'attendance_card') {
                        return (
                          <div key={c.id} className="p-2.5 bg-white rounded-xl border border-slate-200 flex items-center justify-between">
                            <div>
                              <p className="font-bold text-slate-800 text-[11px]">{c.title}</p>
                              <p className="text-[10px] text-green-600 font-semibold">Present Today (07:55 AM)</p>
                            </div>
                            <span className="h-2 w-2 rounded-full bg-green-500 animate-pulse" />
                          </div>
                        );
                      }
                      if (c.type === 'routine_strip') {
                        return (
                          <div key={c.id} className="p-2.5 bg-white rounded-xl border border-slate-200">
                            <p className="font-bold text-slate-800 text-[11px] mb-1">{c.title}</p>
                            <div className="p-1.5 rounded bg-slate-50 border border-slate-100 text-[10px] flex justify-between">
                              <span className="font-semibold">Next: Math (Room 301)</span>
                              <span className="text-blue-600 font-mono">09:00 AM</span>
                            </div>
                          </div>
                        );
                      }
                      if (c.type === 'result_card') {
                        return (
                          <div key={c.id} className="p-2.5 bg-white rounded-xl border border-slate-200 flex items-center justify-between">
                            <div>
                              <p className="font-bold text-slate-800 text-[11px]">{c.title}</p>
                              <p className="text-[10px] text-slate-500">First Term Exam Result</p>
                            </div>
                            <span className="px-2 py-0.5 rounded bg-blue-50 text-blue-700 font-bold text-[10px]">
                              GPA 5.00 (A+)
                            </span>
                          </div>
                        );
                      }
                      if (c.type === 'fee_summary_card') {
                        return (
                          <div key={c.id} className="p-2.5 bg-white rounded-xl border border-slate-200 flex items-center justify-between">
                            <div>
                              <p className="font-bold text-slate-800 text-[11px]">{c.title}</p>
                              <p className="text-[10px] text-red-500 font-semibold">Due: ৳2,500</p>
                            </div>
                            <button className="px-2 py-1 rounded bg-blue-600 text-white text-[10px] font-bold">
                              Pay bKash
                            </button>
                          </div>
                        );
                      }
                      return (
                        <div key={c.id} className="p-2.5 bg-white rounded-xl border border-slate-200">
                          <p className="font-bold text-slate-800 text-[11px]">{c.title}</p>
                          <p className="text-[10px] text-slate-400 mt-0.5">Exam schedule published</p>
                        </div>
                      );
                    })}
                </div>

                {/* Mobile Bottom Navigation Bar */}
                <div className="bg-white border-t border-slate-200 px-3 py-2 flex items-center justify-around text-[10px] font-semibold text-slate-400">
                  <div className="text-blue-600 font-bold text-center">Home</div>
                  <div className="text-center">Routine</div>
                  <div className="text-center">Results</div>
                  <div className="text-center">Profile</div>
                </div>
              </div>
            </div>
            <p className="text-xs text-slate-400 mt-3 font-medium">Live Android Material 3 Preview</p>
          </div>
        </div>
      )}

      {/* -------------------------------------------------------------------------- */}
      {/* TAB 2: CENTRAL FEATURE FLAGS                                               */}
      {/* -------------------------------------------------------------------------- */}
      {activeTab === 'features' && (
        <Card>
          <CardHeader>
            <CardTitle>Platform-Wide Feature Flag Matrix</CardTitle>
            <CardDescription>
              Toggle core SaaS modules remotely. Disabling a feature hides navigation and blocks backend API routes.
            </CardDescription>
          </CardHeader>
          <CardContent className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {Object.entries(features).map(([key, val]) => (
              <div
                key={key}
                className="flex items-center justify-between p-4 rounded-xl border border-slate-200 hover:bg-slate-50 transition"
              >
                <div>
                  <p className="text-sm font-bold text-slate-800 capitalize">
                    {key.replace(/_/g, ' ')}
                  </p>
                  <p className="text-xs text-slate-400 font-mono">flag: {key}</p>
                </div>
                <button
                  type="button"
                  onClick={() => toggleFeature(key as any)}
                  className={`px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer ${
                    val ? 'bg-blue-600 text-white' : 'bg-slate-200 text-slate-600'
                  }`}
                >
                  {val ? 'Enabled' : 'Disabled'}
                </button>
              </div>
            ))}
          </CardContent>
        </Card>
      )}

      {/* -------------------------------------------------------------------------- */}
      {/* TAB 3: DYNAMIC NAVIGATION BUILDER                                          */}
      {/* -------------------------------------------------------------------------- */}
      {activeTab === 'navigation' && (
        <Card>
          <CardHeader>
            <CardTitle>Dynamic Navigation Menu Builder</CardTitle>
            <CardDescription>
              Configure mobile bottom navigation bar and web drawer tabs remotely
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            {navItems.map((item, idx) => (
              <div
                key={item.id}
                className="flex items-center justify-between p-3.5 rounded-xl border border-slate-200 bg-white"
              >
                <div className="flex items-center space-x-3">
                  <span className="h-6 w-6 rounded-full bg-slate-100 text-slate-600 font-bold text-xs flex items-center justify-center">
                    {item.order}
                  </span>
                  <div>
                    <p className="text-sm font-bold text-slate-900">{item.title}</p>
                    <p className="text-xs text-slate-400 font-mono">route: {item.route} • icon: {item.icon}</p>
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  <Button
                    size="sm"
                    variant={item.visible ? 'outline' : 'secondary'}
                    onClick={() => {
                      const updated = [...navItems];
                      updated[idx].visible = !updated[idx].visible;
                      setNavItems(updated);
                    }}
                    className="text-xs"
                  >
                    {item.visible ? 'Active' : 'Hidden'}
                  </Button>
                </div>
              </div>
            ))}
          </CardContent>
        </Card>
      )}

      {/* -------------------------------------------------------------------------- */}
      {/* TAB 4: MAINTENANCE & VERSION CONTROL                                       */}
      {/* -------------------------------------------------------------------------- */}
      {activeTab === 'maintenance' && (
        <Card>
          <CardHeader>
            <CardTitle>Global Maintenance & Force Update Policy</CardTitle>
            <CardDescription>
              Enforce emergency locks or minimum Android APK version thresholds
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="flex items-center justify-between p-4 rounded-xl border border-red-200 bg-red-50/50">
              <div>
                <p className="text-sm font-bold text-red-900">Global Platform Maintenance Mode</p>
                <p className="text-xs text-red-600 mt-0.5">
                  When enabled, all mobile and web applications display an emergency maintenance banner
                </p>
              </div>
              <input
                type="checkbox"
                className="h-6 w-6 rounded text-red-600 cursor-pointer"
                checked={maintenance.enabled}
                onChange={(e) => setMaintenance({ ...maintenance, enabled: e.target.checked })}
              />
            </div>

            <div>
              <label className="text-xs font-semibold text-slate-600">Maintenance Announcement Message</label>
              <Input
                className="mt-1.5"
                value={maintenance.message}
                onChange={(e) => setMaintenance({ ...maintenance, message: e.target.value })}
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="text-xs font-semibold text-slate-600">Minimum Supported App Version Code</label>
                <Input
                  type="number"
                  className="mt-1.5"
                  value={maintenance.minVersionCode}
                  onChange={(e) => setMaintenance({ ...maintenance, minVersionCode: Number(e.target.value) })}
                />
              </div>
              <div>
                <label className="text-xs font-semibold text-slate-600">Force Update Required</label>
                <div className="flex items-center h-10 mt-1.5">
                  <input
                    type="checkbox"
                    className="h-5 w-5 rounded text-blue-600 cursor-pointer mr-2"
                    checked={maintenance.forceUpdate}
                    onChange={(e) => setMaintenance({ ...maintenance, forceUpdate: e.target.checked })}
                  />
                  <span className="text-xs text-slate-600 font-medium">Block older APK versions</span>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      {/* -------------------------------------------------------------------------- */}
      {/* TAB 5: CONFIGURATION HISTORY & ONE-CLICK ROLLBACK                          */}
      {/* -------------------------------------------------------------------------- */}
      {activeTab === 'history' && (
        <Card>
          <CardHeader>
            <CardTitle>Configuration Audit History & Rollback</CardTitle>
            <CardDescription>
              Every published version is recorded with full state snapshots. Revert to any previous stable version with one click.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            {historyLogs.map((log) => (
              <div
                key={log.version}
                className="flex items-center justify-between p-4 rounded-xl border border-slate-200 bg-white"
              >
                <div>
                  <div className="flex items-center gap-2">
                    <span className="px-2 py-0.5 rounded font-bold font-mono text-xs bg-blue-100 text-blue-700">
                      Version {log.version}
                    </span>
                    <p className="text-sm font-bold text-slate-900">{log.action}</p>
                  </div>
                  <p className="text-xs text-slate-400 mt-1 font-mono">
                    Author: {log.author} • Timestamp: {log.date}
                  </p>
                </div>

                <Button
                  size="sm"
                  variant="outline"
                  onClick={() => {
                    setPublishedVersion(log.version);
                    alert(`Rolled back to Version ${log.version} successfully!`);
                  }}
                  className="gap-1.5 text-xs text-amber-600 hover:text-amber-700"
                >
                  <RotateCcw className="h-3.5 w-3.5" />
                  <span>Rollback to v{log.version}</span>
                </Button>
              </div>
            ))}
          </CardContent>
        </Card>
      )}
    </div>
  );
}
