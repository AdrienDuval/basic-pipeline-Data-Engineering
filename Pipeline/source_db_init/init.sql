-- ==============================
-- 1) TABLE USERS + INSERTS
-- ==============================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    date_of_birth DATE
);

INSERT INTO users (first_name, last_name, email, date_of_birth) VALUES
('John', 'Doe', 'john.doe@example.com', '1990-01-01'),
('Jane', 'Smith', 'jane.smith@example.com', '1992-05-15'),
('Alice', 'Johnson', 'alice.johnson@example.com', '1985-10-20'),
('Bob', 'Williams', 'bob.williams@example.com', '1998-07-30'),
('Emily', 'Clark', 'emily.clark@example.com', '1987-02-14'),
('Michael', 'Robinson', 'michael.robinson@example.com', '1995-06-05'),
('Sarah', 'Lewis', 'sarah.lewis@example.com', '1989-03-25'),
('David', 'Walker', 'david.walker@example.com', '1992-11-12'),
('Sophia', 'Hall', 'sophia.hall@example.com', '1996-08-30'),
('James', 'Allen', 'james.allen@example.com', '1984-04-20'),
('Olivia', 'Young', 'olivia.young@example.com', '1993-12-30'),
('Chris', 'King', 'chris.king@example.com', '1990-09-15'),
('Grace', 'Wright', 'grace.wright@example.com', '1997-05-10'),
('William', 'Scott', 'william.scott@example.com', '1986-07-22');

-- ==============================
-- 2) TABLE FILMS + INSERTS
-- ==============================
CREATE TABLE films (
    film_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    release_date DATE,
    price DECIMAL(5,2),
    rating VARCHAR(10),
    user_rating DECIMAL(2,1) CHECK (user_rating >= 1 AND user_rating <= 5)
);

INSERT INTO films (title, release_date, price, rating, user_rating) VALUES
('Inception', '2010-07-16', 12.99, 'PG-13', 4.8),
('The Shawshank Redemption', '1994-09-23', 9.99, 'R', 4.9),
('The Godfather', '1972-03-24', 9.49, 'R', 4.9),
('The Dark Knight', '2008-07-18', 11.99, 'PG-13', 4.8),
('Pulp Fiction', '1994-10-14', 10.99, 'R', 4.6),
('The Matrix', '1999-03-31', 9.99, 'R', 4.7),
('Forrest Gump', '1994-07-06', 9.99, 'PG-13', 4.5),
('Toy Story', '1995-11-22', 7.99, 'G', 4.4),
('Jurassic Park', '1993-06-11', 9.99, 'PG-13', 4.3),
('Avatar', '2009-12-18', 12.99, 'PG-13', 4.3),
('Blade Runner 2049', '2017-10-06', 13.99, 'R', 4.3),
('Mad Max: Fury Road', '2015-05-15', 11.99, 'R', 4.6),
('Coco', '2017-11-22', 9.99, 'PG', 4.8),
('Dunkirk', '2017-07-21', 10.99, 'PG-13', 4.5),
('Spider-Man: Into the Spider-Verse', '2018-12-14', 10.99, 'PG', 4.9),
('Parasite', '2019-10-11', 14.99, 'R', 4.9),
('Whiplash', '2014-10-10', 9.99, 'R', 4.7),
('Inside Out', '2015-06-19', 9.99, 'PG', 4.8),
('The Grand Budapest Hotel', '2014-03-28', 10.99, 'R', 4.4),
('La La Land', '2016-12-09', 11.99, 'PG-13', 4.5);

-- ==============================
-- 3) TABLE FILM_CATEGORY + INSERTS
-- ==============================
CREATE TABLE film_category (
    category_id SERIAL PRIMARY KEY,
    film_id INTEGER REFERENCES films(film_id),
    category_name VARCHAR(50) NOT NULL
);

INSERT INTO film_category (film_id, category_name) VALUES
(1, 'Sci-Fi'),
(1, 'Thriller'),
(2, 'Drama'),
(3, 'Crime'),
(3, 'Drama'),
(4, 'Action'),
(5, 'Thriller'),
(5, 'Crime'),
(6, 'Drama'),
(6, 'Sci-Fi'),
(7, 'Drama'),
(8, 'Animation'),
(8, 'Family'),
(9, 'Action'),
(9, 'Adventure'),
(10, 'Sci-Fi'),
(10, 'Adventure'),
(11, 'Sci-Fi'),
(12, 'Drama'),
(13, 'Drama'),
(14, 'Action'),
(15, 'Animation'),
(16, 'Drama'),
(17, 'Music'),
(18, 'Comedy'),
(19, 'Drama'),
(20, 'Music');

-- ==============================
-- 4) TABLE ACTORS + INSERTS
-- ==============================
CREATE TABLE actors (
    actor_id SERIAL PRIMARY KEY,
    actor_name VARCHAR(255) NOT NULL
);

INSERT INTO actors (actor_name) VALUES
('Leonardo DiCaprio'),
('Tim Robbins'),
('Marlon Brando'),
('Christian Bale'),
('John Travolta'),
('Keanu Reeves'),
('Tom Hanks'),
('Tom Hanks'), -- Toy Story (appears twice as noted)
('Sam Neill'),
('Sam Worthington'),
('Ryan Gosling'),
('Anthony Gonzalez'),
('Fionn Whitehead'),
('Shameik Moore'),
('Song Kang-ho'),
('Miles Teller'),
('Amy Poehler'),
('Ralph Fiennes'),
('Emma Stone'),
('Matthew McConaughey'); -- AJOUTÉ comme acteur_id = 20

-- ==============================
-- 5) TABLE FILM_ACTORS + INSERTS
-- ==============================
CREATE TABLE film_actors (
    film_id INTEGER REFERENCES films(film_id),
    actor_id INTEGER REFERENCES actors(actor_id),
    PRIMARY KEY (film_id, actor_id)
);

INSERT INTO film_actors (film_id, actor_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20);
