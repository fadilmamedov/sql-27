/* 1. В каких городах больше одного аэропорта? */

select
  city,
  count(airport_name) as airport_count
from
  airports
group by
  city
having
  count(airport_name) > 1
order by
  airport_count desc

/*
  Группируем список аэропортов по городам (таблица airports)
  group by
    city

  Выводим
    - название города
    - кол-во аэропортов в нем, используя агрегатную функцию count
  select
    city,
    count(airport_name) as airport_count

  Отсортируем результат по кол-ву аэропортов в убывающем порядке
  order by
    airport_count desc

  В результирующем наборе оставим только те записи, где кол-во городов больше 1
  having
    count(airport_name) > 1
*/


/* 2. В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета? */

select
  airports.airport_name
from
  flights
inner join
  airports on airports.airport_code = flights.departure_airport or airports.airport_code = flights.arrival_airport
inner join
  (
    select
      aircraft_code
    from
      aircrafts
    order by
      "range" desc
    limit
      1
  ) as max_flight_distance_aircraft on flights.aircraft_code = max_flight_distance_aircraft.aircraft_code
group by
  airports.airport_name

/*
  Сначала найдем самолет с максимальной дальностью полета

  Из таблицы aircrafts выберем выберем модель самолета (aircraft_code)
  select
    aircraft_code
  from
    aircrafts

  Отсортируем результат по дальности полета (range) в убывающем порядке
  order by
    "range" desc

  Ограничим результат только одной записью, посколько нам нужен только
  один самолет с максимальной дальностью полета
  limit
    1

  Теперь найдем аэропорты, в которых есть рейсы, выполняемые найденным на предыдущем шаге самолетом

  Присоединим таблицу flights к таблице airports по следующей логике - код аэропорта должен быть либо
  аэропортом отправления, либо аэропортом прибытия (хотя мы можем проверять лишь аэропорт отправления)
  from
    airports
  inner join
    airports on airports.airport_code = flights.departure_airport or airports.airport_code = flights.arrival_airport

  Присоеденим к получившемуся результату таблицу со списком самолетов (в кол-ве одной штуки) с максимальной
  дальностью полета (max_flight_distance_aircraft) по ключу aircraft_code (модель самолета)
  inner join
    (
      select
        aircraft_code
      from
        aircrafts
      order by
        "range" desc
      limit
        1
    ) as max_flight_distance_aircraft on flights.aircraft_code = max_flight_distance_aircraft.aircraft_code

  В получившемся результате имеем список рейсов с названиями аэропортов и моделями самолетов (в нашем случае всего одна модель)
  Сгруппируем его по названию аэропорта
  group by
    airports.airport_name

  А в итоговом результате выведем названия аэропортов (уникальные из-за группировки)
  select
    airports.airport_name
*/

/* 3. Вывести 10 рейсов с максимальным временем задержки вылета */

select
  flight_no,
  actual_departure - scheduled_departure as "delay"
from
  flights
where
  actual_departure is not null
order by
  "delay" desc
limit
  10

/*
  Выведем из таблицы flights две колонки: номер рейса и задержку, которую
  рассчитываем как разницу между фактическим временем вылета и запланированным
  времем вылета
  select
    flight_no,
    actual_departure - scheduled_departure as "delay"
  from
    flights

  Для некоторых рейсов фактическое время вылета отсутствует, что значит, что самолет не вылетел.
  Исключим такие рейсы из результирующего набора данных
  where
    actual_departure is not null

  Посколько нам нужно найти 10 рейсов с максимальным временем задержки вылета,
  отсортируем данные по столбцу delay по убыванию и оставим только 10 записей
  order by
    "delay" desc
  limit
    10
*/

/* 4. Были ли брони, по которым не были получены посадочные талоны? */

select
  case
    when count(bookings.book_ref) > 0 then 'Да. Есть бронирования, по которым не были получены посадочные талоны'
    else 'Нет. Нет таких бронирований, по которым не были получены посадочные талоны'
  end as answer
from
  bookings
inner join
  tickets on tickets.book_ref = bookings.book_ref
inner join
  ticket_flights on ticket_flights.ticket_no = tickets.ticket_no
left join
  boarding_passes on boarding_passes.ticket_no = ticket_flights.ticket_no and boarding_passes.flight_id = ticket_flights.flight_id
where
  boarding_passes.boarding_no is null

