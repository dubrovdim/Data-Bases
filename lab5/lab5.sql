DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS rentals CASCADE;
DROP TABLE IF EXISTS movies CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL
);

CREATE TABLE movies (
    movie_id SERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    price NUMERIC(5,2) NOT NULL CHECK (price > 0)
);

CREATE TABLE rentals (
    rental_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    movie_id INTEGER REFERENCES movies(movie_id),
    rental_date DATE NOT NULL DEFAULT CURRENT_DATE,
    return_date DATE
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    rental_id INTEGER UNIQUE REFERENCES rentals(rental_id),
    amount NUMERIC(8,2) NOT NULL CHECK (amount > 0)
);