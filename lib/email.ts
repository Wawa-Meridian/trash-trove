import { Resend } from 'resend';
import { rateLimit } from '@/lib/rate-limit';
import { contactNotificationHtml } from '@/lib/email-templates';

const resend = process.env.RESEND_API_KEY
  ? new Resend(process.env.RESEND_API_KEY)
  : null;

const FROM_EMAIL = process.env.RESEND_FROM_EMAIL ?? 'TrashTrove <noreply@trashtrove.app>';

export async function sendContactNotification({
  sellerEmail,
  sellerName,
  saleTitle,
  saleId,
  senderName,
  senderEmail,
  message,
}: {
  sellerEmail: string;
  sellerName: string;
  saleTitle: string;
  saleId: string;
  senderName: string;
  senderEmail: string;
  message: string;
}): Promise<boolean> {
  if (!resend) {
    console.warn('RESEND_API_KEY not configured, skipping email');
    return false;
  }

  if (!sellerEmail) return false;

  // Daily rate limit: 90 emails/day (leave headroom below Resend's 100/day free tier)
  const { success: withinLimit } = rateLimit('email:daily', 90, 24 * 60 * 60 * 1000);
  if (!withinLimit) {
    console.warn('Daily email rate limit reached');
    return false;
  }

  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL ?? 'https://trashtrove.app';

  const { error } = await resend.emails.send({
    from: FROM_EMAIL,
    to: sellerEmail,
    replyTo: senderEmail,
    subject: `Someone is interested in "${saleTitle}"`,
    html: contactNotificationHtml({
      sellerName,
      saleTitle,
      saleId,
      senderName,
      senderEmail,
      message,
      baseUrl,
    }),
  });

  if (error) {
    console.error('Failed to send email:', error);
    return false;
  }

  return true;
}