/*
  Выполняем первоначальную выборку из таблицы bookings, и соединяем ее с таблицей tickets,
  чтобы получить номера билетов по ключу book_ref (номер брони)
  from
    bookings
  inner join
    tickets on tickets.book_ref = bookings.book_ref

  Получившийся результат соединяем с таблицей ticket_flights по ключу ticket_no (номер билета),
  чтобы получить все рейсы по билетам, посколько один билет может включать в себя один или несколько перелетов
  inner join
    ticket_flights on ticket_flights.ticket_no = tickets.ticket_no

  Теперь к получившемуся результату присоеденим таблицу boarding_passes по двум ключам -
  ticket_no и flight_id (номер билета и идентификатор перелета). Здесь уже мы
  используем left join, потому что теоретически возможно, что по билету на рейс не был
  получен посадочный талон. В таком случае у нас будут пропущенные значения (например boarding_no, seat_no)
  таблицы boarding_passes для некоторых строк
  left join
    boarding_passes on boarding_passes.ticket_no = ticket_flights.ticket_no and boarding_passes.flight_id = ticket_flights.flight_id

  Чтобы найти только те билеты на перелеты, где не был получен посадончый талон, отфильтруем результат
  where
    boarding_passes.boarding_no is null

  Поскольку нам нужно найти именно кол-во броней, то мы можем подсчитать их кол-во в получившемся
  результате, и это будут как раз те брони, по которым не был получен посадочный талон хотя бы для одного рейса.
  Исходя из постановки вопроса, выведем просто ответ на вопрос в виде строки
  select
    case
      when count(bookings.book_ref) > 0 then 'Да. Есть бронирования, по которым не были получены посадочные талоны'
      else 'Нет. Нет таких бронирований, по которым не были получены посадочные талоны'
    end as answer
*/

/* 5. Найдите свободные места для каждого рейса, их % отношение к общему количеству мест в самолете.
      Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров из каждого аэропорта на каждый день.
      Т.е. в этом столбце должна отражаться накопительная сумма - сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах за день */

select
  flights.flight_id,
  flights.flight_no,
  flights.departure_airport,
  aircrafts_details.seat_count,
  flights_passengers_details.passengers_count,
  round(((aircrafts_details.seat_count - flights_passengers_details.passengers_count)::numeric / aircrafts_details.seat_count * 100), 2) as free_seats_percentage,
  flights.actual_departure,
  sum(flights_passengers_details.passengers_count) over (partition by flights.departure_airport, date(flights.actual_departure) order by flights.actual_departure)
from
  flights
inner join
  (
    select
      aircrafts.aircraft_code,
      aircrafts.model as aircraft_model,
      count(seats.seat_no) as seat_count
    from
      aircrafts
    inner join
      seats using(aircraft_code)
    group by
      aircrafts.aircraft_code
  ) as aircrafts_details using(aircraft_code)
inner join
  (
    select
      flights.flight_id,
      count(boarding_passes.boarding_no) as passengers_count
    from
      flights
    inner join
      ticket_flights using(flight_id)
    left join
      boarding_passes using(ticket_no, flight_id)
    where
      flights.actual_departure is not null and
      flights.status <> 'Cancelled'
    group by
      flights.flight_id
  ) as flights_passengers_details using(flight_id)
order by
  flights.departure_airport, flights.actual_departure

