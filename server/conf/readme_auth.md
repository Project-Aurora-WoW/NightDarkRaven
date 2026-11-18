# Настройки аутентификации (Auth / Аккаунты / Реалмы)

## AuthDatabase
Создайте базу `auth` из схемы AzerothCore:
```bash
mysql -u root -p < ac-server/data/sql/create/auth_create.sql
```

## WorldDatabase
Создайте базу `world`:
```bash
mysql -u root -p < ac-server/data/sql/create/mysql_create.sql
```

## CharacterDatabase
Создайте базу `characters`:
```bash
mysql -u root -p < ac-server/data/sql/create/characters_create.sql
```

## Реалмы
Добавьте реалм в таблицу `realmlist` базы `auth`:
```sql
INSERT INTO `realmlist` (`name`, `address`, `localAddress`, `port`, `icon`, `color`, `timezone`, `allowed_security_level`, `population`, `gamebuild`, `region`, `battlegroup`)
VALUES ('Ночь темного Ворона', '127.0.0.1', '127.0.0.1', 8090, 0, 1, 1, 0, 0, 12340, 1, 1);
```

## Аккаунт GM
Создать аккаунт с правами GM:
```sql
INSERT INTO `account` (`username`, `sha_pass_hash`, `gmlevel`) VALUES ('admin', SHA2('пароль', 256), 3);
```

## Клиент
В `WTF/realmlist.wtf` клиента WoW 3.3.5a:
```
set realmlist 127.0.0.1
```
или удалённый адрес сервера.