-- =============================================================
-- SAMPLE DATA - Online Food Management System
-- =============================================================

-- 1. Admins
INSERT INTO ADMINS (username, password) VALUES ('admin', 'admin123');

-- 2. Customers (5+)
INSERT INTO CUSTOMERS (name, email, password, phone, address) VALUES ('Rahul Sharma', 'rahul@example.com', 'pass123', '9876543210', 'Block A, Connaught Place, New Delhi');
INSERT INTO CUSTOMERS (name, email, password, phone, address) VALUES ('Priya Singh', 'priya@example.com', 'pass123', '9876543211', 'Sector 15, Gurgaon');
INSERT INTO CUSTOMERS (name, email, password, phone, address) VALUES ('Amit Patel', 'amit@example.com', 'pass123', '9876543212', 'Vastrapur, Ahmedabad');
INSERT INTO CUSTOMERS (name, email, password, phone, address) VALUES ('Sneha Reddy', 'sneha@example.com', 'pass123', '9876543213', 'Hitech City, Hyderabad');
INSERT INTO CUSTOMERS (name, email, password, phone, address) VALUES ('Vikram Rao', 'vikram@example.com', 'pass123', '9876543214', 'Indiranagar, Bangalore');
INSERT INTO CUSTOMERS (name, email, password, phone, address) VALUES ('Neha Gupta', 'neha@example.com', 'pass123', '9876543215', 'Bandra West, Mumbai');

-- 3. Restaurants (3+)
INSERT INTO RESTAURANTS (name, location, rating) VALUES ('Spice Garden', 'CP, Delhi', 4.5);
INSERT INTO RESTAURANTS (name, location, rating) VALUES ('The Italian Job', 'MG Road, Bangalore', 4.2);
INSERT INTO RESTAURANTS (name, location, rating) VALUES ('Burger Barn', 'Multiple Locations', 4.0);
INSERT INTO RESTAURANTS (name, location, rating) VALUES ('Dragon Wok', 'Jubilee Hills, Hyderabad', 4.7);

-- 4. Menu Categories
INSERT INTO MENU_CATEGORIES (category_name) VALUES ('Starters');
INSERT INTO MENU_CATEGORIES (category_name) VALUES ('Main Course');
INSERT INTO MENU_CATEGORIES (category_name) VALUES ('Beverages');
INSERT INTO MENU_CATEGORIES (category_name) VALUES ('Desserts');

-- 5. Menu Items
-- Spice Garden (restaurant_id=1)
INSERT INTO MENU_ITEMS (item_name, price, category_id, restaurant_id) VALUES ('Paneer Tikka', 250, 1, 1);
INSERT INTO MENU_ITEMS (item_name, price, category_id, restaurant_id) VALUES ('Butter Chicken', 450, 2, 1);
INSERT INTO MENU_ITEMS (item_name, price, category_id, restaurant_id) VALUES ('Dal Makhani', 300, 2, 1);
INSERT INTO MENU_ITEMS (item_name, price, category_id, restaurant_id) VALUES ('Mango Lassi', 120, 3, 1);
INSERT INTO MENU_ITEMS (item_name, price, category_id, restaurant_id) VALUES ('Gulab Jamun', 150, 4, 1);
-- The Italian Job (restaurant_id=2)
INSERT INTO MENU_ITEMS (item_name, price, category_id, restaurant_id) VALUES ('Margherita Pizza', 350, 2, 2);
INSERT INTO MENU_ITEMS (item_name, price, category_id, restaurant_id) VALUES ('Pasta Alfredo', 400, 2, 2);
INSERT INTO MENU_ITEMS (item_name, price, category_id, restaurant_id) VALUES ('Tiramisu', 250, 4, 2);
INSERT INTO MENU_ITEMS (item_name, price, category_id, restaurant_id) VALUES ('Cappuccino', 180, 3, 2);
-- Burger Barn (restaurant_id=3)
INSERT INTO MENU_ITEMS (item_name, price, category_id, restaurant_id) VALUES ('Classic Burger', 180, 2, 3);
INSERT INTO MENU_ITEMS (item_name, price, category_id, restaurant_id) VALUES ('Cheese Fries', 120, 1, 3);
INSERT INTO MENU_ITEMS (item_name, price, category_id, restaurant_id) VALUES ('Cold Coffee', 90, 3, 3);
-- Dragon Wok (restaurant_id=4)
INSERT INTO MENU_ITEMS (item_name, price, category_id, restaurant_id) VALUES ('Szechuan Noodles', 280, 2, 4);
INSERT INTO MENU_ITEMS (item_name, price, category_id, restaurant_id) VALUES ('Spring Rolls', 200, 1, 4);
INSERT INTO MENU_ITEMS (item_name, price, category_id, restaurant_id) VALUES ('Dim Sum', 320, 1, 4);

-- 6. Delivery Agents
INSERT INTO DELIVERY_AGENTS (agent_name, phone, is_available) VALUES ('Suresh Kumar', '9998887771', 'Y');
INSERT INTO DELIVERY_AGENTS (agent_name, phone, is_available) VALUES ('Mahesh Babu', '9998887772', 'Y');
INSERT INTO DELIVERY_AGENTS (agent_name, phone, is_available) VALUES ('Rajesh Khanna', '9998887773', 'Y');
INSERT INTO DELIVERY_AGENTS (agent_name, phone, is_available) VALUES ('Pradeep Roy', '9998887774', 'Y');

COMMIT;
