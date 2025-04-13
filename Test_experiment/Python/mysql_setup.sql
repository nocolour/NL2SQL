-- Create the database
CREATE DATABASE IF NOT EXISTS nl2sql_test;
USE nl2sql_test;

-- Create tables
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(200),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE product_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    category_id INT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES product_categories(category_id)
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') NOT NULL DEFAULT 'Pending',
    shipping_address VARCHAR(200),
    shipping_city VARCHAR(50),
    shipping_state VARCHAR(50),
    shipping_country VARCHAR(50),
    shipping_postal_code VARCHAR(20),
    shipping_fee DECIMAL(10, 2) DEFAULT 0.00,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Insert sample data: Categories
INSERT INTO product_categories (category_name, description) VALUES
('Electronics', 'Electronic devices and accessories'),
('Clothing', 'Apparel and fashion items'),
('Books', 'Books, e-books, and publications'),
('Home & Kitchen', 'Home appliances and kitchenware'),
('Sports & Outdoors', 'Sports equipment and outdoor gear');

-- Insert sample data: Products
INSERT INTO products (product_name, description, category_id, price, stock_quantity) VALUES
('Smartphone X', 'Latest smartphone with advanced features', 1, 899.99, 120),
('Laptop Pro', 'High-performance laptop for professionals', 1, 1299.99, 75),
('Wireless Earbuds', 'Bluetooth earbuds with noise cancellation', 1, 149.99, 200),
('Smart Watch', 'Fitness tracker and smartwatch', 1, 249.99, 95),
('4K TV', '55-inch 4K Smart TV', 1, 699.99, 30),

('Men\'s T-Shirt', 'Cotton t-shirt for men', 2, 19.99, 300),
('Women\'s Jeans', 'Slim-fit jeans for women', 2, 49.99, 250),
('Winter Jacket', 'Waterproof winter jacket', 2, 89.99, 120),
('Running Shoes', 'Lightweight running shoes', 2, 79.99, 150),
('Sun Hat', 'Summer sun protection hat', 2, 24.99, 200),

('Sci-Fi Novel', 'Bestselling science fiction novel', 3, 14.99, 180),
('Cookbook', 'Gourmet recipes cookbook', 3, 29.99, 120),
('History Book', 'World history encyclopedia', 3, 39.99, 90),
('Programming Guide', 'Learn to code with Python', 3, 34.99, 110),
('Children\'s Book', 'Illustrated children\'s storybook', 3, 12.99, 230),

('Blender', 'High-speed countertop blender', 4, 79.99, 65),
('Coffee Maker', 'Programmable coffee machine', 4, 59.99, 85),
('Toaster', '4-slice toaster with multiple settings', 4, 39.99, 100),
('Cookware Set', '10-piece non-stick cookware set', 4, 149.99, 40),
('Knife Set', 'Professional kitchen knife set', 4, 99.99, 60),

('Yoga Mat', 'Non-slip exercise yoga mat', 5, 29.99, 150),
('Dumbbells', 'Set of two 5lb dumbbells', 5, 24.99, 100),
('Tennis Racket', 'Professional tennis racket', 5, 89.99, 70),
('Basketball', 'Official size basketball', 5, 29.99, 120),
('Camping Tent', '4-person waterproof tent', 5, 129.99, 45);

-- Insert sample data: Customers
INSERT INTO customers (first_name, last_name, email, phone, address, city, state, country, postal_code) VALUES
('John', 'Doe', 'john.doe@example.com', '555-123-4567', '123 Main St', 'New York', 'NY', 'USA', '10001'),
('Jane', 'Smith', 'jane.smith@example.com', '555-234-5678', '456 Oak Ave', 'Los Angeles', 'CA', 'USA', '90001'),
('Michael', 'Johnson', 'michael.j@example.com', '555-345-6789', '789 Pine Rd', 'Chicago', 'IL', 'USA', '60007'),
('Emily', 'Williams', 'emily.w@example.com', '555-456-7890', '101 Maple Dr', 'Houston', 'TX', 'USA', '77001'),
('David', 'Brown', 'david.b@example.com', '555-567-8901', '202 Cedar Ln', 'Phoenix', 'AZ', 'USA', '85001'),
('Sarah', 'Jones', 'sarah.j@example.com', '555-678-9012', '303 Birch Ct', 'Philadelphia', 'PA', 'USA', '19019'),
('Robert', 'Garcia', 'robert.g@example.com', '555-789-0123', '404 Elm Blvd', 'San Antonio', 'TX', 'USA', '78006'),
('Jennifer', 'Miller', 'jennifer.m@example.com', '555-890-1234', '505 Walnut Pl', 'San Diego', 'CA', 'USA', '92093'),
('William', 'Davis', 'william.d@example.com', '555-901-2345', '606 Cherry St', 'Dallas', 'TX', 'USA', '75001'),
('Elizabeth', 'Rodriguez', 'elizabeth.r@example.com', '555-012-3456', '707 Spruce Rd', 'San Jose', 'CA', 'USA', '95112');

