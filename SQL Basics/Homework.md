### Выведите магазины, имеющие больше 300-от покупателей

```sql
select
  customer.store_id,
  count(customer.store_id)
from
  customer
group by
  customer.store_id
```

### Выведите у каждого покупателя город в котором он живет

```sql
select
  customer.customer_id,
  customer.first_name,
  customer.last_name,
  customer.email,
  city.city
from
  customer
join
  address on customer.address_id = address.address_id
join
  city on address.city_id = city.city_id
```

### Выведите ФИО сотрудников и города магазинов, имеющих больше 300-от покупателей

```sql
select
  staff.first_name,
  staff.last_name,
  city.city
from
  staff
join
  (
    select
      store.store_id,
      store.address_id,
      count(store.store_id)
    from
      store
    join
      customer on store.store_id = customer.store_id
    group by
      store.store_id
    having
      count(store.store_id) > 300
  ) as st on st.store_id = staff.store_id
join
  address on st.address_id = address.address_id
join
  city on address.city_id = city.city_id
```


### Выведите количество актеров, снимавшихся в фильмах, которые сдаются в аренду за 2,99

```sql
select
  film.title,
  film.rental_rate,
  film_actor_count.actor_count
from
  film
join
  (
    select
      film_actor.film_id,
      count(actor.actor_id) as actor_count
    from
      actor
    join
      film_actor on actor.actor_id = film_actor.actor_id
    group by
      film_actor.film_id
  ) as film_actor_count on film.film_id = film_actor_count.film_id
where
  film.rental_rate = 2.99
```