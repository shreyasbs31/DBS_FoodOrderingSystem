import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), 'frontend'))
from db_manager import db

try:
    db.execute_query("ALTER TABLE RESTAURANTS ADD status VARCHAR2(20) DEFAULT 'ACTIVE'", fetch=False)
except Exception as e:
    print(f"Error 1: {e}")

try:
    db.execute_query("ALTER TABLE MENU_ITEMS ADD status VARCHAR2(20) DEFAULT 'ACTIVE'", fetch=False)
except Exception as e:
    print(f"Error 2: {e}")

print("Done")
