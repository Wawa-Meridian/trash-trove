import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'List Your Garage Sale',
  description:
    'Post your garage sale on TrashTrove for free. Add photos, set your date and time, and reach local shoppers in your area.',
};

export default function CreateLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <>{children}</>;
}
