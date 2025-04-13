-- ==================================================================
--      HOME ELECTRICAL SHOP DATABASE SCRIPT (LARGER VERSION)
-- ==================================================================
-- Current Date assumed for "last 3 years": 2025-04-14
CREATE DATABASE IF NOT EXISTS nl2sql_test2;
USE nl2sql_test2;

-- Drop existing tables if they exist to start fresh
DROP TABLE IF EXISTS Order_Items;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS ProductCategories;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS SalesPersons;
DROP TABLE IF EXISTS Vendors;

-- --------------------------
--      TABLE CREATION
-- --------------------------

-- Create Vendors Table
CREATE TABLE Vendors (
    vendor_id INT AUTO_INCREMENT PRIMARY KEY,
    vendor_name VARCHAR(255) NOT NULL UNIQUE,
    contact_person VARCHAR(100),
    phone VARCHAR(25),
    email VARCHAR(255) UNIQUE,
    address TEXT,
    country VARCHAR(50) -- Added Country
);

-- Create SalesPersons Table
CREATE TABLE SalesPersons (
    salesperson_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(25),
    hire_date DATE,
    commission_rate DECIMAL(4, 2) DEFAULT 0.05 -- Added Commission Rate
);

-- Create Customers Table
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(25),
    address TEXT,
    city VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(50) DEFAULT 'Malaysia', -- Default country
    registration_date DATE
);

-- Create ProductCategories Table
CREATE TABLE ProductCategories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- Create Products Table
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    category_id INT,
    vendor_id INT,
    purchase_price DECIMAL(10, 2), -- Price bought from vendor
    selling_price DECIMAL(10, 2) NOT NULL, -- Price sold to customer
    stock_quantity INT DEFAULT 0,
    warranty_period_months INT DEFAULT 12, -- Added Warranty
    FOREIGN KEY (category_id) REFERENCES ProductCategories(category_id) ON DELETE SET NULL,
    FOREIGN KEY (vendor_id) REFERENCES Vendors(vendor_id) ON DELETE SET NULL
);

-- Create Orders Table
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    salesperson_id INT,
    order_date DATETIME NOT NULL,
    status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending', -- Added Status
    shipping_address TEXT, -- Added Shipping Address if different
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE SET NULL,
    FOREIGN KEY (salesperson_id) REFERENCES SalesPersons(salesperson_id) ON DELETE SET NULL
);

-- Create Order_Items Table
CREATE TABLE Order_Items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    price_per_unit DECIMAL(10, 2) NOT NULL, -- Price at the time of sale
    discount DECIMAL(5, 2) DEFAULT 0.00, -- Added Discount per item
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE RESTRICT -- Prevent deleting product if it's in an order
);

-- --------------------------
--      INDEX CREATION
-- --------------------------
CREATE INDEX idx_vendor_country ON Vendors(country);
CREATE INDEX idx_customer_city ON Customers(city);
CREATE INDEX idx_customer_country ON Customers(country);
CREATE INDEX idx_product_category ON Products(category_id);
CREATE INDEX idx_product_vendor ON Products(vendor_id);
CREATE INDEX idx_product_selling_price ON Products(selling_price);
CREATE INDEX idx_order_date ON Orders(order_date);
CREATE INDEX idx_order_status ON Orders(status);
CREATE INDEX idx_order_customer ON Orders(customer_id);
CREATE INDEX idx_order_salesperson ON Orders(salesperson_id);
CREATE INDEX idx_orderitems_order ON Order_Items(order_id);
CREATE INDEX idx_orderitems_product ON Order_Items(product_id);

-- --------------------------
--      SAMPLE DATA INSERTION
-- --------------------------

