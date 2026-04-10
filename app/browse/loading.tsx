import { Loader2 } from 'lucide-react';

export default function BrowseLoading() {
  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <div className="h-8 w-48 bg-gray-200 dark:bg-gray-700 rounded animate-pulse mb-2" />
      <div className="h-5 w-72 bg-gray-100 dark:bg-gray-800 rounded animate-pulse mb-8" />
      <div className="flex items-center justify-center min-h-[300px]">
        <Loader2 size={28} className="animate-spin text-treasure-600" />
      </div>
    </div>
  );
}