/*
  Для получения итогового сначала сформулируем подзапросы

  Первый подзапрос, который нам понадобится - список моделей самолетов с общим кол-вом мест в них
  select
    aircrafts.aircraft_code,
    aircrafts.model as aircraft_model,
    count(seats.seat_no) as seat_count
  from
    aircrafts
  inner join
    seats using(aircraft_code)
  group by
    aircrafts.aircraft_code

  Возьмем таблицу aircrafts, соединим ее с таблицей seats по ключу aircraft_code (код самолета),
  чтобы получить места места в самолете. Сгруппируем результат по коду самолета и выведем
  код самолета, модель самолета и общее кол-во мест в самолете.
  Выберем псевдоним для этого подзапроса - aircrafts_details

  Второй подзапрос - кол-во пассажиров для каждого перелета
  select
    flights.flight_id,
    count(boarding_passes.boarding_no) as passengers_count
  from
    flights
  inner join
    ticket_flights using(flight_id)
  left join
    boarding_passes using(ticket_no, flight_id)
  where
    flights.actual_departure is not null and
    flights.status <> 'Cancelled'
  group by
    flights.flight_id

  Возьмем таблицу flights, соеденими ее с таблицей ticket_flights по ключу flight_id (номер перелета).
  Получившийся результат соединим с таблицей boarding_passes по двум ключам - ticket_no и flight_id
  (номер билета и номер перелета).
  Здесь интересно отметить, что мы могли бы использовать inner join, чтобы отфильтровать те рейсы,
  по которым не было получено ни одног посадочного талона, считая, что в таком случае рейс не должен
  состоятся. Однако, давайте примем, что даже в таком случае рейс состоялся с нулевым заполнением,
  и поэтому будем использовать left join. Отменные рейсы отфильтруем далее.
  Теперь оставим только состоявшиеся рейсы. Их можно найти по следующей логике - у них есть значение
  в колонке actual_departure и статус не равен Cancelled
  Теперь осталось только сгрупиировать перелеты по их идентификатору flight_id и вывести номер
  перелета и кол-во пассажиров на нем
  Выберем псевдоним для этого подзапроса - flights_passengers_details

  Теперь финальный запрос.
  Возьмем таблицу flights и присоеденим к ней таблицу подзапроса aircrafts_details по ключу
  aircraft_code (код самолета)
  К получившемуся результату присоединим таблицу подзапроса flights_passengers_details по ключу
  flight_id (идентификатор перелета)
  Сгруппируем результат сразу по двум полям - аэропорт отправления и фактическая дата вылета.
  Это нам нужно, потому что мы будем добавлять суммарное кол-во вывезенных пассажирова из каждого
  аэропорта на каждый день с накопительным итогом
  Выведем следующие столбцы:
  - Идентификатор перелета
  - Номер рейса
  - Аэропорт отправления
  - Общее кол-во мест в самолете
  - Кол-во пассажирова в самолете
  - Процент свободных мест в самолете, который мы вычисляем по формуле и округляем до 2 знаков после запятой
  - Фактическая дата вылета
  - Накопительная сумма вывезенных пассажиров по из каждого аэропорта на каждый день
    Здесь мы используем оконную функцию sum по кол-ву пассажиров (flights_passengers_details.passengers_count)
    в over(partition by) используем сразу два поля - flights.departure_airport и date(flights.actual_departure).
    Мы используем date(flights.actual_departure), потому что время вылета нам не важно, а мы хотим суммировать
    кол-во пассажиров в течение целого дня, поэтому берем только дату вылета. Отсортируем по фактической дате вылета
    - order by flights.actual_departure. Здесь уже будем сортировать с учетом времени вылета
*/

/* 6. Найдите процентное соотношение перелетов по типам самолетов от общего количества */

select
  aircrafts.model,
  round(flight_count / total_flight_count * 100, 2) as flight_percentage
from
  aircrafts
inner join
  (
    select
      aircraft_code,
      count(flight_id) as flight_count,
      sum(count(flight_id)) over () as total_flight_count
    from
      flights
    group by
      aircraft_code
   ) as aircraft_flights on aircraft_flights.aircraft_code = aircrafts.aircraft_code
order by
  flight_percentage desc

/*
  Сформируем сначала таблицу (подзапрос) с моделями самолетов, кол-вом перелетов для каждого из них и добавим
  общее кол-во перелетов по всем моделям самолетов
  select
    aircraft_code,
    count(flight_id) as flight_count,
    sum(count(flight_id)) over () as total_flight_count
  from
    flights
  group by
    aircraft_code

  Здесь мы делаем выборку из таблицы flights, группируем результат по коду самолета и выбираем следующие поля
  - Код самолета (aircraft_code)
  - Кол-во перелетов для этой модели самолета (flight_count)
  - Общее кол-во перелетов по всем моделям самолетов (total_flight_count)
    Используем оконную функцию sum по всем строкам в результирующей выборке без разбивки. Сортировку не используем,
    потому что накопительная сумма нас не интересует

  Выберем псевдоним для этого подзапроса - aircraft_flights

  Теперь итоговый запрос. Делаем выборку из таблицы aircrafts, соединяем ее с таблицей (подзапрос) aircraft_flights
  по ключу aircraft_code (код самолета). Выбираем следующие поля:
  - Модель самолета (aircrafts.model)
  - Процент перелетов для этой модели самолета - flight_percentage
    Делим кол-во перелетов для этой модели самолета на общее кол-во перелетов по всем типам самолетов, умножаем на 100,
    чтобы получить процент, округляем до 2 знаком после запятой

  Сортируем результат по вычисленному проценту перелетом по убыванию
  order by
    flight_percentage desc
*/

/* 7. Были ли города, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета? */