-- Insert Vendors (More vendors)
INSERT INTO Vendors (vendor_name, contact_person, phone, email, address, country) VALUES
('Global Electronics Inc.', 'Sarah Chen', '+1-555-0101', 'sales@globalelectronics.com', '1 Tech Park, Silicon Valley', 'USA'),
('Appliance Masters Ltd.', 'David Lee', '+44-20-7946-0102', 'contact@appliancemasters.co.uk', '2 Industrial Way, London', 'UK'),
('Lighting Solutions Co.', 'Emily White', '+65-6777-0103', 'info@lightingsolutions.sg', '3 Bright Ave, Singapore', 'Singapore'),
('Home Gadget Suppliers', 'Mike Brown', '+1-555-0104', 'suppliers@homegadget.com', '4 Gadget Hub, Austin', 'USA'),
('EuroKitchen Appliances', 'Hans Muller', '+49-30-123456', 'info@eurokitchen.de', '5 Kurfürstendamm, Berlin', 'Germany'),
('Asia Pacific Tech', 'Kenji Tanaka', '+81-3-1111-2222', 'sales.jp@asiapac.com', '6 Tech Tower, Tokyo', 'Japan'),
('Comfort Living Inc.', 'Laura Green', '+1-555-0107', 'laura.g@comfortliving.com', '7 Comfort Zone, Toronto', 'Canada'),
('Bright Spark Ltd.', 'James Watt', '+61-2-9876-5432', 'james.w@brightspark.au', '8 Power St, Sydney', 'Australia'),
('MY Local Distributor', 'Ahmad Bin Ismail', '03-1234 5678', 'ahmad.i@mylocal.com.my', '9 Jalan Industri, Shah Alam', 'Malaysia'),
('EcoFriendly Elec Co.', 'Maria Garcia', '+34-91-111-2233', 'maria.g@ecofriendly.es', '10 Calle Verde, Madrid', 'Spain');

-- Insert Sales Persons (More salespeople with commissions)
INSERT INTO SalesPersons (first_name, last_name, email, phone, hire_date, commission_rate) VALUES
('Alice', 'Smith', 'alice.s@shop.com.my', '012-3456781', '2021-08-15', 0.06),
('Bob', 'Johnson', 'bob.j@shop.com.my', '019-8765432', '2022-01-10', 0.05),
('Charlie', 'Davis', 'charlie.d@shop.com.my', '017-1112233', '2023-03-01', 0.05),
('Diana', 'Evans', 'diana.e@shop.com.my', '016-4455667', '2023-09-20', 0.04),
('Ethan', 'Miller', 'ethan.m@shop.com.my', '018-7788990', '2024-02-12', 0.05),
('Fiona', 'Wilson', 'fiona.w@shop.com.my', '011-1212121', '2024-07-01', 0.04);

