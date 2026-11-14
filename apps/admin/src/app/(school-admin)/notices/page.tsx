'use client';

import React, { useState } from 'react';
import { Bell, Plus, CheckCircle, AlertTriangle, Send } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';

export default function NoticesPage() {
  const [showAddModal, setShowAddModal] = useState(false);
  const [newNotice, setNewNotice] = useState({
    title: '',
    content: '',
    targetAudience: 'all',
    priority: 'normal',
  });

  const [notices, setNotices] = useState([
    {
      id: '1',
      title: 'First Term Examination 2026 Schedule Published',
      content: 'Dear students and guardians, the schedule for the upcoming First Term Examination 2026 has been published. All students are requested to clear their academic fees before the exam commences.',
      targetAudience: 'all',
      priority: 'high',
      created_at: '2026-04-10',
      is_published: true,
    },
    {
      id: '2',
      title: 'Annual Sports Day 2026',
      content: 'Annual sports competition will be held on the school playground next Saturday. Attendance is mandatory for all students.',
      targetAudience: 'students',
      priority: 'normal',
      created_at: '2026-04-05',
      is_published: true,
    },
  ]);

  const handleCreateNotice = (e: React.FormEvent) => {
    e.preventDefault();
    const created = {
      id: String(Date.now()),
      title: newNotice.title,
      content: newNotice.content,
      targetAudience: newNotice.targetAudience,
      priority: newNotice.priority,
      created_at: new Date().toISOString().split('T')[0],
      is_published: true,
    };
    setNotices([created, ...notices]);
    setShowAddModal(false);
    setNewNotice({ title: '', content: '', targetAudience: 'all', priority: 'normal' });
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">Notice Board & Announcements</h1>
          <p className="text-sm text-slate-500">
            Publish official announcements with live push notification broadcast to students, parents, and teachers
          </p>
        </div>
        <Button onClick={() => setShowAddModal(true)} className="bg-blue-600 hover:bg-blue-700 gap-2">
          <Plus className="h-4 w-4" />
          <span>Publish Notice</span>
        </Button>
      </div>

      <div className="space-y-4">
        {notices.map((n) => (
          <Card key={n.id} className="hover:shadow-xs transition">
            <CardHeader className="pb-3 flex flex-row items-start justify-between">
              <div>
                <div className="flex items-center gap-2 mb-1.5">
                  <Badge variant={n.priority === 'high' ? 'destructive' : 'secondary'} className="uppercase text-[10px]">
                    {n.priority}
                  </Badge>
                  <span className="text-xs text-slate-400 font-medium">Audience: {n.targetAudience}</span>
                  <span className="text-xs text-slate-400">• Published on {n.created_at}</span>
                </div>
                <CardTitle className="text-lg">{n.title}</CardTitle>
              </div>
              <Badge variant="success">Live Broadcasted</Badge>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-slate-700 leading-relaxed">{n.content}</p>
            </CardContent>
          </Card>
        ))}
      </div>

      {showAddModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl border border-slate-100 space-y-4">
            <h3 className="font-bold text-lg text-slate-900">Publish New Notice</h3>
            <form onSubmit={handleCreateNotice} className="space-y-4">
              <div>
                <label className="text-xs font-semibold text-slate-600">Notice Title *</label>
                <Input
                  required
                  placeholder="e.g. Eid-ul-Fitr Vacation Announcement"
                  value={newNotice.title}
                  onChange={(e) => setNewNotice({ ...newNotice, title: e.target.value })}
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-xs font-semibold text-slate-600">Target Audience</label>
                  <select
                    className="h-10 w-full rounded-lg border border-slate-300 bg-white px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value={newNotice.targetAudience}
                    onChange={(e) => setNewNotice({ ...newNotice, targetAudience: e.target.value })}
                  >
                    <option value="all">All School</option>
                    <option value="students">Students Only</option>
                    <option value="parents">Parents Only</option>
                    <option value="teachers">Teachers Only</option>
                  </select>
                </div>
                <div>
                  <label className="text-xs font-semibold text-slate-600">Priority</label>
                  <select
                    className="h-10 w-full rounded-lg border border-slate-300 bg-white px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value={newNotice.priority}
                    onChange={(e) => setNewNotice({ ...newNotice, priority: e.target.value })}
                  >
                    <option value="normal">Normal</option>
                    <option value="high">High (Urgent Alert)</option>
                  </select>
                </div>
              </div>
              <div>
                <label className="text-xs font-semibold text-slate-600">Content *</label>
                <textarea
                  required
                  rows={4}
                  className="w-full rounded-lg border border-slate-300 p-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Write the full announcement text..."
                  value={newNotice.content}
                  onChange={(e) => setNewNotice({ ...newNotice, content: e.target.value })}
                />
              </div>
              <div className="flex justify-end gap-3 pt-2">
                <Button type="button" variant="outline" onClick={() => setShowAddModal(false)}>
                  Cancel
                </Button>
                <Button type="submit" className="bg-blue-600 hover:bg-blue-700">
                  Broadcast Now
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
