import { Loader2 } from 'lucide-react';

export default function Loading() {
  return (
    <div className="flex items-center justify-center min-h-[400px]">
      <Loader2 size={32} className="animate-spin text-treasure-600" />
    </div>
  );
}
