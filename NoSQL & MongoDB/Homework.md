### Создать базу данных
```
use users
```

### Создать коллекцию пользователей
```
db.createCollection('users')
```

### Добавить информацию по 2-м людям с полями фамилия, имя и контактная информация (как вложенный объект)
```
db.users.insertMany([
  {
    firstName: 'Fadil',
    lastName: 'Mamedov',
    contacts: [
      {
        type: 'phone',
        value: '+79951033010'
      },
      {
        type: 'postalCode',
        value: '248000'
      },
      {
        type: 'email',
        value: 'fadil.mamedov@mail.ru'
      }
    ]
  },
  {
    firstName: 'Dori',
    lastName: 'Hilleli',
    contacts: [
      {
        type: 'phone',
        value: '+972547246611'
      },
      {
        type: 'postalCode',
        value: '78000'
      }
    ]
  }
])
```

### Вывести количество контактов у каждого пользователя
```
db.users.aggregate([
  {
    firstName: 1,
    lastName: 1,
    contactsCount: { $size: "$contacts" },
  }
])
```