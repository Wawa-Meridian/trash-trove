export function contactNotificationHtml({
  sellerName,
  saleTitle,
  saleId,
  senderName,
  senderEmail,
  message,
  baseUrl,
}: {
  sellerName: string;
  saleTitle: string;
  saleId: string;
  senderName: string;
  senderEmail: string;
  message: string;
  baseUrl: string;
}): string {
  const saleUrl = `${baseUrl}/sale/${saleId}`;
  const escapedMessage = message
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/\n/g, '<br>');

  return `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body style="margin:0;padding:0;background-color:#fdf8f0;font-family:system-ui,-apple-system,sans-serif;">
  <div style="max-width:560px;margin:0 auto;padding:20px;">
    <!-- Header -->
    <div style="background-color:#c76b23;border-radius:12px 12px 0 0;padding:24px 32px;text-align:center;">
      <h1 style="margin:0;color:#fff;font-size:20px;font-weight:700;">
        🗑️ TrashTrove
      </h1>
    </div>

    <!-- Body -->
    <div style="background-color:#fff;border:1px solid #e5e7eb;border-top:none;border-radius:0 0 12px 12px;padding:32px;">
      <p style="margin:0 0 8px;color:#374151;font-size:16px;">
        Hi ${sellerName},
      </p>
      <p style="margin:0 0 24px;color:#374151;font-size:16px;">
        Someone is interested in your sale <strong>"${saleTitle}"</strong>!
      </p>

      <!-- Message card -->
      <div style="background-color:#f9fafb;border:1px solid #e5e7eb;border-radius:8px;padding:20px;margin-bottom:24px;">
        <p style="margin:0 0 4px;font-weight:600;color:#111827;font-size:14px;">
          ${senderName}
        </p>
        <p style="margin:0 0 12px;color:#6b7280;font-size:13px;">
          ${senderEmail}
        </p>
        <p style="margin:0;color:#374151;font-size:14px;line-height:1.6;">
          ${escapedMessage}
        </p>
      </div>

      <!-- CTA -->
      <div style="text-align:center;margin-bottom:24px;">
        <a href="mailto:${senderEmail}" style="display:inline-block;background-color:#c76b23;color:#fff;text-decoration:none;padding:12px 28px;border-radius:8px;font-weight:600;font-size:14px;">
          Reply to ${senderName}
        </a>
      </div>

      <p style="margin:0;color:#9ca3af;font-size:13px;text-align:center;">
        <a href="${saleUrl}" style="color:#c76b23;text-decoration:none;">View your listing</a>
      </p>
    </div>

    <!-- Footer -->
    <p style="text-align:center;color:#9ca3af;font-size:12px;margin-top:16px;">
      You're receiving this because someone contacted you on TrashTrove.
    </p>
  </div>
</body>
</html>`;
}
