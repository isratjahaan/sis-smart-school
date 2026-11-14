'use client';

import React from 'react';
import { ArrowRight, BookOpen, Award, CheckCircle } from 'lucide-react';

interface HeroProps {
  school: {
    name: string;
    principal_name?: string;
    established_year?: number;
  };
}

export function HeroSection({ school }: HeroProps) {
  return (
    <section className="relative overflow-hidden bg-gradient-to-b from-blue-50/70 via-white to-white py-20 lg:py-28 border-b border-slate-100">
      <div className="max-w-7xl mx-auto px-6">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          <div className="lg:col-span-7 space-y-6">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-100 text-blue-700 text-xs font-bold">
              <Award className="h-3.5 w-3.5" />
              <span>Established in {school.established_year || 1995} • Top Ranking Academic Institution</span>
            </div>

            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-slate-900 tracking-tight leading-[1.15]">
              Empowering Minds, Inspiring <span className="text-blue-600">Excellence</span>
            </h1>

            <p className="text-base sm:text-lg text-slate-600 leading-relaxed max-w-2xl">
              Welcome to <strong>{school.name}</strong>. We offer an integrated, world-class education blending national curriculum excellence with modern digital technologies, moral integrity, and leadership development.
            </p>

            <div className="flex flex-wrap items-center gap-4 pt-2">
              <a
                href="#admission"
                className="inline-flex items-center justify-center rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-bold text-sm px-6 py-3.5 shadow-md shadow-blue-500/20 transition"
              >
                <span>Apply for Admission</span>
                <ArrowRight className="h-4 w-4 ml-2" />
              </a>
              <a
                href="#results"
                className="inline-flex items-center justify-center rounded-xl bg-white hover:bg-slate-50 border border-slate-300 text-slate-800 font-semibold text-sm px-6 py-3.5 transition"
              >
                <span>Check Board Results</span>
              </a>
            </div>

            <div className="grid grid-cols-3 gap-6 pt-8 border-t border-slate-200">
              <div>
                <p className="text-2xl font-black text-slate-900">100%</p>
                <p className="text-xs text-slate-500 font-medium mt-0.5">SSC Pass Rate</p>
              </div>
              <div>
                <p className="text-2xl font-black text-blue-600">GPA 5.0</p>
                <p className="text-xs text-slate-500 font-medium mt-0.5">Average Performance</p>
              </div>
              <div>
                <p className="text-2xl font-black text-slate-900">30+</p>
                <p className="text-xs text-slate-500 font-medium mt-0.5">Expert Educators</p>
              </div>
            </div>
          </div>

          {/* Hero Visual Card */}
          <div className="lg:col-span-5 relative">
            <div className="relative rounded-3xl overflow-hidden shadow-2xl border-4 border-white bg-slate-900 aspect-4/3 flex items-center justify-center">
              <img
                src="https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=800&fit=crop"
                alt="School Campus"
                className="w-full h-full object-cover opacity-90"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-slate-950 via-transparent to-transparent" />
              <div className="absolute bottom-6 left-6 right-6 text-white space-y-1">
                <p className="text-xs text-blue-300 font-semibold uppercase tracking-wider">Campus View</p>
                <p className="text-lg font-bold leading-tight">{school.name} Campus</p>
                <p className="text-xs text-slate-300">Modern computer labs, science facilities & library</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
