import sys
import os

sys.path.append(os.path.join(os.path.dirname(__file__), 'frontend'))
from db_manager import db

def reset_restaurants():
    try:
        tables = [
            "REVIEWS",
            "DELIVERIES",
            "PAYMENTS",
            "ORDER_DETAILS",
            "ORDERS",
            "CARTS",
            "MENU_ITEMS",
            "RESTAURANTS"
        ]
        
        for table in tables:
            print(f"Clearing table {table}...")
            db.execute_query(f"DELETE FROM {table}", fetch=False)
            
        print("Existing data removed.")
        
        manipal_restaurants = [
            {"name": "Dollops", "location": "Manipal", "rating": 4.5},
            {"name": "Vito's", "location": "Manipal", "rating": 4.6},
            {"name": "Kyoto", "location": "Manipal", "rating": 4.7},
            {"name": "Hadiqa", "location": "Manipal", "rating": 4.4}
        ]
        
        for r in manipal_restaurants:
            db.call_procedure("pr_Add_Restaurant", [r["name"], r["location"], r["rating"]])
            
        print("Restaurants added.")
        
        new_rests = db.execute_query("SELECT restaurant_id, name FROM RESTAURANTS")
        rest_ids = {r['NAME']: r['RESTAURANT_ID'] for r in new_rests}
        
        # Categories: 1 Starters, 2 Main Course, 3 Beverages, 4 Desserts
        menu_items = [
            # Dollops
            ("Gobi Manchurian", 120, 1, rest_ids["Dollops"]),
            ("Chicken Fried Rice", 180, 2, rest_ids["Dollops"]),
            ("Butter Chicken", 220, 2, rest_ids["Dollops"]),
            ("Naan", 40, 2, rest_ids["Dollops"]),
            
            # Vito's
            ("Garlic Bread", 150, 1, rest_ids["Vito's"]),
            ("Margherita Pizza", 350, 2, rest_ids["Vito's"]),
            ("Alfredo Pasta", 280, 2, rest_ids["Vito's"]),
            ("Tiramisu", 200, 4, rest_ids["Vito's"]),
            
            # Kyoto
            ("Edamame", 180, 1, rest_ids["Kyoto"]),
            ("Shoyu Ramen", 450, 2, rest_ids["Kyoto"]),
            ("California Roll", 380, 2, rest_ids["Kyoto"]),
            ("Matcha Ice Cream", 150, 4, rest_ids["Kyoto"]),
            
            # Hadiqa
            ("Chicken Tikka", 220, 1, rest_ids["Hadiqa"]),
            ("Mutton Biryani", 320, 2, rest_ids["Hadiqa"]),
            ("Hummus with Pita", 180, 1, rest_ids["Hadiqa"]),
            ("Mint Tea", 60, 3, rest_ids["Hadiqa"])
        ]
        
        for item in menu_items:
            db.call_procedure("pr_Add_Menu_Item", [item[0], item[1], item[2], item[3]])
            
        print("Menu items added.")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    reset_restaurants()
