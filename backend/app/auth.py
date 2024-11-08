import jwt
import datetime
from flask import Blueprint, request, jsonify
from werkzeug.security import check_password_hash, generate_password_hash
from .db import get_db_connection

auth_bp = Blueprint('auth', __name__)
SECRET_KEY = 'votre_clé_secrète'  # Remplacez par une clé secrète robuste

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM users WHERE username = %s", (username,))
    user = cursor.fetchone()
    cursor.close()
    conn.close()

    if user and check_password_hash(user['password_hash'], password):
        # Génération du token JWT avec le rôle de l'utilisateur
        token = jwt.encode({
            'user_id': user['id'],  # ID de l'utilisateur
            'role': user['role'],   # Rôle de l'utilisateur
            'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24)  # Expiration du token dans 24h
        }, SECRET_KEY, algorithm='HS256')

        return jsonify({"token": token}), 200
    else:
        return jsonify({"message": "Invalid credentials"}), 401

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    admin_code = data.get('admin_code')  # Clé secrète pour devenir admin

    # Clé secrète pour devenir admin
    ADMIN_SECRET_CODE = "votre_code_secret_pour_admin"

    # Déterminer le rôle : 'admin' si le code est correct, sinon 'user'
    role = 'admin' if admin_code == ADMIN_SECRET_CODE else 'user'

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM users WHERE username = %s", (username,))
    user = cursor.fetchone()

    if user:
        cursor.close()
        conn.close()
        return jsonify({"message": "Utilisateur existe déjà"}), 400

    hashed_password = generate_password_hash(password)
    cursor.execute(
        "INSERT INTO users (username, password_hash, role) VALUES (%s, %s, %s)", 
        (username, hashed_password, role)
    )
    conn.commit()
    cursor.close()
    conn.close()

    return jsonify({"message": "Utilisateur enregistré avec succès"}), 201
