create view "user_transactions" as
select
  a."from" as user,
  to_timestamp(a."timestamp") as timestamp,
  case
    when b.id is null then false
    else true
  end is_first_use
from
  "sgd1"."transaction" as a
  left outer join "sgd1"."user" as b on a.timestamp = b."created_at_timestamp"
order by
  a."timestamp";
