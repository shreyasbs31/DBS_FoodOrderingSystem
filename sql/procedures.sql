-- =============================================================
-- PL/SQL STORED PROCEDURES - Online Food Management System
-- =============================================================

-- 1. Register a New Customer
CREATE OR REPLACE PROCEDURE pr_Register_Customer (
    p_name IN VARCHAR2,
    p_email IN VARCHAR2,
    p_password IN VARCHAR2,
    p_phone IN VARCHAR2,
    p_address IN VARCHAR2
) AS
BEGIN
    INSERT INTO CUSTOMERS (name, email, password, phone, address)
    VALUES (p_name, p_email, p_password, p_phone, p_address);
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20001, 'Email already exists');
END;
/

-- 2. Place Order from Cart (moves cart items → order_details, clears cart)
--    Total is computed INLINE to avoid ORA-04091 mutating table error in trigger.
CREATE OR REPLACE PROCEDURE pr_Place_Order (
    p_customer_id IN NUMBER,
    p_restaurant_id IN NUMBER,
    p_out_order_id OUT NUMBER
) AS
    v_total NUMBER(10,2) := 0;
BEGIN
    -- Create the order header (total starts at 0)
    INSERT INTO ORDERS (customer_id, restaurant_id, order_status, total_amount)
    VALUES (p_customer_id, p_restaurant_id, 'PENDING', 0)
    RETURNING order_id INTO p_out_order_id;

    -- Move cart items → order details
    INSERT INTO ORDER_DETAILS (order_id, item_id, quantity, unit_price)
    SELECT p_out_order_id, c.item_id, c.quantity, m.price
    FROM CARTS c
    JOIN MENU_ITEMS m ON c.item_id = m.item_id
    WHERE c.customer_id = p_customer_id
      AND m.restaurant_id = p_restaurant_id;

    -- Compute total AFTER all rows are inserted (avoids mutating table)
    SELECT NVL(SUM(quantity * unit_price), 0)
    INTO v_total
    FROM ORDER_DETAILS
    WHERE order_id = p_out_order_id;

    -- Update the order total directly
    UPDATE ORDERS SET total_amount = v_total WHERE order_id = p_out_order_id;

    -- Clear the cart
    DELETE FROM CARTS WHERE customer_id = p_customer_id;

    COMMIT;
END;
/

-- 3. Assign Delivery Agent (picks first available agent)
CREATE OR REPLACE PROCEDURE pr_Assign_Delivery_Agent (
    p_order_id IN NUMBER
) AS
    v_agent_id NUMBER;
BEGIN
    SELECT agent_id INTO v_agent_id
    FROM (SELECT agent_id FROM DELIVERY_AGENTS WHERE is_available = 'Y' ORDER BY agent_id)
    WHERE ROWNUM = 1;

    INSERT INTO DELIVERIES (order_id, agent_id, delivery_status)
    VALUES (p_order_id, v_agent_id, 'ASSIGNED');

    UPDATE DELIVERY_AGENTS SET is_available = 'N' WHERE agent_id = v_agent_id;
    UPDATE ORDERS SET order_status = 'CONFIRMED' WHERE order_id = p_order_id;

    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'No delivery agents available');
END;
/

-- 4. Update Order Status
CREATE OR REPLACE PROCEDURE pr_Update_Order_Status (
    p_order_id IN NUMBER,
    p_status IN VARCHAR2
) AS
BEGIN
    UPDATE ORDERS SET order_status = p_status WHERE order_id = p_order_id;
    COMMIT;
END;
/

-- 5. Process Payment for an Order
CREATE OR REPLACE PROCEDURE pr_Process_Payment (
    p_order_id IN NUMBER,
    p_method IN VARCHAR2
) AS
BEGIN
    INSERT INTO PAYMENTS (order_id, payment_method, payment_status)
    VALUES (p_order_id, p_method, 'COMPLETED');

    UPDATE ORDERS SET order_status = 'CONFIRMED' WHERE order_id = p_order_id;

    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20003, 'Payment already exists for this order');
END;
/

-- 6. Add a New Restaurant (Admin)
CREATE OR REPLACE PROCEDURE pr_Add_Restaurant (
    p_name IN VARCHAR2,
    p_location IN VARCHAR2,
    p_rating IN NUMBER DEFAULT 0
) AS
BEGIN
    INSERT INTO RESTAURANTS (name, location, rating)
    VALUES (p_name, p_location, p_rating);
    COMMIT;
END;
/

-- 7. Add a Menu Item (Admin)
CREATE OR REPLACE PROCEDURE pr_Add_Menu_Item (
    p_item_name IN VARCHAR2,
    p_price IN NUMBER,
    p_category_id IN NUMBER,
    p_restaurant_id IN NUMBER
) AS
BEGIN
    INSERT INTO MENU_ITEMS (item_name, price, category_id, restaurant_id)
    VALUES (p_item_name, p_price, p_category_id, p_restaurant_id);
    COMMIT;
END;
/

-- 8. Delete a Menu Item (Admin)
CREATE OR REPLACE PROCEDURE pr_Delete_Menu_Item (
    p_item_id IN NUMBER
) AS
BEGIN
    DELETE FROM MENU_ITEMS WHERE item_id = p_item_id;
    COMMIT;
END;
/

-- 9. Update Delivery Status
CREATE OR REPLACE PROCEDURE pr_Update_Delivery_Status (
    p_delivery_id IN NUMBER,
    p_status IN VARCHAR2
) AS
BEGIN
    UPDATE DELIVERIES SET delivery_status = p_status WHERE delivery_id = p_delivery_id;
    IF p_status = 'DELIVERED' THEN
        UPDATE DELIVERIES SET completion_time = CURRENT_TIMESTAMP WHERE delivery_id = p_delivery_id;
    END IF;
    COMMIT;
END;
/
