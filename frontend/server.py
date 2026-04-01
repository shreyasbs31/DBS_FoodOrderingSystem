"""
Flask Server — Online Food Management System
"""
from flask import Flask, render_template, request, jsonify, session
from db_manager import db
from functools import wraps
import os
from pathlib import Path

# Load .env
try:
    from dotenv import load_dotenv
    load_dotenv(Path(__file__).parent.parent / ".env")
except ImportError:
    pass

app = Flask(__name__)
app.secret_key = os.environ.get("FLASK_SECRET_KEY", "foodos-dev-secret")

# ─── Auth Helpers ────────────────────────────────────────────────
def login_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if "user" not in session:
            return jsonify({"error": "Unauthorized"}), 401
        return f(*args, **kwargs)
    return decorated

def admin_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if session.get("user", {}).get("role") != "admin":
            return jsonify({"error": "Admin access required"}), 403
        return f(*args, **kwargs)
    return decorated

# ─── Page Routes ─────────────────────────────────────────────────
@app.route("/")
def index():
    return render_template("index.html")

# ─── AUTH API ────────────────────────────────────────────────────
@app.route("/api/login", methods=["POST"])
def login():
    data = request.json
    role = data.get("role", "customer")
    if role == "admin":
        result = db.execute_query(
            "SELECT admin_id, username FROM ADMINS WHERE username = :u AND password = :p",
            {"u": data["email"], "p": data["password"]}
        )
        if result:
            session["user"] = {**result[0], "role": "admin"}
            return jsonify({"ok": True, "user": session["user"]})
    else:
        result = db.execute_query(
            "SELECT customer_id, name, email, phone, address FROM CUSTOMERS WHERE email = :e AND password = :p",
            {"e": data["email"], "p": data["password"]}
        )
        if result:
            session["user"] = {**result[0], "role": "customer"}
            return jsonify({"ok": True, "user": session["user"]})
    return jsonify({"ok": False, "error": "Invalid credentials"}), 401

@app.route("/api/register", methods=["POST"])
def register():
    d = request.json
    try:
        db.call_procedure("pr_Register_Customer",
                          [d["name"], d["email"], d["password"], d["phone"], d["address"]])
        return jsonify({"ok": True})
    except Exception as e:
        return jsonify({"ok": False, "error": str(e)}), 400

@app.route("/api/logout", methods=["POST"])
def logout():
    session.clear()
    return jsonify({"ok": True})

@app.route("/api/session")
def get_session():
    if "user" in session:
        return jsonify({"ok": True, "user": session["user"]})
    return jsonify({"ok": False})

# ─── RESTAURANTS ─────────────────────────────────────────────────
@app.route("/api/restaurants")
@login_required
def get_restaurants():
    rows = db.execute_query("SELECT * FROM RESTAURANTS ORDER BY restaurant_id")
    return jsonify(rows or [])

@app.route("/api/restaurants", methods=["POST"])
@login_required
def add_restaurant():
    d = request.json
    try:
        db.call_procedure("pr_Add_Restaurant", [d["name"], d["location"], d.get("rating", 0)])
        return jsonify({"ok": True})
    except Exception as e:
        return jsonify({"ok": False, "error": str(e)}), 400

@app.route("/api/restaurants/<int:rid>", methods=["DELETE"])
@login_required
def delete_restaurant(rid):
    db.execute_query("DELETE FROM RESTAURANTS WHERE restaurant_id = :id", {"id": rid}, fetch=False)
    return jsonify({"ok": True})

# ─── MENU ────────────────────────────────────────────────────────
@app.route("/api/menu/<int:restaurant_id>")
@login_required
def get_menu(restaurant_id):
    rows = db.execute_query("""
        SELECT m.item_id, m.item_name, m.price, c.category_name, m.category_id
        FROM MENU_ITEMS m JOIN MENU_CATEGORIES c ON m.category_id = c.category_id
        WHERE m.restaurant_id = :rid ORDER BY c.category_name, m.item_name
    """, {"rid": restaurant_id})
    return jsonify(rows or [])

