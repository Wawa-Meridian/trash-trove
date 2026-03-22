import Link from 'next/link';
import { US_STATES } from '@/lib/types';

interface StateWithCount {
  state: string;
  count: number;
}

export default function StateGrid({ stateCounts }: { stateCounts?: StateWithCount[] }) {
  const countMap = new Map(stateCounts?.map((s) => [s.state, s.count]) ?? []);

  const sortedStates = Object.entries(US_STATES).sort(([, a], [, b]) =>
    a.localeCompare(b)
  );

  return (
    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-3">
      {sortedStates.map(([code, name]) => {
        const count = countMap.get(code) ?? 0;
        return (
          <Link
            key={code}
            href={`/browse/${code}`}
            className="flex items-center justify-between p-3 rounded-lg border border-gray-200 hover:border-treasure-400 hover:bg-treasure-50 transition-all group"
          >
            <span className="font-medium text-gray-700 group-hover:text-treasure-800 text-sm">
              {name}
            </span>
            {count > 0 && (
              <span className="text-xs bg-treasure-100 text-treasure-700 px-2 py-0.5 rounded-full">
                {count}
              </span>
            )}
          </Link>
        );
      })}
    </div>
  );
}