-- Insert sample data: Orders (with dates spread over the past year)
INSERT INTO orders (customer_id, order_date, status, shipping_address, shipping_city, shipping_state, shipping_country, shipping_postal_code, shipping_fee, total_amount) VALUES
(1, '2024-03-15', 'Delivered', '123 Main St', 'New York', 'NY', 'USA', '10001', 10.00, 929.99),
(2, '2024-03-10', 'Delivered', '456 Oak Ave', 'Los Angeles', 'CA', 'USA', '90001', 10.00, 169.98),
(3, '2024-03-05', 'Delivered', '789 Pine Rd', 'Chicago', 'IL', 'USA', '60007', 15.00, 1314.99),
(4, '2024-02-28', 'Delivered', '101 Maple Dr', 'Houston', 'TX', 'USA', '77001', 12.50, 49.99),
(5, '2024-02-20', 'Delivered', '202 Cedar Ln', 'Phoenix', 'AZ', 'USA', '85001', 12.50, 174.98),
(6, '2024-02-15', 'Delivered', '303 Birch Ct', 'Philadelphia', 'PA', 'USA', '19019', 0.00, 89.99),
(7, '2024-02-10', 'Delivered', '404 Elm Blvd', 'San Antonio', 'TX', 'USA', '78006', 10.00, 259.99),
(8, '2024-02-05', 'Delivered', '505 Walnut Pl', 'San Diego', 'CA', 'USA', '92093', 15.00, 149.99),
(9, '2024-01-28', 'Delivered', '606 Cherry St', 'Dallas', 'TX', 'USA', '75001', 12.50, 129.99),
(10, '2024-01-20', 'Delivered', '707 Spruce Rd', 'San Jose', 'CA', 'USA', '95112', 0.00, 54.98),
(1, '2024-01-15', 'Delivered', '123 Main St', 'New York', 'NY', 'USA', '10001', 10.00, 249.99),
(2, '2024-01-10', 'Delivered', '456 Oak Ave', 'Los Angeles', 'CA', 'USA', '90001', 10.00, 114.98),
(3, '2023-12-20', 'Delivered', '789 Pine Rd', 'Chicago', 'IL', 'USA', '60007', 15.00, 199.98),
(4, '2023-12-15', 'Delivered', '101 Maple Dr', 'Houston', 'TX', 'USA', '77001', 12.50, 34.99),
(5, '2023-12-10', 'Delivered', '202 Cedar Ln', 'Phoenix', 'AZ', 'USA', '85001', 12.50, 74.98),
(6, '2023-12-05', 'Delivered', '303 Birch Ct', 'Philadelphia', 'PA', 'USA', '19019', 0.00, 699.99),
(7, '2023-11-28', 'Delivered', '404 Elm Blvd', 'San Antonio', 'TX', 'USA', '78006', 10.00, 149.99),
(8, '2023-11-20', 'Delivered', '505 Walnut Pl', 'San Diego', 'CA', 'USA', '92093', 15.00, 109.98),
(9, '2023-11-15', 'Delivered', '606 Cherry St', 'Dallas', 'TX', 'USA', '75001', 12.50, 229.98),
(10, '2023-11-10', 'Delivered', '707 Spruce Rd', 'San Jose', 'CA', 'USA', '95112', 0.00, 79.99);

-- Insert sample data: Order Items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 899.99),
(1, 3, 2, 149.99),
(2, 6, 2, 19.99),
(2, 10, 5, 24.99),
(3, 2, 1, 1299.99),
(3, 15, 1, 12.99),
(4, 7, 1, 49.99),
(5, 4, 1, 249.99),
(5, 5, 1, 699.99),
(6, 8, 1, 89.99),
(7, 4, 1, 249.99),
(8, 3, 1, 149.99),
(9, 25, 1, 129.99),
(10, 11, 1, 14.99),
(10, 13, 1, 39.99),
(11, 4, 1, 249.99),
(12, 11, 1, 14.99),
(12, 16, 1, 79.99),
(12, 21, 1, 29.99),
(13, 9, 1, 79.99),
(13, 20, 1, 99.99),
(14, 14, 1, 34.99),
(15, 23, 1, 29.99),
(15, 22, 1, 24.99),
(16, 5, 1, 699.99),
(17, 3, 1, 149.99),
(18, 18, 1, 39.99),
(18, 19, 1, 149.99),
(19, 8, 1, 89.99),
(19, 24, 1, 29.99),
(20, 16, 1, 79.99);

-- Create a read-only user for the application
CREATE USER IF NOT EXISTS 'nl2sql_user'@'localhost' IDENTIFIED BY 'nlsql_password';
GRANT SELECT ON nl2sql_test.* TO 'nl2sql_user'@'localhost';
FLUSH PRIVILEGES;

-- Some useful views for analysis
CREATE OR REPLACE VIEW customer_order_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent,
    AVG(o.total_amount) AS avg_order_value,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date
FROM 
    customers c
LEFT JOIN 
    orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, customer_name;

CREATE OR REPLACE VIEW product_sales_analysis AS
SELECT 
    p.product_id,
    p.product_name,
    pc.category_name,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    COUNT(DISTINCT o.order_id) AS order_count
FROM 
    products p
JOIN 
    product_categories pc ON p.category_id = pc.category_id
LEFT JOIN 
    order_items oi ON p.product_id = oi.product_id
LEFT JOIN 
    orders o ON oi.order_id = o.order_id
GROUP BY 
    p.product_id, p.product_name, pc.category_name;

-- Monthly sales trends
CREATE OR REPLACE VIEW monthly_sales AS
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    SUM(o.total_amount) AS total_sales,
    COUNT(DISTINCT o.order_id) AS order_count,
    COUNT(DISTINCT o.customer_id) AS customer_count,
    SUM(o.total_amount) / COUNT(DISTINCT o.order_id) AS avg_order_value
FROM 
    orders o
GROUP BY 
    DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY 
    month;
