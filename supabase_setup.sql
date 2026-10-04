-- SMART COOLING EXPERTS — SUPABASE FOUNDATION
-- یہ SQL موجودہ منصوبے کے لیے بنیادی جدولیں بناتا ہے۔
-- اسے اپنے Supabase SQL Editor میں صرف ایک بار چلائیں۔
-- RLS پالیسیوں کو اپنی ضرورت کے مطابق review کریں۔

create extension if not exists pgcrypto;

create table if not exists profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 full_name text,
 role text not null default 'customer' check (role in ('owner','admin','staff','technician','customer')),
 active boolean not null default true,
 created_at timestamptz not null default now()
);

create table if not exists customers (
 id uuid primary key default gen_random_uuid(),
 customer_id text unique not null default ('CUS-'||substr(replace(gen_random_uuid()::text,'-',''),1,10)),
 name text not null, phone text not null, email text, area text, address text, notes text,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table if not exists technicians (
 id uuid primary key default gen_random_uuid(),
 technician_id text unique not null default ('TECH-'||substr(replace(gen_random_uuid()::text,'-',''),1,8)),
 name text not null, phone text, email text, specialization text, status text default 'Active',
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table if not exists service_jobs (
 id uuid primary key default gen_random_uuid(),
 tracking_code text unique not null,
 customer_id text, customer_name text not null, phone text not null,
 area text, address text, service_type text, appliance text, brand text, model text, serial_number text,
 technician_id text, status text default 'New', complaint text, diagnosis text, work_performed text,
 visit_charges numeric default 0, service_charges numeric default 0, parts_charges numeric default 0,
 gas_charges numeric default 0, other_charges numeric default 0, discount numeric default 0,
 payment_method text, payment_status text default 'Pending', warranty_days integer default 0, notes text,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table if not exists sales (
 id uuid primary key default gen_random_uuid(),
 tracking_code text unique not null, customer_name text, phone text, product text, category text,
 brand text, model text, serial_number text, quantity numeric default 1, unit_price numeric default 0,
 discount numeric default 0, notes text, created_at timestamptz not null default now()
);

create table if not exists payments (
 id uuid primary key default gen_random_uuid(),
 payment_id text unique not null default ('PAY-'||substr(replace(gen_random_uuid()::text,'-',''),1,10)),
 tracking_code text, customer_name text, invoice_number text, amount numeric not null default 0,
 method text, status text default 'Paid', created_at timestamptz not null default now()
);

create table if not exists warranties (
 id uuid primary key default gen_random_uuid(),
 warranty_id text unique not null default ('WAR-'||substr(replace(gen_random_uuid()::text,'-',''),1,10)),
 tracking_code text, customer_name text, product_service text, warranty_days integer default 0,
 start_date date, end_date date, status text default 'Active', notes text, created_at timestamptz not null default now()
);

create table if not exists inventory (
 id uuid primary key default gen_random_uuid(),
 part_id text unique not null default ('PRD-'||substr(replace(gen_random_uuid()::text,'-',''),1,10)),
 name text not null, category text, brand text, model text, serial_number text,
 quantity numeric default 0, unit text default 'pcs', purchase_price numeric default 0,
 sale_price numeric default 0, reorder_level numeric default 0, supplier text,
 created_at timestamptz not null default now()
);

create table if not exists service_photos (
 id uuid primary key default gen_random_uuid(),
 tracking_code text not null, photo_type text, url text, storage_path text, uploaded_by uuid,
 created_at timestamptz not null default now()
);

create table if not exists live_locations (
 id uuid primary key default gen_random_uuid(),
 tracking_code text not null, technician_id text, status text, latitude double precision,
 longitude double precision, accuracy double precision, created_at timestamptz not null default now()
);

create table if not exists activity_logs (
 id uuid primary key default gen_random_uuid(),
 user_id uuid, user_email text, role text, action text, module text, details jsonb,
 created_at timestamptz not null default now()
);

create or replace view tracking_records as
select
 tracking_code, status, service_type, appliance, brand, model,
 warranty_days, null::date as warranty_end, customer_name, phone, area, address,
 created_at, updated_at
from service_jobs
union all
select
 tracking_code, 'SALE' as status, category as service_type, product as appliance, brand, model,
 null::integer as warranty_days, null::date as warranty_end, customer_name, phone, null as area, null as address,
 created_at, created_at as updated_at
from sales;

-- Public tracking must be intentionally limited.
alter table profiles enable row level security;
alter table customers enable row level security;
alter table technicians enable row level security;
alter table service_jobs enable row level security;
alter table sales enable row level security;
alter table payments enable row level security;
alter table warranties enable row level security;
alter table inventory enable row level security;
alter table service_photos enable row level security;
alter table live_locations enable row level security;
alter table activity_logs enable row level security;

-- Helper function: only owner/admin/staff/technician may use internal records.
create or replace function public.is_internal_user()
returns boolean language sql stable security definer set search_path=public
as $$
 select exists(select 1 from profiles p where p.id=auth.uid() and p.active=true and p.role in ('owner','admin','staff','technician'));
$$;

create or replace function public.is_owner_admin()
returns boolean language sql stable security definer set search_path=public
as $$
 select exists(select 1 from profiles p where p.id=auth.uid() and p.active=true and p.role in ('owner','admin'));
$$;

drop policy if exists "public tracking read" on service_jobs;
create policy "public tracking read" on service_jobs for select to anon,authenticated using (true);

drop policy if exists "public sales tracking read" on sales;
create policy "public sales tracking read" on sales for select to anon,authenticated using (true);

drop policy if exists "internal customers" on customers;
create policy "internal customers" on customers for all to authenticated using (public.is_internal_user()) with check (public.is_internal_user());

drop policy if exists "internal technicians" on technicians;
create policy "internal technicians" on technicians for all to authenticated using (public.is_internal_user()) with check (public.is_internal_user());

drop policy if exists "internal service" on service_jobs;
create policy "internal service" on service_jobs for all to authenticated using (public.is_internal_user()) with check (public.is_internal_user());

drop policy if exists "internal sales" on sales;
create policy "internal sales" on sales for all to authenticated using (public.is_internal_user()) with check (public.is_internal_user());

drop policy if exists "internal payments" on payments;
create policy "internal payments" on payments for all to authenticated using (public.is_internal_user()) with check (public.is_internal_user());

drop policy if exists "internal warranty" on warranties;
create policy "internal warranty" on warranties for all to authenticated using (public.is_internal_user()) with check (public.is_internal_user());

drop policy if exists "internal inventory" on inventory;
create policy "internal inventory" on inventory for all to authenticated using (public.is_internal_user()) with check (public.is_internal_user());

drop policy if exists "internal photos" on service_photos;
create policy "internal photos" on service_photos for all to authenticated using (public.is_internal_user()) with check (public.is_internal_user());

drop policy if exists "internal locations" on live_locations;
create policy "internal locations" on live_locations for all to authenticated using (public.is_internal_user()) with check (public.is_internal_user());

drop policy if exists "internal logs" on activity_logs;
create policy "internal logs" on activity_logs for select,insert to authenticated using (public.is_internal_user()) with check (public.is_internal_user());

-- After creating the owner's Auth user, run:
-- insert into profiles(id,full_name,role) values ('OWNER_AUTH_USER_UUID','Owner','owner')
-- on conflict (id) do update set role='owner', active=true;
