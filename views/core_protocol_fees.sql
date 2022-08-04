create view core_protocol_fees as
select
  fees.token,
  tokens.symbol,
  fees.amount,
  fees.amount * tokens."usd_price" as "usd_amount",
  fees.date,
  fees.type
from
  (
    select
      concat('0x', t1.token) as token,
      sum(t1.amount) as amount,
      timestamp as date,
      type
    from
      (
        select
          encode(token:: bytea, 'hex') as token,
          amount,
          date(to_timestamp(timestamp)) as timestamp,
          'Lending' as type
        from
          "sgd1"."pay_lending_fee"
        UNION ALL
        select
          encode(token:: bytea, 'hex') as token,
          amount,
          date(to_timestamp(timestamp)) as timestamp,
          'Borrowing' as type
        from
          "sgd1"."pay_borrowing_fee"
        UNION ALL
        select
          encode(token:: bytea, 'hex') as token,
          amount,
          date(to_timestamp(timestamp)) as timestamp,
          'Trading' as type
        from
          "sgd1"."pay_trading_fee"
      ) as t1
    group by
      token,
      timestamp,
      type
  ) as fees
  inner join (
    select
      round(avg("price"), 2) as "usd_price",
      date,
      token,
      symbol
    from
      (
        select
          a."id" as token,
          symbol,
          "last_price_usd" as price,
          lower(a."block_range"),
          date(to_timestamp(b."timestamp")) as date
        from
          "sgd1"."token" as a
          inner join "sgd1"."transaction" as b on b."block_number" = lower(a."block_range")
        order by
          a."vid"
      ) as t2
    group by
      token,
      symbol,
      date
  ) as tokens on fees.date = tokens.date
  and tokens.token = fees.token
order by
  tokens.date desc;
