import React from 'react';
import { notFound } from 'next/navigation';
import { Navbar } from '@/components/Navbar';
import { HeroSection } from '@/components/HeroSection';
import { AboutSection } from '@/components/AboutSection';
import { NoticeBoardSection } from '@/components/NoticeBoardSection';
import { ResultCheckerSection } from '@/components/ResultCheckerSection';
import { OnlineAdmissionSection } from '@/components/OnlineAdmissionSection';
import { Footer } from '@/components/Footer';
import { supabase, isSupabaseConfigured } from '@/lib/supabase';

interface SchoolData {
  id: string;
  name: string;
  slug: string;
  code: string;
  phone: string;
  email: string;
  address: string;
  city?: string;
  established_year?: number;
  principal_name?: string;
}

const mockSchools: Record<string, SchoolData> = {
  'dhaka-model': {
    id: '11111111-1111-1111-1111-111111111111',
    name: 'Dhaka Model School',
    slug: 'dhaka-model',
    code: 'DMS',
    phone: '+8801711223344',
    email: 'contact@dhakamodel.edu.bd',
    address: 'House 42, Road 11, Dhanmondi, Dhaka',
    city: 'Dhaka',
    established_year: 1995,
    principal_name: 'Prof. Mohammad Rafiqul Islam',
  },
  'cgs-ctg': {
    id: '22222222-2222-2222-2222-222222222222',
    name: 'Chittagong Grammar School',
    slug: 'cgs-ctg',
    code: 'CGS',
    phone: '+8801819876543',
    email: 'admin@cgs.edu.bd',
    address: 'Plot 15, Nasirabad Hills, Chittagong',
    city: 'Chittagong',
    established_year: 2002,
    principal_name: 'Dr. Syeda Nusrat Jahan',
  },
};

const defaultNotices = [
  {
    id: '1',
    title: 'First Term Examination 2026 Schedule Published',
    content: 'Dear students and guardians, the schedule for the upcoming First Term Examination 2026 has been published. All students are requested to clear their academic fees before the exam commences.',
    priority: 'high',
    created_at: '2026-04-10',
  },
  {
    id: '2',
    title: 'Annual Sports Day 2026',
    content: 'Annual sports competition will be held on the school playground next Saturday. Attendance is mandatory for all students.',
    priority: 'normal',
    created_at: '2026-04-05',
  },
];

export default async function SchoolPublicPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  let school = mockSchools[slug];

  if (!school && isSupabaseConfigured) {
    try {
      const { data } = await supabase
        .from('schools')
        .select('*')
        .eq('slug', slug)
        .eq('status', 'active')
        .single();

      if (data) {
        school = data;
      }
    } catch (e) {
      console.error('Failed to query school from Supabase:', e);
    }
  }

  if (!school) {
    // Default to Dhaka Model School if slug is unknown
    school = mockSchools['dhaka-model'];
  }

  return (
    <div className="min-h-screen flex flex-col bg-white">
      <Navbar school={school} />
      <main className="flex-1">
        <HeroSection school={school} />
        <AboutSection school={school} />
        <NoticeBoardSection notices={defaultNotices} />
        <ResultCheckerSection />
        <OnlineAdmissionSection school={school} />
      </main>
      <Footer school={school} />
    </div>
  );
}
