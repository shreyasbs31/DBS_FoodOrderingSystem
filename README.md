# 🍔 FoodOS — Online Food Management System

A full-stack food ordering system built with **Oracle PL/SQL** + **Flask** + **Tailwind CSS** for a Database Systems Mini Project.

---

## 🚀 Quick Start

### Prerequisites
- Python 3.13
- Docker Desktop (running)
- Git

### 1. Clone the repo
```bash
git clone https://github.com/shreyasbs31/DBS_FoodOrderingSystem.git
cd DBS_FoodOrderingSystem
```

### 2. Install Python dependencies
```bash
pip3 install flask oracledb python-dotenv
```

### 3. Start Oracle Database (Docker)
```bash
docker run -d --name oracle-db -p 1521:1521 -e ORACLE_PASSWORD=Shreyas123 gvenzl/oracle-xe
```
Wait ~2 minutes, then check it's ready:
```bash
docker logs oracle-db 2>&1 | grep "DATABASE IS READY"
```

### 4. Configure credentials
Create a `.env` file in the project root (already gitignored):
```
DB_USER=system
DB_PASSWORD=Shreyas123
DB_DSN=localhost:1521/XE
FLASK_SECRET_KEY=foodos-super-secret-key-change-me
```

### 5. Load the database schema & data
Run each SQL file in order via the Oracle CLI:
```bash
docker exec -it oracle-db bash -c "sqlplus system/Shreyas123@XE"
```
Then inside sqlplus, run:
```
@/path/to/sql/schema.sql
@/path/to/sql/functions.sql
@/path/to/sql/procedures.sql
@/path/to/sql/triggers.sql
@/path/to/sql/sample_data.sql
EXIT;
```

### 6. Start the web server
```bash
python3.13 frontend/server.py
```
Open **http://127.0.0.1:5000** in your browser.

---

## 🔐 Login Credentials

### Admin
| Field    | Value      |
|----------|------------|
| Tab      | **Admin** (click the Admin tab on login screen) |
| Username | `admin`    |
| Password | `admin123` |

### Sample Customers
| Email               | Password  |
|---------------------|-----------|
| rahul@example.com   | pass123   |
| priya@example.com   | pass123   |
| amit@example.com    | pass123   |

---

## 📋 Features

### Customer Dashboard
- Browse restaurants and menus
- Add items to cart, place orders
- Pay via UPI / Credit Card / Cash on Delivery
- View order history with itemized receipt (click any order)
- Stats: My Spend, Orders Placed, Active Orders, Cart Items

### Admin Dashboard
- Add / remove restaurants and menu items
- View all orders, confirm and manage statuses
- Assign delivery agents to confirmed orders
- Track delivery progress (Assign → Dispatch → Complete)
- View agent roster with availability status
- Dashboard stats: Total Revenue, Orders, Customers, Pending

---

## 🗄️ Database Design (Oracle SQL / PL/SQL)

### Tables (3NF Normalized)
| Table | Description |
|---|---|
| CUSTOMERS | Registered users |
| ADMINS | Admin accounts |
| RESTAURANTS | Restaurant listings |
| MENU_CATEGORIES | Food categories |
| MENU_ITEMS | Dishes with price & category |
| CARTS | Active cart items per customer |
| ORDERS | Order headers with status & total |
| ORDER_DETAILS | Line items per order |
| PAYMENTS | Payment records |
| DELIVERY_AGENTS | Registered delivery agents |
| DELIVERIES | Delivery assignments |
| REVIEWS | Customer ratings |

### PL/SQL Objects
| Type | Name | Purpose |
|---|---|---|
| Procedure | `pr_Register_Customer` | Create new customer account |
| Procedure | `pr_Place_Order` | Convert cart → order, compute total |
| Procedure | `pr_Process_Payment` | Record payment, confirm order |
| Procedure | `pr_Update_Order_Status` | Change order lifecycle status |
| Procedure | `pr_Add_Restaurant` | Admin: add restaurant |
| Procedure | `pr_Add_Menu_Item` | Admin: add menu item |
| Procedure | `pr_Delete_Menu_Item` | Admin: remove menu item |
| Procedure | `pr_Assign_Delivery_Agent` | Auto-assign available agent |
| Procedure | `pr_Update_Delivery_Status` | Mark delivery progress |
| Function | `fn_Calculate_Order_Total` | Sum order line items |
| Function | `fn_Get_Restaurant_Avg_Rating` | Average restaurant rating |
| Function | `fn_Get_Customer_Total_Spend` | Lifetime spend per customer |
| Function | `fn_Is_Agent_Available` | Check agent availability |
| Trigger | `trg_Payment_Confirms_Order` | Auto-confirm on payment insert |
| Trigger | `trg_Update_Order_Total` | Recalculate total on detail change |
| Trigger | `trg_Set_Delivery_Complete` | Auto-update order on delivery done |

### Order Status Flow
```
PENDING → ORDER_RECEIVED (Cash on Delivery)
PENDING → CONFIRMED (Online Payment)
CONFIRMED → OUT_FOR_DELIVERY (after agent assigned + dispatched)
OUT_FOR_DELIVERY → DELIVERED
```

---

## 🔍 Viewing the Database (for Demo/Viva)

**Option 1 — Terminal (quick)**
```bash
docker exec -it oracle-db bash -c "sqlplus system/Shreyas123@XE"
```
Then run any query, e.g.:
```sql
SELECT * FROM ORDERS;
SELECT * FROM CUSTOMERS;
SELECT * FROM MENU_ITEMS;
```

**Option 2 — DBeaver GUI (recommended for viva)**
1. Download free from [dbeaver.io](https://dbeaver.io)
2. New Connection → Oracle
3. Host: `127.0.0.1` | Port: `1521` | Database: `XE`
4. Username: `system` | Password: `Shreyas123`

---

## 🔄 Restarting After Shutdown

Every time your Mac restarts:
```bash
# 1. Start Oracle (takes ~2 min)
docker start oracle-db

# 2. Start web app
cd /path/to/DBS_FoodOrderingSystem
python3.13 frontend/server.py
```
Open **http://127.0.0.1:5000**

---

## 📂 Project Structure
```
DBS_Project/
├── .env                    # ← Your credentials (gitignored, never committed)
├── .gitignore
├── README.md
├── sql/
│   ├── schema.sql          # Tables (3NF)
│   ├── functions.sql       # 4 PL/SQL Functions
│   ├── procedures.sql      # 9 Stored Procedures
│   ├── triggers.sql        # 3 Triggers
│   └── sample_data.sql     # Demo data
└── frontend/
    ├── server.py           # Flask REST API (20+ endpoints)
    ├── db_manager.py       # Oracle DB connection singleton
    └── templates/
        └── index.html      # Single-page dashboard (Tailwind CSS)
```
