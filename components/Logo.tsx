interface LogoProps {
  size?: number;
  className?: string;
}

export default function Logo({ size = 28, className }: LogoProps) {
  const s = size / 100;
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 100 100"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
    >
      {/* Slab card tilted, sticking out */}
      <g transform="rotate(12, 72, 22)">
        <rect x="55" y="0" width="24" height="38" rx="2" fill="#fef3c7" stroke="#e5e7eb" strokeWidth="1.5" />
        <rect x="58" y="4" width="18" height="12" rx="1" fill="#fde68a" />
        <rect x="58" y="19" width="12" height="2" rx="1" fill="#d1d5db" />
        <rect x="58" y="24" width="8" height="2" rx="1" fill="#d1d5db" />
        <rect x="58" y="29" width="14" height="2" rx="1" fill="#d1d5db" />
      </g>
      {/* Trash can lid handle */}
      <rect x="40" y="28" width="20" height="7" rx="3" fill="none" stroke="#c76b23" strokeWidth="3.5" />
      {/* Trash can lid */}
      <rect x="12" y="34" width="76" height="8" rx="3" fill="none" stroke="#c76b23" strokeWidth="3.5" />
      {/* Trash can body */}
      <rect x="18" y="42" width="64" height="52" rx="4" fill="none" stroke="#c76b23" strokeWidth="3.5" />
      {/* Trash lines */}
      <line x1="36" y1="54" x2="36" y2="82" stroke="#c76b23" strokeWidth="3" strokeLinecap="round" />
      <line x1="50" y1="54" x2="50" y2="82" stroke="#c76b23" strokeWidth="3" strokeLinecap="round" />
      <line x1="64" y1="54" x2="64" y2="82" stroke="#c76b23" strokeWidth="3" strokeLinecap="round" />
    </svg>
  );
}
