'use client';

import { useState } from 'react';
import { Link2, Share2 } from 'lucide-react';

interface ShareButtonsProps {
  title: string;
  url?: string;
}

export default function ShareButtons({ title, url }: ShareButtonsProps) {
  const [copied, setCopied] = useState(false);

  const getUrl = () => url ?? window.location.href;

  const copyToClipboard = async () => {
    try {
      await navigator.clipboard.writeText(getUrl());
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      // Fallback for older browsers
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

  return (
    <div className="flex items-center gap-2 mt-3">
      <Share2 size={16} className="text-gray-400" />
      <button
        type="button"
        onClick={copyToClipboard}
        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium border border-gray-300 text-gray-600 hover:border-treasure-400 hover:text-treasure-700 transition-all"
      >
        <Link2 size={14} />
        {copied ? 'Copied!' : 'Copy Link'}
      </button>
      <button
        type="button"
        onClick={shareOnFacebook}
        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium border border-gray-300 text-gray-600 hover:border-treasure-400 hover:text-treasure-700 transition-all"
      >
        Facebook
      </button>
      <button
        type="button"
        onClick={shareOnTwitter}
        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium border border-gray-300 text-gray-600 hover:border-treasure-400 hover:text-treasure-700 transition-all"
      >
        X
      </button>
    </div>
  );
}
