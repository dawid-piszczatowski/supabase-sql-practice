-- 02_queries.sql
-- Questions a billing support agent asks, answered in SQL.

-- 1. Which invoices are overdue, and by how many days?
select i.id as invoice_id, c.name, i.amount, i.currency, i.due_date,
       current_date - i.due_date as days_overdue
from invoices i
join customers c on c.id = i.customer_id
where i.status = 'open' and i.due_date < current_date
order by days_overdue desc;

-- 2. Which payments failed in the last 30 days, and why?
select c.name, i.id as invoice_id, p.amount, p.failure_reason, p.attempted_at
from payments p
join invoices i on i.id = p.invoice_id
join customers c on c.id = i.customer_id
where p.status = 'failed' and p.attempted_at >= now() - interval '30 days'
order by p.attempted_at desc;

-- 3. How much has each customer paid in total?
select c.name, coalesce(sum(p.amount), 0) as total_paid
from customers c
left join invoices i on i.customer_id = c.id
left join payments p on p.invoice_id = i.id and p.status = 'succeeded'
group by c.name
order by total_paid desc;

-- 4. Which invoices have more than one failed payment attempt?
select i.id as invoice_id, c.name, count(*) as failed_attempts
from payments p
join invoices i on i.id = p.invoice_id
join customers c on c.id = i.customer_id
where p.status = 'failed'
group by i.id, c.name
having count(*) > 1;

-- 5. Invoice discrepancy: paid invoices where the amount collected does not match the amount invoiced.
select i.id as invoice_id, c.name, i.amount as invoiced,
       coalesce(sum(p.amount), 0) as collected
from invoices i
join customers c on c.id = i.customer_id
left join payments p on p.invoice_id = i.id and p.status = 'succeeded'
where i.status = 'paid'
group by i.id, c.name, i.amount
having coalesce(sum(p.amount), 0) <> i.amount;
