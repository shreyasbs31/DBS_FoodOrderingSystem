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
--    Validates cart has items before creating order to prevent empty $0 orders.
CREATE OR REPLACE PROCEDURE pr_Place_Order (
    p_customer_id IN NUMBER,
    p_restaurant_id IN NUMBER,
    p_out_order_id OUT NUMBER
) AS
    v_total NUMBER(10,2) := 0;
    v_item_count NUMBER := 0;
BEGIN
    -- Verify cart has items for this restaurant
    SELECT COUNT(*)
    INTO v_item_count
    FROM CARTS c
    JOIN MENU_ITEMS m ON c.item_id = m.item_id
    WHERE c.customer_id = p_customer_id
      AND m.restaurant_id = p_restaurant_id;

    IF v_item_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Cart is empty for this restaurant');
    END IF;

    -- Create the order header (total starts at 0)
    INSERT INTO ORDERS (customer_id, restaurant_id, order_status, total_amount)
    VALUES (p_customer_id, p_restaurant_id, 'PENDING', 0)
    RETURNING order_id INTO p_out_order_id;

    -- Move cart items → order details (only for this restaurant)
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

    -- Clear ONLY the cart items that were ordered (only this restaurant's items)
    DELETE FROM CARTS
    WHERE customer_id = p_customer_id
      AND item_id IN (
          SELECT item_id FROM MENU_ITEMS WHERE restaurant_id = p_restaurant_id
      );

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20005, SQLERRM);
END;
/

-- 3. Assign Delivery Agent (picks first available agent atomically)
CREATE OR REPLACE PROCEDURE pr_Assign_Delivery_Agent (
    p_order_id IN NUMBER
) AS
    v_agent_id NUMBER;
    v_exists NUMBER;
BEGIN
    -- 1. Check if already assigned
    SELECT COUNT(*) INTO v_exists FROM DELIVERIES WHERE order_id = p_order_id;
    IF v_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20013, 'Agent already assigned to this order');
    END IF;

    -- 2. Atomically pick an available agent and mark them busy
    -- This avoids FOR UPDATE which triggers ORA-02014 in some environments.
    UPDATE DELIVERY_AGENTS
    SET is_available = 'N'
    WHERE agent_id = (
        SELECT MIN(agent_id)
        FROM DELIVERY_AGENTS
        WHERE is_available = 'Y'
    )
    RETURNING agent_id INTO v_agent_id;

    -- 3. If no agent was updated, then none were available
    IF v_agent_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'No delivery agents available');
    END IF;

    -- 4. Create the delivery record
    INSERT INTO DELIVERIES (order_id, agent_id, delivery_status)
    VALUES (p_order_id, v_agent_id, 'ASSIGNED');

    -- 5. Finalize the order status
    UPDATE ORDERS SET order_status = 'CONFIRMED' WHERE order_id = p_order_id;

    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'No delivery agents available');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

-- 4. Update Order Status (with validation of legal transitions)
CREATE OR REPLACE PROCEDURE pr_Update_Order_Status (
    p_order_id IN NUMBER,
    p_status IN VARCHAR2
) AS
    v_current_status VARCHAR2(20);
BEGIN
    -- Validate status is allowed value
    IF p_status NOT IN ('PENDING', 'ORDER_RECEIVED', 'CONFIRMED', 'OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED') THEN
        RAISE_APPLICATION_ERROR(-20006, 'Invalid order status: ' || p_status);
    END IF;

    -- Get current status
    SELECT order_status INTO v_current_status FROM ORDERS WHERE order_id = p_order_id;

    -- Validate legal transitions
    -- PENDING → ORDER_RECEIVED, CONFIRMED, CANCELLED
    -- ORDER_RECEIVED → CONFIRMED, CANCELLED
    -- CONFIRMED → OUT_FOR_DELIVERY, CANCELLED
    -- OUT_FOR_DELIVERY → DELIVERED, CANCELLED
    -- DELIVERED → (terminal, no transitions)
    -- CANCELLED → (terminal, no transitions)
    IF v_current_status = 'DELIVERED' OR v_current_status = 'CANCELLED' THEN
        RAISE_APPLICATION_ERROR(-20007, 'Cannot transition from ' || v_current_status || ' status');
    END IF;

    IF (v_current_status = 'PENDING' AND p_status NOT IN ('ORDER_RECEIVED', 'CONFIRMED', 'CANCELLED')) OR
       (v_current_status = 'ORDER_RECEIVED' AND p_status NOT IN ('CONFIRMED', 'CANCELLED')) OR
       (v_current_status = 'CONFIRMED' AND p_status NOT IN ('OUT_FOR_DELIVERY', 'CANCELLED')) OR
       (v_current_status = 'OUT_FOR_DELIVERY' AND p_status NOT IN ('DELIVERED', 'CANCELLED')) THEN
        RAISE_APPLICATION_ERROR(-20008, 'Invalid transition from ' || v_current_status || ' to ' || p_status);
    END IF;

    UPDATE ORDERS SET order_status = p_status WHERE order_id = p_order_id;
    COMMIT;