@app.route("/api/menu", methods=["POST"])
@login_required
def add_menu_item():
    d = request.json
    try:
        db.call_procedure("pr_Add_Menu_Item",
                          [d["item_name"], d["price"], d["category_id"], d["restaurant_id"]])
        return jsonify({"ok": True})
    except Exception as e:
        return jsonify({"ok": False, "error": str(e)}), 400

@app.route("/api/menu/<int:item_id>", methods=["DELETE"])
@login_required
def delete_menu_item(item_id):
    try:
        db.call_procedure("pr_Delete_Menu_Item", [item_id])
        return jsonify({"ok": True})
    except Exception as e:
        return jsonify({"ok": False, "error": str(e)}), 400

@app.route("/api/categories")
@login_required
def get_categories():
    rows = db.execute_query("SELECT * FROM MENU_CATEGORIES ORDER BY category_id")
    return jsonify(rows or [])

# ─── CART ─────────────────────────────────────────────────────────
@app.route("/api/cart")
@login_required
def get_cart():
    cid = session["user"]["CUSTOMER_ID"]
    rows = db.execute_query("""
        SELECT c.item_id, m.item_name, c.quantity, m.price,
               (c.quantity * m.price) AS subtotal, m.restaurant_id, r.name AS restaurant_name
        FROM CARTS c
        JOIN MENU_ITEMS m ON c.item_id = m.item_id
        JOIN RESTAURANTS r ON m.restaurant_id = r.restaurant_id
        WHERE c.customer_id = :cid
    """, {"cid": cid})
    return jsonify(rows or [])

@app.route("/api/cart", methods=["POST"])
@login_required
def add_to_cart():
    cid = session["user"]["CUSTOMER_ID"]
    item_id = request.json["item_id"]
    existing = db.execute_query(
        "SELECT quantity FROM CARTS WHERE customer_id = :c AND item_id = :i",
        {"c": cid, "i": item_id}
    )
    if existing:
        db.execute_query(
            "UPDATE CARTS SET quantity = quantity + 1 WHERE customer_id = :c AND item_id = :i",
            {"c": cid, "i": item_id}, fetch=False)
    else:
        db.execute_query(
            "INSERT INTO CARTS (customer_id, item_id, quantity) VALUES (:c, :i, 1)",
            {"c": cid, "i": item_id}, fetch=False)
    return jsonify({"ok": True})

@app.route("/api/cart/<int:item_id>", methods=["DELETE"])
@login_required
def remove_from_cart(item_id):
    cid = session["user"]["CUSTOMER_ID"]
    db.execute_query("DELETE FROM CARTS WHERE customer_id = :c AND item_id = :i",
                     {"c": cid, "i": item_id}, fetch=False)
    return jsonify({"ok": True})

@app.route("/api/cart/clear", methods=["DELETE"])
@login_required
def clear_cart():
    cid = session["user"]["CUSTOMER_ID"]
    db.execute_query("DELETE FROM CARTS WHERE customer_id = :c", {"c": cid}, fetch=False)
    return jsonify({"ok": True})

# ─── ORDERS ──────────────────────────────────────────────────────
@app.route("/api/orders")
@login_required
def get_orders():
    user = session["user"]
    if user.get("role") == "admin":
        rows = db.execute_query("""
            SELECT o.order_id, o.order_status, o.total_amount, o.order_time,
                   c.name AS customer_name, r.name AS restaurant_name
            FROM ORDERS o
            JOIN CUSTOMERS c ON o.customer_id = c.customer_id
            JOIN RESTAURANTS r ON o.restaurant_id = r.restaurant_id
            ORDER BY o.order_time DESC
        """)
    else:
        rows = db.execute_query("""
            SELECT o.order_id, o.order_status, o.total_amount, o.order_time,
                   r.name AS restaurant_name
            FROM ORDERS o
            JOIN RESTAURANTS r ON o.restaurant_id = r.restaurant_id
            WHERE o.customer_id = :cid ORDER BY o.order_time DESC
        """, {"cid": user["CUSTOMER_ID"]})
    for r in (rows or []):
        if r.get("ORDER_TIME"):
            r["ORDER_TIME"] = r["ORDER_TIME"].strftime("%d %b %Y, %H:%M")
        # Convert Decimal to float for JSON serialization
        if r.get("TOTAL_AMOUNT") is not None:
            r["TOTAL_AMOUNT"] = float(r["TOTAL_AMOUNT"])
    return jsonify(rows or [])

