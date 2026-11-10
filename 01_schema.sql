-- 01_schema.sql
-- A small billing-style dataset for SQL practice. All names and emails are fictional.

create table customers (
  id serial primary key,
  name text not null,
  email text not null,
  country text
);

create table plans (
  id serial primary key,
  name text not null,
  monthly_price numeric(10,2) not null
);

create table subscriptions (
  id serial primary key,
  customer_id int references customers(id),
  plan_id int references plans(id),
  status text check (status in ('active', 'past_due', 'cancelled')),
  started_at date
);

create table invoices (
  id serial primary key,
  customer_id int references customers(id),
  amount numeric(10,2) not null,
  currency text default 'USD',
  status text check (status in ('paid', 'open', 'void')),
  due_date date,
  paid_at date
);

create table payments (
  id serial primary key,
  invoice_id int references invoices(id),
  amount numeric(10,2) not null,
  status text check (status in ('succeeded', 'failed')),
  failure_reason text,
  attempted_at timestamptz
);

insert into customers (name, email, country) values
  ('Acme Analytics', 'billing@acme.example', 'DE'),
  ('Nordlicht Apps', 'finance@nordlicht.example', 'SE'),
  ('Paloma Studio', 'hola@paloma.example', 'ES'),
  ('Vistula Labs', 'admin@vistula.example', 'PL');

insert into plans (name, monthly_price) values
  ('Free', 0),
  ('Pro', 25),
  ('Team', 599);

insert into subscriptions (customer_id, plan_id, status, started_at) values
  (1, 2, 'active',   current_date - 200),
  (2, 3, 'past_due', current_date - 90),
  (3, 2, 'active',   current_date - 30),
  (4, 1, 'active',   current_date - 10);

insert into invoices (customer_id, amount, status, due_date, paid_at) values
  (1, 25,  'paid', current_date - 35, current_date - 35),
  (1, 25,  'paid', current_date - 5,  current_date - 5),
  (2, 599, 'open', current_date - 12, null),
  (3, 25,  'open', current_date + 3,  null),
  (2, 599, 'paid', current_date - 42, current_date - 40);

insert into payments (invoice_id, amount, status, failure_reason, attempted_at) values
  (1, 25,  'succeeded', null,                 now() - interval '35 days'),
  (2, 20,  'succeeded', null,                 now() - interval '5 days'),
  (3, 599, 'failed',    'card_declined',      now() - interval '12 days'),
  (3, 599, 'failed',    'insufficient_funds', now() - interval '9 days'),
  (5, 599, 'failed',    'expired_card',       now() - interval '42 days'),
  (5, 599, 'succeeded', null,                 now() - interval '40 days');
