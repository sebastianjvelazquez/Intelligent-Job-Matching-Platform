import os
import mysql.connector
from mysql.connector import Error
from flask import Flask


def create_app():
    app = Flask(__name__, template_folder="../templates", static_folder="../static")

    from .routes import main
    app.register_blueprint(main)

    return app


def get_db_connection():
    """Return a new MySQL connection using environment variables."""
    try:
        connection = mysql.connector.connect(
            host=os.environ["DB_HOST"],
            user=os.environ["DB_USER"],
            password=os.environ["DB_PASS"],
            database=os.environ["DB_NAME"],
        )
        return connection
    except Error as e:
        raise RuntimeError(f"Database connection failed: {e}") from e
