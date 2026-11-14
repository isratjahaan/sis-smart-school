import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'SIS Smart School — Public School Web Portal',
  description: 'Enterprise Multi-Tenant School Information System',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="scroll-smooth">
      <body className="antialiased min-h-screen bg-white text-slate-900">
        {children}
      </body>
    </html>
  );
}
