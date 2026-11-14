import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'SAS Smart School — Official Web Portal',
  description: 'Official Web Portal and Online Information System for SAS Smart School',
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
