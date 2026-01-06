from flask import Flask, request, jsonify

app = Flask(__name__)

users = []
properties = []
transactions = []
ml_metadata = []

# CORS support for Flutter web app
@app.after_request
def add_cors_headers(response):
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
    return response

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
    # no real auth, just accept
    return jsonify({"message": "Login successful", "token": "dummy_token_123"}), 200


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
    data["id"] = len(properties) + 1
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



if __name__ == "__main__":
    app.run(port=8000)
