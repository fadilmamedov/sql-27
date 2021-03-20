### Перечислить все таблицы и первичные ключи в базе данных

| Название таблицы | Первичный ключ |
|---|---|
| `actor` | `actor_id` |
| `address` | `address_id` |
| `category` | `category_id` |
| `city` | `city_id` |
| `country` | `country_id` |
| `customer` | `customer_id` |
| `film` | `film_id` |
| `film_actor` | `actor_id / film_id` |
| `film_category` | `film_id / category_id` |
| `inventory` | `inventory_id` |
| `language` | `language_id` |
| `payment` | `payment_id` |
| `rental` | `rental_id` |
| `staff` | `staff_id` |
| `store` | `store_id` |

---

### Вывести всех неактивных покупателей

```sql
select * from customer where active = 0;
```

---

### Вывести все фильмы, выпущенные в 2006 году

```sql
select * from film where release_year = 2006;
```

---

### Вывести 10 последних платежей за прокат фильмов

```sql
select * from payment order by payment_date desc limit 10;
```

---

### Вывести первичные ключи через запрос

```sql
select
  table_name,
  constraint_type,
  constraint_name
from
  information_schema.table_constraints
where
  constraint_type = 'PRIMARY KEY';
```

К сожалению сами первичные ключи (имена колонок?) вывести не удалось, не смог найти эту информацию в таблице `information_schema.table_constraints`

---

### Расширить запрос с первичными ключами, добавив информацию по типу данных

```sql
select
  information_schema.table_constraints.table_name,
  information_schema.table_constraints.constraint_type,
  information_schema.columns.column_name,
  information_schema.columns.data_type
from
  information_schema.table_constraints
left join
  information_schema.columns on information_schema.table_constraints.table_name = information_schema.columns.table_name
where
  information_schema.table_constraints.constraint_type = 'PRIMARY KEY';
```

И вот здесь тоже не получилось получить и сформировать те данные, которые необходимы