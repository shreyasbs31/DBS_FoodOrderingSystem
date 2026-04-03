# 🍔 FoodOS — Online Food Management System

A full-stack, production-ready food ordering and delivery management system built with **Oracle Database**, **Python Flask**, **Tailwind CSS**, and **HTML/JavaScript**. Designed as a comprehensive Database Systems mini-project demonstrating advanced SQL, PL/SQL, and web application architecture.

**Repository:** [GitHub - DBS_FoodOrderingSystem](https://github.com/shreyasbs31/DBS_FoodOrderingSystem)

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Tech Stack](#tech-stack)
3. [Project Structure](#project-structure)
4. [Prerequisites](#prerequisites)
5. [Installation & Setup](#installation--setup)
6. [Database Schema](#database-schema)
7. [Login Credentials](#login-credentials)
8. [Features](#features)
9. [API Documentation](#api-documentation)
10. [PL/SQL Components](#plsql-components)
11. [Architecture & Design](#architecture--design)

---

## Overview

FoodOS is a comprehensive online food ordering and delivery management platform that enables customers to browse restaurants, place orders, and track deliveries, while admins manage restaurants, menus, and delivery operations. The system implements enterprise-grade database design with 3NF normalization, PL/SQL stored procedures, functions, and triggers for business logic enforcement.

**Key Characteristics:**

- Dual-role authentication (Customer & Admin)
- Real-time order status tracking
- Delivery agent assignment and management
- Payment method support (Cash, Credit Card, UPI)
- Shopping cart with single-restaurant constraint
- Order history with itemized receipts
- Comprehensive dashboard analytics

---

## Tech Stack

| Layer                  | Technology                                            |
| ---------------------- | ----------------------------------------------------- |
| **Database**           | Oracle Database 23c (Docker: gvenzl/oracle-xe)        |
| **Backend**            | Python 3.12+ with Flask web framework                 |
| **Database Driver**    | oracledb (Python Oracle Driver)                       |
| **Frontend**           | HTML5, TailwindCSS, Vanilla JavaScript                |
| **Session Management** | Flask built-in sessions                               |
| **Config Management**  | python-dotenv                                         |
| **Deployment**         | Docker Desktop (for Oracle), Local Python interpreter |

---

## Project Structure

```
DBS_Project/
├── README.md                          # Project documentation
├── .env                               # Configuration (credentials, port) — not in repo
├── .gitignore                         # Git ignore rules
│
├── frontend/                          # Flask web application
│   ├── server.py                      # Main Flask app with all API routes
│   ├── db_manager.py                  # Oracle database connection wrapper
│   ├── __pycache__/                   # Compiled Python cache
│   └── templates/
│       └── index.html                 # Single-page application UI (Tailwind CSS)
│
└── sql/                               # Database initialization scripts
    ├── schema.sql                     # Table definitions (12 tables, 3NF normalized)
    ├── functions.sql                  # PL/SQL functions for business logic
    ├── procedures.sql                 # PL/SQL stored procedures
    ├── triggers.sql                   # Triggers for data integrity
    └── sample_data.sql                # Sample restaurants, users, menu items
```

---

## Prerequisites

Ensure you have the following installed and configured:

- **Python 3.12 or higher** — [Download](https://www.python.org/downloads/)
- **Docker Desktop (with Docker daemon running)** — [Download](https://www.docker.com/products/docker-desktop)
- **Git** — [Download](https://git-scm.com/)
- **2GB available disk space** — for Oracle Docker image
- **macOS, Linux, or Windows** — (project tested on macOS, Linux; Windows requires WSL2)

Verify installations:

```bash
# Check Python version
python3 --version

# Check Docker is running
docker --version
docker ps

# Check Git
git --version
```

---

## Installation & Setup

### Step 1: Clone the Repository

```bash
git clone https://github.com/shreyasbs31/DBS_FoodOrderingSystem.git
cd DBS_FoodOrderingSystem
```

### Step 2: Install Python Dependencies

```bash
# Create a virtual environment (optional but recommended)
python3 -m venv venv
source venv/bin/activate          # On Windows: venv\Scripts\activate

# Install required packages
pip install flask oracledb python-dotenv
```

**Packages:**

- `flask` — Web framework for API routes and page serving
- `oracledb` — Official Python Oracle Database driver
- `python-dotenv` — Load environment variables from .env file

### Step 3: Start Oracle Database (Docker)

```bash
# Pull and run Oracle XE container in background
docker run -d \
  --name oracle-db \
  -p 1521:1521 \
  -e ORACLE_PASSWORD=Shreyas123 \
  gvenzl/oracle-xe
```

Watch for startup completion (~2-3 minutes):

```bash
# Check container status
docker logs oracle-db 2>&1 | grep "DATABASE IS READY"

# Alternative: tail container logs
docker logs -f oracle-db
```

**Expected Output:**

```
LSNRCTL for Linux: Version 23.0.0.0.0 - Production on ...
...
DATABASE IS READY TO USE!
```

### Step 4: Create Environment Configuration File

Create a `.env` file in the project root directory (this file is gitignored):

```bash
# .env
DB_USER=system
DB_PASSWORD=Shreyas123
DB_DSN=localhost:1521/XE
FLASK_SECRET_KEY=foodos-super-secret-key-change-this-in-production
PORT=5001
```

**Configuration Details:**

- `DB_USER` — Oracle admin user (default: `system`)
- `DB_PASSWORD` — Oracle password from Docker run
- `DB_DSN` — Data Source Name in format `host:port/service_name`
- `FLASK_SECRET_KEY` — Secret key for session encryption (change in production)
- `PORT` — Flask server port (default: 5001)

### Step 5: Initialize Database Schema

Connect to Oracle and execute SQL scripts in order:

```bash
# Open sqlplus session inside Docker
docker exec -it oracle-db bash -c "sqlplus system/Shreyas123@XE"
```

Inside the sqlplus prompt, execute each SQL file:

```sql
@/opt/oracle/oradata/dbfiles/sql/schema.sql
@/opt/oracle/oradata/dbfiles/sql/functions.sql
@/opt/oracle/oradata/dbfiles/sql/procedures.sql
@/opt/oracle/oradata/dbfiles/sql/triggers.sql
@/opt/oracle/oradata/dbfiles/sql/sample_data.sql
EXIT;
```

**Note:** If you get "file not found" errors, first copy the SQL files into the container:

```bash
docker cp sql/schema.sql oracle-db:/opt/oracle/oradata/dbfiles/
docker cp sql/functions.sql oracle-db:/opt/oracle/oradata/dbfiles/
docker cp sql/procedures.sql oracle-db:/opt/oracle/oradata/dbfiles/
docker cp sql/triggers.sql oracle-db:/opt/oracle/oradata/dbfiles/
docker cp sql/sample_data.sql oracle-db:/opt/oracle/oradata/dbfiles/
```

Then reconnect and run the scripts.

**Script Execution Order (Important):**

1. `schema.sql` — Creates all 12 tables
2. `functions.sql` — Creates 4 PL/SQL functions for calculations
3. `procedures.sql` — Creates 8 stored procedures for business logic
4. `triggers.sql` — Creates triggers for data integrity
5. `sample_data.sql` — Inserts test data (admins, customers, restaurants, menu items)

### Step 6: Start the Flask Web Server

```bash
# From project root directory
python3 frontend/server.py

# Expected output:
# [DB] Connected to Oracle (localhost:1521/XE) successfully!
#  * Running on http://127.0.0.1:5001
#  * Press CTRL+C to quit
```

### Step 7: Access the Application

Open your browser and navigate to:

```
http://localhost:5001
```

You should see the FoodOS login screen.

---

## Database Schema

### Entity Relationship Diagram

The system uses **Third Normal Form (3NF)** normalization with 12 main entities:

```
ADMINS
│
├─► CUSTOMERS ◄─ ORDERS ──► RESTAURANTS
│                 │
│                 ├─► ORDER_DETAILS ──► MENU_ITEMS ──► MENU_CATEGORIES
│                 │
│                 ├─► PAYMENTS
│                 │
│                 ├─► DELIVERIES ──► DELIVERY_AGENTS
│                 │
│                 └─► REVIEWS

CARTS (temporary cart storage)
    │
    └─► CUSTOMERS, MENU_ITEMS
```

### Table Definitions

| Table               | Purpose                                               | Key Columns                                                                        |
| ------------------- | ----------------------------------------------------- | ---------------------------------------------------------------------------------- |
| **ADMINS**          | Admin user accounts                                   | admin_id, username, password                                                       |
| **CUSTOMERS**       | Customer accounts                                     | customer_id, email, password, phone, address                                       |
| **RESTAURANTS**     | Restaurant information                                | restaurant_id, name, location, rating                                              |
| **MENU_CATEGORIES** | Item categories (Appetizers, Mains, Desserts, etc.)   | category_id, category_name                                                         |
| **MENU_ITEMS**      | Restaurant menu items                                 | item_id, item_name, price, category_id, restaurant_id                              |
| **ORDERS**          | Customer orders                                       | order_id, customer_id, restaurant_id, order_status, total_amount, order_time       |
| **ORDER_DETAILS**   | Items in each order (M:N junction)                    | order_id, item_id, quantity, unit_price                                            |
| **PAYMENTS**        | Payment records                                       | payment_id, order_id, payment_method, payment_status, payment_time                 |
| **DELIVERY_AGENTS** | Delivery staff roster                                 | agent_id, agent_name, phone, is_available                                          |
| **DELIVERIES**      | Delivery tracking                                     | delivery_id, order_id, agent_id, delivery_status, assignment_time, completion_time |
| **REVIEWS**         | Customer reviews                                      | review_id, order_id, customer_id, rating, comments                                 |
| **CARTS**           | Shopping cart (temporary, cleared on order placement) | customer_id, item_id, quantity                                                     |

### Key Constraints

- **Primary Keys:** All tables have IDENTITY-generated PKs for referential integrity
- **Foreign Keys:** Cascade delete constraints to maintain data consistency
- **Check Constraints:**
  - `order_status` ∈ {PENDING, ORDER_RECEIVED, CONFIRMED, OUT_FOR_DELIVERY, DELIVERED, CANCELLED}
  - `payment_method` ∈ {CASH, CREDIT_CARD, UPI}
  - `payment_status` ∈ {PENDING, COMPLETED, FAILED}
  - `delivery_status` ∈ {ASSIGNED, OUT_FOR_DELIVERY, DELIVERED}
  - `rating` ∈ [0, 5] for restaurants and [1, 5] for reviews
  - `price` ≥ 0, `quantity` > 0
- **Unique Constraints:** Email (CUSTOMERS), Username (ADMINS), Category_name (MENU_CATEGORIES)

---

## Login Credentials

Use these credentials to test the system after loading sample data:

### 🔐 Admin Account

| Field    | Value                          |
| -------- | ------------------------------ |
| Role     | **Admin** (select "Admin" tab) |
| Username | `admin`                        |
| Password | `admin123`                     |

### 👥 Sample Customer Accounts

All sample customers use password: `pass123`

| Email             | Name         | Phone      |
| ----------------- | ------------ | ---------- |
| rahul@example.com | Rahul Sharma | 9876543210 |
| priya@example.com | Priya Verma  | 9765432109 |
| amit@example.com  | Amit Patel   | 9654321098 |

**To create new customer accounts:** Use the "Register" button on the login screen.

---

## Features

### 👤 Customer Features

**Authentication & Profile**

- Login and register with email/password
- Profile information: name, email, phone, address
- Secure session management with Flask

**Restaurant & Menu Browsing**

- View all registered restaurants
- Browse menu items by restaurant
- Filter menu items by category (Appetizers, Main Course, Desserts, Beverages, etc.)
- Real-time pricing display

**Shopping Cart**

- Add items to cart with quantity selection
- View cart with item details and subtotals
- Remove individual items or clear entire cart
- Constraint: Cannot mix items from different restaurants (enforced by backend)
- Cart persists across page navigation

**Order Management**

- Place orders from cart (creates ORDER_DETAILS from cart items)
- View order history sorted by date (newest first)
- Click any order to see itemized receipt with:
  - Item names, quantities, unit prices, subtotals
  - Order total and status
  - Order timestamp
- Real-time order status updates

**Payment Options**

- Credit Card
- UPI (Unified Payments Interface)
- Cash on Delivery (COD)

**Dashboard Analytics**

- **My Spend:** Total amount spent on all completed orders
- **Orders Placed:** Total count of orders placed
- **Active Orders:** Count of orders still pending, confirmed, or out for delivery
- **Cart Items:** Number of items in current shopping cart

---

### 🛡️ Admin Features

**Restaurant Management**

- Add new restaurants (name, location, initial rating)
- View all registered restaurants
- Delete restaurants (cascades to menu items, orders, etc.)
- Edit restaurant details via inline updates

**Menu Management**

- Add menu items to restaurants (name, price, category)
- View all menu items across restaurants
- Delete menu items and automatically clean up cart references
- Categorize items (Appetizers, Main Course, Desserts, Beverages)
- Adjust item prices

**Order Management**

- View all orders system-wide (not filtered by restaurant)
- See detailed order information:
  - Customer name
  - Restaurant name
  - Order total and status
  - Order timestamp
- Update order status through workflow:
  - PENDING → ORDER_RECEIVED → CONFIRMED → OUT_FOR_DELIVERY → DELIVERED
  - Cancel orders at any stage
- Confirm orders to trigger delivery assignment

**Delivery Management**

- View delivery agent roster with availability status
- Assign available delivery agents to confirmed orders
- Track delivery progress: ASSIGNED → OUT_FOR_DELIVERY → DELIVERED
- Mark deliveries as complete and update agent availability
- Real-time agent status display (Available/Unavailable)

**Dashboard Analytics**

- **Total Revenue:** Sum of all completed order amounts
- **Total Orders:** Count of all orders in system
- **Unique Customers:** Count of registered customers
- **Pending Orders:** Count of orders awaiting confirmation or delivery

---

## API Documentation

### Authentication Endpoints

#### Login

```http
POST /api/login
Content-Type: application/json

{
  "email": "admin|customer_email",
  "password": "password",
  "role": "admin|customer"
}

Response (Success):
{
  "ok": true,
  "user": {
    "admin_id": 1,              // or customer_id
    "username": "admin",        // or name
    "role": "admin"             // or "customer"
  }
}

Response (Failure):
{
  "ok": false,
  "error": "Invalid credentials"
}
```

#### Register

```http
POST /api/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "securepassword",
  "phone": "9876543210",
  "address": "123 Main St, City, State 12345"
}

Response:
{ "ok": true } or { "ok": false, "error": "..." }
```

#### Logout

```http
POST /api/logout
Response: { "ok": true }
```

#### Get Session

```http
GET /api/session

Response (Authenticated):
{
  "ok": true,
  "user": { "customer_id": 1, "name": "John", ... }
}

Response (Not Authenticated):
{ "ok": false }
```

### Restaurant Endpoints

```http
GET /api/restaurants
# Returns: [{ restaurant_id, name, location, rating }, ...]

POST /api/restaurants
{ "name": "Pizza Palace", "location": "Downtown", "rating": 4.5 }

DELETE /api/restaurants/<restaurant_id>
```

### Menu Endpoints

```http
GET /api/menu/<restaurant_id>
# Returns: [{ item_id, item_name, price, category_name }, ...]

GET /api/categories
# Returns: [{ category_id, category_name }, ...]

POST /api/menu
{ "item_name": "Margherita Pizza", "price": 299.99, "category_id": 1, "restaurant_id": 1 }

DELETE /api/menu/<item_id>
```

### Cart Endpoints

```http
GET /api/cart
# Returns: [{ item_id, item_name, quantity, price, subtotal, restaurant_name }, ...]

POST /api/cart
{ "item_id": 5 }
# Adds to cart or increments quantity

DELETE /api/cart/<item_id>          # Remove single item
DELETE /api/cart/clear              # Clear entire cart
```

### Order Endpoints

```http
GET /api/orders
# Customer: Returns user's orders only
# Admin: Returns all system orders

GET /api/orders/<order_id>/details
# Returns: [{ item_id, item_name, quantity, unit_price, subtotal }, ...]

POST /api/orders
{ "restaurant_id": 1 }
# Creates order from cart, returns { order_id }

PUT /api/orders/<order_id>/status
{ "status": "CONFIRMED" }

PUT /api/orders/<order_id>/payment
{ "method": "CREDIT_CARD" }
```

### Payment Endpoints

```http
GET /api/payments/<order_id>
# Returns: { payment_id, payment_method, payment_status, payment_time }

POST /api/payments/<order_id>
{ "payment_method": "UPI" }
```

### Delivery Endpoints

```http
GET /api/agents
# Admin only: Returns [{agent_id, agent_name, is_available}, ...]

GET /api/deliveries/<order_id>
# Returns: { delivery_id, agent_id, agent_name, delivery_status, ... }

POST /api/deliveries/<order_id>/assign
# Admin: Assigns available agent and creates DELIVERIES record

PUT /api/deliveries/<order_id>/status
{ "status": "OUT_FOR_DELIVERY" }
```

---

## PL/SQL Components

### Functions

#### `fn_Calculate_Order_Total(p_order_id)`

Calculates the total amount for an order by summing (quantity × unit_price) from ORDER_DETAILS.

- **Returns:** NUMBER (10,2)
- **Used By:** Triggers and procedures to update order totals

#### `fn_Get_Customer_Order_Count(p_customer_id)`

Returns the total number of orders placed by a customer.

- **Returns:** NUMBER
- **Used By:** Dashboard analytics

#### `fn_Get_Restaurant_Avg_Rating(p_restaurant_id)`

Calculates average restaurant rating from customer reviews.

- **Returns:** NUMBER (2,1) [0.0 - 5.0]
- **Used By:** Restaurant display, sorting

#### `fn_Available_Agent_Count()`

Returns the count of available delivery agents (is_available = 'Y').

- **Returns:** NUMBER
- **Used By:** Admin dashboard availability tracking

### Procedures

#### `pr_Register_Customer(p_name, p_email, p_password, p_phone, p_address)`

Registers a new customer account.

- **Error Handling:** Duplicate email raises `DUP_VAL_ON_INDEX` exception
- **Atomicity:** Uses COMMIT to ensure durability

#### `pr_Place_Order(p_customer_id, p_restaurant_id, → p_out_order_id)`

Creates order from cart and moves items to ORDER_DETAILS (complex business logic).

- **Steps:**
  1. Validates cart has items for the specified restaurant
  2. Creates ORDERS header with status=PENDING, total_amount=0
  3. Inserts rows into ORDER_DETAILS from CARTS
  4. Calculates and updates order total
  5. Clears cart items for that restaurant only
- **Error Handling:** Raises exceptions for empty cart or invalid restaurant
- **Concurrency:** Uses row-level locking to prevent race conditions

#### `pr_Add_Menu_Item(p_item_name, p_price, p_category_id, p_restaurant_id)`

Adds a new item to a restaurant's menu.

#### `pr_Delete_Menu_Item(p_item_id)`

Removes a menu item (with cascade cleanup of cart references).

#### `pr_Add_Restaurant(p_name, p_location, p_rating)`

Creates a new restaurant record.

#### `pr_Delete_Restaurant(p_restaurant_id)`

Removes a restaurant and all dependent records.

#### `pr_Assign_Delivery_Agent(p_order_id)`

Assigns the first available agent to an order.

- **Features:**
  - Row-level locking (FOR UPDATE) to prevent duplicate assignments
  - Automatically marks agent as unavailable (is_available = 'N')
  - Updates order status to CONFIRMED
  - Creates DELIVERIES record

#### `pr_Complete_Delivery(p_delivery_id)`

Marks a delivery as complete and releases agent back to available pool.

- **Steps:**
  1. Updates DELIVERIES status = DELIVERED
  2. Sets completion_time = CURRENT_TIMESTAMP
  3. Updates DELIVERY_AGENTS is_available = 'Y'
  4. Updates ORDERS status = DELIVERED

### Triggers

#### `trg_ORDER_DETAILS_INSERT`

**Event:** BEFORE INSERT ON ORDER_DETAILS

- Validates item exists in MENU_ITEMS
- Ensures item belongs to order's restaurant
- Captures unit price from MENU_ITEMS

#### `trg_ORDER_UPDATE_STATUS`

**Event:** AFTER UPDATE ON ORDERS

- Updates order_status to ORDER_RECEIVED when payment is made
- Recalculates total if order details modified
- Prevents invalid status transitions

#### `trg_DELIVERY_STATUS_UPDATE`

**Event:** AFTER UPDATE ON DELIVERIES

- Cascades delivery status changes to associated order
- Releases delivery agent when delivery is completed

#### `trg_PAYMENT_INSERT`

**Event:** AFTER INSERT ON PAYMENTS

- Validates payment method and amount
- Automatically marks order as paid if payment_status = COMPLETED

---

## Architecture & Design

### Design Patterns Used

**1. Model-View-Controller (MVC)**

- **Model:** `DatabaseManager` class and PL/SQL procedures (business logic)
- **View:** `index.html` with Tailwind CSS components (presentation)
- **Controller:** Flask routes in `server.py` (request handling)

**2. Singleton Pattern**

- `DatabaseManager` class ensures single database connection across app lifecycle
- Prevents connection pool exhaustion

**3. Repository Pattern**

- `db_manager.py` encapsulates all database operations
- Clean separation between data layer and business logic

**4. Session Management**

- Flask sessions store user context (role, ID)
- Decorators (@login_required, @admin_required) enforce authorization

### Data Integrity & Constraints

**Referential Integrity**

- All foreign keys enforce relationships
- Cascade delete maintains consistency when parent records removed
- NOT NULL constraints on critical fields

**Business Logic Enforcement**

- PL/SQL procedures enforce complex rules (e.g., single-restaurant cart constraint)
- Triggers prevent invalid state transitions (e.g., payment → order status workflow)
- Check constraints limit allowed values (status enums, rating ranges)

**Concurrency Control**

- Row-level locking (FOR UPDATE) in `pr_Assign_Delivery_Agent` prevents race conditions
- Stored procedures with COMMIT/ROLLBACK for atomicity

### Security Considerations

**Authentication**

- Email and password required for login (compared against database)
- Admin and customer roles segregated with decorators

**Session Security**

- Flask SECRET_KEY should be strong and unique per environment
- Sessions can include HTTP-only, secure flags (framework level)

**SQL Injection Prevention**

- All queries use parameterized queries with named bindings (`:param`)
- Never constructs SQL strings with string concatenation

**Data Validation**

- Backend validates all user inputs before database operations
- Frontend validates cart constraints (single restaurant)

### Performance Optimizations

**Database**

- Indexes on foreign keys and frequently queried columns
- Identity-generated PKs for fast inserts
- Stored procedures reduce round-trip network calls

**Frontend**

- Single-page application (SPA) reduces server hits
- CSS loaded from CDN (Tailwind)
- Icon library from Iconify CDN
- Vanilla JavaScript (no heavy frameworks)

**Caching**

- Session data cached in Flask memory (not fetched on every request)
- Menu items fetched once and displayed client-side

---

## Development & Testing

### Running in Development Mode

```bash
# Ensure .env is created and Docker databases is running
python3 frontend/server.py

# Server runs on http://127.0.0.1:[PORT]
# Flask auto-reloads on file changes (in development mode)
```

### Testing Login Workflows

**Customer Workflow:**

1. Click "Customer" tab on login screen
2. Enter: email=`rahul@example.com`, password=`pass123`
3. Click restaurants to browse menus
4. Add items to cart
5. Place order and select payment method
6. View order history and receipt

**Admin Workflow:**

1. Click "Admin" tab on login screen
2. Enter: username=`admin`, password=`admin123`
3. Add restaurant or menu items
4. View all orders and manage statuses
5. Assign delivery agents and track progress

### Database Troubleshooting

**Connection Issues**

```bash
# Check if Docker container is running
docker ps | grep oracle-db

# Restart if needed
docker restart oracle-db

# View logs for errors
docker logs oracle-db
```

**SQL Errors**

```bash
# Connect via sqlplus to run manual queries
docker exec -it oracle-db bash -c "sqlplus system/Shreyas123@XE"

# Inside sqlplus:
SELECT * FROM CUSTOMERS;
SELECT * FROM ORDERS;
-- etc
```

---

## Deployment Considerations

For production deployment:

1. **Update Environment Variables**
   - Change `FLASK_SECRET_KEY` to a cryptographically secure random string
   - Use configured Oracle instance (not Docker)
   - Set `PORT` to 80 or via reverse proxy

2. **Security**
   - Enable HTTPS/SSL for all routes
   - Implement proper authentication (JWT tokens, OAuth)
   - Hash passwords with bcrypt or similar (currently stored plaintext)
   - Enable CORS restrictions
   - Rate limit API endpoints

3. **Database**
   - Migrate from XE (single-tenant) to production Oracle instance
   - Enable backups and point-in-time recovery
   - Set up replication for high availability
   - Enable audit logging

4. **Application**
   - Run Flask with production WSGI server (Gunicorn, uWSGI)
   - Use load balancer (nginx, Apache)
   - Enable logging and monitoring
   - Set up error tracking (Sentry, etc.)

5. **Testing**
   - Implement unit tests for PL/SQL procedures
   - Add integration tests for API endpoints
   - Performance testing under load

---

## Contributing

To contribute to this project:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit changes: `git commit -m "Add your feature"`
4. Push to branch: `git push origin feature/your-feature`
5. Open a Pull Request

Please ensure:

- Code follows PEP 8 (Python)
- SQL follows naming conventions (UPPERCASE for keywords)
- All changes are tested manually
- README is updated if features are added

---

## License & Attribution

This project is created as part of a Database Systems mini-project. It demonstrates practical application of:

- Advanced SQL and PL/SQL
- Database normalization (3NF)
- Web application development
- Full-stack system design

---

## Support & Contact

For issues, questions, or suggestions:

- Open an issue on GitHub
- Contact the project maintainer

---

## Changelog

### v1.0.0 (Initial Release)

- ✅ Customer authentication and registration
- ✅ Restaurant and menu management
- ✅ Shopping cart with single-restaurant constraint
- ✅ Order placement and history
- ✅ Admin dashboard with analytics
- ✅ Delivery agent assignment and tracking
- ✅ Payment method selection
- ✅ Order itemized receipts
- ✅ 12 database tables with 3NF normalization
- ✅ 4 PL/SQL functions and 8 procedures
- ✅ Comprehensive trigger suite

---

## 🗄️ Database Design (Oracle SQL / PL/SQL)

### Tables (3NF Normalized)

| Table           | Description                       |
| --------------- | --------------------------------- |
| CUSTOMERS       | Registered users                  |
| ADMINS          | Admin accounts                    |
| RESTAURANTS     | Restaurant listings               |
| MENU_CATEGORIES | Food categories                   |
| MENU_ITEMS      | Dishes with price & category      |
| CARTS           | Active cart items per customer    |
| ORDERS          | Order headers with status & total |
| ORDER_DETAILS   | Line items per order              |
| PAYMENTS        | Payment records                   |
| DELIVERY_AGENTS | Registered delivery agents        |
| DELIVERIES      | Delivery assignments              |
| REVIEWS         | Customer ratings                  |

### PL/SQL Objects

| Type      | Name                           | Purpose                             |
| --------- | ------------------------------ | ----------------------------------- |
| Procedure | `pr_Register_Customer`         | Create new customer account         |
| Procedure | `pr_Place_Order`               | Convert cart → order, compute total |
| Procedure | `pr_Process_Payment`           | Record payment, confirm order       |
| Procedure | `pr_Update_Order_Status`       | Change order lifecycle status       |
| Procedure | `pr_Add_Restaurant`            | Admin: add restaurant               |
| Procedure | `pr_Add_Menu_Item`             | Admin: add menu item                |
| Procedure | `pr_Delete_Menu_Item`          | Admin: remove menu item             |
| Procedure | `pr_Assign_Delivery_Agent`     | Auto-assign available agent         |
| Procedure | `pr_Update_Delivery_Status`    | Mark delivery progress              |
| Function  | `fn_Calculate_Order_Total`     | Sum order line items                |
| Function  | `fn_Get_Restaurant_Avg_Rating` | Average restaurant rating           |
| Function  | `fn_Get_Customer_Total_Spend`  | Lifetime spend per customer         |
| Function  | `fn_Is_Agent_Available`        | Check agent availability            |
| Trigger   | `trg_Payment_Confirms_Order`   | Auto-confirm on payment insert      |
| Trigger   | `trg_Update_Order_Total`       | Recalculate total on detail change  |
| Trigger   | `trg_Set_Delivery_Complete`    | Auto-update order on delivery done  |

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

Open **http://127.0.0.1:5001**
If needed, set a different `PORT` in `.env`.

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