-- Insert Customers (More customers, some local)
INSERT INTO Customers (first_name, last_name, email, phone, address, city, postal_code, country, registration_date) VALUES
('John', 'Doe', 'john.doe@email.com', '555-2221', '123 Main St', 'New York', '10001', 'USA', '2022-05-20'),
('Jane', 'Smith', 'jane.s@email.com', '555-2222', '456 Oak Ave', 'London', 'SW1A 0AA', 'UK', '2022-06-11'),
('Peter', 'Jones', 'peter.j@email.com', '555-2223', '789 Pine Rd', 'Sydney', '2000', 'Australia', '2023-01-15'),
('Mary', 'Williams', 'mary.w@email.com', '555-2224', '101 Maple Dr', 'Toronto', 'M5H 2N2', 'Canada', '2023-07-22'),
('David', 'Brown', 'david.b@email.com', '555-2225', '202 Birch Ln', 'Austin', '78701', 'USA', '2024-02-10'),
('Siti', 'Binti Rahman', 'siti.r@email.com.my', '012-1122334', 'Lot 15, Taman Desa', 'Johor Bahru', '81100', 'Malaysia', '2022-08-01'),
('Lim', 'Wei Jie', 'weijie.lim@email.com.my', '019-5566778', '22 Jalan Harmoni', 'Kuala Lumpur', '50480', 'Malaysia', '2022-09-15'),
('Kumar', 'A/L Muthu', 'kumar.m@email.com.my', '017-9900112', '8 Lorong Indah', 'Penang', '11900', 'Malaysia', '2023-03-10'),
('Chen', 'Mei Ling', 'mling.chen@email.com.my', '016-2233445', 'Block C-2-1, Subang Jaya', 'Selangor', '47500', 'Malaysia', '2023-10-05'),
('Abdul', 'Bin Hamid', 'abdul.h@email.com.my', '018-6677889', '5 Jalan Mutiara', 'Johor Bahru', '80250', 'Malaysia', '2024-01-20'),
('Isabelle', 'Dubois', 'isabelle.d@email.fr', '+33-1-4567890', '10 Rue de la Paix', 'Paris', '75002', 'France', '2023-05-11'),
('Kenji', 'Sato', 'kenji.s@email.jp', '+81-80-1234-5678', '1-2-3 Shibuya', 'Tokyo', '150-0002', 'Japan', '2024-04-01'),
-- Add more customers (up to 30)
('Fatima', 'Al-Sayed', 'fatima.a@email.ae', '+971-50-111-2222', 'Villa 5, Jumeirah', 'Dubai', '34106', 'UAE', '2022-11-05'),
('Carlos', 'Gomez', 'carlos.g@email.mx', '+52-55-9876-5432', 'Av. Reforma 100', 'Mexico City', '06600', 'Mexico', '2023-06-25'),
('Aisha', 'Binti Ibrahim', 'aisha.i@email.com.my', '011-3344556', '18 Jalan Ceria', 'Johor Bahru', '81300', 'Malaysia', '2023-08-18'),
('Ravi', 'Sharma', 'ravi.s@email.in', '+91-98-1111-2222', 'Flat 12, Sector 5', 'New Delhi', '110017', 'India', '2024-05-01'),
('Hans', 'Schmidt', 'hans.s@email.de', '+49-170-1234567', 'Musterstraße 1', 'Berlin', '10117', 'Germany', '2022-07-14'),
('Olivia', 'Martinez', 'olivia.m@email.es', '+34-600-112233', 'Calle Mayor 5', 'Madrid', '28013', 'Spain', '2023-11-30'),
('Tan', 'Ah Kow', 'ak.tan@email.com.my', '013-7788990', '77 Jalan Sutera', 'Johor Bahru', '80150', 'Malaysia', '2024-06-10'),
('Chloe', 'Nguyen', 'chloe.n@email.vn', '+84-90-123-4567', '15 Le Loi St', 'Ho Chi Minh City', '700000', 'Vietnam', '2022-12-01'),
('Mike', 'Lee', 'mike.l@email.com.sg', '+65-9876-5432', 'Blk 10, Orchard Road', 'Singapore', '238888', 'Singapore', '2023-04-19'),
('Nur', 'Fazura', 'nur.f@email.com.my', '014-1122337', '25 Lorong Bahagia', 'Kota Kinabalu', '88000', 'Malaysia', '2024-08-22'),
('William', 'Taylor', 'william.t@email.co.uk', '+44-7700-900123', 'Flat 5, Baker Street', 'London', 'NW1 6XE', 'UK', '2023-02-28'),
('Sophia', 'Liu', 'sophia.l@email.cn', '+86-139-1111-2222', 'No. 8 Wangfujing Ave', 'Beijing', '100006', 'China', '2024-09-05'),
('Mohd', 'Ali', 'mohd.ali@email.com.my', '015-4455668', '1 Kampung Baru', 'Kuala Lumpur', '50300', 'Malaysia', '2022-10-12'),
('Anna', 'Petrova', 'anna.p@email.ru', '+7-916-123-45-67', 'Tverskaya St 10', 'Moscow', '125009', 'Russia', '2023-09-14'),
('David', 'Kim', 'david.k@email.kr', '+82-10-9876-5432', 'Gangnam-daero 100', 'Seoul', '06134', 'South Korea', '2024-10-30'),
('Jennifer', 'Wong', 'jen.wong@email.com.hk', '+852-9123-4567', 'Flat 10A, Central Tower', 'Hong Kong', '999077', 'Hong Kong', '2023-12-25'),
('Ahmed', 'Khan', 'ahmed.k@email.pk', '+92-300-1112233', 'House 5, Sector F-8', 'Islamabad', '44000', 'Pakistan', '2024-11-15'),
('Maria', 'Silva', 'maria.s@email.br', '+55-11-98765-4321', 'Rua Augusta 1500', 'Sao Paulo', '01304-001', 'Brazil', '2023-01-05');


