'use client';

import React from 'react';
import Link from 'next/link';
import { School, ArrowRight, Phone, Mail } from 'lucide-react';

interface NavbarProps {
  school: {
    name: string;
    slug: string;
    code: string;
    logo_url?: string | null;
    phone: string;
    email: string;
  };
}

export function Navbar({ school }: NavbarProps) {
  return (
    <header className="sticky top-0 z-50 bg-white/95 backdrop-blur-md border-b border-slate-200">
      {/* Top Contact Strip */}
      <div className="bg-slate-900 text-slate-300 text-xs py-2 px-6">
        <div className="max-w-7xl mx-auto flex items-center justify-between">
          <div className="flex items-center space-x-6">
            <span className="flex items-center gap-1.5">
              <Phone className="h-3.5 w-3.5 text-blue-400" /> {school.phone}
            </span>
            <span className="hidden sm:flex items-center gap-1.5">
              <Mail className="h-3.5 w-3.5 text-blue-400" /> {school.email}
            </span>
          </div>
          <div className="flex items-center space-x-4">
            <span className="text-[11px] text-slate-400">Government Approved • Code: {school.code}</span>
          </div>
        </div>
      </div>

      {/* Main Navigation Bar */}
      <div className="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <div className="h-11 w-11 rounded-xl bg-blue-600 text-white font-bold flex items-center justify-center text-lg shadow-sm">
            {school.code}
          </div>
          <div>
            <h1 className="font-extrabold text-lg text-slate-900 leading-tight tracking-tight">
              {school.name}
            </h1>
            <p className="text-xs text-slate-500 font-medium">Excellence in Education</p>
          </div>
        </div>

        <nav className="hidden lg:flex items-center space-x-8 text-sm font-semibold text-slate-700">
          <a href="#about" className="hover:text-blue-600 transition">About</a>
          <a href="#academics" className="hover:text-blue-600 transition">Academics</a>
          <a href="#notices" className="hover:text-blue-600 transition">Notice Board</a>
          <a href="#results" className="hover:text-blue-600 transition">Exam Results</a>
          <a href="#admission" className="hover:text-blue-600 transition">Online Admission</a>
          <a href="#contact" className="hover:text-blue-600 transition">Contact</a>
        </nav>

        <div className="flex items-center space-x-3">
          <a
            href="http://localhost:3000/login"
            target="_blank"
            rel="noreferrer"
            className="inline-flex items-center justify-center rounded-lg bg-blue-600 hover:bg-blue-700 text-white font-semibold text-xs px-4 py-2.5 transition shadow-sm"
          >
            <span>Portal Sign In</span>
            <ArrowRight className="h-3.5 w-3.5 ml-1.5" />
          </a>
        </div>
      </div>
    </header>
  );
}
