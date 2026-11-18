import type { Metadata } from 'next';
import './globals.css';
export const metadata: Metadata = { title:'EV Premium Taxi | จองรถออนไลน์', description:'จองรถ EV พร้อมคนขับ ราชบุรี และเดินทางทั่วประเทศ' };
export default function RootLayout({children}:{children:React.ReactNode}) { return <html lang="th"><body>{children}</body></html>; }