@app.route("/api/orders/<int:order_id>/details")
@login_required
def get_order_details(order_id):
    rows = db.execute_query("""
        SELECT od.item_id, m.item_name, od.quantity, od.unit_price,
               (od.quantity * od.unit_price) AS subtotal
        FROM ORDER_DETAILS od
        JOIN MENU_ITEMS m ON od.item_id = m.item_id
        WHERE od.order_id = :oid
    """, {"oid": order_id})
    for r in (rows or []):
        if r.get("UNIT_PRICE") is not None:
            r["UNIT_PRICE"] = float(r["UNIT_PRICE"])
        if r.get("SUBTOTAL") is not None:
            r["SUBTOTAL"] = float(r["SUBTOTAL"])
    return jsonify(rows or [])

@app.route("/api/orders", methods=["POST"])
@login_required
def place_order():
    cid = session["user"]["CUSTOMER_ID"]
    rid = request.json["restaurant_id"]
    try:
        order_id = db.call_procedure_with_out("pr_Place_Order", [cid, rid])
        return jsonify({"ok": True, "order_id": int(order_id) if order_id else None})
    except Exception as e:
        return jsonify({"ok": False, "error": str(e)}), 400

@app.route("/api/orders/<int:order_id>/status", methods=["PUT"])
@login_required
def update_order_status(order_id):
    status = request.json["status"]
    try:
        db.call_procedure("pr_Update_Order_Status", [order_id, status])
        return jsonify({"ok": True})
    except Exception as e:
        return jsonify({"ok": False, "error": str(e)}), 400

# ─── PAYMENTS ────────────────────────────────────────────────────
@app.route("/api/payments", methods=["POST"])
@login_required
def process_payment():
    d = request.json
    order_id = d["order_id"]
    method = d["method"]
    # COD: payment stays PENDING, order goes to ORDER_RECEIVED
    if method == "CASH":
        try:
            db.execute_query(
                "INSERT INTO PAYMENTS (order_id, payment_method, payment_status) VALUES (:oid, :m, 'PENDING')",
                {"oid": order_id, "m": method}, fetch=False)
            db.call_procedure("pr_Update_Order_Status", [order_id, "ORDER_RECEIVED"])
            return jsonify({"ok": True, "message": "Order received! Pay on delivery."})
        except Exception as e:
            return jsonify({"ok": False, "error": str(e)}), 400
    else:
        try:
            db.call_procedure("pr_Process_Payment", [order_id, method])
            return jsonify({"ok": True, "message": "Payment confirmed!"})
        except Exception as e:
            return jsonify({"ok": False, "error": str(e)}), 400

@app.route("/api/payments")
@login_required
def get_payments():
    rows = db.execute_query("""
        SELECT p.payment_id, p.order_id, p.payment_method,
               p.payment_status, p.payment_time
        FROM PAYMENTS p ORDER BY p.payment_time DESC
    """)
    for r in (rows or []):
        if r.get("PAYMENT_TIME"):
            r["PAYMENT_TIME"] = r["PAYMENT_TIME"].strftime("%d %b %Y, %H:%M")
    return jsonify(rows or [])

