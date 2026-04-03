-- =============================================================
-- PL/SQL TRIGGERS - Online Food Management System
-- =============================================================

-- 1. Auto-update total_amount in ORDERS when ORDER_DETAILS change
--    Uses the fn_Calculate_Order_Total function.
CREATE OR REPLACE TRIGGER trg_Update_Order_Total
AFTER INSERT OR UPDATE OR DELETE ON ORDER_DETAILS
FOR EACH ROW
BEGIN
    IF INSERTING OR UPDATING THEN
        UPDATE ORDERS
        SET total_amount = fn_Calculate_Order_Total(:NEW.order_id)
        WHERE order_id = :NEW.order_id;
    ELSIF DELETING THEN
        UPDATE ORDERS
        SET total_amount = fn_Calculate_Order_Total(:OLD.order_id)
        WHERE order_id = :OLD.order_id;
    END IF;
END;
/

-- 2. When a delivery status changes:
--    → If DELIVERED: set order to DELIVERED, free up agent
--    → If CANCELLED: free up agent (needs manual order cancellation)
CREATE OR REPLACE TRIGGER trg_Complete_Delivery
AFTER UPDATE OF delivery_status ON DELIVERIES
FOR EACH ROW
BEGIN
    IF :NEW.delivery_status = 'DELIVERED' THEN
        UPDATE ORDERS SET order_status = 'DELIVERED' WHERE order_id = :NEW.order_id;
        -- Free up agent (safely check for NOT NULL)
        IF :NEW.agent_id IS NOT NULL THEN
            UPDATE DELIVERY_AGENTS SET is_available = 'Y' WHERE agent_id = :NEW.agent_id;
        END IF;
    END IF;
END;
/

-- 3. After a payment is marked COMPLETED, auto-confirm the order
--    and attempt to assign a delivery agent via the stored procedure.
CREATE OR REPLACE TRIGGER trg_Payment_Confirms_Order
AFTER INSERT ON PAYMENTS
FOR EACH ROW
WHEN (NEW.payment_status = 'COMPLETED')
BEGIN
    UPDATE ORDERS SET order_status = 'CONFIRMED' WHERE order_id = :NEW.order_id;
END;
/
