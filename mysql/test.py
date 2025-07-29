

from flask import Flask
import mysql.connector

app = Flask(__name__)

# Function to load DB connection config
def load_db_config(filename='db_config.txt'):
    config = {}
    with open(filename, 'r') as f:
        for line in f:
            if '=' in line:
                key, value = line.strip().split('=', 1)
                config[key.strip()] = value.strip()
    return config

# Home route to show employee table
@app.route('/')
def show_employees():
    config = load_db_config()

    try:
        conn = mysql.connector.connect(
            host=config['host'],
            port=int(config.get('port', 3306)),
            user=config['user'],
            password=config['password'],
            database=config['database']
        )

        cursor = conn.cursor()
        cursor.execute("SELECT * FROM employees;")
        rows = cursor.fetchall()

        html = "<h2>Employee List</h2><table border='1'><tr>"
        for col in cursor.description:
            html += f"<th>{col[0]}</th>"
        html += "</tr>"

        for row in rows:
            html += "<tr>" + "".join(f"<td>{cell}</td>" for cell in row) + "</tr>"

        html += "</table>"
        return html

    except mysql.connector.Error as err:
        return f"<h3>Error: {err}</h3>"

    finally:
        if 'conn' in locals() and conn.is_connected():
            cursor.close()
            conn.close()

# Run the Flask app
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