-- Insert Product Categories (More categories)
INSERT INTO ProductCategories (category_name, description) VALUES
('Major Kitchen Appliances', 'Refrigerators, Ovens, Dishwashers'),
('Audio & Video Entertainment', 'TVs, Sound Systems, Projectors'),
('Lighting Fixtures', 'Ceiling lights, Lamps, Outdoor lighting'),
('Climate Control', 'Air Conditioners, Heaters, Fans, Purifiers'),
('Small Kitchen Appliances', 'Microwaves, Blenders, Kettles, Toasters'),
('Personal Care Appliances', 'Hair Dryers, Electric Shavers'),
('Smart Home Devices', 'Smart Speakers, Smart Lighting, Smart Security'),
('Power & Accessories', 'Extension cords, Adapters, Surge Protectors');

-- Insert Products (More products with variety)
INSERT INTO Products (product_name, description, category_id, vendor_id, purchase_price, selling_price, stock_quantity, warranty_period_months) VALUES
('Smart Frost-Free Refrigerator XL', '450L Capacity, WiFi Enabled', 1, 1, 1500.00, 2199.99, 10, 24),
('Ultra HD 8K QLED TV 65"', '65-inch 8K Television with Quantum Dot', 2, 1, 1800.00, 2999.99, 8, 24),
('Dimmable LED Ceiling Fan Light', 'Modern fan with integrated dimmable light', 3, 3, 120.00, 199.99, 30, 12),
('HEPA Air Purifier Tower', 'Covers large rooms, quiet operation', 4, 2, 180.00, 279.99, 25, 18),
('Robotic Vacuum & Mop Pro G2', 'Advanced navigation, mopping function', 7, 4, 450.00, 649.99, 15, 12),
('Inverter Microwave Oven 1200W', 'Stainless steel, sensor cooking', 5, 5, 150.00, 229.99, 35, 12),
('Dolby Atmos Soundbar 5.1.2', 'Immersive home theater sound', 2, 6, 400.00, 599.99, 22, 18),
('Smart WiFi Thermostat Gen 3', 'Learns schedule, remote control', 7, 4, 110.00, 179.99, 40, 12),
('Digital Electric Kettle 1.7L', 'Variable temperature control', 5, 9, 45.00, 69.99, 50, 12),
('High-Power Blender 1500W', 'Smoothie maker, ice crushing', 5, 5, 90.00, 149.99, 28, 24),
('Smart RGB LED Light Bulb E27', 'Color changing, works with Alexa/Google', 7, 3, 15.00, 29.99, 150, 12),
('Portable Air Conditioner 12000 BTU', 'Cools rooms up to 400 sq ft', 4, 7, 350.00, 499.99, 12, 18),
('Professional Hair Dryer 2200W', 'Ionic technology, multiple settings', 6, 7, 50.00, 89.99, 45, 12),
('Electric Wet/Dry Shaver Series 9', 'Premium shaver for sensitive skin', 6, 1, 180.00, 279.99, 20, 24),
('Smart Security Camera Outdoor WiFi', '1080p, Night Vision, Motion Detection', 7, 4, 80.00, 129.99, 33, 12),
('Heavy Duty Extension Cord 10m', '13A rating, surge protected', 8, 9, 18.00, 29.99, 80, 6),
('Universal Travel Adapter Multi-Plug', 'Works in 150+ countries, USB ports', 8, 6, 20.00, 34.99, 100, 12),
('Convection Toaster Oven', 'Fits 12-inch pizza, multiple functions', 5, 2, 100.00, 159.99, 26, 12),
('Silent Tower Fan Oscillating', 'Slim design, remote control', 4, 10, 60.00, 99.99, 40, 12),
('Smart WiFi Power Strip', '4 Outlets, USB Ports, Voice Control', 8, 8, 35.00, 59.99, 60, 12),
('Induction Cooktop Single Burner', 'Portable, energy efficient', 5, 5, 70.00, 119.99, 18, 12),
('Wireless Bluetooth Headphones', 'Noise-cancelling, Over-ear', 2, 1, 120.00, 199.99, 25, 12),
('Compact Dishwasher Countertop', 'Ideal for small kitchens', 1, 2, 300.00, 449.99, 7, 24),
('Smart Doorbell Video Camera', 'Two-way audio, motion alerts', 7, 4, 130.00, 199.99, 19, 12),
('Electric Hand Mixer 5-Speed', 'Lightweight, includes beaters and dough hooks', 5, 9, 25.00, 39.99, 55, 12);