END;
/

-- 5. Process Payment for an Order (card/UPI - payment successful upfront)
CREATE OR REPLACE PROCEDURE pr_Process_Payment (
    p_order_id IN NUMBER,
    p_method IN VARCHAR2
) AS
    v_payment_status VARCHAR2(20);
BEGIN
    -- Validate payment method
    IF p_method NOT IN ('CREDIT_CARD', 'UPI') THEN
        RAISE_APPLICATION_ERROR(-20012, 'Invalid payment method');
    END IF;

    INSERT INTO PAYMENTS (order_id, payment_method, payment_status)
    VALUES (p_order_id, p_method, 'COMPLETED');

    -- Order status will be updated to CONFIRMED by trigger when COMPLETED payment is inserted
    -- Do NOT update here to avoid redundancy

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

-- 8. Delete a Menu Item (Admin - Soft Delete)
CREATE OR REPLACE PROCEDURE pr_Delete_Menu_Item (
    p_item_id IN NUMBER
) AS
BEGIN
    UPDATE MENU_ITEMS SET status = 'DELETED' WHERE item_id = p_item_id;
    DELETE FROM CARTS WHERE item_id = p_item_id;
    COMMIT;
END;
/

-- 8b. Restore a Menu Item (Admin)
CREATE OR REPLACE PROCEDURE pr_Restore_Menu_Item (
    p_item_id IN NUMBER
) AS
BEGIN
    UPDATE MENU_ITEMS SET status = 'ACTIVE' WHERE item_id = p_item_id;
    COMMIT;
END;
/

-- 9. Update Delivery Status (with validation)
CREATE OR REPLACE PROCEDURE pr_Update_Delivery_Status (
    p_delivery_id IN NUMBER,
    p_status IN VARCHAR2
) AS
    v_current_status VARCHAR2(20);
    v_agent_id NUMBER;
BEGIN
    -- Validate status is allowed value
    IF p_status NOT IN ('ASSIGNED', 'OUT_FOR_DELIVERY', 'DELIVERED') THEN
        RAISE_APPLICATION_ERROR(-20009, 'Invalid delivery status: ' || p_status);
    END IF;

    -- Get current status and agent_id
    SELECT delivery_status, agent_id INTO v_current_status, v_agent_id
    FROM DELIVERIES WHERE delivery_id = p_delivery_id;

    -- Validate legal transitions: ASSIGNED → OUT_FOR_DELIVERY → DELIVERED (one-way only)
    IF v_current_status = 'DELIVERED' THEN
        RAISE_APPLICATION_ERROR(-20010, 'Cannot change status of already delivered order');
    END IF;

    IF (v_current_status = 'ASSIGNED' AND p_status NOT IN ('OUT_FOR_DELIVERY', 'ASSIGNED')) OR
       (v_current_status = 'OUT_FOR_DELIVERY' AND p_status NOT IN ('DELIVERED', 'OUT_FOR_DELIVERY')) THEN
        RAISE_APPLICATION_ERROR(-20011, 'Invalid delivery transition from ' || v_current_status || ' to ' || p_status);
    END IF;

    UPDATE DELIVERIES SET delivery_status = p_status WHERE delivery_id = p_delivery_id;

    -- Set completion_time only on first DELIVERED transition
    IF p_status = 'DELIVERED' AND v_current_status != 'DELIVERED' THEN
        UPDATE DELIVERIES SET completion_time = CURRENT_TIMESTAMP WHERE delivery_id = p_delivery_id;
    END IF;

    COMMIT;
END;
/

-- 10. Delete Restaurant (Soft Delete)
CREATE OR REPLACE PROCEDURE pr_Delete_Restaurant (
    p_restaurant_id IN NUMBER
) AS
BEGIN
    UPDATE RESTAURANTS SET status = 'DELETED' WHERE restaurant_id = p_restaurant_id;
    UPDATE MENU_ITEMS SET status = 'DELETED' WHERE restaurant_id = p_restaurant_id;
    
    DELETE FROM CARTS WHERE item_id IN 
        (SELECT item_id FROM MENU_ITEMS WHERE restaurant_id = p_restaurant_id);

    COMMIT;
END;
/

-- 10b. Restore Restaurant
CREATE OR REPLACE PROCEDURE pr_Restore_Restaurant (
    p_restaurant_id IN NUMBER
) AS
BEGIN
    UPDATE RESTAURANTS SET status = 'ACTIVE' WHERE restaurant_id = p_restaurant_id;
    UPDATE MENU_ITEMS SET status = 'ACTIVE' WHERE restaurant_id = p_restaurant_id;
    COMMIT;
END;
/
