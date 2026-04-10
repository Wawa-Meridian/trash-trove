'use client';

import { Printer, ArrowLeft } from 'lucide-react';
import Link from 'next/link';

export default function PrintButton() {
  return (
    <div className="flex items-center gap-3">
      <Link href=".." className="btn-secondary flex items-center gap-2 text-sm">
        <ArrowLeft size={16} />
        Back to Sale
      </Link>
      <button
        onClick={() => window.print()}
        className="btn-primary flex items-center gap-2 text-sm"
      >
        <Printer size={16} />
        Print Flyer
      </button>
    </div>
  );
}
