from flask import Flask, jsonify
from pymongo import MongoClient

# Load DB credentials from db_config.txt
def load_config(path="db_config.txt"):
    config = {}
    with open(path, "r") as f:
        for line in f:
            if '=' in line:
                key, value = line.strip().split('=', 1)
                config[key.strip()] = value.strip()
    return config

app = Flask(__name__)
config = load_config()

# Setup MongoDB client
mongo_uri = f"mongodb://{config['username']}:{config['password']}@{config['host']}:{config['port']}/?authSource={config['auth_db']}"
client = MongoClient(mongo_uri)
db = client[config["db_name"]]
collection = db[config["collection"]]

@app.route("/")
def index():
    employees = list(collection.find({}, {'_id': 0}))  # Exclude MongoDB _id field
    return jsonify(employees)

if __name__ == "__main__":
    from flask import Flask, jsonify
from pymongo import MongoClient

# Load DB credentials from db_config.txt
def load_config(path="db_config.txt"):
    config = {}
    with open(path, "r") as f:
        for line in f:
            if '=' in line:
                key, value = line.strip().split('=', 1)
                config[key.strip()] = value.strip()
    return config

app = Flask(__name__)
config = load_config()

# Setup MongoDB client
mongo_uri = f"mongodb://{config['username']}:{config['password']}@{config['host']}:{config['port']}/?authSource={config['auth_db']}"
client = MongoClient(mongo_uri)
db = client[config["db_name"]]
collection = db[config["collection"]]

@app.route("/")
def index():
    employees = list(collection.find({}, {'_id': 0}))  # Exclude MongoDB _id field
    return jsonify(employees)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
