"""
Database Manager — Oracle DB Connection Wrapper
Online Food Management System
Credentials loaded from .env file via python-dotenv
"""
import oracledb
import os
from pathlib import Path

# ─── Load .env ────────────────────────────────────────────────────
try:
    from dotenv import load_dotenv
    load_dotenv(Path(__file__).parent.parent / ".env")
except ImportError:
    pass  # dotenv optional — can also set env vars directly

DB_CONFIG = {
    "user":     os.environ.get("DB_USER",     "system"),
    "password": os.environ.get("DB_PASSWORD", "Shreyas123"),
    "dsn":      os.environ.get("DB_DSN",      "localhost:1521/XE"),
}


class DatabaseManager:
    """Singleton wrapper around an oracledb connection."""
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance.connection = None
        return cls._instance

    def connect(self):
        try:
            self.connection = oracledb.connect(
                user=DB_CONFIG["user"],
                password=DB_CONFIG["password"],
                dsn=DB_CONFIG["dsn"]
            )
            print(f"[DB] Connected to Oracle ({DB_CONFIG['dsn']}) successfully!")
            return True
        except oracledb.Error as e:
            print(f"[DB] Connection Error: {e}")
            return False

    def _ensure_connection(self):
        if not self.connection:
            if not self.connect():
                raise ConnectionError("Cannot connect to Oracle Database. Check DB_USER/DB_PASSWORD/DB_DSN in .env")

    # ── Generic Queries ──────────────────────────────────────────
    def execute_query(self, query, params=None, fetch=True):
        """Run a SQL query. Returns list of dicts if fetch=True."""
        self._ensure_connection()
        cursor = self.connection.cursor()
        try:
            cursor.execute(query, params or {})
            if fetch:
                columns = [col[0] for col in cursor.description]
                return [dict(zip(columns, row)) for row in cursor.fetchall()]
            self.connection.commit()
            return True
        except oracledb.Error as e:
            print(f"[DB] Query Error: {e}")
            self.connection.rollback()
            return None
        finally:
            cursor.close()

    # ── Procedure Calls ──────────────────────────────────────────
    def call_procedure(self, proc_name, params):
        """Call a stored procedure. Returns True or raises."""
        self._ensure_connection()
        cursor = self.connection.cursor()
        try:
            cursor.callproc(proc_name, params)
            self.connection.commit()
            return True
        except oracledb.Error as e:
            self.connection.rollback()
            raise Exception(str(e))
        finally:
            cursor.close()

    def call_procedure_with_out(self, proc_name, in_params, out_type=float):
        """Call a procedure that has one trailing OUT NUMBER parameter."""
        self._ensure_connection()
        cursor = self.connection.cursor()
        try:
            out_var = cursor.var(out_type)
            cursor.callproc(proc_name, in_params + [out_var])
            self.connection.commit()
            return out_var.getvalue()
        except oracledb.Error as e:
            self.connection.rollback()
            raise Exception(str(e))
        finally:
            cursor.close()

    # ── Function Calls ───────────────────────────────────────────
    def call_function(self, func_name, return_type, params):
        """Call a stored function and return its result."""
        self._ensure_connection()
        cursor = self.connection.cursor()
        try:
            return cursor.callfunc(func_name, return_type, params)
        except oracledb.Error as e:
            print(f"[DB] Function Error: {e}")
            return None
        finally:
            cursor.close()


# Global singleton
db = DatabaseManager()