-- Insert Orders (More orders spanning last 3 years)
-- Dates range roughly from 2022-04-14 to 2025-04-14
INSERT INTO Orders (customer_id, salesperson_id, order_date, status, shipping_address) VALUES
(6, 1, '2022-04-20 11:05:00', 'Delivered', NULL), -- Siti
(1, 2, '2022-05-15 14:20:00', 'Delivered', NULL), -- John
(7, 3, '2022-06-10 09:30:00', 'Delivered', NULL), -- Lim
(11, 1, '2022-07-05 16:00:00', 'Delivered', '15 Rue de Rivoli, Paris'), -- Isabelle
(8, 2, '2022-08-18 10:45:00', 'Delivered', NULL), -- Kumar
(13, 4, '2022-09-22 13:10:00', 'Delivered', NULL), -- Fatima
(2, 1, '2022-10-30 15:00:00', 'Delivered', NULL), -- Jane
(9, 3, '2022-11-25 11:55:00', 'Delivered', NULL), -- Chen
(15, 4, '2022-12-15 17:30:00', 'Delivered', NULL), -- Aisha
(3, 2, '2023-01-20 09:00:00', 'Delivered', NULL), -- Peter
(10, 5, '2023-02-14 10:10:00', 'Delivered', NULL), -- Abdul
(17, 6, '2023-03-05 12:25:00', 'Delivered', NULL), -- Hans
(4, 1, '2023-04-19 14:50:00', 'Delivered', NULL), -- Mary
(12, 3, '2023-05-28 11:15:00', 'Delivered', NULL), -- Kenji
(19, 4, '2023-06-30 16:40:00', 'Delivered', NULL), -- Tan Ah Kow
(5, 2, '2023-07-11 09:55:00', 'Delivered', NULL), -- David Brown
(21, 5, '2023-08-09 13:00:00', 'Delivered', NULL), -- Mike Lee
(6, 1, '2023-09-14 10:35:00', 'Delivered', NULL), -- Siti
(23, 6, '2023-10-21 15:20:00', 'Delivered', NULL), -- William
(25, 3, '2023-11-16 17:05:00', 'Delivered', NULL), -- Mohd Ali
(14, 4, '2023-12-22 11:45:00', 'Delivered', 'Av. Insurgentes Sur 500, Mexico City'), -- Carlos
(16, 5, '2024-01-29 10:00:00', 'Shipped', NULL), -- Ravi
(18, 6, '2024-02-17 14:00:00', 'Shipped', NULL), -- Olivia
(7, 1, '2024-03-10 16:15:00', 'Processing', NULL), -- Lim
(20, 2, '2024-04-05 09:20:00', 'Delivered', NULL), -- Chloe
(22, 3, '2024-05-12 11:00:00', 'Delivered', NULL), -- Nur
(1, 4, '2024-06-18 13:30:00', 'Delivered', NULL), -- John
(24, 5, '2024-07-25 15:50:00', 'Delivered', NULL), -- Sophia
(9, 6, '2024-08-30 10:10:00', 'Delivered', NULL), -- Chen
(26, 1, '2024-09-11 12:40:00', 'Shipped', NULL), -- Anna
(10, 2, '2024-10-16 14:25:00', 'Processing', NULL), -- Abdul
(28, 3, '2024-11-20 09:45:00', 'Delivered', NULL), -- Jennifer
(12, 4, '2024-12-08 16:00:00', 'Delivered', NULL), -- Kenji
(30, 5, '2025-01-15 11:35:00', 'Processing', NULL), -- Maria Silva
(3, 6, '2025-01-28 17:10:00', 'Shipped', NULL), -- Peter
(27, 1, '2025-02-19 10:50:00', 'Pending', NULL), -- David Kim
(15, 2, '2025-03-05 14:05:00', 'Processing', NULL), -- Aisha
(29, 3, '2025-03-25 09:00:00', 'Pending', NULL), -- Ahmed Khan
(5, 4, '2025-04-10 11:20:00', 'Pending', NULL); -- David Brown

