# EV Premium Taxi Online Booking

Responsive booking website starter for EV Premium Taxi. Includes customer booking UI, server-side fare calculation endpoint, booking intake endpoint, PostgreSQL schema, multi-vehicle overlap protection, and environment template.

## Important status
This is a development starter, not a production-ready deployed service. Google Maps, Supabase credentials, LINE credentials, admin authentication, admin CRUD screens, image/PDF quote generation, Excel export, and payment slip review must be configured/implemented before public launch. The sample customer page currently accepts manually entered kilometer values when Maps is not configured. Do not publish until these gaps are completed and tested.

## Requirements
- Node.js 20+
- Supabase project
- Google Maps Platform project with Routes API enabled and billing configured

## Setup
1. Copy `.env.example` to `.env.local` and fill the Supabase URL, anon key, service role key, and Google Maps server key.
2. In Supabase SQL Editor, run `supabase/schema.sql`.
3. Add at least one active pricing rule with real rates. Example (replace values first):

```sql
insert into pricing_rules(name,rate_per_km,hourly_rate,daily_rate,minimum_fare,active)
values ('ราคามาตรฐาน', 0, 0, 0, 300, true);
```

Set actual prices instead of zero before enabling bookings.
4. Install and run:

```bash
npm install
npm run dev
```

5. Open http://localhost:3000.

## Fare logic
- One-way, airport, interprovincial: outbound distance × per-km rate.
- Round trip: (outbound + return distance) × per-km rate.
- Hourly: hours × hourly rate.
- Daily: days × daily rate.
- Minimum fare: 300 THB.
- Deposit: 500 THB, manually verified by operator.
- Additional fees/discount fields are supported by the fare calculation library but must be exposed in the admin UI.

## Production checklist
- Implement Supabase Auth and admin-only authorization before exposing `/admin` or any privileged endpoint.
- Add server-side validation, rate limiting, CAPTCHA/abuse controls, and idempotency for public booking requests.
- Configure Google API key restrictions and billing alerts.
- Implement route-based kilometer calculation; remove manual kilometer entry from customer form after Maps is active.
- Add a vehicle assignment and availability-hold transaction; the exclusion constraint prevents overlapping reservations for the same vehicle.
- Add quote PNG/PDF generation and secure storage.
- Add LINE OA account linking / Messaging API; a typed LINE ID is not sufficient to push a message.
- Add manual slip upload and verification; never mark a payment as verified from a customer-submitted form.
- Add customer data access/deletion policy, privacy notice, consent, retention, backups, and audit trail.
- Configure deployment secrets in hosting; never commit `.env.local` or service-role keys.

## Environment variables
See `.env.example`. `SUPABASE_SERVICE_ROLE_KEY` and `GOOGLE_MAPS_API_KEY` must remain server-side only.
