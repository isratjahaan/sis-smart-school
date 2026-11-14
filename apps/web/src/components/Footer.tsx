'use client';

import React from 'react';
import { School, Phone, Mail, MapPin, Smartphone } from 'lucide-react';

interface FooterProps {
  school: {
    name: string;
    code: string;
    address: string;
    phone: string;
    email: string;
    city?: string;
  };
}

export function Footer({ school }: FooterProps) {
  return (
    <footer id="contact" className="bg-slate-950 text-slate-400 py-16 text-xs">
      <div className="max-w-7xl mx-auto px-6 grid grid-cols-1 md:grid-cols-4 gap-10 pb-12 border-b border-slate-900">
        <div className="space-y-3">
          <div className="flex items-center space-x-2 text-white font-bold text-base">
            <div className="h-8 w-8 rounded-lg bg-blue-600 flex items-center justify-center font-black text-sm">
              {school.code}
            </div>
            <span>{school.name}</span>
          </div>
          <p className="text-slate-500 leading-relaxed">
            A premier secondary institution imparting progressive education, moral enlightenment, and technological literacy.
          </p>
        </div>

        <div>
          <h4 className="font-bold text-sm text-slate-200 uppercase tracking-wider mb-3">Quick Navigation</h4>
          <ul className="space-y-2">
            <li><a href="#about" className="hover:text-blue-400 transition">About Us</a></li>
            <li><a href="#notices" className="hover:text-blue-400 transition">Notice Board</a></li>
            <li><a href="#results" className="hover:text-blue-400 transition">Exam Results & GPA</a></li>
            <li><a href="#admission" className="hover:text-blue-400 transition">Online Admission</a></li>
            <li><a href="http://localhost:3000/login" target="_blank" className="text-blue-400 hover:underline">Staff & Student Portal</a></li>
          </ul>
        </div>

        <div>
          <h4 className="font-bold text-sm text-slate-200 uppercase tracking-wider mb-3">Campus Contact</h4>
          <ul className="space-y-2.5">
            <li className="flex items-start gap-2">
              <MapPin className="h-4 w-4 text-blue-400 shrink-0 mt-0.5" />
              <span>{school.address}</span>
            </li>
            <li className="flex items-center gap-2">
              <Phone className="h-4 w-4 text-blue-400 shrink-0" />
              <span>{school.phone}</span>
            </li>
            <li className="flex items-center gap-2">
              <Mail className="h-4 w-4 text-blue-400 shrink-0" />
              <span>{school.email}</span>
            </li>
          </ul>
        </div>

        <div>
          <h4 className="font-bold text-sm text-slate-200 uppercase tracking-wider mb-3">Tuition Fee Payment</h4>
          <p className="text-slate-500 leading-relaxed mb-3">
            Students and guardians can clear monthly tuition fees through official MFS channels:
          </p>
          <div className="space-y-1.5 font-mono text-slate-300">
            <p className="flex items-center justify-between p-2 rounded bg-slate-900 border border-slate-800">
              <span className="text-pink-400 font-bold">bKash:</span>
              <span>01711223344</span>
            </p>
            <p className="flex items-center justify-between p-2 rounded bg-slate-900 border border-slate-800">
              <span className="text-orange-400 font-bold">Nagad:</span>
              <span>01811223344</span>
            </p>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-6 pt-8 flex flex-col sm:flex-row items-center justify-between text-slate-500 text-[11px] gap-4">
        <p>© 2026 {school.name}. All rights reserved.</p>
        <p className="flex items-center gap-1">
          Powered by <strong className="text-blue-400 font-bold">SIS Smart School SaaS</strong> Ecosystem
        </p>
      </div>
    </footer>
  );
}