with cte_flights as (
  select
    flight_id,
    min(case when fare_conditions = 'Business' then amount end) as min_business_amount,
    max(case when fare_conditions = 'Economy' then amount end) as max_economy_amount
  from
    ticket_flights
  where
    fare_conditions = 'Business' or fare_conditions = 'Economy'
  group by
    flight_id
)

select
  airports.city as arrival_airport
from
  cte_flights
inner join
  flights using(flight_id)
inner join
  airports on airports.airport_code = flights.arrival_airport
where
  cte_flights.min_business_amount < cte_flights.max_economy_amount
group by
  airports.city

/*
  Для ответа на этот вопрос, сформулируем сначала запрос, который будет выводить список
  перелетов и для каждого перелета минимальную цену на бизнес-класс и максимальную цену
  на эконом-класс. Далее логика будет такая: если минимальная цена на бизнес-класс выше
  максимальной цены на эконом-класс, значит на этом рейсе можно было полететь бизнес-классе
  дешевле, чем на эконом-классе. Мы говорим про минимальные и максимальные цены, потому что
  допускаем, что в рамках одно полета цены на один и тот же класс могут быть разные (это действительно так)
  with cte_flights as (
    select
      flight_id,
      min(case when fare_conditions = 'Business' then amount end) as min_business_amount,
      max(case when fare_conditions = 'Economy' then amount end) as max_economy_amount
    from
      ticket_flights
    where
      fare_conditions = 'Business' or fare_conditions = 'Economy'
    group by
      flight_id
  )

  Делаем выборку из таблицы ticket_flights, оставляем только те записи, где класс полета
  Business или Economy, потому что есть и другие. Группируем по идентификатору перелета (flight_id).
  Выводим следующие поля:
  - Идентификатор перелета (flight_id)
  - Минимальная цена на бизнес-класс - min_business_amount
    Используем агрегатную функцию min, внутри отфильтровываем бизнес-класс
  - Максимальная цена на эконом-класс - max_economy_amount
    Используем агрегатную функцию max, внутри отфильтровываем эконом-класс

  Оформляем запрос как CTE с именем cte_flights

  Теперь очередь итогового запроса

  Делаем выборку из нашего CTE cte_flights
  from
    cte_flights

  Соединяем с таблицей flights по ключу flight_id (идентификатор перелета)
  inner join
    flights using(flight_id)

  А также с таблицей airports по ключу airports.airport_code/flights.arrival_airport (код аэропорта)
  inner join
    airports on airports.airport_code = flights.arrival_airport

  Оставляем только те записи, в которых минимальная цена на бизнес-класс меньше максимальной цены на эконом-класс
  where
    cte_flights.min_business_amount < cte_flights.max_economy_amount

  Группируем по городу
  group by
    airports.city

  И выводим только название города из таблицы airports - arrival_airport
*/

/* 8. Между какими городами нет прямых рейсов? */

create view flights_cities as
select
  flights.flight_id,
  airports_departure.city as departure_city,
  airports_arrival.city as arrival_city
from
  flights
inner join
  airports as airports_departure on airports_departure.airport_code = flights.departure_airport
inner join
  airports as airports_arrival on airports_arrival.airport_code = flights.arrival_airport

select
  distinct
  case
    when airports_departure.city > airports_arrival.city then airports_departure.city
    else airports_arrival.city
  end as city_1,
  case
    when airports_departure.city < airports_arrival.city then airports_departure.city
    else airports_arrival.city
  end as city_2
from
  airports as airports_departure
cross join
  airports as airports_arrival
where
  airports_departure.city <> airports_arrival.city
except
  select departure_city, arrival_city from flights_cities

