from flask import Flask
from flask_cors import CORS

def create_app():
    app = Flask(__name__)
    CORS(app)  # Activer CORS

    # Charger la configuration depuis un fichier ou un objet de configuration
    app.config.from_object('config.Config')
    
    # Enregistrer le blueprint pour l'authentification
    from app.auth import auth_bp
# Enregistrement du Blueprint
    app.register_blueprint(auth_bp, url_prefix='/api/auth')     

    # Enregistrer le blueprint pour les autres routes
    from app.routes import bp as routes_bp
    app.register_blueprint(routes_bp)

    return app
