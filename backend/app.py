from flask import Flask, request, jsonify
import json
import os

app = Flask(__name__)

users = []
properties = []
transactions = []
ml_metadata = []

# Load properties from JSON file on startup
def load_properties():
    global properties
    try:
        # Get the directory where the script is located
        current_dir = os.path.dirname(os.path.abspath(__file__))
        json_path = os.path.join(current_dir, 'properties.json')
        
        print(f"Looking for properties.json at: {json_path}")
        
        if os.path.exists(json_path):
            with open(json_path, 'r') as f:
                properties = json.load(f)
            print(f"✓ Loaded {len(properties)} properties from JSON")
        else:
            print(f"✗ File not found at {json_path}")
            properties = []
    except Exception as e:
        print(f"Error loading properties: {e}")
        import traceback
        traceback.print_exc()
        properties = []

# Load properties when app starts
load_properties()

# Hardcoded admin credentials
ADMIN_USERNAME = "admin"
ADMIN_PASSWORD = "admin123"

# Track banned users
banned_users = []

# CORS support for Flutter web app
@app.after_request
def add_cors_headers(response):
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
    return response

# Handle OPTIONS requests for CORS preflight
@app.before_request
def handle_preflight():
    if request.method == "OPTIONS":
        response = jsonify({"status": "ok"})
        response.headers['Access-Control-Allow-Origin'] = '*'
        response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
        return response, 200

# helper function
def find_property(pid):
    for p in properties:
        if p["id"] == pid:
            return p
    return None



@app.route("/api/register", methods=["POST"])
def register():
    data = request.json
    users.append(data)
    return jsonify({"message": "User registered successfully", "user": data}), 201


@app.route("/api/login", methods=["POST"])
def login():
    data = request.json
    email = data.get("email")
    password = data.get("password")
    
    # Check if user exists with matching email and password
    for user in users:
        if user.get("email") == email and user.get("password") == password:
            return jsonify({
                "message": "Login successful",
                "token": "user_token_123",
                "username": user.get("username")
            }), 200
    
    # User not found or password incorrect
    return jsonify({"error": "Invalid email or password"}), 401


@app.route("/api/admin/login", methods=["POST"])
def admin_login():
    data = request.json
    username = data.get("username")
    password = data.get("password")
    
    if username == ADMIN_USERNAME and password == ADMIN_PASSWORD:
        return jsonify({
            "message": "Admin login successful",
            "token": "admin_token_secure",
            "role": "admin"
        }), 200
    else:
        return jsonify({"error": "Invalid admin credentials"}), 401


@app.route("/api/logout", methods=["POST"])
def logout():
    return jsonify({"message": "Logout successful"}), 200



@app.route("/api/properties", methods=["GET"])
def list_properties():
    # support optional filters
    filtered = properties
    location = request.args.get("location")
    if location:
        filtered = [p for p in filtered if p.get("location") == location]

    return jsonify(filtered), 200


@app.route("/api/properties", methods=["POST"])
def add_property():
    data = request.json
    
    # Validate required fields
    required_fields = ['title', 'location', 'total_area', 'total_units', 'bedrooms', 'bathrooms', 'price']
    for field in required_fields:
        if field not in data:
            return jsonify({"error": f"Missing required field: {field}"}), 400
    
    # Generate new ID
    data["id"] = max([p.get("id", 0) for p in properties] + [0]) + 1
    properties.append(data)
    return jsonify({"message": "Property added", "property": data}), 201


@app.route("/api/properties/<int:pid>", methods=["PUT"])
def update_property(pid):
    prop = find_property(pid)
    if not prop:
        return jsonify({"error": "Property not found"}), 404

    update_data = request.json
    prop.update(update_data)
    return jsonify({"message": "Property updated", "property": prop}), 200


@app.route("/api/properties/<int:pid>", methods=["DELETE"])
def delete_property(pid):
    prop = find_property(pid)
    if not prop:
        return jsonify({"error": "Property not found"}), 404

    properties.remove(prop)
    return jsonify({"message": "Property deleted"}), 200



@app.route("/api/recommend", methods=["POST"])
def recommend_properties():
    data = request.json
    recommendations = properties[:3]
    return jsonify({
        "input": data,
        "recommendations": recommendations
    }), 200


@app.route("/api/predict_price", methods=["POST"])
def predict_price():
    data = request.json
    # dummy ML prediction
    predicted_price = 50000 + (len(data.get("features", [])) * 1000)

    return jsonify({
        "input": data,
        "predicted_price": predicted_price
    }), 200



@app.route("/api/health", methods=["GET"])
def health():
    return jsonify({
        "status": "OK",
        "properties_count": len(properties),
        "users_count": len(users)
    }), 200


# Admin Dashboard Statistics
@app.route("/api/admin/dashboard", methods=["GET"])
def admin_dashboard():
    total_users = len(users)
    total_properties = len(properties)
    total_value = sum(float(p.get("price", 0)) for p in properties)
    banned_count = len(banned_users)
    
    return jsonify({
        "total_users": total_users,
        "total_properties": total_properties,
        "total_property_value": total_value,
        "banned_users": banned_count,
        "properties": properties
    }), 200


# Admin User Management
@app.route("/api/admin/users", methods=["GET"])
def get_all_users():
    users_with_status = []
    for user in users:
        user_copy = user.copy()
        user_copy["banned"] = user.get("email") in banned_users
        users_with_status.append(user_copy)
    return jsonify(users_with_status), 200


@app.route("/api/admin/users/ban", methods=["POST"])
def ban_user():
    data = request.json
    email = data.get("email")
    
    if email and email not in banned_users:
        banned_users.append(email)
        return jsonify({"message": f"User {email} has been banned"}), 200
    return jsonify({"error": "Invalid request or user already banned"}), 400


@app.route("/api/admin/users/unban", methods=["POST"])
def unban_user():
    data = request.json
    email = data.get("email")
    
    if email and email in banned_users:
        banned_users.remove(email)
        return jsonify({"message": f"User {email} has been unbanned"}), 200
    return jsonify({"error": "Invalid request or user not banned"}), 400



if __name__ == "__main__":
    app.run(port=8000)
