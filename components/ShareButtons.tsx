'use client';

import { useState } from 'react';
import { Link2, Share2 } from 'lucide-react';
import { shareContent, isNativeApp, hapticTap } from '@/lib/native';

interface ShareButtonsProps {
  title: string;
  url?: string;
}

export default function ShareButtons({ title, url }: ShareButtonsProps) {
  const [copied, setCopied] = useState(false);

  const getUrl = () => url ?? (typeof window !== 'undefined' ? window.location.href : '');

  const handleNativeShare = async () => {
    await hapticTap();
    await shareContent({ title, url: getUrl() });
  };

  const copyToClipboard = async () => {
    try {
      await navigator.clipboard.writeText(getUrl());
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      const textarea = document.createElement('textarea');
      textarea.value = getUrl();
      document.body.appendChild(textarea);
      textarea.select();
      document.execCommand('copy');
      document.body.removeChild(textarea);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  };

  const shareOnFacebook = () => {
    const shareUrl = `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(getUrl())}`;
    window.open(shareUrl, '_blank', 'noopener,noreferrer,width=600,height=400');
  };

  const shareOnTwitter = () => {
    const shareUrl = `https://twitter.com/intent/tweet?text=${encodeURIComponent(title)}&url=${encodeURIComponent(getUrl())}`;
    window.open(shareUrl, '_blank', 'noopener,noreferrer,width=600,height=400');
  };

  const btnClass = 'inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium border border-gray-300 dark:border-gray-600 text-gray-600 dark:text-gray-400 hover:border-treasure-400 hover:text-treasure-700 dark:hover:text-treasure-400 transition-all';

  // On native apps, show a single native share button
  if (isNativeApp()) {
    return (
      <div className="flex items-center gap-2 mt-3">
        <button type="button" onClick={handleNativeShare} className={btnClass}>
          <Share2 size={14} />
          Share
        </button>
      </div>
    );
  }

  return (
    <div className="flex items-center gap-2 mt-3">
      <Share2 size={16} className="text-gray-400" />
      <button type="button" onClick={copyToClipboard} className={btnClass}>
        <Link2 size={14} />
        {copied ? 'Copied!' : 'Copy Link'}
      </button>
      <button type="button" onClick={shareOnFacebook} className={btnClass}>
        Facebook
      </button>
      <button type="button" onClick={shareOnTwitter} className={btnClass}>
        X
      </button>
    </div>
  );
}
