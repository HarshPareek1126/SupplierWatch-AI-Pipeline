-- SupplierWatch schema (Supabase / PostgreSQL)

-- Every article ever processed. Used by Workflow 01 to skip repeats.
create table if not exists supplierwatch_seen (
  id bigint generated always as identity primary key,
  source_hash text not null unique,
  supplier text,
  title text,
  url text,
  published_at text,
  first_seen_at timestamptz not null default now()
);

-- Classified risk events (the ones that pass the relevance check).
create table if not exists supplierwatch_events (
  id serial primary key,
  supplier text,
  title text,
  url text,
  event_type text,
  severity integer,
  risk_score integer,
  reason text,
  created_at timestamptz default now(),
  source_hash text unique,
  published_at timestamptz
);

-- Hand-labeled headlines used by Workflow 04 (evaluation).
create table if not exists supplierwatch_eval (
  id bigint generated always as identity primary key,
  supplier text not null,
  title text not null unique,
  expected_type text check (expected_type in
    ('layoff','lawsuit','breach','bankruptcy','recall',
     'leadership_change','disruption','other','not_relevant'))
);

-- Duplicate guard: silently skip an insert when the hash already exists.
create or replace function public.skip_dup_hash() returns trigger
language plpgsql as $$
declare dup boolean;
begin
  execute format('select exists (select 1 from %I.%I where source_hash = $1)',
                 TG_TABLE_SCHEMA, TG_TABLE_NAME) into dup using new.source_hash;
  if dup then return null; end if;
  return new;
end $$;

drop trigger if exists events_skip_dup on public.supplierwatch_events;
create trigger events_skip_dup before insert on public.supplierwatch_events
for each row execute function public.skip_dup_hash();

drop trigger if exists seen_skip_dup on public.supplierwatch_seen;
create trigger seen_skip_dup before insert on public.supplierwatch_seen
for each row execute function public.skip_dup_hash();