create extension if not exists pgcrypto;
create extension if not exists btree_gist;
create table if not exists customers(id uuid primary key default gen_random_uuid(),full_name text not null,phone text not null unique,line_id text,email text,created_at timestamptz not null default now());
create table if not exists vehicles(id uuid primary key default gen_random_uuid(),name text not null,registration text unique,vehicle_type text default 'EV Sedan',active boolean not null default true,notes text,created_at timestamptz not null default now());
create table if not exists pricing_rules(id uuid primary key default gen_random_uuid(),name text not null default 'ราคามาตรฐาน',rate_per_km numeric(10,2) not null default 0,hourly_rate numeric(10,2) not null default 0,daily_rate numeric(10,2) not null default 0,minimum_fare numeric(10,2) not null default 300,active boolean not null default true,created_at timestamptz not null default now(),check(rate_per_km>=0 and hourly_rate>=0 and daily_rate>=0 and minimum_fare>=300));
create table if not exists bookings(id uuid primary key default gen_random_uuid(),booking_code text not null unique,customer_id uuid not null references customers(id),vehicle_id uuid references vehicles(id),origin_text text not null,destination_text text not null,origin_lat double precision,origin_lng double precision,destination_lat double precision,destination_lng double precision,travel_date date not null,pickup_time time not null,estimated_end timestamptz,service_type text not null check(service_type in ('one_way','round_trip','hourly','daily','airport','interprovincial')),passenger_count integer not null default 1,notes text,outbound_km numeric(10,2),return_km numeric(10,2),quoted_total numeric(10,2),deposit_required numeric(10,2) not null default 500,balance_due numeric(10,2),status text not null default 'new' check(status in ('new','quoted','pending_deposit','confirmed','in_progress','completed','cancelled','expired')),payment_status text not null default 'unpaid' check(payment_status in ('unpaid','slip_received','verified','refunded')),created_at timestamptz not null default now(),updated_at timestamptz not null default now());
create table if not exists fare_quotes(id uuid primary key default gen_random_uuid(),booking_id uuid not null references bookings(id) on delete cascade,pricing_rule_id uuid references pricing_rules(id),rate_per_km numeric(10,2),outbound_km numeric(10,2),return_km numeric(10,2),base_fare numeric(10,2),additional_fee numeric(10,2) default 0,discount numeric(10,2) default 0,total numeric(10,2) not null,deposit numeric(10,2) not null default 500,balance numeric(10,2) not null,valid_until timestamptz,document_path text,created_at timestamptz not null default now());
create table if not exists payments(id uuid primary key default gen_random_uuid(),booking_id uuid not null references bookings(id) on delete cascade,amount numeric(10,2) not null,method text default 'bank_transfer',slip_path text,verified_by uuid,verified_at timestamptz,status text not null default 'pending' check(status in ('pending','verified','rejected','refunded')),created_at timestamptz not null default now());
create table if not exists availability(id uuid primary key default gen_random_uuid(),booking_id uuid not null references bookings(id) on delete cascade,vehicle_id uuid not null references vehicles(id),starts_at timestamptz not null,ends_at timestamptz not null,status text not null default 'held' check(status in ('held','confirmed','released')),hold_expires_at timestamptz,created_at timestamptz not null default now(),check(ends_at>starts_at));
-- Prevent overlapping active reservations for the SAME vehicle. Expired/released holds do not block.
alter table availability drop constraint if exists availability_no_overlap;
alter table availability add constraint availability_no_overlap exclude using gist (vehicle_id with =, tstzrange(starts_at,ends_at,'[)') with &&) where (status in ('held','confirmed'));
create table if not exists notifications(id uuid primary key default gen_random_uuid(),booking_id uuid references bookings(id) on delete set null,channel text not null,status text not null default 'queued',message text,created_at timestamptz not null default now());
create table if not exists audit_logs(id uuid primary key default gen_random_uuid(),actor text,action text not null,entity text not null,entity_id uuid,details jsonb,created_at timestamptz not null default now());
create index if not exists bookings_date_status_idx on bookings(travel_date,status);
create index if not exists bookings_customer_idx on bookings(customer_id,created_at desc);
create index if not exists availability_vehicle_time_idx on availability(vehicle_id,starts_at,ends_at);
-- Insert a disabled-by-default starter rule. Admin must set real rates before accepting quotes.
insert into pricing_rules(name,rate_per_km,hourly_rate,daily_rate,minimum_fare,active)
select 'ตั้งค่าเริ่มต้น - กรุณากำหนดราคา',0,0,0,300,false
where not exists(select 1 from pricing_rules);
-- Production security: enable RLS. Public booking writes must go through validated server routes only.
alter table customers enable row level security;
alter table vehicles enable row level security;
alter table pricing_rules enable row level security;
alter table bookings enable row level security;
alter table fare_quotes enable row level security;
alter table payments enable row level security;
alter table availability enable row level security;
alter table notifications enable row level security;
alter table audit_logs enable row level security;
