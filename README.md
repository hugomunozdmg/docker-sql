## Limpiar docker
- docker system prune -a --volumes
- docker volume prune -a

## Iniciar la base de datos
- docker-compose up

## Entrar en la base de datos desde terminal
- docker exec -it sql-postgres-1 psql -U myuser -d mydb

# Dentro de la terminal de POSTGRESQL
- listar bases de datos -> \l
- cambiar de base de datos -> \c nombredatabase
- listar tablas en la base de datos -> \dt
- ver estructura de una tabla -> \d nombretabla
- salir de postgres -> \q

## Manejar datos
- crear tabla -> 
CREATE TABLE users ( id SERIAL PRIMARY KEY, name VARCHAR(50), age INT, password VARCHAR(50));

- eliminar tabla ->
DROP TABLE users;

- anadir datos a la tabla -> 
INSERT INTO users (name, age, password) VALUES ('Alice', 20, 'password1'), ('Peter', 34, 'password2');

- ver datos en una tabla ->
SELECT * FROM users;

-eliminar un dato ->
DELETE FROM users WHERE name = 'Alice';
DELETE FROM users WHERE id = 1;

-actualizar un dato ->
UPDATE users SET name = 'Luis', age = 43 WHERE id = 2;

# docker-sql
