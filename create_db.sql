DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS contacts;
DROP TABLE IF EXISTS friends;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS mobile_companies;
DROP TABLE IF EXISTS countries;
DROP TYPE IF EXISTS contact_status;
DROP TYPE IF EXISTS event_type;

CREATE TABLE IF NOT EXISTS countries (
	id serial PRIMARY KEY,
	name text UNIQUE,
	code varchar(3) UNIQUE
);
CREATE TABLE IF NOT EXISTS mobile_companies (
	id serial PRIMARY KEY,
	name text NOT NULL UNIQUE,
	code varchar(3) NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS users (
	id serial PRIMARY KEY,
	first_name text NOT NULL,
	last_name text NOT NULL,
	phone varchar(7) NOT NULL UNIQUE,
	country text NOT NULL references countries(name),
	mobile_company text NOT NULL references mobile_companies(name)
);

CREATE TABLE IF NOT EXISTS friends(
	first_friend_id integer references users(id), 
	second_friend_id integer references users(id)
);

CREATE TYPE contact_status AS ENUM ('active', 'blocked');
CREATE TABLE IF NOT EXISTS contacts (
	id serial PRIMARY KEY ,
	owner int NOT NULL references users(id),
	friend int NOT NULL references users(id),
	friend_nickname text,
	contact_phone text,
	status contact_status not null default 'active'
);

CREATE TYPE event_type AS ENUM ('call', 'message', 'add', 'delete', 'block', 'unblock');

CREATE TABLE IF NOT EXISTS events(
	id serial PRIMARY KEY,
	contact_id integer,
	owner_id integer,
	event_type event_type,
	success boolean NOT NULL default true,
	comment text
);

INSERT INTO countries(name, code) 
VALUES ('RUSSIA', '+7'), ('USA', '+1'), ('ITALY', '+39'), ('SPAIN', '+34'), ('GERMANY', '+49');

INSERT INTO mobile_companies(name, code) 
VALUES ('MEGAFON', '926'), ('VODAFONE', '050'), ('ORANGE', '812');

INSERT INTO users(first_name, last_name, phone, country, mobile_company) 
VALUES ('Michael', 'Schumacher', '9293232', 'GERMANY', 'VODAFONE'),
('Ralph', 'Schumacher', '9234232', 'GERMANY', 'ORANGE'),
('Fernando', 'Alonso', '3442323', 'SPAIN', 'ORANGE'),
('Vitaliy', 'Petrov', '5662351', 'RUSSIA', 'MEGAFON'),
('Michael', 'Andretti', '2335512', 'USA', 'VODAFONE'),
('Carlos', 'Sainz', '2542313', 'SPAIN', 'ORANGE'),
('Sergei', 'Sirotkin', '2312313', 'RUSSIA', 'MEGAFON'),
('Jarno', 'Trulli', '4659492', 'ITALY', 'VODAFONE');