# ─── DELIVERIES ──────────────────────────────────────────────────
@app.route("/api/deliveries")
@login_required
def get_deliveries():
    rows = db.execute_query("""
        SELECT d.delivery_id, d.order_id, d.delivery_status,
               d.assignment_time, d.completion_time,
               a.agent_name, a.phone AS agent_phone
        FROM DELIVERIES d
        JOIN DELIVERY_AGENTS a ON d.agent_id = a.agent_id
        ORDER BY d.assignment_time DESC
    """)
    for r in (rows or []):
        if r.get("ASSIGNMENT_TIME"):
            r["ASSIGNMENT_TIME"] = r["ASSIGNMENT_TIME"].strftime("%d %b %Y, %H:%M")
        if r.get("COMPLETION_TIME"):
            r["COMPLETION_TIME"] = r["COMPLETION_TIME"].strftime("%d %b %Y, %H:%M")
    return jsonify(rows or [])

@app.route("/api/deliveries/assign", methods=["POST"])
@login_required
def assign_delivery():
    oid = request.json["order_id"]
    try:
        db.call_procedure("pr_Assign_Delivery_Agent", [oid])
        return jsonify({"ok": True})
    except Exception as e:
        return jsonify({"ok": False, "error": str(e)}), 400

@app.route("/api/deliveries/<int:did>/status", methods=["PUT"])
@login_required
def update_delivery_status(did):
    status = request.json["status"]
    try:
        db.call_procedure("pr_Update_Delivery_Status", [did, status])
        return jsonify({"ok": True})
    except Exception as e:
        return jsonify({"ok": False, "error": str(e)}), 400

@app.route("/api/agents")
@login_required
def get_agents():
    rows = db.execute_query("SELECT * FROM DELIVERY_AGENTS ORDER BY agent_id")
    return jsonify(rows or [])

# ─── STATS (role-aware) ───────────────────────────────────────────
@app.route("/api/stats")
@login_required
def get_stats():
    user = session["user"]
    if user.get("role") == "admin":
        total_orders   = db.execute_query("SELECT COUNT(*) AS C FROM ORDERS")[0]["C"]
        total_revenue  = float(db.execute_query("SELECT NVL(SUM(total_amount),0) AS S FROM ORDERS")[0]["S"])
        total_customers= db.execute_query("SELECT COUNT(*) AS C FROM CUSTOMERS")[0]["C"]
        pending_orders = db.execute_query("SELECT COUNT(*) AS C FROM ORDERS WHERE order_status IN ('PENDING','ORDER_RECEIVED')")[0]["C"]
        return jsonify({
            "total_orders": total_orders,
            "total_revenue": total_revenue,
            "total_customers": total_customers,
            "pending_orders": pending_orders
        })
    else:
        cid = user["CUSTOMER_ID"]
        my_orders   = db.execute_query("SELECT COUNT(*) AS C FROM ORDERS WHERE customer_id=:c", {"c": cid})[0]["C"]
        my_spending = float(db.execute_query("SELECT NVL(SUM(total_amount),0) AS S FROM ORDERS WHERE customer_id=:c", {"c": cid})[0]["S"])
        active      = db.execute_query("SELECT COUNT(*) AS C FROM ORDERS WHERE customer_id=:c AND order_status NOT IN ('DELIVERED','CANCELLED')", {"c": cid})[0]["C"]
        cart_items  = db.execute_query("SELECT NVL(SUM(quantity),0) AS C FROM CARTS WHERE customer_id=:c", {"c": cid})[0]["C"]
        return jsonify({
            "total_orders": my_orders,
            "total_revenue": my_spending,
            "total_customers": active,      # repurposed field
            "pending_orders": cart_items,   # repurposed field
            # extra metadata so frontend knows which labels to show
            "_is_customer": True
        })

# ─── REVIEWS ─────────────────────────────────────────────────────
@app.route("/api/reviews", methods=["POST"])
@login_required
def add_review():
    d = request.json
    cid = session["user"]["CUSTOMER_ID"]
    db.execute_query(
        "INSERT INTO REVIEWS (order_id, customer_id, rating, comments) VALUES (:oid, :cid, :r, :c)",
        {"oid": d["order_id"], "cid": cid, "r": d["rating"], "c": d.get("comments", "")},
        fetch=False
    )
    return jsonify({"ok": True})

# ─── RUN ─────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("\n  🍔  FoodOS starting on http://localhost:5000\n")
    app.run(debug=True, port=5000)
