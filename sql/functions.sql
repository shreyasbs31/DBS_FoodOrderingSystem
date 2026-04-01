-- =============================================================
-- PL/SQL FUNCTIONS - Online Food Management System
-- =============================================================

-- 1. Calculate Total Amount for an Order
CREATE OR REPLACE FUNCTION fn_Calculate_Order_Total (p_order_id IN NUMBER)
RETURN NUMBER IS
    v_total NUMBER(10,2) := 0;
BEGIN
    SELECT NVL(SUM(quantity * unit_price), 0)
    INTO v_total
    FROM ORDER_DETAILS
    WHERE order_id = p_order_id;

    RETURN v_total;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END;
/

-- 2. Get Customer Order Count
CREATE OR REPLACE FUNCTION fn_Get_Customer_Order_Count (p_customer_id IN NUMBER)
RETURN NUMBER IS
    v_count NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM ORDERS
    WHERE customer_id = p_customer_id;
    RETURN v_count;
END;
/

-- 3. Get Restaurant Average Rating from Reviews
CREATE OR REPLACE FUNCTION fn_Get_Restaurant_Avg_Rating (p_restaurant_id IN NUMBER)
RETURN NUMBER IS
    v_avg NUMBER(2,1) := 0;
BEGIN
    SELECT NVL(AVG(r.rating), 0) INTO v_avg
    FROM REVIEWS r
    JOIN ORDERS o ON r.order_id = o.order_id
    WHERE o.restaurant_id = p_restaurant_id;
    RETURN v_avg;
END;
/

-- 4. Check if a Delivery Agent is Available
CREATE OR REPLACE FUNCTION fn_Available_Agent_Count
RETURN NUMBER IS
    v_count NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM DELIVERY_AGENTS
    WHERE is_available = 'Y';
    RETURN v_count;
END;
/
