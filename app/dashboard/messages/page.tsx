'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { Loader2, Mail, MailOpen, Clock } from 'lucide-react';
import { formatDistanceToNow, parseISO } from 'date-fns';
import { createSupabaseBrowser } from '@/lib/supabase';
import { useAuth } from '@/components/AuthProvider';

interface ContactMessage {
  id: string;
  sender_name: string;
  sender_email: string;
  message: string;
  is_read: boolean;
  created_at: string;
  sale: {
    id: string;
    title: string;
  };
}

export default function MessagesPage() {
  const { user } = useAuth();
  const [messages, setMessages] = useState<ContactMessage[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) return;

    const fetchMessages = async () => {
      const supabase = createSupabaseBrowser();
      const { data } = await supabase
        .from('contact_messages')
        .select(`
          id, sender_name, sender_email, message, is_read, created_at,
          sale:garage_sales!inner(id, title)
        `)
        .eq('garage_sales.user_id', user.id)
        .order('created_at', { ascending: false });

      // Flatten the nested sale object
      const formatted = (data ?? []).map((msg: any) => ({
        ...msg,
        sale: Array.isArray(msg.sale) ? msg.sale[0] : msg.sale,
      }));

      setMessages(formatted);
      setLoading(false);
    };

    fetchMessages();
  }, [user]);

  const markAsRead = async (messageId: string) => {
    const supabase = createSupabaseBrowser();
    await supabase
      .from('contact_messages')
      .update({ is_read: true })
      .eq('id', messageId);

    setMessages((prev) =>
      prev.map((msg) =>
        msg.id === messageId ? { ...msg, is_read: true } : msg
      )
    );
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[200px]">
        <Loader2 size={24} className="animate-spin text-treasure-600" />
      </div>
    );
  }

  const unreadCount = messages.filter((m) => !m.is_read).length;

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h2 className="font-display text-xl font-bold text-gray-900">
          Messages
          {unreadCount > 0 && (
            <span className="ml-2 text-sm font-normal text-treasure-600">
              ({unreadCount} unread)
            </span>
          )}
        </h2>
      </div>

      {messages.length === 0 ? (
        <div className="text-center py-16 bg-white rounded-xl border border-gray-200">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-treasure-50 rounded-full">
            <Mail size={28} className="text-treasure-600" />
          </div>
          <h3 className="font-semibold text-gray-700 mt-4">No messages yet</h3>
          <p className="text-gray-500 mt-1 text-sm">
            When someone contacts you about a sale, their messages will appear here.
          </p>
        </div>
      ) : (
        <div className="space-y-3">
          {messages.map((msg) => (
            <div
              key={msg.id}
              className={`bg-white rounded-xl border p-4 transition-colors ${
                msg.is_read
                  ? 'border-gray-200'
                  : 'border-treasure-300 bg-treasure-50/30'
              }`}
              onClick={() => !msg.is_read && markAsRead(msg.id)}
            >
              <div className="flex items-start gap-3">
                <div className="mt-0.5">
                  {msg.is_read ? (
                    <MailOpen size={18} className="text-gray-400" />
                  ) : (
                    <Mail size={18} className="text-treasure-600" />
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between gap-2">
                    <span className="font-semibold text-gray-900 text-sm">
                      {msg.sender_name}
                    </span>
                    <span className="text-xs text-gray-400 flex items-center gap-1 flex-shrink-0">
                      <Clock size={12} />
                      {formatDistanceToNow(parseISO(msg.created_at), { addSuffix: true })}
                    </span>
                  </div>
                  <div className="text-xs text-gray-500 mt-0.5">
                    Re:{' '}
                    <Link
                      href={`/sale/${msg.sale.id}`}
                      className="text-treasure-600 hover:underline"
                    >
                      {msg.sale.title}
                    </Link>
                  </div>
                  <p className="text-sm text-gray-600 mt-2 whitespace-pre-line">
                    {msg.message}
                  </p>
                  <a
                    href={`mailto:${msg.sender_email}`}
                    className="inline-flex items-center gap-1.5 text-sm text-treasure-600 hover:text-treasure-700 font-medium mt-2"
                  >
                    <Mail size={14} />
                    Reply to {msg.sender_email}
                  </a>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
