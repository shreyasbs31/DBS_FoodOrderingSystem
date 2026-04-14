import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), 'frontend'))
from db_manager import db

p1 = """
CREATE OR REPLACE PROCEDURE pr_Delete_Menu_Item (
    p_item_id IN NUMBER
) AS
BEGIN
    UPDATE MENU_ITEMS SET status = 'DELETED' WHERE item_id = p_item_id;
    DELETE FROM CARTS WHERE item_id = p_item_id;
    COMMIT;
END;
"""

p2 = """
CREATE OR REPLACE PROCEDURE pr_Restore_Menu_Item (
    p_item_id IN NUMBER
) AS
BEGIN
    UPDATE MENU_ITEMS SET status = 'ACTIVE' WHERE item_id = p_item_id;
    COMMIT;
END;
"""

p3 = """
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
"""

p4 = """
CREATE OR REPLACE PROCEDURE pr_Restore_Restaurant (
    p_restaurant_id IN NUMBER
) AS
BEGIN
    UPDATE RESTAURANTS SET status = 'ACTIVE' WHERE restaurant_id = p_restaurant_id;
    UPDATE MENU_ITEMS SET status = 'ACTIVE' WHERE restaurant_id = p_restaurant_id;
    COMMIT;
END;
"""

for p_text in [p1, p2, p3, p4]:
    try:
        db.execute_query(p_text, fetch=False)
        print("Successfully created a procedure.")
    except Exception as e:
        print("Failed:", e)

print("Procedure definitions applied.")
