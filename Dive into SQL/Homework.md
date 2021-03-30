### Спроектируйте базу данных для следующих сущностей:
- Язык (в смысле английский, французский и тп)
- Народность (в смысле славяне, англосаксы и тп)
- Страны (в смысле Россия, Германия и тп)

### Правила следующие:
- На одном языке может говорить несколько народностей
- Одна народность может входить в несколько стран
- Каждая страна может состоять из нескольких народностей

---

## Создание таблиц

#### Примечание:
В тексте домашнего задания указано, что должно получится 5 таблиц для проектирования связей между ними. У меня поулчилось 4, и мне кажется, что этого достаточно. В дополнение к трем таблицам-справочникам я создал одну таблицу для выражения связи многие-ко-многим между таблицами **nationality** и **country**.

Для удовлетворения правила:
> На одном языке может говорить несколько народностей

достаточно создать внешний ключ на таблицу **language** в таблице **nationality**

```sql
CREATE TABLE "language" (
  id smallserial PRIMARY KEY,
  name VARCHAR(200) NOT NULL
);

CREATE TABLE nationality (
  id smallserial PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  language_id SMALLINT NOT NULL
);

CREATE TABLE country (
  id smallserial PRIMARY KEY,
  name VARCHAR(200) NOT NULL
);

CREATE TABLE country_nationality (
  country_id SMALLINT NOT NULL,
  nationality_id SMALLINT NOT NULL,
  PRIMARY KEY (country_id, nationality_id),
  FOREIGN KEY (country_id) REFERENCES country(id),
  FOREIGN KEY (nationality_id) REFERENCES nationality(id)
);

ALTER TABLE nationality ADD CONSTRAINT nationality_language_id_fkey FOREIGN KEY (language_id) REFERENCES "language"(id)
```


## Добавление данных

```sql
INSERT INTO country(name)
VALUES
  ('Россия'),
  ('Германия'),
  ('Китай'),
  ('США'),
  ('Греция');

INSERT INTO "language"(name)
VALUES
  ('Русский'),
  ('Английский'),
  ('Китайский'),
  ('Французский'),
  ('Испанский');

INSERT INTO nationality(name, language_id)
VALUES
  ('Славяне', 1),
  ('Англосаксы', 2),
  ('Скандинавы', 1),
  ('Армяне', 1),
  ('Китайцы', 3);

INSERT INTO country_nationality(country_id, nationality_id)
VALUES
  (1, 1),
  (1, 2),
  (1, 4),
  (3, 1),
  (3, 5);
```

## Расширение таблиц

```sql
ALTER TABLE country ADD COLUMN english_main_language boolean NOT NULL DEFAULT false

ALTER TABLE country ADD COLUMN counties TEXT[]

ALTER TABLE country ADD COLUMN foundation_date TIMESTAMP
```