-- Insert Order Items (More items per order, some with discounts)
-- Note: Prices are copied from product table for simplicity, real system might use historical price.
INSERT INTO Order_Items (order_id, product_id, quantity, price_per_unit, discount) VALUES
-- Order 1 (Siti)
(1, 9, 1, 69.99, 0.00), (1, 16, 1, 29.99, 0.00),
-- Order 2 (John)
(2, 2, 1, 2999.99, 100.00), -- Discount on TV
-- Order 3 (Lim)
(3, 6, 1, 229.99, 0.00), (3, 25, 1, 39.99, 0.00),
-- Order 4 (Isabelle)
(4, 13, 1, 89.99, 0.00),
-- Order 5 (Kumar)
(5, 4, 1, 279.99, 0.00), (5, 11, 2, 29.99, 0.00),
-- Order 6 (Fatima)
(6, 23, 1, 449.99, 20.00), -- Discount on Dishwasher
-- Order 7 (Jane)
(7, 7, 1, 599.99, 0.00),
-- Order 8 (Chen)
(8, 10, 1, 149.99, 10.00), (8, 17, 1, 34.99, 0.00),
-- Order 9 (Aisha)
(9, 15, 1, 129.99, 0.00), (9, 20, 1, 59.99, 0.00),
-- Order 10 (Peter)
(10, 12, 1, 499.99, 0.00),
-- Order 11 (Abdul)
(11, 18, 1, 159.99, 0.00),
-- Order 12 (Hans)
(12, 1, 1, 2199.99, 0.00),
-- Order 13 (Mary)
(13, 14, 1, 279.99, 15.00), (13, 13, 1, 89.99, 0.00),
-- Order 14 (Kenji)
(14, 5, 1, 649.99, 0.00),
-- Order 15 (Tan Ah Kow)
(15, 19, 2, 99.99, 0.00), (15, 21, 1, 119.99, 0.00),
-- Order 16 (David Brown)
(16, 3, 1, 199.99, 0.00),
-- Order 17 (Mike Lee)
(17, 22, 1, 199.99, 0.00), (17, 11, 5, 29.99, 5.00), -- Bulk discount bulbs
-- Order 18 (Siti)
(18, 8, 1, 179.99, 0.00),
-- Order 19 (William)
(19, 24, 1, 199.99, 0.00),
-- Order 20 (Mohd Ali)
(20, 9, 1, 69.99, 0.00), (20, 25, 1, 39.99, 0.00),
-- Order 21 (Carlos)
(21, 1, 1, 2199.99, 200.00), -- Big discount Fridge
-- Order 22 (Ravi)
(22, 10, 1, 149.99, 0.00), (22, 16, 2, 29.99, 0.00),
-- Order 23 (Olivia)
(23, 13, 1, 89.99, 0.00),
-- Order 24 (Lim)
(24, 17, 2, 34.99, 0.00), (24, 20, 1, 59.99, 0.00),
-- Order 25 (Chloe)
(25, 4, 1, 279.99, 0.00),
-- Order 26 (Nur)
(26, 18, 1, 159.99, 10.00),
-- Order 27 (John)
(27, 5, 1, 649.99, 0.00),
-- Order 28 (Sophia)
(28, 2, 1, 2999.99, 0.00), (28, 7, 1, 599.99, 50.00),
-- Order 29 (Chen)
(29, 11, 10, 29.99, 10.00), -- Bulk bulbs
-- Order 30 (Anna)
(30, 12, 1, 499.99, 0.00),
-- Order 31 (Abdul)
(31, 6, 1, 229.99, 0.00),
-- Order 32 (Jennifer)
(32, 15, 2, 129.99, 5.00), (32, 24, 1, 199.99, 0.00),
-- Order 33 (Kenji)
(33, 22, 1, 199.99, 0.00),
-- Order 34 (Maria Silva)
(34, 14, 1, 279.99, 0.00), (34, 21, 1, 119.99, 0.00),
-- Order 35 (Peter)
(35, 9, 2, 69.99, 5.00),
-- Order 36 (David Kim)
(36, 1, 1, 2199.99, 0.00),
-- Order 37 (Aisha)
(37, 19, 1, 99.99, 0.00), (37, 16, 3, 29.99, 2.00),
-- Order 38 (Ahmed Khan)
(38, 3, 1, 199.99, 0.00),
-- Order 39 (David Brown)
(39, 8, 1, 179.99, 0.00), (39, 11, 3, 29.99, 0.00),
-- Order 40 (David Brown) - Assuming this is a new order ID 40
(40, 25, 2, 39.99, 0.00);

