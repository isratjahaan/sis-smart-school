import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'SIS Smart School — Enterprise Multi-Tenant Administration Ecosystem',
  description: 'Centralized Multi-Tenant SaaS School Information System',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="antialiased min-h-screen bg-slate-50 text-slate-900">
        {children}
      </body>
    </html>
  );
}
