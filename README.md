# 🍔 Online Food Management System

A comprehensive database systems project featuring an **Oracle PL/SQL backend** and a **Python (Flask) web dashboard** with a brutalist dark UI aesthetic. The system follows strict relational design principles and is normalized up to **3NF**.

---

## ✨ Features

### Customer Module
- Registration & Login (stored procedures)
- Browse restaurants with ratings
- Explore menus by category
- Persistent cart with real-time subtotal
- One-click order placement via PL/SQL procedure
- Payment processing (UPI, Credit Card, COD)
- Order history tracking

### Admin Module
- Full restaurant CRUD (Add / Delete)
- Menu item management (Add / Delete)
- View and manage all orders system-wide
- Assign delivery agents to confirmed orders
- Delivery tracking with agent roster

### Database Logic (PL/SQL)
| Type | Name | Purpose |
|------|------|---------|
| **Procedure** | `pr_Register_Customer` | Secure customer registration |
| **Procedure** | `pr_Place_Order` | Atomic cart → order transfer |
| **Procedure** | `pr_Assign_Delivery_Agent` | Auto-picks available agent |
| **Procedure** | `pr_Process_Payment` | Simulates payment processing |
| **Procedure** | `pr_Add_Restaurant` | Admin: add restaurant |
| **Procedure** | `pr_Add_Menu_Item` | Admin: add menu item |
| **Function** | `fn_Calculate_Order_Total` | Computes order total |
| **Function** | `fn_Get_Customer_Order_Count` | Returns customer's order count |
| **Trigger** | `trg_Update_Order_Total` | Auto-updates total on item changes |
| **Trigger** | `trg_Complete_Delivery` | Syncs order/agent status on delivery |
| **Trigger** | `trg_Payment_Confirms_Order` | Auto-confirms order on payment |

---

## 🛠️ Tech Stack
- **Database**: Oracle SQL / PL-SQL
- **Backend**: Python 3.x + Flask
- **Frontend**: HTML5 + Tailwind CSS + Vanilla JS
- **DB Driver**: `python-oracledb` (Thin Client)

---

## 📂 Project Structure
```
/DBS_Project
├── sql/
│   ├── schema.sql          # Tables, FKs, Constraints (3NF)
│   ├── functions.sql       # PL/SQL Functions
│   ├── procedures.sql      # Stored Procedures
│   ├── triggers.sql        # Database Triggers
│   └── sample_data.sql     # Initial Data
├── frontend/
│   ├── server.py           # Flask Backend (API Routes)
│   ├── db_manager.py       # Oracle Connection Wrapper
│   └── templates/
│       └── index.html      # Web Dashboard (Single Page App)
└── README.md
```

---

## 📐 Database Design (3NF)

The system eliminates redundancy and ensures data integrity:
- **1NF**: Atomic values, unique primary keys
- **2NF**: No partial dependencies
- **3NF**: No transitive dependencies

### ER Relationships
```
Customers (1) ───< (M) Orders
Restaurants (1) ───< (M) Menu_Items
Orders (1) ───< (M) Order_Details (Junction)
Orders (1) ───── (1) Payments
Orders (1) ───── (1) Deliveries
Delivery_Agents (1) ───< (M) Deliveries
```

### Tables (12)
`CUSTOMERS` · `RESTAURANTS` · `MENU_CATEGORIES` · `MENU_ITEMS` · `ORDERS` · `ORDER_DETAILS` · `PAYMENTS` · `DELIVERY_AGENTS` · `DELIVERIES` · `REVIEWS` · `CARTS` · `ADMINS`

---

## ⚙️ Setup & Installation

### 1. Database Setup (macOS Recommendation)
Since Oracle doesn't run natively on Mac, use **Docker**:

1. **Install Docker Desktop**.
2. **Run Oracle XE**:
   ```bash
   docker run -d --name oracle-db -p 1521:1521 -e ORACLE_PASSWORD=your_password gvenzl/oracle-xe
   ```
3. **Wait** for logs to say `DATABASE IS READY TO USE!`.
4. **Execute SQL**: Run the scripts in `/sql/` folder against the local instance.

### 2. Configure Database Connection
Edit `frontend/db_manager.py` and update these values:
```python
DB_CONFIG = {
    "user": "system",
    "password": "your_password", # Match your Docker password
    "dsn": "localhost:1521/XE"
}
```

### 3. Install Python Dependencies
```bash
pip install flask oracledb
```

### 4. Run the Application
```bash
python frontend/server.py
```
Then open **http://localhost:5000** in your browser.

### 5. Test Credentials
| Role | Email/Username | Password |
|------|---------------|----------|
| Customer | rahul@example.com | pass123 |
| Admin | admin | admin123 |

---

## 📸 Screenshots
*(Add your screenshots here for the viva presentation)*

---

## 🔮 Future Improvements
- Real payment gateway integration
- Delivery agent mobile app
- Real-time GPS tracking
- Email/SMS order notifications

---
**Developed for DBS Mini Project — 2026**