-- --------------------------
--      END OF SAMPLE DATA
-- --------------------------

-- Example Revenue Queries (Remain the same logic)

-- Total Revenue All Time (considering discounts)
-- SELECT SUM(quantity * (price_per_unit - discount)) AS total_revenue FROM Order_Items;

-- Total Revenue for the Year 2024
-- SELECT SUM(oi.quantity * (oi.price_per_unit - oi.discount)) AS revenue_2024
-- FROM Order_Items oi
-- JOIN Orders o ON oi.order_id = o.order_id
-- WHERE YEAR(o.order_date) = 2024;

-- Total Revenue for the Year 2023
-- SELECT SUM(oi.quantity * (oi.price_per_unit - oi.discount)) AS revenue_2023
-- FROM Order_Items oi
-- JOIN Orders o ON oi.order_id = o.order_id
-- WHERE YEAR(o.order_date) = 2023;

-- Total Revenue for the Year 2022
-- SELECT SUM(oi.quantity * (oi.price_per_unit - oi.discount)) AS revenue_2022
-- FROM Order_Items oi
-- JOIN Orders o ON oi.order_id = o.order_id
-- WHERE YEAR(o.order_date) = 2022;

-- Revenue per Salesperson for 2024
-- SELECT
--     sp.first_name,
--     sp.last_name,
--     SUM(oi.quantity * (oi.price_per_unit - oi.discount)) AS salesperson_revenue_2024
-- FROM Order_Items oi
-- JOIN Orders o ON oi.order_id = o.order_id
-- JOIN SalesPersons sp ON o.salesperson_id = sp.salesperson_id
-- WHERE YEAR(o.order_date) = 2024
-- GROUP BY sp.salesperson_id
-- ORDER BY salesperson_revenue_2024 DESC;

-- Calculate salesperson commission for 2024
-- SELECT
--     sp.first_name,
--     sp.last_name,
--     SUM(oi.quantity * (oi.price_per_unit - oi.discount)) AS total_sales_2024,
--     sp.commission_rate,
--     SUM(oi.quantity * (oi.price_per_unit - oi.discount)) * sp.commission_rate AS commission_earned_2024
-- FROM Order_Items oi
-- JOIN Orders o ON oi.order_id = o.order_id
-- JOIN SalesPersons sp ON o.salesperson_id = sp.salesperson_id
-- WHERE YEAR(o.order_date) = 2024
-- GROUP BY sp.salesperson_id, sp.first_name, sp.last_name, sp.commission_rate
-- ORDER BY commission_earned_2024 DESC;

-- Top 10 Customers by Total Spending
-- SELECT
--     c.first_name,
--     c.last_name,
--     c.email,
--     SUM(oi.quantity * (oi.price_per_unit - oi.discount)) AS total_spent
-- FROM Order_Items oi
-- JOIN Orders o ON oi.order_id = o.order_id
-- JOIN Customers c ON o.customer_id = c.customer_id
-- GROUP BY c.customer_id, c.first_name, c.last_name, c.email
-- ORDER BY total_spent DESC
-- LIMIT 10;

-- Top 5 Selling Products (by quantity) in the last year (2024-04-14 to 2025-04-14)
-- SELECT
--    p.product_name,
--    SUM(oi.quantity) as total_quantity_sold
-- FROM Order_Items oi
-- JOIN Products p ON oi.product_id = p.product_id
-- JOIN Orders o ON oi.order_id = o.order_id
-- WHERE o.order_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 YEAR) AND CURDATE()
-- GROUP BY p.product_id, p.product_name
-- ORDER BY total_quantity_sold DESC
-- LIMIT 5;