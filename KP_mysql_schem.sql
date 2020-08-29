-- Kinopoisk Database Schema
-- Version 1.0

-- Copyright (c) 2020, Alex Khlybov

-- Данная база данных создана для портала о кино "КИНОПОИСК". Она предназначена для хранения данных:
-- о пользователях, авторах, кинотеатрах, фильмах. Так же в ней хранятся информация о сеансах и 
-- ценах на билеты.

DROP DATABASE IF EXISTS kinopoisk;
CREATE DATABASE kinopoisk;
USE kinopoisk;

--
--  Схема для таблицы пользователей
--

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY, 
    firstname VARCHAR(50) NOT NULL COMMENT 'Имя',
    lastname VARCHAR(50) NOT NULL COMMENT 'Фамилия',
    email VARCHAR(120) NOT NULL UNIQUE,
 	password_hash VARCHAR(100), -- 123456 => vzx;clvgkajrpo9udfxvsldkrn24l5456345t
	phone BIGINT(20) UNSIGNED NOT NULL UNIQUE,
	created_at DATETIME DEFAULT NOW(),
	updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	
    INDEX users_firstname_lastname_idx(firstname, lastname)
);

--
-- Схема таблицы разделов портала
--

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL COMMENT 'Название раздела',
  created_at DATETIME DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

--
-- Схема таблица типов медиа (видео, фото и т.п.)
--

DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types(
	id SERIAL PRIMARY KEY,
    name ENUM ('Photo', 'Video', 'Audio', 'Text') NOT NULL COMMENT 'Тип данных',
    created_at DATETIME DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

--
-- Схема таблицы стран
--

DROP TABLE IF EXISTS country;
CREATE TABLE country (
	id SERIAL PRIMARY KEY,
	country VARCHAR(50) NOT NULL,
	updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

--
-- Схема таблицы городов
--

CREATE TABLE city (
  id SERIAL PRIMARY KEY,
  city VARCHAR(50) NOT NULL,
  country_id BIGINT UNSIGNED NOT NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX idx_city(city),
  CONSTRAINT fk_city_country FOREIGN KEY (country_id) REFERENCES country(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

--
-- Схема таблицы адресов
--

CREATE TABLE address (
  id SERIAL PRIMARY KEY,
  address VARCHAR(50) NOT NULL,
  city_id BIGINT UNSIGNED NOT NULL,
  postal_code VARCHAR(10) DEFAULT NULL,
  phone VARCHAR(20) NOT NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  KEY idx_fk_city_id (city_id),
  CONSTRAINT fk_address_city FOREIGN KEY (city_id) REFERENCES city(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

--
-- Схема таблицы жанров
--

DROP TABLE IF EXISTS genre;
CREATE TABLE genre (
	id SERIAL PRIMARY KEY,
	genre VARCHAR(50) NOT NULL,
	updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	
	INDEX idx_genre (genre)
);

--
-- Схема таблицы языков 
--

DROP TABLE IF EXISTS lang;
CREATE TABLE lang (
  id SERIAL PRIMARY KEY,
  name CHAR(20) NOT NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
  
);

--
-- Схема таблицы профессий
--

DROP TABLE IF EXISTS profession;
CREATE TABLE profession (
	id SERIAL PRIMARY KEY,
	profession VARCHAR(50) NOT NULL,
	updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	
	INDEX idx_profession(profession)
);

--
-- Схема таблицы медиа
--

DROP TABLE IF EXISTS media;
CREATE TABLE media(
	id SERIAL PRIMARY KEY,
    media_type_id BIGINT UNSIGNED NOT NULL,
  	filename VARCHAR(255) NOT NULL,
    body text,
    size INT,
	metadata JSON,
    created_at DATETIME DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_filename (filename),
    CONSTRAINT fk_media_type FOREIGN KEY (media_type_id) REFERENCES media_types(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

--
-- Схема таблицы фото
--

DROP TABLE IF EXISTS photo;
CREATE TABLE photo(
	id SERIAL PRIMARY KEY,
	media_id BIGINT UNSIGNED NOT NULL,
	created_at DATETIME DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	
	FOREIGN KEY (media_id) REFERENCES media(id),
	CONSTRAINT fk_photo_media FOREIGN KEY (media_id) REFERENCES media(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

--
-- Схема таблицы профилей
--

DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
	user_id BIGINT UNSIGNED NOT NULL PRIMARY KEY UNIQUE,
    gender CHAR(1) NOT NULL,
    birthday DATE NOT NULL,
	photo_id BIGINT UNSIGNED NULL,
	city_id BIGINT UNSIGNED NULL,
	country_id BIGINT UNSIGNED NULL,
    created_at DATETIME DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
	CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_user_photo FOREIGN KEY (photo_id) REFERENCES media(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_user_city FOREIGN KEY (city_id) REFERENCES city(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_user_country FOREIGN KEY (country_id) REFERENCES country(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

--
-- Схема таблицы фильмов
--

DROP TABLE IF EXISTS film;
CREATE TABLE film(
	id SERIAL PRIMARY KEY,
	title VARCHAR(100) NOT NULL COMMENT 'Название фильма',
	description TEXT NOT NULL COMMENT 'Описание',
	media_id BIGINT UNSIGNED NOT NULL,
	catalogs_id BIGINT UNSIGNED NOT NULL,
	production_year YEAR NOT NULL COMMENT 'Год производства',
    country_id BIGINT UNSIGNED NOT NULL COMMENT 'Страна производства',
    lang_id BIGINT UNSIGNED NOT NULL COMMENT 'Язык',
  	original_lang_id BIGINT UNSIGNED NOT NULL COMMENT 'Язык оригинала',
    premiere_russia DATETIME NOT NULL COMMENT 'Дата премьеры в России',
    premiere_world DATETIME NOT NULL COMMENT 'Дата премьеры в мире',
    age_restrict ENUM ('0+','6+', '12+', '16+', '18+') NOT NULL COMMENT 'Возрастные ограничения',
    duration TIME COMMENT 'Продолжительность фильма',
    created_at DATETIME NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW() ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_title(title),
    INDEX idx_title_year(title, production_year),
    CONSTRAINT fk_film_media FOREIGN KEY (media_id) REFERENCES media(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_film_catalogs FOREIGN KEY (catalogs_id) REFERENCES catalogs(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_film_country FOREIGN KEY (country_id) REFERENCES country(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_film_lang FOREIGN KEY (lang_id) REFERENCES lang(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_film_original_lang FOREIGN KEY (original_lang_id) REFERENCES lang(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

--
-- Схема таблицы создателей фильма
--

DROP TABLE IF EXISTS autor;
CREATE TABLE autor (
	id SERIAL PRIMARY KEY,
	firstname VARCHAR(50) NOT NULL COMMENT 'Имя',
    lastname VARCHAR(50) NOT NULL COMMENT 'Фамилия',
    profession_id BIGINT UNSIGNED NOT NULL COMMENT 'Карьера',
    birthday DATE NOT NULL,
    city_id BIGINT UNSIGNED NOT NULL COMMENT 'Место рождения',
    film_id BIGINT UNSIGNED NOT NULL COMMENT 'Фильмография',
    created_at DATETIME DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_autor_firstname_lastname(firstname, lastname),
    CONSTRAINT fk_autor_profession FOREIGN KEY (profession_id) REFERENCES profession(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_autor_city FOREIGN KEY (city_id) REFERENCES city(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_autor_film FOREIGN KEY (film_id) REFERENCES film(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

--
-- Схема таблицы любимый автор
--

DROP TABLE IF EXISTS love_autor;
CREATE TABLE love_autor (
	id SERIAL,
	user_id BIGINT UNSIGNED NULL,
	autor_id BIGINT UNSIGNED NULL,
	
	CONSTRAINT fk_love_autor_profiles FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_love_autor_autor FOREIGN KEY (autor_id) REFERENCES autor(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

--
-- Схема таблицы любимый жанр
--

DROP TABLE IF EXISTS love_genre;
CREATE TABLE love_genre (
	id SERIAL,
	user_id BIGINT UNSIGNED NULL,
	genre_id BIGINT UNSIGNED NULL,
	
	CONSTRAINT fk_love_genre_profiles FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_love_genre_genre FOREIGN KEY (genre_id) REFERENCES genre(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

--
-- Схема таблицы Жанры-фильмы
--

DROP TABLE IF EXISTS film_genre;
CREATE TABLE film_genre(
	film_id BIGINT UNSIGNED NOT NULL,
	genre_id BIGINT UNSIGNED NOT NULL,
	updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	
	CONSTRAINT fk_film_genre FOREIGN KEY (genre_id) REFERENCES genre(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_genre_film FOREIGN KEY (film_id) REFERENCES film(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

--
-- Схема таблицы Жанры-авторы
--

DROP TABLE IF EXISTS autor_genre;
CREATE TABLE autor_genre(
	autor_id BIGINT UNSIGNED NOT NULL,
	genre_id BIGINT UNSIGNED NOT NULL,
	updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	
	CONSTRAINT fk_autor_ganre FOREIGN KEY (autor_id) REFERENCES autor(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_genre_autor FOREIGN KEY (genre_id) REFERENCES genre(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

--
-- Схема таблицы рейтингов
--

DROP TABLE IF EXISTS rating;
CREATE TABLE rating(
	user_id BIGINT UNSIGNED NOT NULL,
	film_id BIGINT UNSIGNED NOT NULL,
	value DECIMAL(5,4) UNSIGNED DEFAULT 0,
	created_at DATETIME DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	
	CONSTRAINT fk_rating_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT fk_rating_film FOREIGN KEY (film_id) REFERENCES film(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

--
-- Схема таблицы трейлеров
--

DROP TABLE IF EXISTS trailer;
CREATE TABLE trailer(
	id SERIAL PRIMARY KEY,
	media_id BIGINT UNSIGNED NOT NULL,
	film_id BIGINT UNSIGNED NOT NULL,
	title VARCHAR(255) NOT NULL COMMENT 'Название трейлера',
	lang_id BIGINT UNSIGNED NOT NULL COMMENT 'Язык',
	age_restrict ENUM ('0+','6+', '12+', '16+', '18+') NOT NULL COMMENT 'Возрастные ограничения',
	created_at DATETIME DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    KEY idx_title (title),
    CONSTRAINT fk_trailer_media FOREIGN KEY (media_id) REFERENCES media(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_trailer_film FOREIGN KEY (film_id) REFERENCES film(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_trailer_lang FOREIGN KEY (lang_id) REFERENCES lang(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

--
-- схема таблицы фильмография
--

DROP TABLE IF EXISTS filmography;
CREATE TABLE filmography(
	autor_id BIGINT UNSIGNED NOT NULL,
	film_id BIGINT UNSIGNED NOT NULL,
	updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	
	CONSTRAINT fk_filmography_autor FOREIGN KEY (autor_id) REFERENCES autor(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_filmography_film FOREIGN KEY (film_id) REFERENCES film(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

--
-- Схема таблицы отзывов
--

DROP TABLE IF EXISTS review;
CREATE TABLE review(
	id SERIAL PRIMARY KEY,
	users_id BIGINT UNSIGNED NOT NULL COMMENT 'Пользователь',
	film_id BIGINT UNSIGNED NOT NULL COMMENT 'Фильм',
	title VARCHAR(255) NOT NULL,
	review_text TEXT NOT NULL,
	created_at DATETIME DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	
	CONSTRAINT fk_users_review FOREIGN KEY (users_id) REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT fk_users_film FOREIGN KEY (film_id) REFERENCES film(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

--
--  Схема таблицы кинотеатры
--

DROP TABLE IF EXISTS cinemas;
CREATE TABLE cinemas(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL COMMENT 'Название кинотеатра',
	address_id BIGINT UNSIGNED NOT NULL,
	created_at DATETIME DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	
	INDEX idx_cinemas(name),
	CONSTRAINT fk_cinemas_addres FOREIGN KEY (address_id) REFERENCES address(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

--
-- Схема таблицы показы в кино
--

DROP TABLE IF EXISTS movie_screen;
CREATE TABLE movie_screen(
	id SERIAL PRIMARY KEY,
	film_id BIGINT UNSIGNED NOT NULL,
	cinemas_id BIGINT UNSIGNED NOT NULL, 
	sessions DATETIME NOT NULL COMMENT 'Сеансы',
	price INT NOT NULL COMMENT 'Цена билета',
	number_of_tickets INT UNSIGNED NOT NULL,
	
	INDEX idx_film_cinemas(film_id, cinemas_id),
	INDEX idx_cinemas_sessions(cinemas_id, sessions),
	CONSTRAINT fk_movie_screen_film FOREIGN KEY (film_id) REFERENCES film(id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT fk_movie_screen_cinemas FOREIGN KEY (cinemas_id) REFERENCES cinemas(id) ON DELETE RESTRICT ON UPDATE CASCADE
);