/*
  В первую очередь получим список всех перелетов с городами отправления и прибытия
  и сохраним его как представление

  create view flights_cities as
  select
    flights.flight_id,
    airports_departure.city as departure_city,
    airports_arrival.city as arrival_city
  from
    flights
  inner join
    airports as airports_departure on airports_departure.airport_code = flights.departure_airport
  inner join
    airports as airports_arrival on airports_arrival.airport_code = flights.arrival_airport

  Делаем выборку из таблицы flights, соединяем с таблицей airports по ключу
  airport_code/flights.departure_airport (код аэропорта/код аэропорта отправления)
  и еще раз с таблицей airports по ключу airport_code/flights.arrival_airport
  (код аэропорта/код аэропорта прибытия)

  Выберем следующие поля:
  - Идентификатор перелета (flight_id)
  - Город отправления (departure_city)
  - Город прибытия (arrival_city)

  Чтобы ответить на поставленный вопрос мы поступим так:
  - Составим список всех возможных комбинаций городов с аэропортами (отправление/прибытие)
  - Исключим те записи, где названия городов в одной строке совпадают
    Хотя в одном городе может быть несколько аэропортов, мы сознательно не берем это в расчет,
    исходя из формы поставленного вопроса
  - Таким образом мы получили все теоретически возможные комбинации городов
  - Теперь из этого списка мы вычтем действительные (реальные) комбинации городов отправления/прибытия
  - Получим список городов, между которыми нет прямых рейсов

  from
    airports as airports_departure
  cross join
    airports as airports_arrival
  where
    airports_departure.city <> airports_arrival.city
  except
    select departure_city, arrival_city from flights_cities

  Чтобы максимально корректно ответить на поставленный вопрос, надо еще убрать дублирующиеся пары городов,
  потому что в результате мы можем получить следующее:
  Калуга - Сочи
  Сочи - Калуга

  Второй результат надо убрать. Мы это делаем при выборке полей путем перестановки их местами в выборке.
  Таким образом предыдущий пример будет выглядет так:
  Калуга - Сочи
  Калуга - Сочи

  Останется только убрать дублирующиеся строки с помощью оператора distinct
*/

/* 9. Вычислите расстояние между аэропортами, связанными прямыми рейсами, сравните
      с допустимой максимальной дальностью перелетов  в самолетах, обслуживающих эти рейсы */

select
  distinct
  case
    when airports_departure.airport_code > airports_arrival.airport_code then airports_departure.airport_code
    else airports_arrival.airport_code
  end as airport_code_1,
  case
    when airports_departure.airport_code < airports_arrival.airport_code then airports_departure.airport_code
    else airports_arrival.airport_code
  end as airport_code_2,
  round(
    degrees(
      acos(
        cos(radians(airports_departure.latitude)) * cos(radians(airports_arrival.latitude)) * cos(radians(airports_departure.longitude - airports_arrival.longitude)) +
        sin(radians(airports_departure.latitude)) * sin(radians(airports_arrival.latitude))
      )
     )::numeric * 111.111,
    2
  ) as distance_km,
  aircrafts.range
from
  flights
inner join
  airports as airports_departure on airports_departure.airport_code = flights.departure_airport
inner join
  airports as airports_arrival on airports_arrival.airport_code = flights.arrival_airport
inner join
  aircrafts on aircrafts.aircraft_code = flights.aircraft_code

/*
  Делаем первоначальную выборку из таблицы flights, соединяем ее два раза с таблицей airports,
  чтобы найти аэропорты отправления и прибытия
  from
    flights
  inner join
    airports as airports_departure on airports_departure.airport_code = flights.departure_airport
  inner join
    airports as airports_arrival on airports_arrival.airport_code = flights.arrival_airport

  Получившийся результат соединяем с таблицей aircrafts по ключу aircraft_code (код самолета)
  inner join
    aircrafts on aircrafts.aircraft_code = flights.aircraft_code

  Теперь мы можем получить список прямых рейсов между аэропортами и расстрояние между ними, которое мы
  можем подсчитать по формуле и округлить до 2 знаков после запятой
  round(
    degrees(
      acos(
        cos(radians(airports_departure.latitude)) * cos(radians(airports_arrival.latitude)) * cos(radians(airports_departure.longitude - airports_arrival.longitude)) +
        sin(radians(airports_departure.latitude)) * sin(radians(airports_arrival.latitude))
      )
     )::numeric * 111.111,
    2
  ) as distance_km

  После добавления максимальной дальности полета самолетов, обслуживающих эти рейсы результат
  мог бы выглядить следующим образом:
  KLF | LED | 688.94 | 1200
  LED | KLF | 688.94 | 1200

  Причем пока что результаты будут дублироваться, потому что выборку мы делали из таблицы flights.
  В первую очередь избавимся от дублирующихся записей, например вместо
  KLF | LED
  LED | KLF

  Мы хотим получить только
  KLF | LED или LED | KLF

  Это мы делаем из-за формулировки вопроса: расстояние между аэропортами, связанными прямыми рейсами.
  Так что мы применяем такой же трюк, как и в задаче номер 8
  case
    when airports_departure.airport_code > airports_arrival.airport_code then airports_departure.airport_code
    else airports_arrival.airport_code
  end as airport_code_1,
  case
    when airports_departure.airport_code < airports_arrival.airport_code then airports_departure.airport_code
    else airports_arrival.airport_code
  end as airport_code_2

  И с помощью оператора distinct избавляемся от дублирующихся записей
*/