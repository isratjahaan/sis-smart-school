'use client';

import React from 'react';
import { Award, BookOpen, Heart, Shield, CheckCircle2 } from 'lucide-react';

interface AboutProps {
  school: {
    name: string;
    principal_name?: string;
  };
}

export function AboutSection({ school }: AboutProps) {
  return (
    <section id="about" className="py-20 bg-slate-50 border-b border-slate-200">
      <div className="max-w-7xl mx-auto px-6 space-y-12">
        <div className="text-center max-w-2xl mx-auto space-y-2">
          <span className="text-xs font-bold uppercase tracking-wider text-blue-600">About Our Institution</span>
          <h2 className="text-3xl font-extrabold text-slate-900 tracking-tight">
            Nurturing Tomorrow's Global Citizens
          </h2>
          <p className="text-sm text-slate-600">
            Dedicated to scholarly excellence, character development, and holistic student growth.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          {/* Principal's Message Card */}
          <div className="bg-white p-8 rounded-2xl border border-slate-200 shadow-sm space-y-4">
            <span className="text-xs font-bold text-blue-600 uppercase tracking-wider">Leadership Message</span>
            <h3 className="text-xl font-bold text-slate-900">Message from the Principal</h3>
            <p className="text-sm text-slate-600 leading-relaxed italic">
              "Education is not merely the accumulation of facts; it is the ignition of curiosity, the formation of high moral character, and the development of compassionate leaders. Here at {school.name}, we provide a nurturing sanctuary where every student discovers their latent gifts and attains the pinnacle of their potential."
            </p>
            <div className="pt-4 border-t border-slate-100 flex items-center space-x-3">
              <div className="h-10 w-10 rounded-full bg-blue-100 text-blue-700 font-bold flex items-center justify-center text-sm">
                PR
              </div>
              <div>
                <p className="font-bold text-sm text-slate-900">{school.principal_name || 'Prof. Mohammad Rafiqul Islam'}</p>
                <p className="text-xs text-slate-500">Principal & Chief Academic Officer</p>
              </div>
            </div>
          </div>

          {/* Core Pillars */}
          <div className="space-y-4">
            {[
              {
                title: 'Rigorous National Curriculum',
                desc: 'Full alignment with Bangladesh Education Board standard standards with advanced STEM labs.',
                icon: BookOpen,
              },
              {
                title: 'Modern Digital Infrastructure',
                desc: 'Smart classrooms, high-speed Wi-Fi, computer coding labs, and mobile learning ecosystem.',
                icon: Shield,
              },
              {
                title: 'Values & Character Development',
                desc: 'Emphasis on discipline, ethics, sportsmanship, and cultural heritage.',
                icon: Heart,
              },
            ].map((p, i) => {
              const Icon = p.icon;
              return (
                <div key={i} className="flex items-start space-x-4 p-4 rounded-xl bg-white border border-slate-200 shadow-2xs">
                  <div className="h-10 w-10 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center shrink-0">
                    <Icon className="h-5 w-5" />
                  </div>
                  <div>
                    <h4 className="font-bold text-sm text-slate-900">{p.title}</h4>
                    <p className="text-xs text-slate-600 mt-0.5 leading-relaxed">{p.desc}</p>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </section>
  );
}
