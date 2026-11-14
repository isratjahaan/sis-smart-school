'use client';

import React from 'react';
import { Bell, Calendar, Download, FileText, ArrowRight } from 'lucide-react';

interface NoticeProps {
  notices: Array<{
    id: string;
    title: string;
    content: string;
    priority: string;
    created_at: string;
  }>;
}

export function NoticeBoardSection({ notices }: NoticeProps) {
  return (
    <section id="notices" className="py-20 bg-white border-b border-slate-200">
      <div className="max-w-7xl mx-auto px-6 space-y-10">
        <div className="flex flex-col md:flex-row md:items-end justify-between gap-4">
          <div>
            <span className="text-xs font-bold uppercase tracking-wider text-blue-600">Official Circulars</span>
            <h2 className="text-3xl font-extrabold text-slate-900 tracking-tight mt-1">
              Notice Board & Announcements
            </h2>
            <p className="text-sm text-slate-500 mt-1">
              Important circulars regarding examinations, admissions, and academic routines
            </p>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {notices.map((n) => (
            <div
              key={n.id}
              className="p-6 rounded-2xl border border-slate-200 bg-slate-50/50 hover:bg-slate-50 transition shadow-2xs space-y-3"
            >
              <div className="flex items-center justify-between">
                <span className={`px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase ${
                  n.priority === 'high' ? 'bg-red-100 text-red-700' : 'bg-blue-100 text-blue-700'
                }`}>
                  {n.priority} Priority
                </span>
                <span className="text-xs text-slate-400 flex items-center gap-1">
                  <Calendar className="h-3 w-3" /> {n.created_at}
                </span>
              </div>
              <h3 className="font-bold text-base text-slate-900 leading-snug">{n.title}</h3>
              <p className="text-xs text-slate-600 leading-relaxed line-clamp-3">{n.content}</p>
              <div className="pt-2 flex items-center justify-between border-t border-slate-200/60">
                <span className="text-[11px] font-semibold text-blue-600 flex items-center gap-1 cursor-pointer hover:underline">
                  <FileText className="h-3.5 w-3.5" /> Read Full Circular
                </span>
                <span className="text-[11px] text-slate-400">PDF Download Available</span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
